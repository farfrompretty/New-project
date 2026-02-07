# SSL/TLS Zertifikat-Setup für C2-Infrastruktur

> **Ziel:** Gültige, vertrauenswürdige SSL/TLS-Zertifikate für maximale OPSEC und um Detection zu vermeiden.

---

## 📋 Inhaltsverzeichnis

1. [Warum gültige SSL-Zertifikate?](#warum-gültige-ssl-zertifikate)
2. [Let's Encrypt (Kostenlos & Empfohlen)](#lets-encrypt-kostenlos--empfohlen)
3. [Kommerzielle Zertifikate](#kommerzielle-zertifikate)
4. [Self-Signed Zertifikate (Nur für Tests)](#self-signed-zertifikate-nur-für-tests)
5. [Automatische Erneuerung](#automatische-erneuerung)
6. [Havoc C2 SSL-Konfiguration](#havoc-c2-ssl-konfiguration)

---

## Warum gültige SSL-Zertifikate?

**Self-Signed vs. Gültig:**

| Aspekt | Self-Signed | Let's Encrypt | Kommerziell |
|--------|-------------|---------------|-------------|
| **Kosten** | Kostenlos | Kostenlos | €50-500/Jahr |
| **Browser-Warnung** | ⚠️ Ja | ✅ Nein | ✅ Nein |
| **EDR/AV Detection** | 🔴 Hoch | 🟢 Niedrig | 🟢 Niedrig |
| **Proxy-Kompatibilität** | ❌ Oft blockiert | ✅ Funktioniert | ✅ Funktioniert |
| **OPSEC** | ❌ Schlecht | ✅ Gut | ✅ Sehr gut |

**Fazit:** Nutzen Sie **IMMER** gültige Zertifikate für echte Engagements!

---

## Let's Encrypt (Kostenlos & Empfohlen)

### Voraussetzungen

1. **Domain:** Sie benötigen eine registrierte Domain
2. **DNS:** A-Record muss auf Ihre Server-IP zeigen
3. **Port 80:** Muss für HTTP-01 Challenge erreichbar sein (temporär)

### Option 1: Certbot (Einfach)

#### Schritt 1: Certbot installieren

**Ubuntu/Debian:**

```bash
sudo apt update
sudo apt install certbot python3-certbot-apache -y
```

Oder für Nginx:

```bash
sudo apt install certbot python3-certbot-nginx -y
```

#### Schritt 2: Zertifikat anfordern (Apache)

```bash
sudo certbot --apache -d ihre-domain.com -d www.ihre-domain.com
```

**Interaktive Fragen:**
1. **Email:** Ihre E-Mail-Adresse (für Ablauf-Benachrichtigungen)
2. **Terms of Service:** Akzeptieren Sie mit `A`
3. **Redirect HTTP → HTTPS:** Empfohlen `2` (Redirect)

#### Schritt 3: Zertifikat anfordern (Nginx)

```bash
sudo certbot --nginx -d ihre-domain.com -d www.ihre-domain.com
```

#### Schritt 4: Standalone-Modus (ohne Webserver)

Wenn Sie certbot VOR dem Webserver-Setup ausführen möchten:

```bash
sudo certbot certonly --standalone -d ihre-domain.com -d www.ihre-domain.com
```

**⚠️ Wichtig:** Port 80 muss frei sein!

Zertifikate werden gespeichert unter:
```
/etc/letsencrypt/live/ihre-domain.com/
  ├── fullchain.pem (Zertifikat + Chain)
  ├── privkey.pem (Private Key)
  ├── cert.pem (Nur Zertifikat)
  └── chain.pem (Nur Chain)
```

---

### Option 2: DNS-01 Challenge (Fortgeschritten)

**Vorteil:** Keine Port 80/443 erforderlich, funktioniert hinter Firewall.

#### Für Cloudflare:

```bash
# Cloudflare Plugin installieren
sudo apt install python3-certbot-dns-cloudflare -y

# Cloudflare API-Token erstellen (auf cloudflare.com)
# Benötigte Permissions: Zone:DNS:Edit

# Credentials-Datei erstellen
sudo nano /root/.secrets/cloudflare.ini
```

Inhalt:

```ini
# Cloudflare API Token
dns_cloudflare_api_token = Ihr_Cloudflare_API_Token_Hier
```

Datei absichern:

```bash
sudo chmod 600 /root/.secrets/cloudflare.ini
```

Zertifikat anfordern:

```bash
sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
  -d ihre-domain.com \
  -d '*.ihre-domain.com'  # Wildcard möglich!
```

#### Für andere DNS-Provider:

- **AWS Route53:** `python3-certbot-dns-route53`
- **DigitalOcean:** `python3-certbot-dns-digitalocean`
- **Google Cloud DNS:** `python3-certbot-dns-google`
- **Hetzner:** `python3-certbot-dns-hetzner`

Liste: https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins

---

### Option 3: acme.sh (Alternative zu Certbot)

```bash
# Installation
curl https://get.acme.sh | sh
source ~/.bashrc

# Zertifikat mit HTTP-Validierung
acme.sh --issue -d ihre-domain.com -w /var/www/html

# Zertifikat mit DNS-Validierung (Cloudflare)
export CF_Token="Ihr_Cloudflare_API_Token"
acme.sh --issue --dns dns_cf -d ihre-domain.com -d '*.ihre-domain.com'

# Zertifikate nach Apache/Nginx kopieren
acme.sh --install-cert -d ihre-domain.com \
  --cert-file /etc/ssl/certs/ihre-domain.com.crt \
  --key-file /etc/ssl/private/ihre-domain.com.key \
  --fullchain-file /etc/ssl/certs/ihre-domain.com.fullchain.crt \
  --reloadcmd "systemctl reload apache2"
```

---

## Kommerzielle Zertifikate

### Wann kommerzielle Zertifikate?

**Vorteile:**
- ✅ Extended Validation (EV) möglich (grüne Adressleiste)
- ✅ Längere Gültigkeit (1 Jahr statt 90 Tage)
- ✅ Weniger Erneuerungen = weniger Fehlerquellen
- ✅ Besser für langfristige Operationen
- ✅ Multi-Domain (SAN) Zertifikate

**Empfohlene Anbieter (Budget-freundlich):**

| Anbieter | Preis/Jahr | Besonderheiten |
|----------|-----------|----------------|
| **Namecheap** | €5-10 | Günstig, schnell |
| **SSLs.com** | €7-15 | Gute Support |
| **GoGetSSL** | €5-12 | Viele Provider |
| **DigiCert** | €200+ | EV, Enterprise |
| **Sectigo** | €50+ | Etabliert, vertrauenswürdig |

### Bestellung & Installation

#### Schritt 1: CSR (Certificate Signing Request) erstellen

```bash
# Private Key generieren
openssl genrsa -out ihre-domain.com.key 2048

# CSR erstellen
openssl req -new -key ihre-domain.com.key -out ihre-domain.com.csr
```

**Informationen angeben:**
- Country Name: `DE`
- State: `Bavaria`
- Locality: `Munich`
- Organization: `Your Company GmbH`
- Common Name: `ihre-domain.com`
- Email: `admin@ihre-domain.com`

#### Schritt 2: CSR beim Anbieter einreichen

Kopieren Sie den Inhalt von `ihre-domain.com.csr` und geben Sie ihn bei Ihrem Zertifikatsanbieter ein.

#### Schritt 3: Domain-Validierung

Die meisten Anbieter senden eine Email an:
- `admin@ihre-domain.com`
- `webmaster@ihre-domain.com`
- `postmaster@ihre-domain.com`

Oder Sie müssen eine Datei auf Ihrem Webserver platzieren.

#### Schritt 4: Zertifikat erhalten & installieren

Sie erhalten per Email:
- `ihre-domain.com.crt` (Ihr Zertifikat)
- `bundle.crt` oder `ca-bundle.crt` (Intermediate Certificates)

**Installation Apache:**

```bash
# Dateien kopieren
sudo cp ihre-domain.com.crt /etc/ssl/certs/
sudo cp ihre-domain.com.key /etc/ssl/private/
sudo cp bundle.crt /etc/ssl/certs/

# Berechtigungen setzen
sudo chmod 644 /etc/ssl/certs/ihre-domain.com.crt
sudo chmod 600 /etc/ssl/private/ihre-domain.com.key
sudo chmod 644 /etc/ssl/certs/bundle.crt
```

**Apache VHost-Konfiguration:**

```apache
<VirtualHost *:443>
    ServerName ihre-domain.com
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/ihre-domain.com.crt
    SSLCertificateKeyFile /etc/ssl/private/ihre-domain.com.key
    SSLCertificateChainFile /etc/ssl/certs/bundle.crt
    
    # ... restliche Konfiguration
</VirtualHost>
```

**Nginx Konfiguration:**

```nginx
server {
    listen 443 ssl;
    server_name ihre-domain.com;
    
    ssl_certificate /etc/ssl/certs/ihre-domain.com.crt;
    ssl_certificate_key /etc/ssl/private/ihre-domain.com.key;
    
    # ... restliche Konfiguration
}
```

Webserver neu laden:

```bash
sudo systemctl reload apache2
# oder
sudo systemctl reload nginx
```

---

## Self-Signed Zertifikate (Nur für Tests)

**⚠️ NUR für interne Labs verwenden!**

### Generierung

```bash
# Private Key erstellen
openssl genrsa -out selfsigned.key 2048

# Self-Signed Zertifikat erstellen (gültig 365 Tage)
openssl req -new -x509 -key selfsigned.key -out selfsigned.crt -days 365

# Oder in einem Befehl:
openssl req -x509 -newkey rsa:4096 -keyout selfsigned.key -out selfsigned.crt -days 365 -nodes
```

### Installation (für Test-Teamserver)

```bash
sudo mkdir -p /opt/Havoc/ssl
sudo cp selfsigned.crt /opt/Havoc/ssl/
sudo cp selfsigned.key /opt/Havoc/ssl/
sudo chmod 600 /opt/Havoc/ssl/selfsigned.key
```

---

## Automatische Erneuerung

### Let's Encrypt Auto-Renewal

Certbot installiert automatisch einen systemd-Timer oder Cronjob.

**Prüfen ob Timer aktiv ist:**

```bash
sudo systemctl status certbot.timer
```

**Manuell testen:**

```bash
sudo certbot renew --dry-run
```

**Manuell erneuern:**

```bash
sudo certbot renew
```

### Erneuerung mit Webserver-Reload

Erstellen Sie ein Renewal-Hook-Script:

```bash
sudo nano /etc/letsencrypt/renewal-hooks/deploy/reload-services.sh
```

Inhalt:

```bash
#!/bin/bash

# Apache neu laden
systemctl reload apache2

# Optional: Havoc Teamserver neu laden
# systemctl restart havoc-teamserver

# Logging
echo "$(date): SSL certificates renewed and services reloaded" >> /var/log/certbot-renewal.log
```

Ausführbar machen:

```bash
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-services.sh
```

### Monitoring der Gültigkeit

**Script erstellen:**

```bash
sudo nano /opt/check-ssl-expiry.sh
```

```bash
#!/bin/bash

DOMAIN="ihre-domain.com"
ALERT_EMAIL="ihre-email@domain.com"
DAYS_WARNING=14

# Ablaufdatum ermitteln
EXPIRY_DATE=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | \
  openssl x509 -noout -enddate | cut -d= -f2)

EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
CURRENT_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))

echo "SSL-Zertifikat für $DOMAIN läuft ab in: $DAYS_LEFT Tagen"

if [ $DAYS_LEFT -lt $DAYS_WARNING ]; then
    echo "WARNUNG: SSL-Zertifikat läuft bald ab!" | \
      mail -s "SSL-Zertifikat Warnung für $DOMAIN" $ALERT_EMAIL
fi
```

Cronjob hinzufügen:

```bash
sudo crontab -e
```

```
0 8 * * * /opt/check-ssl-expiry.sh
```

---

## Havoc C2 SSL-Konfiguration

### Havoc mit Let's Encrypt Zertifikaten

**Option 1: Havoc nutzt Zertifikate direkt**

Bearbeiten Sie Ihre `havoc.yaotl`:

```yaml
Listeners:
  - Name: "Secure HTTPS Listener"
    Protocol: https
    Hosts:
      - "ihre-domain.com"
    Port: 443
    HostBind: 0.0.0.0
    PortBind: 443
    Secure: true
    
    # SSL-Zertifikate
    Cert:
      Cert: "/etc/letsencrypt/live/ihre-domain.com/fullchain.pem"
      Key: "/etc/letsencrypt/live/ihre-domain.com/privkey.pem"
    
    Response:
      Headers:
        Server: "nginx/1.18.0"
        Content-Type: "text/html; charset=UTF-8"
        X-Powered-By: "PHP/7.4.3"
```

**⚠️ Berechtigungen:** Havoc benötigt Lesezugriff auf die Zertifikate:

```bash
# Havoc User zur certbot-Gruppe hinzufügen
sudo usermod -a -G ssl-cert root  # Wenn Havoc als root läuft

# Oder: Zertifikate kopieren
sudo cp /etc/letsencrypt/live/ihre-domain.com/fullchain.pem /opt/Havoc/ssl/
sudo cp /etc/letsencrypt/live/ihre-domain.com/privkey.pem /opt/Havoc/ssl/
sudo chmod 600 /opt/Havoc/ssl/*.pem
```

**Option 2: Reverse Proxy mit SSL-Termination (Empfohlen)**

Lassen Sie Apache/Nginx das SSL handhaben:

```
[Internet] → [Apache/Nginx (Port 443, SSL)] → [Havoc (Port 40443, HTTP)]
```

**Apache-Konfiguration:**

```apache
<VirtualHost *:443>
    ServerName ihre-domain.com
    
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/ihre-domain.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/ihre-domain.com/privkey.pem
    
    # Proxy zu Havoc
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:40443/
    ProxyPassReverse / http://127.0.0.1:40443/
    
    # WebSocket Support
    RewriteEngine on
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/?(.*) "ws://127.0.0.1:40443/$1" [P,L]
</VirtualHost>
```

**Havoc Listener (läuft intern auf HTTP):**

```yaml
Listeners:
  - Name: "Internal HTTP Listener"
    Protocol: http  # Kein HTTPS, da Apache SSL handhabt
    Hosts:
      - "ihre-domain.com"
    Port: 40443
    HostBind: 127.0.0.1  # Nur localhost
    PortBind: 40443
```

**Vorteile:**
- ✅ Einfachere SSL-Verwaltung
- ✅ Automatische Zertifikatserneuerung funktioniert ohne Havoc-Neustart
- ✅ Zusätzliche Traffic-Filterung möglich

---

## SSL/TLS Best Practices

### Sichere Cipher Suites

**Apache (`/etc/apache2/mods-available/ssl.conf`):**

```apache
SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
SSLHonorCipherOrder off
SSLSessionTickets off

# HSTS (optional, aber empfohlen für OPSEC)
Header always set Strict-Transport-Security "max-age=31536000"
```

**Nginx:**

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# HSTS
add_header Strict-Transport-Security "max-age=31536000" always;
```

### SSL-Konfiguration testen

```bash
# Online-Test (nach Deployment)
https://www.ssllabs.com/ssltest/

# Lokal mit testssl.sh
git clone https://github.com/drwetter/testssl.sh.git
cd testssl.sh
./testssl.sh https://ihre-domain.com
```

**Ziel:** Mindestens **A-Rating** auf SSL Labs.

---

## Troubleshooting

### Problem: Certbot Fehler "Port 80 bereits in Benutzung"

**Lösung:**

```bash
# Apache/Nginx temporär stoppen
sudo systemctl stop apache2

# Certbot im Standalone-Modus ausführen
sudo certbot certonly --standalone -d ihre-domain.com

# Apache wieder starten
sudo systemctl start apache2
```

### Problem: "Certificate verification failed"

**Ursache:** Intermediate Certificates fehlen.

**Lösung:**

Nutzen Sie `fullchain.pem` statt `cert.pem`:

```apache
SSLCertificateFile /etc/letsencrypt/live/ihre-domain.com/fullchain.pem
```

### Problem: Havoc kann Zertifikate nicht lesen

**Lösung:**

```bash
# Berechtigungen prüfen
ls -la /etc/letsencrypt/live/ihre-domain.com/

# Zertifikate nach /opt/Havoc kopieren
sudo cp /etc/letsencrypt/live/ihre-domain.com/*.pem /opt/Havoc/ssl/
sudo chown root:root /opt/Havoc/ssl/*.pem
sudo chmod 600 /opt/Havoc/ssl/*.pem
```

### Problem: Rate Limit von Let's Encrypt

**Limits:**
- 50 Zertifikate pro Domain pro Woche
- 5 Duplikate pro Woche

**Lösung:**

Nutzen Sie Staging-Environment zum Testen:

```bash
sudo certbot --staging --apache -d ihre-domain.com
```

---

## Checkliste: SSL/TLS Deployment

- [ ] Domain registriert und DNS konfiguriert (A-Record)
- [ ] Port 80/443 in Firewall geöffnet
- [ ] Certbot/acme.sh installiert
- [ ] Zertifikat erfolgreich angefordert
- [ ] Zertifikate in Apache/Nginx konfiguriert
- [ ] HTTPS funktioniert (Browser-Test ohne Warnung)
- [ ] SSL Labs Test: Mindestens A-Rating
- [ ] Auto-Renewal aktiviert und getestet (`certbot renew --dry-run`)
- [ ] Renewal-Hook für Webserver-Reload konfiguriert
- [ ] Monitoring-Script für Ablaufdatum eingerichtet
- [ ] Havoc C2 nutzt gültige Zertifikate
- [ ] Backup der Zertifikate & Private Keys erstellt

---

## Weitere Ressourcen

- **Let's Encrypt Dokumentation:** https://letsencrypt.org/docs/
- **Certbot Dokumentation:** https://eff-certbot.readthedocs.io/
- **SSL Configuration Generator:** https://ssl-config.mozilla.org/
- **SSL Labs Test:** https://www.ssllabs.com/ssltest/
- **testssl.sh:** https://github.com/drwetter/testssl.sh

---

**Erstellt:** 2026-02-05
**Version:** 1.0
