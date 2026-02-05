#!/bin/bash
#
# MASTER SETUP - VOLLAUTOMATISIERT
#
# Dieses Script übernimmt ALLE Konfigurationen für Sie!
# Keine manuellen Eingaben nötig (außer API-Keys am Anfang)
#
# Verwendung: sudo bash master_setup_automated.sh
#

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     HAVOC C2 - MASTER SETUP (VOLLAUTOMATISIERT)             ║
║                                                               ║
║     Alle Konfigurationen werden automatisch erstellt         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Root-Check
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!] Bitte als root ausführen (sudo)${NC}"
    exit 1
fi

# ===== SCHRITT 1: INTERAKTIVE KONFIGURATION =====

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  SCHRITT 1: Konfiguration (nur einmalig)                     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

CONFIG_FILE="/root/.havoc_setup_config"

if [ -f "$CONFIG_FILE" ]; then
    echo -e "${GREEN}[+] Gespeicherte Konfiguration gefunden!${NC}"
    source "$CONFIG_FILE"
    
    echo ""
    echo -e "${YELLOW}Gespeicherte Einstellungen:${NC}"
    echo "  Setup-Typ: $SETUP_TYPE"
    echo "  Domain: $DOMAIN"
    echo "  Admin Email: $ADMIN_EMAIL"
    echo ""
    
    read -p "Diese Konfiguration verwenden? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        rm "$CONFIG_FILE"
    else
        USE_EXISTING=true
    fi
fi

if [ ! -f "$CONFIG_FILE" ] || [ "$USE_EXISTING" != "true" ]; then
    echo -e "${YELLOW}[?] Was möchten Sie installieren?${NC}"
    echo ""
    echo "  1) Komplette Infrastruktur (Teamserver + Redirector)"
    echo "  2) Nur Teamserver (versteckt, für Operator-Zugriff)"
    echo "  3) Nur Redirector (öffentlich, leitet zu Teamserver weiter)"
    echo "  4) Lokales Test-Setup (All-in-One für Training)"
    echo ""
    read -p "Auswahl [1-4]: " SETUP_TYPE
    
    case $SETUP_TYPE in
        1) SETUP_NAME="Komplette Infrastruktur" ;;
        2) SETUP_NAME="Nur Teamserver" ;;
        3) SETUP_NAME="Nur Redirector" ;;
        4) SETUP_NAME="Lokales Test-Setup" ;;
        *) echo -e "${RED}Ungültige Auswahl!${NC}"; exit 1 ;;
    esac
    
    echo ""
    echo -e "${GREEN}[✓] Setup-Typ: $SETUP_NAME${NC}"
    echo ""
    
    # Domain (nur wenn Redirector)
    if [ "$SETUP_TYPE" = "1" ] || [ "$SETUP_TYPE" = "3" ]; then
        read -p "Ihre Domain (z.B. example.com): " DOMAIN
        if [ -z "$DOMAIN" ]; then
            echo -e "${RED}[!] Domain ist erforderlich!${NC}"
            exit 1
        fi
        
        read -p "Subdomain für Redirector (z.B. cdn): " SUBDOMAIN
        SUBDOMAIN=${SUBDOMAIN:-cdn}
        FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"
        
        read -p "Admin Email (für SSL-Zertifikat): " ADMIN_EMAIL
        ADMIN_EMAIL=${ADMIN_EMAIL:-admin@${DOMAIN}}
    fi
    
    # Passwörter generieren
    ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d '/+=')
    OPERATOR_PASSWORD=$(openssl rand -base64 16 | tr -d '/+=')
    
    # Redirector-Typ (falls benötigt)
    if [ "$SETUP_TYPE" = "1" ] || [ "$SETUP_TYPE" = "3" ]; then
        echo ""
        echo -e "${YELLOW}[?] Welchen Redirector-Typ möchten Sie?${NC}"
        echo "  1) Nginx (Standard, bewährt)"
        echo "  2) Apache (Flexibel, viele Features)"
        echo "  3) Caddy (Modern, automatisches HTTPS)"
        echo "  4) Traefik (Cloud-Native, automatisch)"
        echo ""
        read -p "Auswahl [1-4]: " REDIRECTOR_CHOICE
        
        case $REDIRECTOR_CHOICE in
            1) REDIRECTOR_TYPE="nginx" ;;
            2) REDIRECTOR_TYPE="apache" ;;
            3) REDIRECTOR_TYPE="caddy" ;;
            4) REDIRECTOR_TYPE="traefik" ;;
            *) REDIRECTOR_TYPE="nginx" ;;
        esac
    fi
    
    # Teamserver IP (falls nur Redirector)
    if [ "$SETUP_TYPE" = "3" ]; then
        read -p "Teamserver IP-Adresse: " TEAMSERVER_IP
        if [ -z "$TEAMSERVER_IP" ]; then
            echo -e "${RED}[!] Teamserver IP erforderlich!${NC}"
            exit 1
        fi
    fi
    
    # Konfiguration speichern
    cat > "$CONFIG_FILE" << EOF
