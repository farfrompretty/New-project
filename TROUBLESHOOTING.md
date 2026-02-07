# Troubleshooting & Wartungs-Guide für Havoc C2

> **Ziel:** Lösungen für häufige Probleme und Wartungsanleitungen.

---

## 📋 Inhaltsverzeichnis

1. [Häufige Probleme & Lösungen](#häufige-probleme--lösungen)
2. [Havoc Teamserver Troubleshooting](#havoc-teamserver-troubleshooting)
3. [Redirector Troubleshooting](#redirector-troubleshooting)
4. [SSL/TLS Probleme](#ssltls-probleme)
5. [Netzwerk & Connectivity](#netzwerk--connectivity)
6. [Performance-Optimierung](#performance-optimierung)
7. [Wartungsaufgaben](#wartungsaufgaben)
8. [Monitoring & Alerting](#monitoring--alerting)
9. [Backup & Recovery](#backup--recovery)
10. [Notfall-Prozeduren](#notfall-prozeduren)

---

## Häufige Probleme & Lösungen

### 🔴 Problem: "Connection refused" beim Verbinden zum Teamserver

**Symptome:**
- Havoc Client kann sich nicht verbinden
- Fehlermeldung: "Connection refused" oder "Connection timeout"

**Diagnose:**

```bash
# 1. Ist der Teamserver aktiv?
sudo systemctl status havoc-teamserver

# 2. Läuft der Prozess?
ps aux | grep havoc

# 3. Horcht der Port?
sudo netstat -tlnp | grep 40056

# 4. Firewall-Regeln?
sudo ufw status | grep 40056

# 5. Kann man den Port erreichen?
nc -zv TEAMSERVER_IP 40056
```

**Lösungen:**

**A) Service nicht gestartet:**
```bash
sudo systemctl start havoc-teamserver
sudo systemctl status havoc-teamserver
```

**B) Firewall blockiert:**
```bash
sudo ufw allow 40056/tcp
sudo ufw reload
```

**C) Falscher Port/IP in Konfiguration:**
```bash
sudo nano /opt/Havoc/profiles/havoc.yaotl
# Prüfen Sie Host und Port
sudo systemctl restart havoc-teamserver
```

**D) Prozess hängt:**
```bash
sudo pkill -9 havoc
sudo systemctl start havoc-teamserver
```

---

### 🔴 Problem: Beacon verbindet sich nicht zum Listener

**Symptome:**
- Payload wurde ausgeführt
- Keine Session erscheint in Havoc

**Diagnose:**

```bash
# 1. Läuft der Listener?
# Im Havoc Client: View → Listeners (Muss "Started" zeigen)

# 2. Redirector erreichbar?
curl -v https://ihre-domain.com/api/check

# 3. Redirector-Logs prüfen
# Apache:
sudo tail -f /var/log/apache2/redirector_access.log
sudo tail -f /var/log/apache2/redirector_error.log

# Nginx:
sudo tail -f /var/log/nginx/redirector_access.log
sudo tail -f /var/log/nginx/redirector_error.log

# 4. Teamserver-Logs
sudo journalctl -u havoc-teamserver -f

# 5. Netzwerk-Verbindung vom Target
# (Auf Target-System):
curl -v https://ihre-domain.com
```

**Lösungen:**

**A) Listener nicht gestartet:**
- In Havoc Client: Rechtsklick auf Listener → Start

**B) Falsche URI in Payload:**
- Payload muss gleiche URI wie in Redirector-Config nutzen
- Regenerieren Sie Payload mit korrekter Konfiguration

**C) Redirector leitet nicht weiter:**
```bash
# Apache: Teste mod_rewrite
sudo apache2ctl -M | grep rewrite
# Wenn fehlt:
sudo a2enmod rewrite
sudo systemctl restart apache2

# Teste Proxy
curl -v -H "Host: ihre-domain.com" http://127.0.0.1/api/check
```

**D) SSL-Zertifikat ungültig:**
```bash
# Prüfe Zertifikat
openssl s_client -connect ihre-domain.com:443 -servername ihre-domain.com

# Falls abgelaufen:
sudo certbot renew
sudo systemctl reload apache2  # oder nginx
```

**E) Firewall auf Target blockiert:**
- Nutzen Sie alternative Ports (80, 8080, 8443)
- Oder Domain-Fronting

---

### 🔴 Problem: Havoc Teamserver Kompilierung schlägt fehl

**Symptome:**
- `make ts-build` bricht mit Fehler ab
- Go Dependencies fehlen

**Lösungen:**

```bash
# 1. Alle Dependencies installieren
sudo apt update
sudo apt install -y golang-go build-essential

# 2. Go-Version prüfen (min 1.19)
go version

# Falls zu alt, manuell installieren:
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

# 3. Dependencies neu laden
cd /opt/Havoc/teamserver
go mod tidy
go mod download

cd /opt/Havoc
sudo make ts-build
```

---

### 🔴 Problem: SSL-Zertifikat kann nicht angefordert werden

**Symptome:**
- Certbot schlägt fehl
- "Challenge failed" Fehler

**Diagnose:**

```bash
# 1. DNS korrekt?
dig ihre-domain.com
nslookup ihre-domain.com

# 2. Port 80 erreichbar?
curl http://ihre-domain.com/.well-known/acme-challenge/test

# 3. Webserver läuft?
sudo systemctl status apache2  # oder nginx
```

**Lösungen:**

**A) DNS zeigt nicht auf Server:**
- Warten Sie bis DNS propagiert ist (kann 24h dauern)
- Prüfen: https://dnschecker.org/

