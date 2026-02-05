#!/bin/bash
#
# EINFACHES SETUP - Vollautomatisch
#
# Verwendung:
#   1. cp config.example config
#   2. nano config (Werte ausfüllen)
#   3. sudo bash einfaches_setup.sh
#
# ODER direkt mit bash:
#   sudo bash einfaches_setup.sh
#

# Fehler abbrechen
set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║     HAVOC C2 - EINFACHES AUTOMATISCHES SETUP                ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Root-Check
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!] Bitte als root ausführen: sudo bash einfaches_setup.sh${NC}"
    exit 1
fi

# Config-Check
if [ ! -f "./config" ]; then
    echo -e "${RED}[!] Config-Datei nicht gefunden!${NC}"
    echo ""
    echo "Bitte erstellen:"
    echo "  cp config.example config"
    echo "  nano config"
    echo ""
    exit 1
fi

# Config laden
echo -e "${GREEN}[+] Lade Konfiguration...${NC}"
source ./config

echo ""
echo -e "${BLUE}Server-Typ: ${SERVER_TYPE}${NC}"
echo ""

# System aktualisieren
echo -e "${YELLOW}[1/5] Aktualisiere System...${NC}"
apt update -qq
apt upgrade -y -qq
echo -e "${GREEN}[✓] System aktualisiert${NC}"

# Basis-Tools
echo -e "${YELLOW}[2/5] Installiere Basis-Tools...${NC}"
apt install -y curl wget git ufw net-tools
echo -e "${GREEN}[✓] Basis-Tools installiert${NC}"

# Teamserver oder Redirector?
if [ "$SERVER_TYPE" = "teamserver" ]; then
    
    echo ""
    echo -e "${BLUE}═══ TEAMSERVER INSTALLATION ═══${NC}"
    echo ""
    
    # Dependencies
    echo -e "${YELLOW}[3/5] Installiere Havoc-Dependencies (dauert 2-3 Min)...${NC}"
    apt install -y build-essential cmake golang-go mingw-w64 nasm \
        libboost-all-dev libssl-dev libncurses5-dev libgdbm-dev \
        libreadline-dev libffi-dev libsqlite3-dev libbz2-dev
    
    echo -e "${GREEN}[✓] Dependencies installiert${NC}"
    
    # Havoc klonen
    echo -e "${YELLOW}[4/5] Klone und kompiliere Havoc (10-15 Min)...${NC}"
    
    if [ ! -d "/opt/Havoc" ]; then
        cd /opt
        git clone https://github.com/HavocFramework/Havoc.git
    fi
    
    cd /opt/Havoc
    cd teamserver
    go mod download || true
    cd ..
    
    make ts-build
    
    echo -e "${GREEN}[✓] Havoc kompiliert${NC}"
    
    # Konfiguration
    echo -e "${YELLOW}[5/5] Erstelle Konfiguration...${NC}"
    
    mkdir -p /opt/Havoc/profiles
    
    cat > /opt/Havoc/profiles/havoc.yaotl << EOFCONFIG
Teamserver:
  Host: ${TS_HOST}
  Port: ${TS_PORT}
  Build:
    Compiler64: "/usr/bin/x86_64-w64-mingw32-gcc"
    Compiler86: "/usr/bin/i686-w64-mingw32-gcc"
    Nasm: "/usr/bin/nasm"
Operators:
  - Name: ${ADMIN_USER}
    Password: "${ADMIN_PASSWORD}"
  - Name: ${OPERATOR_USER}
    Password: "${OPERATOR_PASSWORD}"
Listeners:
  - Name: "HTTPS Listener"
    Protocol: https
    Hosts:
      - "${LISTENER_HOST}"
    Port: ${LISTENER_PORT}
    HostBind: 0.0.0.0
    PortBind: ${LISTENER_PORT}
    Secure: true
EOFCONFIG
    
    # Systemd Service
    cat > /etc/systemd/system/havoc-teamserver.service << EOFSERVICE
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
EOFSERVICE
    
    systemctl daemon-reload
    systemctl enable havoc-teamserver
    systemctl start havoc-teamserver
    
    # Firewall
    ufw --force enable
    ufw allow 22/tcp
    ufw allow ${TS_PORT}/tcp
    ufw allow ${LISTENER_PORT}/tcp
    
    # Credentials speichern
    cat > /root/TEAMSERVER_INFO.txt << EOFCRED