SETUP_TYPE="$SETUP_TYPE"
SETUP_NAME="$SETUP_NAME"
DOMAIN="$DOMAIN"
SUBDOMAIN="$SUBDOMAIN"
FULL_DOMAIN="$FULL_DOMAIN"
ADMIN_EMAIL="$ADMIN_EMAIL"
ADMIN_PASSWORD="$ADMIN_PASSWORD"
OPERATOR_PASSWORD="$OPERATOR_PASSWORD"
REDIRECTOR_TYPE="$REDIRECTOR_TYPE"
TEAMSERVER_IP="$TEAMSERVER_IP"
EOF
    
    chmod 600 "$CONFIG_FILE"
    
    echo ""
    echo -e "${GREEN}[✓] Konfiguration gespeichert!${NC}"
fi

# ===== SCHRITT 2: SYSTEM VORBEREITEN =====

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  SCHRITT 2: System vorbereiten                               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}[*] Aktualisiere System...${NC}"
apt update -qq
apt upgrade -y -qq

echo -e "${YELLOW}[*] Installiere Basis-Tools...${NC}"
apt install -y -qq curl wget git net-tools ufw

# ===== SCHRITT 3: INSTALLATION =====

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  SCHRITT 3: Installation                                     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

case $SETUP_TYPE in
    1)
        # Komplette Infrastruktur
        echo -e "${MAGENTA}[*] Installiere Teamserver UND Redirector...${NC}"
        
        # Entscheide basierend auf IPs
        CURRENT_IP=$(hostname -I | awk '{print $1}')
        echo -e "${YELLOW}[?] Ist dies der Teamserver (versteckt) oder Redirector (öffentlich)?${NC}"
        echo "  Aktuelle IP: $CURRENT_IP"
        echo ""
        echo "  1) Dies ist der Teamserver"
        echo "  2) Dies ist der Redirector"
        echo ""
        read -p "Auswahl: " SERVER_ROLE
        
        if [ "$SERVER_ROLE" = "1" ]; then
            echo -e "${GREEN}[+] Installiere Teamserver...${NC}"
            bash <(curl -s https://raw.githubusercontent.com/.../install_havoc_teamserver.sh) --auto \
                --password "$ADMIN_PASSWORD" \
                --operator-password "$OPERATOR_PASSWORD"
        else
            echo -e "${GREEN}[+] Installiere Redirector...${NC}"
            
            if [ -z "$TEAMSERVER_IP" ]; then
                read -p "Teamserver IP-Adresse: " TEAMSERVER_IP
            fi
            
            case $REDIRECTOR_TYPE in
                nginx)
                    bash <(curl -s https://raw.githubusercontent.com/.../install_redirector_nginx.sh) --auto \
                        --domain "$FULL_DOMAIN" \
                        --c2-ip "$TEAMSERVER_IP" \
                        --email "$ADMIN_EMAIL"
                    ;;
                apache)
                    bash <(curl -s https://raw.githubusercontent.com/.../install_redirector_apache.sh) --auto \
                        --domain "$FULL_DOMAIN" \
                        --c2-ip "$TEAMSERVER_IP" \
                        --email "$ADMIN_EMAIL"
                    ;;
                caddy)
                    bash <(curl -s https://raw.githubusercontent.com/.../install_redirector_caddy.sh) --auto \
                        --domain "$FULL_DOMAIN" \
                        --c2-ip "$TEAMSERVER_IP" \
                        --email "$ADMIN_EMAIL"
                    ;;
                traefik)
                    bash <(curl -s https://raw.githubusercontent.com/.../install_redirector_traefik.sh) --auto \
                        --domain "$FULL_DOMAIN" \
                        --c2-ip "$TEAMSERVER_IP" \
                        --email "$ADMIN_EMAIL"
                    ;;
            esac
        fi
        ;;
        
    2)
        # Nur Teamserver
        echo -e "${MAGENTA}[*] Installiere Teamserver...${NC}"
        
        # Download und führe Teamserver-Script aus
        SCRIPT_URL="https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_havoc_teamserver.sh"
        
        # Erstelle temporäres Auto-Input
        cat > /tmp/teamserver_input.txt << EOF
