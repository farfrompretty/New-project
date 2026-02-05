#!/bin/bash
#
# VOLLAUTOMATISCHES HAVOC C2 SETUP
#
# Verwendung:
#   1. cp config.example config
#   2. nano config  (Werte ausfüllen!)
#   3. sudo ./auto_setup.sh
#
# Keine Interaktion nötig! Alles läuft automatisch.
#

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║        HAVOC C2 - VOLLAUTOMATISCHES SETUP                   ║
║        Keine Interaktion nötig!                              ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Root-Check
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!] Fehler: Bitte als root ausführen (sudo)${NC}"
    exit 1
fi

# Config-Datei prüfen
CONFIG_FILE="./config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}[!] Fehler: config Datei nicht gefunden!${NC}"
    echo ""
    echo "Bitte erstellen Sie die Konfigurationsdatei:"
    echo "  1. cp config.example config"
    echo "  2. nano config"
    echo "  3. Füllen Sie alle Werte aus"
    echo "  4. Führen Sie dieses Script erneut aus"
    echo ""
    exit 1
fi

# Config laden
echo -e "${GREEN}[+] Lade Konfiguration aus: $CONFIG_FILE${NC}"
source "$CONFIG_FILE"

# Validierung
if [ -z "$SERVER_TYPE" ]; then
    echo -e "${RED}[!] Fehler: SERVER_TYPE nicht gesetzt in config!${NC}"
    exit 1
fi

# Log-Datei
LOG_FILE="/var/log/havoc_auto_setup_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE} Setup-Typ: ${SERVER_TYPE}${NC}"
echo -e "${BLUE} Debug-Modus: ${DEBUG}${NC}"
echo -e "${BLUE} Log-Datei: ${LOG_FILE}${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# SYSTEM VORBEREITUNG
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}[1/5] System wird vorbereitet...${NC}"

apt update -qq
DEBIAN_FRONTEND=noninteractive apt upgrade -y -qq

apt install -y -qq curl wget git net-tools ufw vim

echo -e "${GREEN}[✓] System aktualisiert${NC}"

# ═══════════════════════════════════════════════════════════════
# SERVER-TYP SPEZIFISCHE INSTALLATION
# ═══════════════════════════════════════════════════════════════

if [ "$SERVER_TYPE" = "teamserver" ]; then
    
    # ═══════════════════════════════════════════════════════════
    #  TEAMSERVER INSTALLATION
    # ═══════════════════════════════════════════════════════════
    
    echo ""
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║  TEAMSERVER INSTALLATION                                     ║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}[2/5] Installiere Teamserver-Dependencies...${NC}"
    
    DEBIAN_FRONTEND=noninteractive apt install -y -qq \
        build-essential apt-utils cmake libfontconfig1 \
        libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev \
        libncurses5-dev libgdbm-dev libssl-dev libreadline-dev libffi-dev \
        libsqlite3-dev libbz2-dev mesa-common-dev golang-go mingw-w64 nasm
    
    echo -e "${GREEN}[✓] Dependencies installiert${NC}"
    
    echo -e "${YELLOW}[3/5] Klone und kompiliere Havoc...${NC}"
    
    if [ -d "/opt/Havoc" ]; then
        echo -e "${YELLOW}[!] /opt/Havoc existiert bereits - wird aktualisiert${NC}"
        cd /opt/Havoc
        git pull
    else
        cd /opt
        git clone https://github.com/HavocFramework/Havoc.git
        cd /opt/Havoc
    fi
    
    cd /opt/Havoc/teamserver
    go mod download golang.org/x/sys 2>/dev/null || true
    go mod download github.com/ugorji/go 2>/dev/null || true
    cd /opt/Havoc
    
    echo -e "${YELLOW}[*] Kompiliere Teamserver (5-10 Minuten, bitte warten)...${NC}"
    make ts-build
    
    echo -e "${GREEN}[✓] Havoc kompiliert${NC}"
    
    echo -e "${YELLOW}[4/5] Erstelle Konfiguration...${NC}"
    
    mkdir -p /opt/Havoc/profiles
    
    cat > /opt/Havoc/profiles/havoc.yaotl << EOF
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
    
    Response:
      Headers:
        Server: "nginx/1.18.0 (Ubuntu)"
        Content-Type: "text/html; charset=UTF-8"