╔═══════════════════════════════════════════════════════════════╗
║              TEAMSERVER ZUGANGSDATEN                         ║
╚═══════════════════════════════════════════════════════════════╝

IP:       $(hostname -I | awk '{print $1}')
Port:     ${TS_PORT}
User:     ${ADMIN_USER}
Password: ${ADMIN_PASSWORD}

Operator:
User:     ${OPERATOR_USER}
Password: ${OPERATOR_PASSWORD}

Status prüfen:
  sudo systemctl status havoc-teamserver

Logs:
  sudo journalctl -u havoc-teamserver -f
EOFCRED
    
    chmod 600 /root/TEAMSERVER_INFO.txt
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║          ✅  TEAMSERVER INSTALLIERT!                         ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    cat /root/TEAMSERVER_INFO.txt
    
elif [ "$SERVER_TYPE" = "redirector" ]; then
    
    echo ""
    echo -e "${BLUE}═══ REDIRECTOR INSTALLATION ═══${NC}"
    echo ""
    
    # Nginx
    if [ "$REDIRECTOR_TYPE" = "nginx" ]; then
        
        echo -e "${YELLOW}[3/5] Installiere Nginx...${NC}"
        apt install -y nginx certbot python3-certbot-nginx
        echo -e "${GREEN}[✓] Nginx installiert${NC}"
        
        echo -e "${YELLOW}[4/5] Konfiguriere Redirector...${NC}"
        
        cat > /etc/nginx/sites-available/redirector << 'EOFNGINX'
upstream c2_backend {
    server C2_IP_PLACEHOLDER:C2_PORT_PLACEHOLDER;
}
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    location / {
        return 301 https://$server_name$request_uri;
    }
}
server {
    listen 443 ssl;
    server_name DOMAIN_PLACEHOLDER;
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    location ~ ^URI_PLACEHOLDER {
        proxy_pass https://c2_backend;
        proxy_ssl_verify off;
        proxy_set_header Host $host;
    }
    location / {
        root /var/www/html;
        index index.html;
    }
}
EOFNGINX
        
        # Platzhalter ersetzen
        sed -i "s|DOMAIN_PLACEHOLDER|${REDIRECTOR_DOMAIN}|g" /etc/nginx/sites-available/redirector
        sed -i "s|C2_IP_PLACEHOLDER|${C2_SERVER_IP}|g" /etc/nginx/sites-available/redirector
        sed -i "s|C2_PORT_PLACEHOLDER|${C2_SERVER_PORT}|g" /etc/nginx/sites-available/redirector
        sed -i "s|URI_PLACEHOLDER|${C2_URI}|g" /etc/nginx/sites-available/redirector
        
        # Webseite
        mkdir -p /var/www/html
        echo "<h1>Under Construction</h1>" > /var/www/html/index.html
        
        # Aktivieren
        rm -f /etc/nginx/sites-enabled/default
        ln -sf /etc/nginx/sites-available/redirector /etc/nginx/sites-enabled/
        nginx -t
        systemctl restart nginx
        
        echo -e "${GREEN}[✓] Nginx konfiguriert${NC}"
        
    fi
    
    # Firewall
    echo -e "${YELLOW}[5/5] Konfiguriere Firewall...${NC}"
    ufw --force enable
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    echo -e "${GREEN}[✓] Firewall konfiguriert${NC}"
    
    # SSL
    if [ "$AUTO_SSL" = "true" ]; then
        echo -e "${YELLOW}[*] Hole SSL-Zertifikat...${NC}"
        certbot --nginx -d ${REDIRECTOR_DOMAIN} --non-interactive --agree-tos -m ${ADMIN_EMAIL} --redirect || true
    fi
    
    # Info
    cat > /root/REDIRECTOR_INFO.txt << EOFINFO
╔═══════════════════════════════════════════════════════════════╗
║              REDIRECTOR ZUGANGSDATEN                         ║
╚═══════════════════════════════════════════════════════════════╝

IP:       $(hostname -I | awk '{print $1}')
Domain:   ${REDIRECTOR_DOMAIN}
C2:       ${C2_SERVER_IP}:${C2_SERVER_PORT}

Test:
  curl https://${REDIRECTOR_DOMAIN}/
EOFINFO
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║          ✅  REDIRECTOR INSTALLIERT!                         ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    cat /root/REDIRECTOR_INFO.txt
    
else
    echo -e "${RED}[!] Ungültiger SERVER_TYPE: ${SERVER_TYPE}${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Setup abgeschlossen!${NC}"
echo ""