**B) Port 80 blockiert:**
```bash
sudo ufw allow 80/tcp
sudo ufw reload
```

**C) Webserver nicht gestartet:**
```bash
sudo systemctl start apache2  # oder nginx
```

**D) Webserver konfiguriert Port 80 nicht:**
```bash
# Apache
sudo nano /etc/apache2/sites-available/redirector.conf
# Stellen Sie sicher: <VirtualHost *:80>

# Nginx
sudo nano /etc/nginx/sites-available/redirector
# Stellen Sie sicher: listen 80;

sudo systemctl restart apache2  # oder nginx
```

**E) Rate Limit erreicht:**
```bash
# Nutzen Sie Staging für Tests
sudo certbot --staging certonly --standalone -d ihre-domain.com

# Wenn funktioniert, Production:
sudo certbot certonly --standalone -d ihre-domain.com
```

---

## Havoc Teamserver Troubleshooting

### Teamserver startet, aber akzeptiert keine Verbindungen

**Diagnose:**
```bash
# Detaillierte Logs
sudo journalctl -u havoc-teamserver -n 100 --no-pager

# Manuell im Debug-Modus starten
cd /opt/Havoc
sudo ./havoc server --profile ./profiles/havoc.yaotl -v --debug
```

**Häufige Fehler:**

**1. Falsches Passwort-Format in yaotl:**
```yaml
# FALSCH:
Password: MeinPasswort123!

# RICHTIG:
Password: "MeinPasswort123!"
```

**2. Port bereits belegt:**
```bash
# Prüfen
sudo lsof -i :40056

# Prozess killen
sudo kill -9 PID
```

**3. Fehlende Berechtigungen:**
```bash
sudo chown -R root:root /opt/Havoc
sudo chmod +x /opt/Havoc/havoc
```

---

### Sessions verschwinden plötzlich

**Ursachen & Lösungen:**

**1. Beacon Sleep Timeout:**
- Beacon meldet sich nicht mehr weil Kill-Date erreicht
- Lösung: Prüfen Sie KillDate in Demon-Config

**2. Teamserver-Neustart:**
- Sessions sind nur im Speicher, nicht persistent
- Lösung: Beacon muss sich neu verbinden

**3. Netzwerk-Unterbrechung:**
- Target hat Internet-Verbindung verloren
- Lösung: Warten oder alternative Callback-Methode

**4. Detection & Kill:**
- AV/EDR hat Beacon erkannt und beendet
- Lösung: Bessere Obfuskation, Process Migration

