#!/bin/bash
#
# C2 Infrastruktur Cleanup - Post-Engagement
#
# Verwendung: sudo bash cleanup_infrastructure.sh
#
# ⚠️  WARNUNG: Dieser Script löscht ALLE C2-bezogenen Daten!
#             Nur nach Abschluss des Engagements ausführen!
#

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║               ⚠️  C2 INFRASTRUKTUR CLEANUP  ⚠️                ║"
echo "║                                                               ║"
echo "║  WARNUNG: Dieser Prozess ist IRREVERSIBEL!                   ║"
echo "║  Alle C2-Daten, Logs und Konfigurationen werden gelöscht!    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Root-Check
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!] Bitte als root ausführen (sudo)${NC}"
    exit 1
fi

# Bestätigung
echo -e "${YELLOW}"
echo "Diese Aktion wird:"
echo "  • Alle C2-Services stoppen"
echo "  • Havoc Teamserver deinstallieren"
echo "  • Apache/Nginx Redirector-Konfigurationen löschen"
echo "  • Alle Logs löschen und überschreiben"
echo "  • SSL-Zertifikate löschen"
echo "  • Bash-History löschen"
echo "  • Optional: Gesamte Disk überschreiben"
echo -e "${NC}"
echo ""

read -p "Sind Sie ABSOLUT SICHER? Tippen Sie 'DELETE' um fortzufahren: " CONFIRM

if [ "$CONFIRM" != "DELETE" ]; then
    echo -e "${GREEN}[+] Abgebrochen.${NC}"
    exit 0
fi

echo ""
read -p "Letzte Chance. Fortfahren? (yes/no): " FINAL_CONFIRM

if [ "$FINAL_CONFIRM" != "yes" ]; then
    echo -e "${GREEN}[+] Abgebrochen.${NC}"
    exit 0
fi

echo ""
echo -e "${RED}[!] Cleanup wird gestartet...${NC}"
echo ""

# === SERVICES STOPPEN ===
echo -e "${YELLOW}[1/10] Stoppe C2-Services...${NC}"

if systemctl is-active havoc-teamserver >/dev/null 2>&1; then
    systemctl stop havoc-teamserver
    systemctl disable havoc-teamserver
    echo "  [✓] Havoc Teamserver gestoppt"
fi

if systemctl is-active apache2 >/dev/null 2>&1; then
    systemctl stop apache2
    echo "  [✓] Apache gestoppt"
fi

if systemctl is-active nginx >/dev/null 2>&1; then
    systemctl stop nginx
    echo "  [✓] Nginx gestoppt"
fi

# === HAVOC ENTFERNEN ===
echo -e "${YELLOW}[2/10] Entferne Havoc Framework...${NC}"

if [ -d "/opt/Havoc" ]; then
    # Überschreibe sensible Dateien
    find /opt/Havoc -type f -name "*.yaotl" -exec shred -vfz -n 3 {} \; 2>/dev/null || true
    find /opt/Havoc/logs -type f -exec shred -vfz -n 3 {} \; 2>/dev/null || true
    
    # Lösche Verzeichnis
    rm -rf /opt/Havoc
    echo "  [✓] Havoc Framework gelöscht"
fi

# Systemd Service
if [ -f "/etc/systemd/system/havoc-teamserver.service" ]; then
    rm -f /etc/systemd/system/havoc-teamserver.service
    systemctl daemon-reload
    echo "  [✓] Systemd Service entfernt"
fi

# === REDIRECTOR KONFIGURATIONEN ===
echo -e "${YELLOW}[3/10] Entferne Redirector-Konfigurationen...${NC}"

# Apache
if [ -f "/etc/apache2/sites-available/redirector.conf" ]; then
    rm -f /etc/apache2/sites-available/redirector.conf
    rm -f /etc/apache2/sites-available/redirector-le-ssl.conf
    rm -f /etc/apache2/sites-enabled/redirector*
    echo "  [✓] Apache Redirector-Config gelöscht"
fi

# Nginx
if [ -f "/etc/nginx/sites-available/redirector" ]; then
    rm -f /etc/nginx/sites-available/redirector
    rm -f /etc/nginx/sites-enabled/redirector
    echo "  [✓] Nginx Redirector-Config gelöscht"
fi

# === LOGS LÖSCHEN ===
echo -e "${YELLOW}[4/10] Lösche und überschreibe Logs...${NC}"

# Havoc Logs
if [ -d "/opt/Havoc/logs" ]; then
    find /opt/Havoc/logs -type f -exec shred -vfz -n 3 {} \;
fi

# Apache Logs
if [ -d "/var/log/apache2" ]; then
    find /var/log/apache2 -type f -name "redirector*" -exec shred -vfz -n 3 {} \; 2>/dev/null || true
    echo "  [✓] Apache Logs überschrieben"
fi

# Nginx Logs
if [ -d "/var/log/nginx" ]; then
    find /var/log/nginx -type f -name "redirector*" -exec shred -vfz -n 3 {} \; 2>/dev/null || true
    echo "  [✓] Nginx Logs überschrieben"
fi

# System Logs (vorsichtig!)
if [ -f "/var/log/auth.log" ]; then
    echo "" > /var/log/auth.log
    echo "  [✓] Auth Log geleert"
fi