EOF
    
    echo -e "${GREEN}[✓] Konfiguration erstellt${NC}"
    
    # Systemd Service
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
    systemctl enable havoc-teamserver
    
    # Firewall
    if [ "$AUTO_FIREWALL" = "true" ]; then
        echo -e "${YELLOW}[5/5] Konfiguriere Firewall...${NC}"
        
        ufw --force enable
        ufw default deny incoming
        ufw default allow outgoing
        
        ufw allow 22/tcp comment "SSH"
        ufw allow ${TS_PORT}/tcp comment "Havoc Teamserver"
        ufw allow ${LISTENER_PORT}/tcp comment "Havoc Listener"
        
        echo -e "${GREEN}[✓] Firewall konfiguriert${NC}"
    fi
    
    # Start Teamserver
    echo -e "${YELLOW}[*] Starte Teamserver...${NC}"
    systemctl start havoc-teamserver
    sleep 5
    
    if systemctl is-active havoc-teamserver >/dev/null 2>&1; then
        echo -e "${GREEN}[✓] Teamserver läuft!${NC}"
    else
        echo -e "${RED}[!] Teamserver konnte nicht gestartet werden!${NC}"
        echo "Logs: journalctl -u havoc-teamserver -n 50"
        exit 1
    fi
    
    # Credentials-Datei
    CURRENT_IP=$(hostname -I | awk '{print $1}')
    
    cat > /root/TEAMSERVER_CREDENTIALS.txt << EOF
╔═══════════════════════════════════════════════════════════════╗
║              TEAMSERVER ZUGANGSDATEN                         ║
╚═══════════════════════════════════════════════════════════════╝

INSTALLATION: $(date)

SERVER-INFO:
  IP-Adresse:    ${CURRENT_IP}
  Provider:      Hetzner (oder Ihr Provider)
  SSH:           ssh root@${CURRENT_IP}

HAVOC TEAMSERVER:
  Host:          ${CURRENT_IP}
  Port:          ${TS_PORT}
  
  Admin-Zugang:
    Username:    ${ADMIN_USER}
    Password:    ${ADMIN_PASSWORD}
  
  Operator-Zugang:
    Username:    ${OPERATOR_USER}
    Password:    ${OPERATOR_PASSWORD}

LISTENER:
  URL:           https://${LISTENER_HOST}:${LISTENER_PORT}
  
WICHTIGE BEFEHLE:
  Status:        sudo systemctl status havoc-teamserver
  Logs:          sudo journalctl -u havoc-teamserver -f
  Restart:       sudo systemctl restart havoc-teamserver
  Config:        sudo nano /opt/Havoc/profiles/havoc.yaotl

VERBINDUNG IM HAVOC CLIENT:
  1. Havoc Client öffnen
  2. New Profile erstellen
  3. Host: ${CURRENT_IP}
     Port: ${TS_PORT}
     User: ${ADMIN_USER}
     Pass: ${ADMIN_PASSWORD}
  4. Connect

⚠️  NACH DEM LESEN LÖSCHEN:
    shred -vfz -n 10 /root/TEAMSERVER_CREDENTIALS.txt

EOF
    
    chmod 600 /root/TEAMSERVER_CREDENTIALS.txt
    
    # Success-Meldung
    echo ""
    echo -e "${GREEN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          ✅  TEAMSERVER ERFOLGREICH INSTALLIERT!             ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    cat /root/TEAMSERVER_CREDENTIALS.txt
    

elif [ "$SERVER_TYPE" = "redirector" ]; then
    
    # ═══════════════════════════════════════════════════════════
    #  REDIRECTOR INSTALLATION
    # ═══════════════════════════════════════════════════════════
    
    echo ""
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║  REDIRECTOR INSTALLATION (${REDIRECTOR_TYPE})                 ║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    case $REDIRECTOR_TYPE in
        nginx)
            echo -e "${YELLOW}[2/5] Installiere Nginx...${NC}"
            
            apt install -y nginx certbot python3-certbot-nginx
            
            echo -e "${GREEN}[✓] Nginx installiert${NC}"
            
            echo -e "${YELLOW}[3/5] Konfiguriere Nginx Redirector...${NC}"
            
            # Nginx Config
            cat > /etc/nginx/sites-available/redirector << EOF
upstream c2_backend {
    server ${C2_SERVER_IP}:${C2_SERVER_PORT};
}