---

## Redirector Troubleshooting

### Apache: Requests werden nicht weitergeleitet

**Diagnose:**

```bash
# Test direkt am Server
curl -v -H "Host: ihre-domain.com" http://127.0.0.1/api/check

# Prüfe mod_proxy
sudo apache2ctl -M | grep proxy

# Prüfe Rewrite-Rules
sudo apache2ctl -M | grep rewrite

# Detaillierte Logs
sudo tail -f /var/log/apache2/redirector_error.log
```

**Lösungen:**

```bash
# Module aktivieren
sudo a2enmod proxy proxy_http rewrite headers ssl
sudo systemctl restart apache2

# Teste Konfiguration
sudo apache2ctl configtest

# Wenn Fehler, prüfe Syntax
sudo nano /etc/apache2/sites-available/redirector.conf
```

**Häufige Konfigurationsfehler:**

```apache
# FALSCH: Proxy-Pass ohne ProxyRequests Off
ProxyPass / http://c2-server/

# RICHTIG:
ProxyRequests Off
ProxyPass / http://c2-server/
ProxyPassReverse / http://c2-server/
```

---

### Nginx: 502 Bad Gateway

**Bedeutung:** Nginx kann Backend (C2) nicht erreichen.

**Diagnose:**

```bash
# Logs
sudo tail -f /var/log/nginx/redirector_error.log

# Test Backend-Erreichbarkeit
curl -v http://C2_SERVER_IP:443

# Test von Nginx-Server
nc -zv C2_SERVER_IP 443
```

**Lösungen:**

**1. C2-Server nicht erreichbar:**
```bash
# Firewall auf C2-Server?
# Auf C2-Server:
sudo ufw allow from REDIRECTOR_IP to any port 443
```

**2. Falscher Upstream:**
```nginx
# Prüfe upstream-Block
upstream c2_backend {
    server KORREKTE_IP:443;  # Prüfen!
}
```

**3. SSL-Probleme:**
```nginx
# Deaktiviere SSL-Verify für Tests
location /api/ {
    proxy_pass https://c2_backend;
    proxy_ssl_verify off;  # Füge hinzu
}
```

---

## SSL/TLS Probleme

### Zertifikat abgelaufen

**Prüfen:**
```bash
echo | openssl s_client -connect ihre-domain.com:443 2>/dev/null | \
  openssl x509 -noout -dates

# Oder
sudo certbot certificates
```

**Erneuern:**
```bash
# Manuell
sudo certbot renew

# Force renewal
sudo certbot renew --force-renewal

# Für spezifische Domain
sudo certbot renew --cert-name ihre-domain.com
```

**Auto-Renewal prüfen:**
```bash
# Timer aktiv?
sudo systemctl status certbot.timer

# Falls nicht:
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Test
sudo certbot renew --dry-run
```

---

### Browser zeigt "Certificate Error"

**Ursachen:**

**1. Self-Signed Certificate:**
- Nur für interne Tests OK
- Für Production: Let's Encrypt nutzen

**2. Domain-Mismatch:**
```bash
# Prüfe Certificate
openssl s_client -connect ihre-domain.com:443 -servername ihre-domain.com | \
  openssl x509 -noout -text | grep "DNS:"

# Subject Alternative Name muss ihre-domain.com enthalten
```

**3. Intermediate Certificates fehlen:**
```apache
# Apache: Nutze fullchain.pem
SSLCertificateFile /etc/letsencrypt/live/ihre-domain.com/fullchain.pem
# NICHT cert.pem!
```

---

## Netzwerk & Connectivity

### Firewall-Debugging

```bash
# Aktuelle Regeln
sudo ufw status numbered

# Alle Connections
sudo netstat -tupln

# Spezifischer Port
sudo netstat -tlnp | grep PORT

# Aktive Verbindungen
sudo ss -tulpn

# Geblockte Verbindungen (iptables)
sudo iptables -L -v -n

# Traffic-Counter
watch -n 1 'sudo iptables -L -v -n | grep PORT'
```