if [ -f "/var/log/syslog" ]; then
    echo "" > /var/log/syslog
    echo "  [✓] Syslog geleert"
fi

# Journalctl
journalctl --rotate
journalctl --vacuum-time=1s
echo "  [✓] Journalctl bereinigt"

# === SSL-ZERTIFIKATE ===
echo -e "${YELLOW}[5/10] Entferne SSL-Zertifikate...${NC}"

if [ -d "/etc/letsencrypt" ]; then
    rm -rf /etc/letsencrypt
    echo "  [✓] Let's Encrypt Zertifikate gelöscht"
fi

if [ -d "/opt/Havoc/ssl" ]; then
    find /opt/Havoc/ssl -type f -exec shred -vfz -n 3 {} \;
    rm -rf /opt/Havoc/ssl
    echo "  [✓] Havoc SSL-Zertifikate gelöscht"
fi

# === BASH HISTORY ===
echo -e "${YELLOW}[6/10] Lösche Bash History...${NC}"

# Root
if [ -f "/root/.bash_history" ]; then
    shred -vfz -n 3 /root/.bash_history 2>/dev/null || true
    rm -f /root/.bash_history
    history -c
    echo "  [✓] Root Bash History gelöscht"
fi

# Alle User
for home in /home/*; do
    if [ -f "$home/.bash_history" ]; then
        shred -vfz -n 3 "$home/.bash_history" 2>/dev/null || true
        rm -f "$home/.bash_history"
        echo "  [✓] $(basename $home) Bash History gelöscht"
    fi
done

# === TEMPORÄRE DATEIEN ===
echo -e "${YELLOW}[7/10] Lösche temporäre Dateien...${NC}"

rm -rf /tmp/*
rm -rf /var/tmp/*
echo "  [✓] Temporäre Dateien gelöscht"

# === SSH KEYS (Optional) ===
echo -e "${YELLOW}[8/10] SSH-Keys...${NC}"

read -p "SSH-Keys löschen? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "/root/.ssh" ]; then
        find /root/.ssh -type f -exec shred -vfz -n 3 {} \; 2>/dev/null || true
        rm -rf /root/.ssh
        echo "  [✓] Root SSH-Keys gelöscht"
    fi
fi

# === FIREWALL RESET (Optional) ===
echo -e "${YELLOW}[9/10] Firewall...${NC}"

read -p "Firewall zurücksetzen? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw --force enable
    echo "  [✓] Firewall zurückgesetzt (nur SSH erlaubt)"
fi

# === DISK WIPE (EXTREME - Optional) ===
echo -e "${YELLOW}[10/10] Disk Wipe...${NC}"
echo -e "${RED}"
echo "⚠️  EXTREME OPTION: Gesamte Disk überschreiben"
echo "    Dies macht den Server UNBRAUCHBAR und dauert STUNDEN!"
echo "    Nur sinnvoll vor Server-Destruction."
echo -e "${NC}"

read -p "Gesamte Disk überschreiben? (yes/no) " WIPE_CONFIRM

if [ "$WIPE_CONFIRM" = "yes" ]; then
    echo -e "${RED}[!] Disk Wipe wird gestartet...${NC}"
    echo -e "${RED}[!] Dies ist Ihre LETZTE Chance abzubrechen!${NC}"
    read -p "WIRKLICH fortfahren? Tippen Sie 'WIPE': " FINAL_WIPE
    
    if [ "$FINAL_WIPE" = "WIPE" ]; then
        # Identifiziere Root-Disk
        ROOT_DISK=$(lsblk -no PKNAME $(findmnt -n -o SOURCE /))
        
        echo -e "${RED}[!] Überschreibe /dev/${ROOT_DISK} mit Zufallsdaten...${NC}"
        echo -e "${RED}[!] Server wird danach unbrauchbar sein!${NC}"
        
        # 1 Pass mit Zufallsdaten (mehr Passes dauern zu lange)
        dd if=/dev/urandom of=/dev/${ROOT_DISK} bs=1M status=progress || true
        
        echo -e "${RED}[✓] Disk überschrieben. Server ist jetzt unbrauchbar.${NC}"
        echo -e "${RED}[!] Löschen Sie den VPS bei Ihrem Provider.${NC}"
        
        # System Halt
        sync
        halt -p
    fi
fi

# === ZUSAMMENFASSUNG ===
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                  Cleanup abgeschlossen!                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}[✓] Gelöscht:${NC}"
echo "  • Havoc Teamserver"
echo "  • Redirector-Konfigurationen"
echo "  • Logs (überschrieben)"
echo "  • SSL-Zertifikate"
echo "  • Bash History"
echo "  • Temporäre Dateien"
echo ""
echo -e "${YELLOW}Nächste Schritte:${NC}"
echo "  1. Prüfen Sie, ob alles entfernt wurde"
echo "  2. Bei Provider: VPS löschen/zerstören"
echo "  3. DNS-Records entfernen"
echo "  4. Domain zu anderem Nameserver verschieben"
echo "  5. Engagement-Report finalisieren"
echo ""
echo -e "${RED}Wichtig:${NC}"
echo "  • Dokumentieren Sie alle IoCs für den Kunden"
echo "  • Stellen Sie sicher, dass keine Backdoors auf Ziel-Systemen"
echo "  • Zahlungsspuren bereinigen (Crypto-Wallets, etc.)"
echo ""