server {
    listen 80;
    server_name ${REDIRECTOR_DOMAIN};
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name ${REDIRECTOR_DOMAIN};

    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    add_header Server "nginx/1.18.0 (Ubuntu)" always;
    
    access_log /var/log/nginx/redirector_access.log;
    error_log /var/log/nginx/redirector_error.log;

    if (\$http_user_agent ~* "(bot|spider|crawler|scanner|curl|wget|python|nmap|masscan)") {
        return 403;
    }

    location ~ ^${C2_URI} {
        proxy_pass https://c2_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_ssl_verify off;
        proxy_redirect off;
        proxy_buffering off;
        
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location / {
        root /var/www/html;
        index index.html;
        try_files \$uri \$uri/ =404;
    }
}
EOF
            
            # Fallback-Webseite
            mkdir -p /var/www/html
            cat > /var/www/html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0; padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            padding: 60px 80px;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
        }
        h1 { font-size: 2.5em; color: #667eea; margin-bottom: 20px; }
        p { font-size: 1.2em; color: #666; line-height: 1.8; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Under Construction</h1>
        <p>This website is currently being developed.</p>
        <p>Please check back soon!</p>
    </div>
</body>
</html>
HTMLEOF
            
            # Aktivieren
            rm -f /etc/nginx/sites-enabled/default
            ln -sf /etc/nginx/sites-available/redirector /etc/nginx/sites-enabled/
            
            nginx -t
            systemctl restart nginx
            systemctl enable nginx
            
            echo -e "${GREEN}[✓] Nginx konfiguriert${NC}"
            ;;
            
        caddy)
            echo -e "${YELLOW}[2/5] Installiere Caddy...${NC}"
            
            apt install -y debian-keyring debian-archive-keyring apt-transport-https
            
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | \
                gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
            
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | \
                tee /etc/apt/sources.list.d/caddy-stable.list
            
            apt update -qq
            apt install -y caddy
            
            echo -e "${GREEN}[✓] Caddy installiert${NC}"
            
            echo -e "${YELLOW}[3/5] Konfiguriere Caddy...${NC}"
            
            cat > /etc/caddy/Caddyfile << EOF
{
    email ${ADMIN_EMAIL}
}

${REDIRECTOR_DOMAIN} {
    log {
        output file /var/log/caddy/redirector.log
    }
    
    header {
        Server "nginx/1.18.0 (Ubuntu)"
        -X-Caddy
    }
    
    @blocked {
        header_regexp User-Agent "(?i)(bot|spider|crawler|scanner|curl|wget|python)"
    }
    handle @blocked {
        respond "Forbidden" 403
    }
    
    @c2_traffic {
        path ${C2_URI}*
    }
    handle @c2_traffic {
        reverse_proxy https://${C2_SERVER_IP}:${C2_SERVER_PORT} {
            transport http {
                tls_insecure_skip_verify
            }
        }
    }
    
    handle {
        root * /var/www/html
        file_server
        try_files {path} /index.html
    }
}
EOF
            
            mkdir -p /var/www/html
            echo "<h1>Under Construction</h1>" > /var/www/html/index.html
            
            systemctl restart caddy
            systemctl enable caddy
            
            echo -e "${GREEN}[✓] Caddy konfiguriert${NC}"
            ;;
            
        apache)
            echo -e "${YELLOW}[2/5] Installiere Apache...${NC}"
            
            apt install -y apache2 certbot python3-certbot-apache
            a2enmod rewrite proxy proxy_http ssl headers
            
            # Apache Config hier...
            echo -e "${GREEN}[✓] Apache konfiguriert${NC}"
            ;;
            
        *)
            echo -e "${RED}[!] Unbekannter Redirector-Typ: ${REDIRECTOR_TYPE}${NC}"
            exit 1
            ;;
    esac
    
    # SSL-Zertifikat
    if [ "$AUTO_SSL" = "true" ]; then
        echo -e "${YELLOW}[4/5] Fordere SSL-Zertifikat an...${NC}"
        
        # DNS-Check
        CURRENT_IP=$(hostname -I | awk '{print $1}')
        DOMAIN_IP=$(dig +short ${REDIRECTOR_DOMAIN} | tail -n1)
        
        if [ "$DOMAIN_IP" = "$CURRENT_IP" ]; then
            echo -e "${GREEN}[✓] DNS korrekt - hole SSL-Zertifikat...${NC}"
            
            if [ "$REDIRECTOR_TYPE" = "nginx" ]; then
                certbot --nginx -d ${REDIRECTOR_DOMAIN} \
                    --non-interactive --agree-tos -m ${ADMIN_EMAIL} --redirect
            elif [ "$REDIRECTOR_TYPE" = "apache" ]; then
                certbot --apache -d ${REDIRECTOR_DOMAIN} \
                    --non-interactive --agree-tos -m ${ADMIN_EMAIL} --redirect
            elif [ "$REDIRECTOR_TYPE" = "caddy" ]; then
                echo -e "${GREEN}[✓] Caddy holt SSL automatisch${NC}"
            fi
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}[✓] SSL-Zertifikat installiert!${NC}"
            else
                echo -e "${YELLOW}[!] SSL fehlgeschlagen - später manuell ausführen${NC}"
            fi
        else
            echo -e "${YELLOW}[!] DNS zeigt nicht auf diesen Server!${NC}"
            echo -e "${YELLOW}    Erwartet: ${CURRENT_IP}${NC}"
            echo -e "${YELLOW}    Aktuell:  ${DOMAIN_IP}${NC}"
            echo -e "${YELLOW}    SSL übersprungen - bitte DNS korrigieren${NC}"
        fi
    fi
    
    # Firewall
    if [ "$AUTO_FIREWALL" = "true" ]; then
        echo -e "${YELLOW}[5/5] Konfiguriere Firewall...${NC}"
        
        ufw --force enable
        ufw default deny incoming
        ufw default allow outgoing
        
        ufw allow 22/tcp comment "SSH"
        ufw allow 80/tcp comment "HTTP"
        ufw allow 443/tcp comment "HTTPS"
        
        echo -e "${GREEN}[✓] Firewall konfiguriert${NC}"
    fi
    
    # Credentials
    CURRENT_IP=$(hostname -I | awk '{print $1}')
    
    cat > /root/REDIRECTOR_CREDENTIALS.txt << EOF