0.0.0.0
40056
${ADMIN_PASSWORD}
${ADMIN_PASSWORD}
localhost
443
y
EOF
        
        curl -s "$SCRIPT_URL" | bash -s < /tmp/teamserver_input.txt
        rm /tmp/teamserver_input.txt
        ;;
        
    3)
        # Nur Redirector
        echo -e "${MAGENTA}[*] Installiere Redirector ($REDIRECTOR_TYPE)...${NC}"
        
        SCRIPT_URL="https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_redirector_${REDIRECTOR_TYPE}.sh"
        
        cat > /tmp/redirector_input.txt << EOF
${FULL_DOMAIN}
${TEAMSERVER_IP}
443
/api
${ADMIN_EMAIL}
y
EOF
        
        curl -s "$SCRIPT_URL" | bash -s < /tmp/redirector_input.txt
        rm /tmp/redirector_input.txt
        ;;
        
    4)
        # Lokales Test-Setup
        echo -e "${MAGENTA}[*] Installiere lokales All-in-One Setup...${NC}"
        
        # Lokale Installation ohne externen Zugriff
        cd /tmp
        git clone https://github.com/HavocFramework/Havoc.git
        cd Havoc
        
        # Dependencies
        apt install -y build-essential golang-go mingw-w64 nasm cmake libboost-all-dev
        
        # Build
        cd teamserver && go mod download || true
        cd ..
        make ts-build
        
        # Config
        mkdir -p profiles
        cat > profiles/local.yaotl << EOF
Teamserver:
  Host: 0.0.0.0
  Port: 40056
  Build:
    Compiler64: "/usr/bin/x86_64-w64-mingw32-gcc"
    Compiler86: "/usr/bin/i686-w64-mingw32-gcc"
    Nasm: "/usr/bin/nasm"
Operators:
  - Name: admin
    Password: "$ADMIN_PASSWORD"
Listeners:
  - Name: "Local HTTPS"
    Protocol: https
    Hosts:
      - "localhost"
    Port: 8443
    HostBind: 0.0.0.0
    PortBind: 8443
    Secure: true
EOF
        
        # Systemd
        cat > /etc/systemd/system/havoc-teamserver.service << EOF
[Unit]
Description=Havoc C2 Teamserver
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=/tmp/Havoc
ExecStart=/tmp/Havoc/havoc server --profile /tmp/Havoc/profiles/local.yaotl -v
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        systemctl enable havoc-teamserver
        systemctl start havoc-teamserver
        ;;
esac

# ===== SCHRITT 4: FINALISIERUNG =====

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  SCHRITT 4: Finalisierung                                    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Firewall
echo -e "${YELLOW}[*] Konfiguriere Firewall...${NC}"
ufw --force enable
ufw allow 22/tcp comment "SSH"

if [ "$SETUP_TYPE" = "1" ] || [ "$SETUP_TYPE" = "2" ] || [ "$SETUP_TYPE" = "4" ]; then
    ufw allow 40056/tcp comment "Havoc Teamserver"
fi

if [ "$SETUP_TYPE" = "1" ] || [ "$SETUP_TYPE" = "3" ]; then
    ufw allow 80/tcp comment "HTTP"
    ufw allow 443/tcp comment "HTTPS"
fi