**Port-Freigabe-Checkliste:**

```bash
# 1. Lokale Firewall (ufw)
sudo ufw allow PORT/tcp

# 2. Provider Firewall?
# Prüfen Sie Provider-Dashboard (DigitalOcean, Vultr, etc.)

# 3. Cloud Security Groups?
# AWS: Security Groups, Azure: NSGs, etc.

# 4. Test von extern
# Auf anderem Server:
nc -zv IHRE_IP PORT
```

---

### DNS-Probleme

**Diagnose:**

```bash
# DNS-Auflösung
dig ihre-domain.com
nslookup ihre-domain.com

# Von verschiedenen DNS-Servern
dig @8.8.8.8 ihre-domain.com
dig @1.1.1.1 ihre-domain.com

# Propagation-Check
curl -s "https://dns.google/resolve?name=ihre-domain.com&type=A" | jq
```

**Häufige Probleme:**

**1. DNS nicht propagiert:**
- Kann 24-48h dauern
- Nutzen Sie temporär IP-Adresse

**2. Falscher A-Record:**
```bash
# Sollte auf Redirector-IP zeigen, nicht Teamserver!
dig ihre-domain.com +short
# Vergleiche mit:
curl ifconfig.me  # (Auf Redirector-Server)
```

**3. TTL zu hoch:**
- Bei häufigen Infrastruktur-Wechseln: TTL auf 300 (5 Min) setzen

---

## Performance-Optimierung

### Teamserver langsam

**Ursachen & Lösungen:**

**1. Zu viele Sessions:**
```bash
# Ressourcen prüfen
htop
free -h
df -h

# Upgrade auf größeren VPS
# Empfohlen: 4 GB RAM für 100+ Sessions
```

**2. Logging zu verbose:**
```yaml
# In havoc.yaotl
# Reduziere Log-Level
```

**3. Disk voll:**
```bash
# Logs rotieren
sudo journalctl --rotate
sudo journalctl --vacuum-time=7d

# Große Dateien finden
sudo du -sh /* | sort -rh | head -10
```

---

### Redirector langsam

**Apache Optimierung:**

```bash
sudo nano /etc/apache2/mods-available/mpm_prefork.conf
```

```apache
<IfModule mpm_prefork_module>
    StartServers             5
    MinSpareServers          5
    MaxSpareServers          10
    MaxRequestWorkers        150
    MaxConnectionsPerChild   0
</IfModule>
```

**Nginx Optimierung:**

```bash
sudo nano /etc/nginx/nginx.conf
```

```nginx
worker_processes auto;
worker_connections 2048;

# Buffering
proxy_buffering on;
proxy_buffer_size 4k;
proxy_buffers 8 4k;
proxy_busy_buffers_size 8k;
```

---

## Wartungsaufgaben

### Tägliche Checks

```bash
#!/bin/bash
# /opt/c2_daily_check.sh

echo "=== Daily C2 Infrastructure Check ==="
echo ""

# Teamserver Status
echo "[Teamserver]"
systemctl is-active havoc-teamserver && echo "✓ Running" || echo "✗ Down"

# Redirector Status
echo "[Redirector]"
systemctl is-active apache2 nginx 2>/dev/null | grep -q active && echo "✓ Running" || echo "✗ Down"

# Disk Space
echo "[Disk Space]"
df -h / | tail -1 | awk '{print "Used: " $5}'

# Memory
echo "[Memory]"
free -h | grep Mem | awk '{print "Used: " $3 " / " $2}'

# SSL Expiry
echo "[SSL Certificate]"
if [ -d "/etc/letsencrypt/live" ]; then
    DOMAIN=$(ls /etc/letsencrypt/live | grep -v README | head -1)
    EXPIRY=$(openssl x509 -noout -enddate -in /etc/letsencrypt/live/$DOMAIN/cert.pem | cut -d= -f2)
    echo "Expires: $EXPIRY"
fi

# Failed Login Attempts
echo "[Security]"
FAILED=$(grep "Failed password" /var/log/auth.log | wc -l)
echo "Failed logins: $FAILED"

echo ""
echo "=== End of Check ==="
```

