#!/bin/bash
#
# Traefik Redirector - Automatische Installation & Konfiguration
#
# Verwendung: sudo bash install_redirector_traefik.sh
#
# Beschreibung: Installiert Traefik als C2-Redirector mit automatischem SSL
#

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       Traefik C2 Redirector - Automatische Installation      ║"
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

echo -e "${GREEN}[+] Installiere Dependencies...${NC}"
apt install -y curl ufw net-tools

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

# Traefik herunterladen
echo -e "${GREEN}[+] Lade Traefik herunter...${NC}"
TRAEFIK_VERSION="v2.10"
wget -q https://github.com/traefik/traefik/releases/download/${TRAEFIK_VERSION}/traefik_${TRAEFIK_VERSION}_linux_amd64.tar.gz -O /tmp/traefik.tar.gz

tar -xzf /tmp/traefik.tar.gz -C /tmp
mv /tmp/traefik /usr/local/bin/
chmod +x /usr/local/bin/traefik
rm /tmp/traefik.tar.gz

echo -e "${GREEN}[+] Erstelle Traefik-Benutzer...${NC}"
useradd -r -s /bin/false -d /etc/traefik traefik || true

echo -e "${GREEN}[+] Erstelle Verzeichnisse...${NC}"
mkdir -p /etc/traefik
mkdir -p /etc/traefik/conf.d
mkdir -p /etc/traefik/acme
mkdir -p /var/log/traefik
mkdir -p /var/www/html

chown -R traefik:traefik /etc/traefik
chown -R traefik:traefik /var/log/traefik

# Statische Konfiguration
echo -e "${GREEN}[+] Erstelle Traefik-Konfiguration...${NC}"

cat > /etc/traefik/traefik.yml << EOF
# Traefik Static Configuration

global:
  checkNewVersion: false
  sendAnonymousUsage: false

log:
  level: INFO
  filePath: /var/log/traefik/traefik.log
  format: json

accessLog:
  filePath: /var/log/traefik/access.log
  format: json
  fields:
    headers:
      defaultMode: keep

api:
  dashboard: false
  insecure: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  
  websecure:
    address: ":443"
    http:
      middlewares:
        - security-headers@file
        - block-scanners@file

providers:
  file:
    directory: /etc/traefik/conf.d
    watch: true

certificatesResolvers:
  letsencrypt:
    acme:
      email: ${ADMIN_EMAIL}
      storage: /etc/traefik/acme/acme.json
      httpChallenge:
        entryPoint: web
EOF

# Dynamische Konfiguration - Middlewares
cat > /etc/traefik/conf.d/middlewares.yml << 'EOF'
# Middlewares

http:
  middlewares:
    # Security Headers
    security-headers:
      headers:
        customResponseHeaders:
          Server: "nginx/1.18.0 (Ubuntu)"
          X-Powered-By: "PHP/7.4.3"
        browserXssFilter: true
        contentTypeNosniff: true
        frameDeny: false
        sslRedirect: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 31536000
    
    # Block Scanner/Bot User-Agents
    block-scanners:
      plugin:
        blockUserAgent:
          regex:
            - "(?i)(bot|spider|crawler|scanner|curl|wget|python|nmap|masscan)"
    
    # Rate Limiting
    rate-limit:
      rateLimit:
        average: 100
        burst: 50
        period: 1m
EOF

# Dynamische Konfiguration - Routers
cat > /etc/traefik/conf.d/routers.yml << EOF
# Routers and Services

http:
  routers:
    # C2 Traffic Router
    c2-router:
      rule: "Host(\`${DOMAIN}\`) && PathPrefix(\`${C2_URI}\`)"
      service: c2-service
      entryPoints:
        - websecure
      tls:
        certResolver: letsencrypt
      middlewares:
        - security-headers
        - block-scanners
    
    # Fallback Router (normale Webseite)
    fallback-router:
      rule: "Host(\`${DOMAIN}\`)"
      service: fallback-service
      entryPoints:
        - websecure
      tls:
        certResolver: letsencrypt
      middlewares:
        - security-headers
      priority: 1

  services:
    # C2 Backend
    c2-service:
      loadBalancer:
        servers:
          - url: "https://${C2_IP}:${C2_PORT}"
        serversTransport: insecure-transport
    
    # Fallback (Static Files)
    fallback-service:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:8080"

  serversTransports:
    insecure-transport:
      insecureSkipVerify: true
EOF

# Fallback Web-Server (Python HTTP)
echo -e "${GREEN}[+] Erstelle Fallback-Webseite...${NC}"

cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Business Solutions Provider">
    <title>Business Solutions</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(120deg, #84fab0 0%, #8fd3f4 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            padding: 60px;
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0,0,0,0.2);
            max-width: 700px;
            text-align: center;
            animation: slideIn 0.8s ease-out;
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        h1 {
            font-size: 3em;
            margin-bottom: 20px;
            background: linear-gradient(120deg, #84fab0, #8fd3f4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        p {
            font-size: 1.3em;
            line-height: 1.8;
            color: #555;
            margin-bottom: 20px;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-top: 40px;
        }
        .feature {
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
        }
        .feature-icon {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏢 Business Solutions</h1>
        <p>We provide enterprise-grade solutions for modern businesses.</p>
        <p>Our platform is currently undergoing scheduled maintenance.</p>
        <div class="features">
            <div class="feature">
                <div class="feature-icon">🔒</div>
                <strong>Secure</strong>
            </div>
            <div class="feature">
                <div class="feature-icon">⚡</div>
                <strong>Fast</strong>
            </div>
            <div class="feature">
                <div class="feature-icon">📊</div>
                <strong>Reliable</strong>
            </div>
        </div>
        <p style="margin-top: 40px; font-size: 0.9em; color: #999;">
            © 2026 Business Solutions Inc.
        </p>
    </div>
</body>
</html>
EOF

# Python HTTP Server als systemd service
cat > /etc/systemd/system/fallback-web.service << 'EOF'
[Unit]
Description=Fallback Web Server
After=network.target

[Service]
Type=simple
User=traefik
WorkingDirectory=/var/www/html
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Traefik systemd Service
cat > /etc/systemd/system/traefik.service << 'EOF'
[Unit]
Description=Traefik Reverse Proxy
Documentation=https://traefik.io
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=traefik
Group=traefik
ExecStart=/usr/local/bin/traefik --configFile=/etc/traefik/traefik.yml
Restart=on-failure
RestartSec=5
LimitNOFILE=1048576
PrivateTmp=true
PrivateDevices=false
ProtectHome=true
ProtectSystem=full
ReadWritePaths=/etc/traefik/acme
ReadWritePaths=/var/log/traefik
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# ACME Storage-Datei erstellen
touch /etc/traefik/acme/acme.json
chmod 600 /etc/traefik/acme/acme.json
chown traefik:traefik /etc/traefik/acme/acme.json

echo -e "${GREEN}[+] Aktiviere Services...${NC}"
systemctl daemon-reload
systemctl enable fallback-web
systemctl start fallback-web
systemctl enable traefik
systemctl start traefik

echo -e "${GREEN}[+] Konfiguriere Firewall...${NC}"
ufw --force enable
ufw allow 80/tcp comment "HTTP"
ufw allow 443/tcp comment "HTTPS"
ufw allow 22/tcp comment "SSH"

echo -e "${GREEN}[+] Prüfe DNS-Record...${NC}"
CURRENT_IP=$(hostname -I | awk '{print $1}')
DOMAIN_IP=$(dig +short ${DOMAIN} 2>/dev/null | tail -n1)

if [ -z "$DOMAIN_IP" ]; then
    echo -e "${YELLOW}[!] Warnung: DNS-Record nicht gefunden!${NC}"
    echo -e "${YELLOW}    Erstellen Sie: ${DOMAIN} → ${CURRENT_IP}${NC}"
elif [ "$DOMAIN_IP" != "$CURRENT_IP" ]; then
    echo -e "${YELLOW}[!] DNS-Record zeigt auf: ${DOMAIN_IP}${NC}"
    echo -e "${YELLOW}    Sollte sein: ${CURRENT_IP}${NC}"
else
    echo -e "${GREEN}[✓] DNS-Record korrekt${NC}"
fi

sleep 5

if systemctl is-active traefik >/dev/null 2>&1; then
    echo -e "${GREEN}[✓] Traefik läuft erfolgreich${NC}"
else
    echo -e "${RED}[!] Traefik läuft nicht!${NC}"
    echo -e "${YELLOW}Logs: sudo journalctl -u traefik -n 50${NC}"
fi

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                Installation abgeschlossen!                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}[✓] Traefik Redirector installiert${NC}"
echo ""
echo -e "${YELLOW}Konfigurationsinformationen:${NC}"
echo "  Domain: ${DOMAIN}"
echo "  Server-IP: ${CURRENT_IP}"
echo "  C2-Server: ${C2_IP}:${C2_PORT}"
echo "  C2-URI: ${C2_URI}"
echo ""
echo -e "${YELLOW}Traefik Features:${NC}"
echo "  ✅ Automatisches HTTPS (Let's Encrypt)"
echo "  ✅ Automatische Zertifikatserneuerung"
echo "  ✅ Load Balancing & Failover"
echo "  ✅ Real-time Config Updates"
echo "  ✅ Middlewares für Security"
echo ""
echo -e "${YELLOW}Wichtige Dateien:${NC}"
echo "  Config (Static):  /etc/traefik/traefik.yml"
echo "  Config (Dynamic): /etc/traefik/conf.d/*.yml"
echo "  Logs:             /var/log/traefik/"
echo "  SSL Certs:        /etc/traefik/acme/acme.json"
echo ""
echo -e "${YELLOW}Wichtige Kommandos:${NC}"
echo "  Status:      sudo systemctl status traefik"
echo "  Restart:     sudo systemctl restart traefik"
echo "  Logs (Live): sudo journalctl -u traefik -f"
echo "  Access Logs: sudo tail -f /var/log/traefik/access.log"
echo ""
echo -e "${YELLOW}Konfiguration anpassen:${NC}"
echo "  1. Edit: sudo nano /etc/traefik/conf.d/routers.yml"
echo "  2. Traefik lädt automatisch neu (file watcher)"
echo ""
echo -e "${YELLOW}Test:${NC}"
echo "  curl http://${DOMAIN}/ (→ HTTPS Redirect)"
echo "  curl https://${DOMAIN}/"
echo ""
