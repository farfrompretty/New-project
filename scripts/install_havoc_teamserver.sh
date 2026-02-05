#!/bin/bash
#
# Havoc C2 Teamserver - Automatische Installation
# 
# Verwendung: sudo bash install_havoc_teamserver.sh
#
# Beschreibung: Installiert und konfiguriert Havoc C2 Teamserver auf Ubuntu 20.04/22.04
#

set -e  # Bei Fehler abbrechen

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Havoc C2 Teamserver - Automatische Installation      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Root-Check
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!] Bitte als root ausführen (sudo)${NC}"
    exit 1
fi

# Betriebssystem prüfen
if ! grep -qi ubuntu /etc/os-release; then
    echo -e "${YELLOW}[!] Warnung: Dieses Script ist für Ubuntu optimiert.${NC}"
    read -p "Fortfahren? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}[+] System wird aktualisiert...${NC}"
apt update -qq
apt upgrade -y -qq

echo -e "${GREEN}[+] Installiere Dependencies...${NC}"
apt install -y -qq git build-essential apt-utils cmake libfontconfig1 \
    libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev \
    libncurses5-dev libgdbm-dev libssl-dev libreadline-dev libffi-dev \
    libsqlite3-dev libbz2-dev mesa-common-dev qtbase5-dev qtchooser \
    qt5-qmake qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev \
    qtdeclarative5-dev golang-go qtbase5-dev libqt5websockets5-dev \
    libspdlog-dev python3-dev libboost-all-dev mingw-w64 nasm \
    net-tools ufw

echo -e "${GREEN}[+] Klone Havoc Framework...${NC}"
if [ -d "/opt/Havoc" ]; then
    echo -e "${YELLOW}[!] /opt/Havoc existiert bereits. Überspringe Klonen.${NC}"
else
    cd /opt
    git clone https://github.com/HavocFramework/Havoc.git
fi

cd /opt/Havoc

echo -e "${GREEN}[+] Lade Go-Dependencies...${NC}"
cd teamserver
go mod download golang.org/x/sys 2>/dev/null || true
go mod download github.com/ugorji/go 2>/dev/null || true
cd ..

echo -e "${GREEN}[+] Kompiliere Teamserver (das kann einige Minuten dauern)...${NC}"
make ts-build

if [ ! -f "/opt/Havoc/havoc" ]; then
    echo -e "${RED}[!] Kompilierung fehlgeschlagen!${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Teamserver erfolgreich kompiliert!${NC}"

# Konfiguration erstellen
echo -e "${GREEN}[+] Erstelle Konfiguration...${NC}"
mkdir -p /opt/Havoc/profiles

# User-Input für Konfiguration
read -p "Teamserver Host (0.0.0.0 für alle Interfaces): " TS_HOST
TS_HOST=${TS_HOST:-0.0.0.0}

read -p "Teamserver Port (Standard: 40056): " TS_PORT
TS_PORT=${TS_PORT:-40056}

read -p "Admin Benutzername: " ADMIN_USER
ADMIN_USER=${ADMIN_USER:-admin}

read -sp "Admin Passwort: " ADMIN_PASS
echo
if [ -z "$ADMIN_PASS" ]; then
    ADMIN_PASS=$(openssl rand -base64 16)
    echo -e "${YELLOW}[!] Kein Passwort angegeben. Generiert: ${ADMIN_PASS}${NC}"
fi

read -p "Listener Domain/IP (z.B. example.com): " LISTENER_HOST
LISTENER_HOST=${LISTENER_HOST:-127.0.0.1}

read -p "Listener Port (Standard: 443): " LISTENER_PORT
LISTENER_PORT=${LISTENER_PORT:-443}

cat > /opt/Havoc/profiles/havoc.yaotl << EOF
Teamserver:
  Host: ${TS_HOST}
  Port: ${TS_PORT}
  
  Build:
    Compiler64: "x86_64-w64-mingw32-gcc"
    Compiler86: "i686-w64-mingw32-gcc"
    Nasm: "/usr/bin/nasm"

Operators:
  - Name: ${ADMIN_USER}
    Password: "${ADMIN_PASS}"

Listeners:
  - Name: "Default HTTPS Listener"
    Protocol: https
    Hosts:
      - "${LISTENER_HOST}"
    Port: ${LISTENER_PORT}
    HostBind: 0.0.0.0
    PortBind: ${LISTENER_PORT}
    Secure: true
    
    Response:
      Headers:
        Server: "nginx/1.18.0 (Ubuntu)"
        Content-Type: "text/html; charset=UTF-8"
EOF

echo -e "${GREEN}[+] Konfiguration erstellt: /opt/Havoc/profiles/havoc.yaotl${NC}"

# Systemd Service erstellen
echo -e "${GREEN}[+] Erstelle systemd Service...${NC}"
cat > /etc/systemd/system/havoc-teamserver.service << EOF
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
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

echo -e "${GREEN}[+] Konfiguriere Firewall...${NC}"
ufw --force enable
ufw allow ${TS_PORT}/tcp comment "Havoc Teamserver"
ufw allow ${LISTENER_PORT}/tcp comment "Havoc Listener"
ufw allow 22/tcp comment "SSH"

echo -e "${GREEN}[+] Service wird aktiviert...${NC}"
systemctl enable havoc-teamserver

# Abschlussinformationen
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                Installation abgeschlossen!                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}[✓] Havoc Teamserver installiert${NC}"
echo -e "${GREEN}[✓] Konfiguration: /opt/Havoc/profiles/havoc.yaotl${NC}"
echo -e "${GREEN}[✓] Systemd Service: havoc-teamserver${NC}"
echo ""
echo -e "${YELLOW}Verbindungsinformationen:${NC}"
echo "  Host: $(hostname -I | awk '{print $1}')"
echo "  Port: ${TS_PORT}"
echo "  Benutzername: ${ADMIN_USER}"
echo "  Passwort: ${ADMIN_PASS}"
echo ""
echo -e "${YELLOW}Wichtige Kommandos:${NC}"
echo "  Starten:   sudo systemctl start havoc-teamserver"
echo "  Stoppen:   sudo systemctl stop havoc-teamserver"
echo "  Status:    sudo systemctl status havoc-teamserver"
echo "  Logs:      sudo journalctl -u havoc-teamserver -f"
echo ""
echo -e "${YELLOW}Nächste Schritte:${NC}"
echo "  1. Starten Sie den Teamserver: sudo systemctl start havoc-teamserver"
echo "  2. Prüfen Sie den Status: sudo systemctl status havoc-teamserver"
echo "  3. Verbinden Sie sich mit dem Havoc Client"
echo ""
echo -e "${RED}⚠️  WICHTIG: Notieren Sie das Admin-Passwort!${NC}"
echo ""

read -p "Teamserver jetzt starten? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    systemctl start havoc-teamserver
    sleep 3
    systemctl status havoc-teamserver --no-pager
fi