**Cronjob:**
```bash
sudo crontab -e
```
```
0 8 * * * /opt/c2_daily_check.sh | mail -s "C2 Daily Check" admin@domain.com
```

---

### Wöchentliche Wartung

```bash
#!/bin/bash
# /opt/c2_weekly_maintenance.sh

echo "[+] Weekly Maintenance Started"

# System Updates
echo "[+] Updating system..."
apt update && apt upgrade -y

# Log Rotation
echo "[+] Rotating logs..."
journalctl --rotate
journalctl --vacuum-time=14d

# Apache/Nginx Logs
find /var/log/apache2 -name "*.log" -mtime +14 -delete
find /var/log/nginx -name "*.log" -mtime +14 -delete

# Rootkit Check
echo "[+] Running rootkit check..."
rkhunter --check --skip-keypress --report-warnings-only

# Disk Cleanup
echo "[+] Cleaning up..."
apt autoremove -y
apt clean

# Backup Configuration
echo "[+] Backing up configs..."
tar -czf /root/backup_$(date +%Y%m%d).tar.gz \
    /opt/Havoc/profiles/ \
    /etc/apache2/sites-available/redirector* \
    /etc/nginx/sites-available/redirector \
    2>/dev/null

echo "[+] Maintenance completed"
```

---

## Monitoring & Alerting

### Uptime Monitoring

**Externe Services:**
- UptimeRobot (kostenlos, 50 Monitors)
- Pingdom
- StatusCake

**Konfiguration:**
- Monitor URL: `https://ihre-domain.com/`
- Check Interval: 5 Minuten
- Alert: Email/SMS

---

### Log-Monitoring mit fail2ban

Custom Jail für C2-Traffic:

```bash
sudo nano /etc/fail2ban/jail.d/c2-monitoring.conf
```

```ini
[c2-bruteforce]
enabled = true
port = 40056
filter = c2-bruteforce
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[redirector-scan]
enabled = true
port = http,https
filter = redirector-scan
logpath = /var/log/apache2/redirector_access.log
maxretry = 10
findtime = 60
bantime = 3600
```

Filter erstellen:

```bash
sudo nano /etc/fail2ban/filter.d/redirector-scan.conf
```

```ini
[Definition]
failregex = ^<HOST> .* "(GET|POST|HEAD).*" (403|404|400)
ignoreregex =
```

---

## Backup & Recovery

### Backup-Strategie

**Was sichern:**

```bash
# Teamserver
/opt/Havoc/profiles/
/opt/Havoc/data/  # Falls vorhanden
/etc/systemd/system/havoc-teamserver.service

# Redirector
/etc/apache2/sites-available/redirector*
/etc/nginx/sites-available/redirector
/var/www/html/

# SSL
/etc/letsencrypt/
```

**Backup-Script:**

```bash
#!/bin/bash
# /opt/backup_c2.sh

BACKUP_DIR="/root/c2_backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/c2_backup_$DATE.tar.gz.enc"

mkdir -p $BACKUP_DIR

# Create encrypted backup
tar -czf - \
    /opt/Havoc/profiles/ \
    /etc/apache2/sites-available/redirector* \
    /etc/nginx/sites-available/redirector \
    /etc/letsencrypt/ \
    2>/dev/null | \
openssl enc -aes-256-cbc -salt -out $BACKUP_FILE -k "IhrSicheresPasswort"

echo "[+] Backup created: $BACKUP_FILE"

# Delete old backups (> 30 days)
find $BACKUP_DIR -name "c2_backup_*.tar.gz.enc" -mtime +30 -delete

# Optional: Upload to S3, Cloud Storage, etc.
```

**Restore:**

```bash
# Decrypt and extract
openssl enc -aes-256-cbc -d -in BACKUP_FILE -k "IhrSicheresPasswort" | \
  tar -xzf - -C /
```

---

## Notfall-Prozeduren

### Szenario 1: Teamserver kompromittiert

**Sofortmaßnahmen:**

