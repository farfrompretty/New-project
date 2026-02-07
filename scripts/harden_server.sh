#!/bin/bash
#
# VPS Server Härtung für C2-Infrastruktur
#
# Verwendung: sudo bash harden_server.sh
#
# Beschreibung: Härtet einen frischen VPS für C2-Operationen
#

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              VPS Server Härtung für C2                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Root-Check
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!] Bitte als root ausführen (sudo)${NC}"
    exit 1
fi

# Backup der originalen Konfigurationen
echo -e "${GREEN}[+] Erstelle Backup der Originalkonfigurationen...${NC}"
mkdir -p /root/hardening_backup
cp /etc/ssh/sshd_config /root/hardening_backup/sshd_config.bak 2>/dev/null || true
cp /etc/sysctl.conf /root/hardening_backup/sysctl.conf.bak 2>/dev/null || true

# System-Update
echo -e "${GREEN}[+] Aktualisiere System...${NC}"
apt update -qq
apt upgrade -y -qq

# Wichtige Tools installieren
echo -e "${GREEN}[+] Installiere Security-Tools...${NC}"
apt install -y -qq ufw fail2ban unattended-upgrades apt-listchanges \
    rkhunter chkrootkit logwatch net-tools curl wget

# === SSH HÄRTUNG ===
echo -e "${GREEN}[+] Konfiguriere SSH-Härtung...${NC}"

# SSH Port ändern
read -p "SSH Port ändern? Aktuell: 22, Neuer Port (leer für 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

# SSH-Key vorhanden?
if [ -f "/root/.ssh/authorized_keys" ]; then
    echo -e "${GREEN}[✓] SSH-Keys gefunden${NC}"
    DISABLE_PASSWORD="yes"
else
    echo -e "${YELLOW}[!] Keine SSH-Keys gefunden!${NC}"
    echo -e "${YELLOW}    Passwort-Authentifizierung wird NICHT deaktiviert.${NC}"
    echo -e "${YELLOW}    Fügen Sie zuerst SSH-Keys hinzu:${NC}"
    echo -e "${YELLOW}    ssh-copy-id root@SERVER_IP${NC}"
    DISABLE_PASSWORD="no"
fi

# SSH-Konfiguration anpassen
cat > /etc/ssh/sshd_config << EOF
# Havoc C2 Hardened SSH Configuration
Port ${SSH_PORT}
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

# Authentication
LoginGraceTime 60
PermitRootLogin $([ "$DISABLE_PASSWORD" = "yes" ] && echo "prohibit-password" || echo "yes")
StrictModes yes
MaxAuthTries 3
MaxSessions 5

PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Disable insecure authentication
PasswordAuthentication $([ "$DISABLE_PASSWORD" = "yes" ] && echo "no" || echo "yes")
PermitEmptyPasswords no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no

# Disable X11 and Forwarding (not needed for C2)
X11Forwarding no
AllowAgentForwarding yes
AllowTcpForwarding yes
PermitTunnel no

# Misc
UsePAM yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

# Disconnect idle sessions
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

echo -e "${GREEN}[✓] SSH konfiguriert${NC}"

# SSH neu laden (später, nach Firewall-Setup)

# === FIREWALL (UFW) ===
echo -e "${GREEN}[+] Konfiguriere Firewall (UFW)...${NC}"

# Reset UFW
ufw --force reset

# Default Policies
ufw default deny incoming
ufw default allow outgoing

# SSH erlauben
ufw allow ${SSH_PORT}/tcp comment "SSH"

# Ports für C2 (später zu öffnen)
echo -e "${YELLOW}[!] Wichtig: Öffnen Sie später C2-spezifische Ports mit:${NC}"
echo -e "${YELLOW}    sudo ufw allow PORT/tcp comment 'C2 Service'${NC}"

# Rate-Limiting für SSH
ufw limit ${SSH_PORT}/tcp

# UFW aktivieren
ufw --force enable

echo -e "${GREEN}[✓] Firewall konfiguriert${NC}"

# === FAIL2BAN ===
echo -e "${GREEN}[+] Konfiguriere Fail2Ban...${NC}"

cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
destemail = root@localhost
sendername = Fail2Ban
action = %(action_mwl)s

[sshd]
enabled = true
port = ${SSH_PORT}
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

systemctl enable fail2ban
systemctl restart fail2ban

echo -e "${GREEN}[✓] Fail2Ban konfiguriert${NC}"

# === AUTOMATISCHE UPDATES ===
echo -e "${GREEN}[+] Konfiguriere automatische Security-Updates...${NC}"

cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

echo -e "${GREEN}[✓] Automatische Updates konfiguriert${NC}"

# === KERNEL PARAMETER HARDENING ===
echo -e "${GREEN}[+] Härte Kernel-Parameter...${NC}"

cat >> /etc/sysctl.conf << 'EOF'

# === C2 Server Hardening ===

# IP Forwarding (für Redirectors)
net.ipv4.ip_forward = 0

# Disable IPv6 (wenn nicht benötigt)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# Syn Flood Protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# IP Spoofing Protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP Ping Requests (Stealth)
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore ICMP Redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Log Martians (suspicious packets)
net.ipv4.conf.all.log_martians = 1

# Kernel Pointer Hiding
kernel.kptr_restrict = 2

# Restrict dmesg
kernel.dmesg_restrict = 1

# Restrict kernel logs
kernel.printk = 3 3 3 3
EOF

sysctl -p >/dev/null 2>&1

