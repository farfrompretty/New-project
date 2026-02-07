#!/bin/bash
#
# ELITE SPURLOSES SETUP
# Hinterlässt KEINE Spuren auf VPS!
#
# Verwendung:
#   bash elite_spurlos_setup.sh <TEAMSERVER_IP> <REDIRECTOR_IP> <DOMAIN>
#

set -e

TEAMSERVER_IP="$1"
REDIRECTOR_IP="$2"
DOMAIN="$3"

if [ -z "$TEAMSERVER_IP" ] || [ -z "$REDIRECTOR_IP" ] || [ -z "$DOMAIN" ]; then
    echo "Verwendung: bash $0 <TEAMSERVER_IP> <REDIRECTOR_IP> <DOMAIN>"
    exit 1
fi

# Keine lokalen Logs!
exec 2>/dev/null

# SSH ohne Spuren
SSH="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

ADMIN_PASS=$(openssl rand -base64 20 | tr -d '/+=' | head -c 20)

echo "Elite OPSEC Setup - SPURLOS"
echo "Teamserver:  $TEAMSERVER_IP"
echo "Redirector:  $REDIRECTOR_IP"
echo "Domain:      $DOMAIN"
echo "Admin-Pass:  $ADMIN_PASS"
echo ""

# ═══ TEAMSERVER ═══
$SSH root@$TEAMSERVER_IP bash << ENDTEAMSERVER
unset HISTFILE
export HISTSIZE=0
apt update -qq
apt install -y -qq build-essential cmake golang-go mingw-w64 nasm libboost-all-dev libssl-dev git ufw
cd /tmp
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc/teamserver && go mod download
cd /tmp/Havoc && make ts-build
mkdir -p /opt/Havoc && cp -r /tmp/Havoc/* /opt/Havoc/
rm -rf /tmp/Havoc
mkdir -p /opt/Havoc/profiles
cat > /opt/Havoc/profiles/havoc.yaotl << 'EOF'
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
Listeners:
  - Name: "HTTPS"
    Protocol: https
    Hosts:
      - "$DOMAIN"
    Port: 443
    HostBind: 0.0.0.0
    PortBind: 443
    Secure: true
EOF
sed -i "s/\\\$ADMIN_PASS/$ADMIN_PASS/g" /opt/Havoc/profiles/havoc.yaotl
sed -i "s/\\\$DOMAIN/$DOMAIN/g" /opt/Havoc/profiles/havoc.yaotl
cat > /etc/systemd/system/havoc-teamserver.service << 'EOFSVC'
[Unit]
Description=System Service
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=/opt/Havoc
ExecStart=/opt/Havoc/havoc server --profile /opt/Havoc/profiles/havoc.yaotl
StandardOutput=null
StandardError=null
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOFSVC
systemctl daemon-reload
systemctl enable havoc-teamserver
systemctl start havoc-teamserver
ufw --force enable
ufw default deny incoming
ufw allow 22/tcp
ufw allow 40056/tcp
ufw allow from $REDIRECTOR_IP to any port 443
journalctl --vacuum-time=1s
history -c
shred ~/.bash_history
rm -rf /root/.gitconfig /tmp/*
ENDTEAMSERVER

echo "[✓] Teamserver (spurlos)"

# ═══ REDIRECTOR ═══
$SSH root@$REDIRECTOR_IP bash << ENDREDIRECTOR
unset HISTFILE
apt update -qq
apt install -y -qq nginx certbot python3-certbot-nginx ufw
cat > /etc/nginx/sites-available/redirector << 'EOFNG'
upstream c2 {
    server $TEAMSERVER_IP:443;
}
server {
    listen 80;
    server_name $DOMAIN;
    location / { return 301 https://\$server_name\$request_uri; }
}
server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    access_log off;
    error_log /dev/null crit;
    location ~ ^/api {
        proxy_pass https://c2;
        proxy_ssl_verify off;
    }
    location / {
        root /var/www/html;
        index index.html;
    }
}
EOFNG
sed -i "s/\\\$TEAMSERVER_IP/$TEAMSERVER_IP/g" /etc/nginx/sites-available/redirector
sed -i "s/\\\$DOMAIN/$DOMAIN/g" /etc/nginx/sites-available/redirector
mkdir -p /var/www/html && echo "<h1>Library Management</h1>" > /var/www/html/index.html
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/redirector /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx
ufw --force enable
ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN --redirect || true
journalctl --vacuum-time=1s
history -c
shred ~/.bash_history
ENDREDIRECTOR

echo "[✓] Redirector (spurlos)"
echo ""
echo "Admin-Pass: $ADMIN_PASS"
echo "Host: $TEAMSERVER_IP:40056"

# Lokale Spuren löschen
history -c
shred ~/.bash_history 2>/dev/null