```bash
# 1. Teamserver stoppen
sudo systemctl stop havoc-teamserver

# 2. Alle Sessions beenden (auf Targets)
# Beacons haben Auto-Kill nach X Tagen

# 3. Netzwerk isolieren
sudo ufw default deny incoming
sudo ufw default deny outgoing

# 4. Forensische Sicherung
sudo dd if=/dev/sda of=/mnt/external/forensics.img bs=4M status=progress

# 5. Analyse
# - Prüfe /var/log/auth.log auf unbefugte Logins
# - Prüfe Havoc Logs auf verdächtige Aktivitäten
# - rkhunter --check

# 6. Neu aufsetzen
# Nutzen Sie Backup und neuen VPS
```

---

### Szenario 2: Redirector auf Blacklist

**Detection:**

```bash
# Prüfe IP-Reputation
curl "https://api.abuseipdb.com/api/v2/check?ipAddress=IHRE_IP" \
  -H "Key: IHR_API_KEY"
```

**Maßnahmen:**

```bash
# 1. Neuen Redirector aufsetzen
# Nutzen Sie install_redirector_*.sh auf neuem VPS

# 2. DNS umlenken
# Ändere A-Record auf neue IP

# 3. Alten Redirector cleanup
sudo bash cleanup_infrastructure.sh

# 4. Provider-VPS löschen
```

---

### Szenario 3: SSL-Zertifikat kompromittiert

**Maßnahmen:**

```bash
# 1. Zertifikat widerrufen
sudo certbot revoke --cert-path /etc/letsencrypt/live/ihre-domain.com/cert.pem

# 2. Neues Zertifikat anfordern
sudo certbot certonly --standalone -d ihre-domain.com

# 3. Listener neu starten
sudo systemctl restart apache2  # oder nginx
sudo systemctl restart havoc-teamserver

# 4. Neue Payloads generieren
# (Mit neuen SSL-Fingerprints)
```

---

### Szenario 4: Detection während Engagement

**Blue Team hat C2 erkannt:**

```bash
# 1. NICHT PANIKEN
# Dokumentieren Sie alles

# 2. Engagement sofort pausieren
# Stoppen Sie alle aktiven Sessions

# 3. Kommunikation mit Kunde
# Informieren Sie Auftraggeber

# 4. Fallback-Infrastruktur aktivieren (falls vorhanden)
# Wechseln Sie zu Backup-Redirector/Domain

# 5. Post-Mortem
# - Was wurde erkannt?
# - Wie wurde es erkannt?
# - Lessons Learned
```

---

## Checklisten

### Pre-Engagement Check

- [ ] Teamserver erreichbar
- [ ] Alle Redirectors erreichbar
- [ ] SSL-Zertifikate gültig (> 14 Tage)
- [ ] DNS-Records korrekt
- [ ] Firewall-Regeln korrekt
- [ ] Backup vorhanden
- [ ] Monitoring aktiv
- [ ] Fallback-Infrastruktur bereit
- [ ] Payloads getestet

### Während Engagement

- [ ] Tägliche Infrastruktur-Checks
- [ ] Logs überwachen
- [ ] Disk Space prüfen
- [ ] Session-Health prüfen
- [ ] Threat-Intel auf eigene IoCs prüfen

### Post-Engagement

- [ ] Alle Sessions beendet
- [ ] Artifacts auf Targets entfernt
- [ ] Cleanup-Script ausgeführt
- [ ] VPS bei Provider gelöscht
- [ ] DNS-Records entfernt
- [ ] Dokumentation/Report finalisiert
- [ ] Lessons Learned dokumentiert

---

## Weitere Ressourcen

- **Havoc GitHub Issues:** https://github.com/HavocFramework/Havoc/issues
- **Havoc Discord:** https://discord.gg/havoc
- **Apache Docs:** https://httpd.apache.org/docs/
- **Nginx Docs:** https://nginx.org/en/docs/
- **Let's Encrypt Community:** https://community.letsencrypt.org/

---

**Erstellt:** 2026-02-05
**Version:** 1.0