echo -e "${GREEN}[✓] Kernel-Parameter gehärtet${NC}"

# === UNNÖTIGE SERVICES DEAKTIVIEREN ===
echo -e "${GREEN}[+] Deaktiviere unnötige Services...${NC}"

SERVICES_TO_DISABLE=(
    "bluetooth"
    "avahi-daemon"
    "cups"
    "isc-dhcp-server"
    "isc-dhcp-server6"
    "nfs-common"
    "rpcbind"
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl is-enabled "$service" >/dev/null 2>&1; then
        systemctl disable "$service" >/dev/null 2>&1 || true
        systemctl stop "$service" >/dev/null 2>&1 || true
        echo -e "  ${YELLOW}[-] Deaktiviert: $service${NC}"
    fi
done

echo -e "${GREEN}[✓] Unnötige Services deaktiviert${NC}"

# === ROOTKIT CHECKER ===
echo -e "${GREEN}[+] Konfiguriere Rootkit-Checker...${NC}"

# rkhunter updaten
rkhunter --update >/dev/null 2>&1 || true
rkhunter --propupd >/dev/null 2>&1 || true

# Cronjob für täglichen Scan
cat > /etc/cron.daily/rkhunter << 'EOF'
#!/bin/bash
/usr/bin/rkhunter --cronjob --update --quiet
EOF
chmod +x /etc/cron.daily/rkhunter

echo -e "${GREEN}[✓] Rootkit-Checker konfiguriert${NC}"

# === SHARED MEMORY HÄRTEN ===
echo -e "${GREEN}[+] Härte Shared Memory...${NC}"

if ! grep -q "tmpfs /run/shm" /etc/fstab; then
    echo "tmpfs /run/shm tmpfs defaults,noexec,nodev,nosuid 0 0" >> /etc/fstab
fi

echo -e "${GREEN}[✓] Shared Memory gehärtet${NC}"

# === LOGWATCH (optional) ===
echo -e "${GREEN}[+] Konfiguriere Logwatch...${NC}"

mkdir -p /var/cache/logwatch
cat > /etc/cron.daily/00logwatch << 'EOF'
#!/bin/bash
/usr/sbin/logwatch --output mail --mailto root --detail high
EOF
chmod +x /etc/cron.daily/00logwatch

echo -e "${GREEN}[✓] Logwatch konfiguriert${NC}"

# === TIMEZONE ===
echo -e "${GREEN}[+] Setze Timezone...${NC}"
timedatectl set-timezone UTC
echo -e "${GREEN}[✓] Timezone: UTC${NC}"

# === SSH RESTART ===
echo -e "${YELLOW}[!] SSH-Konfiguration wird neu geladen...${NC}"
echo -e "${YELLOW}    Ihre aktuelle SSH-Sitzung sollte bestehen bleiben.${NC}"
echo -e "${YELLOW}    Testen Sie NEUE SSH-Verbindung in separatem Terminal!${NC}"

if [ "$SSH_PORT" != "22" ]; then
    echo -e "${RED}[!] SSH Port geändert zu: ${SSH_PORT}${NC}"
    echo -e "${RED}    Neue Verbindung: ssh -p ${SSH_PORT} root@SERVER_IP${NC}"
fi

read -p "SSH-Service neu laden? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    systemctl reload sshd
    echo -e "${GREEN}[✓] SSH neu geladen${NC}"
fi

# === ZUSAMMENFASSUNG ===
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║               Server-Härtung abgeschlossen!                  ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}[✓] Durchgeführte Härtungen:${NC}"
echo "  • SSH konfiguriert (Port: ${SSH_PORT})"
echo "  • Firewall (UFW) aktiviert"
echo "  • Fail2Ban aktiviert"
echo "  • Automatische Security-Updates"
echo "  • Kernel-Parameter gehärtet"
echo "  • Unnötige Services deaktiviert"
echo "  • Rootkit-Checker installiert"
echo ""
echo -e "${YELLOW}Wichtige Hinweise:${NC}"
echo ""
if [ "$SSH_PORT" != "22" ]; then
    echo -e "${RED}[!] SSH-PORT GEÄNDERT!${NC}"
    echo "    Neue Verbindung: ssh -p ${SSH_PORT} root@$(hostname -I | awk '{print $1}')"
    echo ""
fi

if [ "$DISABLE_PASSWORD" = "yes" ]; then
    echo -e "${RED}[!] PASSWORT-LOGIN DEAKTIVIERT!${NC}"
    echo "    Nur SSH-Key-Authentifizierung möglich."
    echo ""
fi

echo -e "${YELLOW}Testen Sie UNBEDINGT eine neue SSH-Verbindung!${NC}"
echo -e "${YELLOW}Falls Sie ausgesperrt werden:${NC}"
echo "  1. Nutzen Sie VPS-Provider-Console/VNC"
echo "  2. Backup: /root/hardening_backup/"
echo ""
echo -e "${YELLOW}Weitere Schritte:${NC}"
echo "  • C2-Software installieren"
echo "  • Spezifische Ports öffnen: ufw allow PORT/tcp"
echo "  • Regelmäßig Updates prüfen: apt update && apt upgrade"
echo ""
echo -e "${GREEN}Status-Kommandos:${NC}"
echo "  • Firewall:  sudo ufw status"
echo "  • Fail2Ban:  sudo fail2ban-client status"
echo "  • SSH:       sudo systemctl status sshd"
echo "  • Logs:      sudo tail -f /var/log/auth.log"
echo ""