# Credentials-Datei erstellen
CREDS_FILE="/root/havoc_credentials.txt"
cat > "$CREDS_FILE" << EOF
╔═══════════════════════════════════════════════════════════════╗
║          HAVOC C2 - ZUGANGSDATEN (SICHER AUFBEWAHREN!)      ║
╚═══════════════════════════════════════════════════════════════╝

Setup: $SETUP_NAME
Datum: $(date)

TEAMSERVER:
  IP:       $(hostname -I | awk '{print $1}')
  Port:     40056
  Username: admin
  Password: $ADMIN_PASSWORD

EOF

if [ "$SETUP_TYPE" = "1" ] || [ "$SETUP_TYPE" = "2" ] || [ "$SETUP_TYPE" = "4" ]; then
    cat >> "$CREDS_FILE" << EOF
ZUSÄTZLICHER OPERATOR:
  Username: operator1
  Password: $OPERATOR_PASSWORD

EOF
fi

if [ "$SETUP_TYPE" = "1" ] || [ "$SETUP_TYPE" = "3" ]; then
    cat >> "$CREDS_FILE" << EOF
REDIRECTOR:
  Domain:   $FULL_DOMAIN
  IP:       $(hostname -I | awk '{print $1}')
  Typ:      $REDIRECTOR_TYPE
  C2-IP:    ${TEAMSERVER_IP:-"Dieser Server"}

SSL:
  Email:    $ADMIN_EMAIL
  Status:   Let's Encrypt (automatisch)

EOF
fi

cat >> "$CREDS_FILE" << EOF
WICHTIGE KOMMANDOS:

Teamserver Status:
  sudo systemctl status havoc-teamserver

Teamserver Logs:
  sudo journalctl -u havoc-teamserver -f

Redirector Status:
  sudo systemctl status $REDIRECTOR_TYPE

SICHERHEIT:
  - Ändern Sie SSH-Port (aktuell: 22)
  - Nutzen Sie SSH-Keys statt Passwörter
  - Aktivieren Sie Fail2Ban

NEXT STEPS:
  1. Verbinden Sie Havoc Client:
     Host: $(hostname -I | awk '{print $1}')
     Port: 40056
     User: admin
     Pass: $ADMIN_PASSWORD
  
  2. Testen Sie die Verbindung:
     nc -zv $(hostname -I | awk '{print $1}') 40056
  
EOF

if [ "$SETUP_TYPE" = "1" ] || [ "$SETUP_TYPE" = "3" ]; then
    cat >> "$CREDS_FILE" << EOF
  3. Testen Sie Redirector:
     curl https://$FULL_DOMAIN/

EOF
fi

cat >> "$CREDS_FILE" << EOF
DOKUMENTATION:
  - Haupt-Guide: https://github.com/farfrompretty/New-project
  - Troubleshooting: TROUBLESHOOTING.md
  - OPSEC-Guide: OPSEC_GUIDE.md

╔═══════════════════════════════════════════════════════════════╗
║  ⚠️  DIESE DATEI NACH DEM LESEN SICHER LÖSCHEN!             ║
║     shred -vfz -n 10 $CREDS_FILE                             ║
╚═══════════════════════════════════════════════════════════════╝
EOF

chmod 600 "$CREDS_FILE"

# ===== FERTIG =====

clear
echo -e "${GREEN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          ✅  INSTALLATION ERFOLGREICH ABGESCHLOSSEN!         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

cat "$CREDS_FILE"

echo ""
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  WICHTIG: Credentials gespeichert in:                        ║${NC}"
echo -e "${YELLOW}║  $CREDS_FILE${NC}"
echo -e "${YELLOW}║                                                               ║${NC}"
echo -e "${YELLOW}║  Lesen Sie diese Datei und löschen Sie sie dann:            ║${NC}"
echo -e "${YELLOW}║  shred -vfz -n 10 $CREDS_FILE                                ║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Installations-Log
echo "Installation completed at $(date)" >> /var/log/havoc_setup.log
echo "Setup type: $SETUP_NAME" >> /var/log/havoc_setup.log

echo -e "${GREEN}[✓] Setup abgeschlossen!${NC}"
echo ""
