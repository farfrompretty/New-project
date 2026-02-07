#!/usr/bin/env bash
#
# STANDALONE TEAMSERVER INSTALLATION
# Benötigt KEINE externe Config-Datei!
# Alles wird automatisch generiert!
#
# VERWENDUNG:
#   wget https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh
#   sudo bash install_teamserver_standalone.sh
#
# ODER mit curl:
#   curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh
#   sudo bash install_teamserver_standalone.sh
#

set -e

# Root-Check
if [ "$EUID" -ne 0 ]; then 
    echo "[!] Bitte als root ausführen: sudo bash $0"
    exit 1
fi

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║          HAVOC C2 TEAMSERVER - AUTO-INSTALLATION            ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Automatische Passwort-Generierung
ADMIN_PASS=$(openssl rand -base64 20 | tr -d '/+=' | head -c 20)
OPERATOR_PASS=$(openssl rand -base64 20 | tr -d '/+=' | head -c 20)

echo "[*] Generiere Passwörter..."
echo "    Admin:    $ADMIN_PASS"
echo "    Operator: $OPERATOR_PASS"
echo ""

# Frage nach Listener-Domain (einzige Eingabe)
echo "[?] Listener-Domain/IP (für Beacon-Callbacks):"
echo "    Wenn Sie einen Redirector haben: Geben Sie Domain ein (z.B. cdn.example.com)"
echo "    Wenn direkter Zugriff: Geben Sie Server-IP oder 0.0.0.0 ein"
echo ""
read -p "Listener Host: " LISTENER_HOST
LISTENER_HOST=${LISTENER_HOST:-0.0.0.0}

echo ""
echo "[+] Setup startet in 3 Sekunden..."
sleep 3

# System-Update
echo "[1/6] Aktualisiere System..."
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt upgrade -y -qq

# Dependencies
echo "[2/6] Installiere Dependencies (2-3 Minuten)..."
apt install -y build-essential cmake golang-go mingw-w64 nasm \
    libboost-all-dev libssl-dev libncurses5-dev libgdbm-dev \
    libreadline-dev libffi-dev libsqlite3-dev libbz2-dev ufw git

# Havoc klonen
echo "[3/6] Klone Havoc Framework..."
if [ -d "/opt/Havoc" ]; then
    cd /opt/Havoc
    git pull
else
    cd /opt
    git clone https://github.com/HavocFramework/Havoc.git
fi

# Kompilieren
echo "[4/6] Kompiliere Teamserver (10-15 Minuten - bitte warten)..."
cd /opt/Havoc/teamserver
go mod download 2>/dev/null || true
cd /opt/Havoc
make ts-build

# Konfiguration
echo "[5/6] Erstelle Konfiguration..."
mkdir -p /opt/Havoc/profiles

cat > /opt/Havoc/profiles/havoc.yaotl << ENDCONFIG
Teamserver:
  Host: 0.0.0.0
  Port: 40056
  
  Build:
    Compiler64: "/usr/bin/x86_64-w64-mingw32-gcc"
    Compiler86: "/usr/bin/i686-w64-mingw32-gcc"
    Nasm: "/usr/bin/nasm"

Operators:
  - Name: admin
    Password: "${ADMIN_PASS}"
  
  - Name: operator1
    Password: "${OPERATOR_PASS}"

Listeners:
  - Name: "HTTPS Listener"
    Protocol: https
    Hosts:
      - "${LISTENER_HOST}"
    Port: 443
    HostBind: 0.0.0.0
    PortBind: 443
    Secure: true
    
    Response:
      Headers:
        Server: "nginx/1.18.0"
        X-Powered-By: "PHP/7.4.3"
ENDCONFIG

# Systemd Service
cat > /etc/systemd/system/havoc-teamserver.service << 'ENDSERVICE'
[Unit]
Description=Havoc C2 Teamserver
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/Havoc
ExecStart=/opt/Havoc/havoc server --profile /opt/Havoc/profiles/havoc.yaotl -v
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
ENDSERVICE

systemctl daemon-reload
systemctl enable havoc-teamserver

# Firewall
echo "[6/6] Konfiguriere Firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 40056/tcp
ufw allow 443/tcp

# Start
echo ""
echo "[*] Starte Teamserver..."
systemctl start havoc-teamserver
sleep 3

# Status
if systemctl is-active havoc-teamserver >/dev/null 2>&1; then
    STATUS="✅ LÄUFT"
else
    STATUS="❌ FEHLER"
fi

# Ausgabe
CURRENT_IP=$(hostname -I | awk '{print $1}')

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║          ✅  TEAMSERVER ERFOLGREICH INSTALLIERT!             ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "TEAMSERVER-INFO:"
echo "  IP-Adresse:    $CURRENT_IP"
echo "  Port:          40056"
echo "  Status:        $STATUS"
echo ""
echo "ZUGANGSDATEN:"
echo "  Admin Username:    admin"
echo "  Admin Password:    $ADMIN_PASS"
echo "  Operator Username: operator1"
echo "  Operator Password: $OPERATOR_PASS"
echo ""
echo "LISTENER:"
echo "  Host: $LISTENER_HOST"
echo "  Port: 443"
echo ""
echo "⚠️  WICHTIG: Notieren Sie diese Passwörter!"
echo ""
echo "BEFEHLE:"
echo "  Status:  systemctl status havoc-teamserver"
echo "  Logs:    journalctl -u havoc-teamserver -f"
echo ""

# Credentials speichern
cat > /root/TEAMSERVER_ZUGANGSDATEN.txt << ENDCREDS
═══════════════════════════════════════════════════════════════
HAVOC TEAMSERVER - ZUGANGSDATEN
═══════════════════════════════════════════════════════════════

IP:       $CURRENT_IP
Port:     40056

Admin:
  User:   admin
  Pass:   $ADMIN_PASS

Operator:
  User:   operator1
  Pass:   $OPERATOR_PASS

Listener: https://$LISTENER_HOST:443

Installation: $(date)

⚠️  NACH DEM LESEN LÖSCHEN:
    shred -vfz -n 10 /root/TEAMSERVER_ZUGANGSDATEN.txt
═══════════════════════════════════════════════════════════════
ENDCREDS

chmod 600 /root/TEAMSERVER_ZUGANGSDATEN.txt

echo "Zugangsdaten gespeichert in: /root/TEAMSERVER_ZUGANGSDATEN.txt"
echo ""