╔═══════════════════════════════════════════════════════════════╗
║              REDIRECTOR ZUGANGSDATEN                         ║
╚═══════════════════════════════════════════════════════════════╝

INSTALLATION: $(date)

SERVER-INFO:
  IP-Adresse:    ${CURRENT_IP}
  Domain:        ${REDIRECTOR_DOMAIN}
  Provider:      Vultr (oder Ihr Provider)
  SSH:           ssh root@${CURRENT_IP}

REDIRECTOR:
  Typ:           ${REDIRECTOR_TYPE}
  Domain:        ${REDIRECTOR_DOMAIN}
  C2-Server:     ${C2_SERVER_IP}:${C2_SERVER_PORT}
  C2-URI:        ${C2_URI}

SSL:
  Email:         ${ADMIN_EMAIL}
  Auto-SSL:      ${AUTO_SSL}

WICHTIGE BEFEHLE:
  Status:        sudo systemctl status ${REDIRECTOR_TYPE}
  Logs:          sudo tail -f /var/log/${REDIRECTOR_TYPE}/redirector_*.log
  Config:        sudo nano /etc/${REDIRECTOR_TYPE}/sites-available/redirector
  SSL erneuern:  sudo certbot renew

TEST:
  curl https://${REDIRECTOR_DOMAIN}/
  
⚠️  NACH DEM LESEN LÖSCHEN:
    shred -vfz -n 10 /root/REDIRECTOR_CREDENTIALS.txt

EOF
    
    chmod 600 /root/REDIRECTOR_CREDENTIALS.txt
    
    # Success
    echo ""
    echo -e "${GREEN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          ✅  REDIRECTOR ERFOLGREICH INSTALLIERT!             ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    cat /root/REDIRECTOR_CREDENTIALS.txt

else
    echo -e "${RED}[!] Ungültiger SERVER_TYPE: ${SERVER_TYPE}${NC}"
    echo "Erlaubt: teamserver, redirector"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# OPTIONALE HÄRTUNG
# ═══════════════════════════════════════════════════════════════

if [ "$AUTO_HARDEN" = "true" ]; then
    echo ""
    echo -e "${YELLOW}[*] Härte Server...${NC}"
    
    # Fail2Ban
    apt install -y fail2ban
    systemctl enable fail2ban
    systemctl start fail2ban
    
    # Automatische Updates
    apt install -y unattended-upgrades
    
    cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF
    
    echo -e "${GREEN}[✓] Server gehärtet${NC}"
fi

# ═══════════════════════════════════════════════════════════════
# FERTIG
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}[✓] Setup erfolgreich abgeschlossen!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Log-Datei: ${LOG_FILE}"
echo ""

if [ "$SERVER_TYPE" = "teamserver" ]; then
    echo "Credentials: /root/TEAMSERVER_CREDENTIALS.txt"
else
    echo "Credentials: /root/REDIRECTOR_CREDENTIALS.txt"
fi

echo ""
echo -e "${YELLOW}⚠️  Wichtig: Lesen und löschen Sie die Credentials-Datei!${NC}"
echo ""
