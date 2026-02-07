#!/bin/bash
#
# Caddy Redirector - Automatische Installation & Konfiguration
#
# Verwendung: sudo bash install_redirector_caddy.sh
#
# Beschreibung: Installiert Caddy als C2-Redirector mit automatischem SSL
#

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Caddy C2 Redirector - Automatische Installation      ║"
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
apt install -y debian-keyring debian-archive-keyring apt-transport-https curl ufw

echo -e "${GREEN}[+] Füge Caddy Repository hinzu...${NC}"
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list

echo -e "${GREEN}[+] Installiere Caddy...${NC}"
apt update -qq
apt install -y caddy

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

# Caddy-Konfiguration erstellen
echo -e "${GREEN}[+] Erstelle Caddy-Konfiguration...${NC}"

cat > /etc/caddy/Caddyfile << EOF
# Caddy C2 Redirector Configuration

{
    email ${ADMIN_EMAIL}
    
    # Security hardening
    servers {
        protocol {
            strict_sni_host
        }
    }
}

${DOMAIN} {
    # Automatisches HTTPS (Let's Encrypt)
    
    # Request-Logging
    log {
        output file /var/log/caddy/redirector.log
        format json
    }
    
    # Header-Manipulation (Tarnung)
    header {
        Server "nginx/1.18.0 (Ubuntu)"
        X-Powered-By "PHP/7.4.3"
        -X-Caddy
    }
    
    # === TRAFFIC FILTERING ===
    
    # Blockiere bekannte Scanner/Bots
    @blocked {
        header_regexp User-Agent "(?i)(bot|spider|crawler|scanner|curl|wget|python|nmap|masscan)"
    }
    
    handle @blocked {
        respond "Forbidden" 403
        abort
    }
    
    # Blockiere Scanner-IPs
    @scanner_ips {
        remote_ip 192.0.2.0/24 198.18.0.0/15 203.0.113.0/24
    }
    
    handle @scanner_ips {
        respond "Forbidden" 403
        abort
    }
    
    # === C2 PROXY RULES ===
    
    # Leite C2-Traffic weiter
    @c2_traffic {
        path ${C2_URI}*
    }
    
    handle @c2_traffic {
        # Reverse Proxy zu C2 Teamserver
        reverse_proxy https://${C2_IP}:${C2_PORT} {
            transport http {
                tls_insecure_skip_verify
            }
            
            # Preserve original headers
            header_up Host {host}
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
            
            # WebSocket support
            header_up Connection {>Connection}
            header_up Upgrade {>Upgrade}
        }
    }
    
    # === FALLBACK: Normale Webseite ===
    
    handle {
        root * /var/www/html
        file_server
        
        # Wenn Datei nicht existiert, zeige index.html
        try_files {path} /index.html
    }
    
    # Error pages
    handle_errors {
        respond "{http.error.status_code} {http.error.status_text}"
    }
}
EOF

echo -e "${GREEN}[+] Erstelle Fallback-Webseite...${NC}"
mkdir -p /var/www/html

cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Corporate website">
    <title>Welcome</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #333;
        }
        .container {
            background: white;
            padding: 60px 80px;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            text-align: center;
            animation: fadeIn 1s ease-in;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        h1 {
            font-size: 2.5em;
            margin-bottom: 20px;
            color: #667eea;
        }
        p {
            font-size: 1.2em;
            line-height: 1.8;
            color: #666;
            margin-bottom: 15px;
        }
        .icon {
            font-size: 4em;
            margin-bottom: 20px;
        }
        .footer {
            margin-top: 40px;
            font-size: 0.9em;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">🚀</div>
        <h1>Under Construction</h1>
        <p>This website is currently being developed.</p>
        <p>We're working hard to bring you something amazing.</p>
        <p>Please check back soon!</p>
        <div class="footer">
            © 2026 Corporate Services
        </div>
    </div>
</body>
</html>
EOF

echo -e "${GREEN}[+] Setze Berechtigungen...${NC}"
chown -R caddy:caddy /var/www/html
chmod -R 755 /var/www/html

echo -e "${GREEN}[+] Log-Verzeichnis erstellen...${NC}"
mkdir -p /var/log/caddy
chown caddy:caddy /var/log/caddy

echo -e "${GREEN}[+] Teste Caddy-Konfiguration...${NC}"
caddy validate --config /etc/caddy/Caddyfile

if [ $? -ne 0 ]; then
    echo -e "${RED}[!] Caddy-Konfiguration ist ungültig!${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Starte Caddy neu...${NC}"
systemctl restart caddy
systemctl enable caddy

echo -e "${GREEN}[+] Konfiguriere Firewall...${NC}"
ufw --force enable
ufw allow 80/tcp comment "HTTP"
ufw allow 443/tcp comment "HTTPS"
ufw allow 22/tcp comment "SSH"

echo -e "${GREEN}[+] Prüfe DNS-Record...${NC}"
CURRENT_IP=$(hostname -I | awk '{print $1}')
DOMAIN_IP=$(dig +short ${DOMAIN} 2>/dev/null | tail -n1)

if [ -z "$DOMAIN_IP" ]; then
    echo -e "${YELLOW}[!] Warnung: DNS-Record für ${DOMAIN} nicht gefunden!${NC}"
    echo -e "${YELLOW}    Bitte erstellen Sie A-Record: ${DOMAIN} → ${CURRENT_IP}${NC}"
elif [ "$DOMAIN_IP" != "$CURRENT_IP" ]; then
    echo -e "${YELLOW}[!] Warnung: DNS-Record zeigt nicht auf diesen Server!${NC}"
    echo -e "${YELLOW}    Erwartet: ${CURRENT_IP}${NC}"
    echo -e "${YELLOW}    Aktuell:  ${DOMAIN_IP}${NC}"
else
    echo -e "${GREEN}[✓] DNS-Record korrekt konfiguriert${NC}"
fi

# Warte auf SSL-Zertifikat
echo -e "${GREEN}[+] Warte auf Let's Encrypt Zertifikat (kann bis zu 60 Sekunden dauern)...${NC}"
sleep 10

# Prüfe Caddy Status
if systemctl is-active caddy >/dev/null 2>&1; then
    echo -e "${GREEN}[✓] Caddy läuft erfolgreich${NC}"
else
    echo -e "${RED}[!] Caddy läuft nicht! Prüfe Logs:${NC}"
    echo -e "${YELLOW}sudo journalctl -u caddy -n 50${NC}"
fi

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                Installation abgeschlossen!                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}[✓] Caddy Redirector installiert und konfiguriert${NC}"
echo ""
echo -e "${YELLOW}Konfigurationsinformationen:${NC}"
echo "  Domain: ${DOMAIN}"
echo "  Server-IP: ${CURRENT_IP}"
echo "  C2-Server: ${C2_IP}:${C2_PORT}"
echo "  C2-URI: ${C2_URI}"
echo ""
echo -e "${YELLOW}Besonderheiten von Caddy:${NC}"
echo "  ✅ Automatisches HTTPS (Let's Encrypt)"
echo "  ✅ Automatische Zertifikatserneuerung"
echo "  ✅ HTTP/2 und HTTP/3 Support"
echo "  ✅ Moderne, einfache Konfiguration"
echo ""
echo -e "${YELLOW}Wichtige Dateien:${NC}"
echo "  Config:    /etc/caddy/Caddyfile"
echo "  Logs:      /var/log/caddy/redirector.log"
echo "  Web:       /var/www/html/"
echo "  SSL Certs: /var/lib/caddy/.local/share/caddy/certificates/"
echo ""
echo -e "${YELLOW}Wichtige Kommandos:${NC}"
echo "  Status:         sudo systemctl status caddy"
echo "  Restart:        sudo systemctl restart caddy"
echo "  Reload Config:  sudo systemctl reload caddy"
echo "  Config Test:    sudo caddy validate --config /etc/caddy/Caddyfile"
echo "  Logs (Live):    sudo journalctl -u caddy -f"
echo "  Access Logs:    sudo tail -f /var/log/caddy/redirector.log"
echo ""
echo -e "${YELLOW}Test:${NC}"
echo "  curl http://${DOMAIN}/ (Redirect zu HTTPS)"
echo "  curl https://${DOMAIN}/"
echo ""
echo -e "${YELLOW}SSL-Zertifikat prüfen:${NC}"
echo "  curl -vI https://${DOMAIN}/ 2>&1 | grep -E '(subject|issuer)'"
echo ""
echo -e "${GREEN}Caddy holt automatisch SSL-Zertifikat von Let's Encrypt!${NC}"
echo -e "${GREEN}Kein manueller certbot-Aufruf notwendig.${NC}"
echo ""
