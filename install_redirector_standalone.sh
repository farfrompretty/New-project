#!/usr/bin/env bash
#
# STANDALONE REDIRECTOR INSTALLATION (NGINX)
# Benötigt KEINE externe Config-Datei!
#
# VERWENDUNG:
#   wget https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_redirector_standalone.sh
#   sudo bash install_redirector_standalone.sh
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
echo "║          NGINX REDIRECTOR - AUTO-INSTALLATION               ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Eingaben sammeln
echo "[?] Konfiguration (3 Fragen):"
echo ""

read -p "1. Ihre Domain (z.B. cdn.example.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo "[!] Domain ist erforderlich!"
    exit 1
fi

read -p "2. Teamserver-IP (z.B. 49.12.34.56): " C2_IP
if [ -z "$C2_IP" ]; then
    echo "[!] Teamserver-IP ist erforderlich!"
    exit 1
fi

read -p "3. Email (für SSL): " EMAIL
EMAIL=${EMAIL:-admin@${DOMAIN}}

echo ""
echo "[+] Setup startet in 3 Sekunden..."
sleep 3

# System-Update
echo "[1/5] Aktualisiere System..."
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt upgrade -y -qq

# Nginx installieren
echo "[2/5] Installiere Nginx..."
apt install -y nginx certbot python3-certbot-nginx ufw

# Konfiguration
echo "[3/5] Konfiguriere Nginx..."

cat > /etc/nginx/sites-available/redirector << 'ENDNGINX'
upstream c2_backend {
    server C2_IP_PLACEHOLDER:443;
}

server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name DOMAIN_PLACEHOLDER;

    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    add_header Server "nginx/1.18.0" always;
    
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    if ($http_user_agent ~* "(bot|spider|crawler|scanner|curl|wget|python|nmap)") {
        return 403;
    }

    location ~ ^/api {
        proxy_pass https://c2_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_ssl_verify off;
        proxy_buffering off;
        
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location / {
        root /var/www/html;
        index index.html;
    }
}
ENDNGINX

# Platzhalter ersetzen
sed -i "s|DOMAIN_PLACEHOLDER|${DOMAIN}|g" /etc/nginx/sites-available/redirector
sed -i "s|C2_IP_PLACEHOLDER|${C2_IP}|g" /etc/nginx/sites-available/redirector

# Webseite
mkdir -p /var/www/html
cat > /var/www/html/index.html << 'ENDHTML'
<!DOCTYPE html>
<html>
<head><title>Welcome</title>
<style>body{margin:0;padding:0;font-family:Arial;background:linear-gradient(135deg,#667eea,#764ba2);min-height:100vh;display:flex;align-items:center;justify-content:center}.box{background:#fff;padding:60px;border-radius:15px;box-shadow:0 20px 60px rgba(0,0,0,.3);text-align:center}h1{color:#667eea;font-size:2.5em}</style>
</head>
<body><div class="box"><h1>🚀 Under Construction</h1><p>Check back soon!</p></div></body>
</html>
ENDHTML

# Aktivieren
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/redirector /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# Firewall
echo "[4/5] Konfiguriere Firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# SSL
echo "[5/5] Fordere SSL-Zertifikat an..."

CURRENT_IP=$(hostname -I | awk '{print $1}')
DOMAIN_IP=$(dig +short ${DOMAIN} 2>/dev/null | tail -n1)

if [ "$DOMAIN_IP" = "$CURRENT_IP" ]; then
    certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${EMAIL} --redirect || echo "[!] SSL fehlgeschlagen - später nachholen"
else
    echo "[!] DNS zeigt nicht auf diesen Server - SSL übersprungen"
    echo "    Erwartet: $CURRENT_IP"
    echo "    DNS zeigt: $DOMAIN_IP"
fi

# Fertig
clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          ✅  REDIRECTOR INSTALLIERT!                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Domain:     $DOMAIN"
echo "IP:         $CURRENT_IP"
echo "C2-Server:  $C2_IP:443"
echo ""
echo "TEST:"
echo "  curl https://$DOMAIN/"
echo ""

cat > /root/REDIRECTOR_INFO.txt << ENDINFO
REDIRECTOR INFO
===============
Domain:   $DOMAIN
IP:       $CURRENT_IP
C2:       $C2_IP:443
Email:    $EMAIL
Datum:    $(date)

Test: curl https://$DOMAIN/
ENDINFO

chmod 600 /root/REDIRECTOR_INFO.txt
echo "Info gespeichert: /root/REDIRECTOR_INFO.txt"
echo ""
