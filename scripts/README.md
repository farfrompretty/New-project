# Automatisierungs-Skripte für Havoc C2 Infrastruktur

Dieses Verzeichnis enthält Automatisierungs-Skripte zur schnellen Einrichtung Ihrer C2-Infrastruktur.

---

## 📋 Verfügbare Skripte

### 1. `install_havoc_teamserver.sh`

Automatische Installation und Konfiguration des Havoc C2 Teamservers.

**Verwendung:**
```bash
wget https://raw.githubusercontent.com/.../install_havoc_teamserver.sh
sudo bash install_havoc_teamserver.sh
```

**Was macht es:**
- ✅ Installiert alle Dependencies
- ✅ Klont Havoc Framework
- ✅ Kompiliert Teamserver
- ✅ Erstellt Konfigurationsdatei
- ✅ Richtet systemd Service ein
- ✅ Konfiguriert Firewall

**Interaktive Eingaben:**
- Teamserver Host/Port
- Admin-Credentials
- Listener-Konfiguration

---

### 2. `install_redirector_apache.sh`

Automatische Installation eines Apache-basierten Redirectors.

**Verwendung:**
```bash
wget https://raw.githubusercontent.com/.../install_redirector_apache.sh
sudo bash install_redirector_apache.sh
```

**Was macht es:**
- ✅ Installiert Apache2 mit mod_rewrite
- ✅ Konfiguriert Traffic-Filterung
- ✅ Erstellt Fallback-Webseite
- ✅ Fordert Let's Encrypt SSL-Zertifikat an
- ✅ Richtet automatische Proxy-Regeln ein

**Interaktive Eingaben:**
- Domain
- C2-Server IP/Port
- C2-URI-Pfad
- Admin-Email

---

### 3. `install_redirector_nginx.sh`

Automatische Installation eines Nginx-basierten Redirectors.

**Verwendung:**
```bash
wget https://raw.githubusercontent.com/.../install_redirector_nginx.sh
sudo bash install_redirector_nginx.sh
```

**Was macht es:**
- ✅ Installiert Nginx
- ✅ Konfiguriert Traffic-Filterung
- ✅ Erstellt Fallback-Webseite
- ✅ Fordert Let's Encrypt SSL-Zertifikat an
- ✅ Richtet Proxy zu C2 ein

**Interaktive Eingaben:**
- Domain
- C2-Server IP/Port
- C2-URI-Pfad
- Admin-Email

---

### 4. `harden_server.sh`

Sicherheitshärtung für VPS-Server.

**Verwendung:**
```bash
wget https://raw.githubusercontent.com/.../harden_server.sh
sudo bash harden_server.sh
```

**Was macht es:**
- ✅ SSH-Härtung (Key-only, Port ändern)
- ✅ Firewall-Konfiguration
- ✅ Fail2Ban Installation
- ✅ Automatische Updates
- ✅ Deaktiviert unnötige Services
- ✅ Kernel-Parameter-Optimierung

---

### 5. `cleanup_infrastructure.sh`

Bereinigt C2-Infrastruktur nach Engagement.

**Verwendung:**
```bash
sudo bash cleanup_infrastructure.sh
```

**Was macht es:**
- ⚠️ Stoppt alle C2-Services
- ⚠️ Löscht Logs
- ⚠️ Löscht Konfigurationen
- ⚠️ Überschreibt sensible Dateien
- ⚠️ Optional: Überschreibt gesamte Disk

**⚠️ WARNUNG:** Irreversibler Vorgang!

---

## 🚀 Schnellstart-Workflows

### Workflow 1: Einfaches Setup (Lab/Training)

```bash
# Schritt 1: Teamserver-VPS
ssh root@teamserver-ip
wget SCRIPT_URL/install_havoc_teamserver.sh
sudo bash install_havoc_teamserver.sh
# Notieren Sie die Credentials!

# Schritt 2: Auf Ihrer Workstation
cd /opt/Havoc
./havoc client
# Verbinden Sie sich zum Teamserver
```

---

### Workflow 2: Production mit Redirector

```bash
# Schritt 1: Teamserver-VPS (versteckt)
ssh root@teamserver-ip
wget SCRIPT_URL/install_havoc_teamserver.sh
wget SCRIPT_URL/harden_server.sh
sudo bash harden_server.sh
sudo bash install_havoc_teamserver.sh

# Schritt 2: Redirector-VPS (öffentlich)
ssh root@redirector-ip
wget SCRIPT_URL/install_redirector_apache.sh
# ODER
wget SCRIPT_URL/install_redirector_nginx.sh
sudo bash install_redirector_apache.sh
# Geben Sie Teamserver-IP und Domain ein

# Schritt 3: DNS konfigurieren
# Setzen Sie A-Record: ihre-domain.com → redirector-ip

# Schritt 4: Testen
curl https://ihre-domain.com/
# Sollte Fallback-Webseite zeigen

# Schritt 5: Auf Workstation verbinden
cd /opt/Havoc
./havoc client
# Verbinden zu Teamserver-IP:40056
```

---

### Workflow 3: Multi-Redirector Setup

```bash
# Teamserver (1x)
ssh root@teamserver-ip
bash install_havoc_teamserver.sh

# Redirector 1 (Europa)
ssh root@redirector-eu-ip
bash install_redirector_nginx.sh
# Domain: eu.ihre-domain.com
# C2-IP: teamserver-ip

# Redirector 2 (USA)
ssh root@redirector-us-ip
bash install_redirector_nginx.sh
# Domain: us.ihre-domain.com
# C2-IP: teamserver-ip

# Redirector 3 (Asien)
ssh root@redirector-asia-ip
bash install_redirector_nginx.sh
# Domain: asia.ihre-domain.com
# C2-IP: teamserver-ip

# DNS:
# A eu.ihre-domain.com    → redirector-eu-ip
# A us.ihre-domain.com    → redirector-us-ip
# A asia.ihre-domain.com  → redirector-asia-ip
```

---

## 🔧 Anpassung der Skripte

### Variablen am Anfang der Skripte anpassen

Alle Skripte haben konfigurierbare Variablen. Öffnen Sie das Script und passen Sie an:

```bash
# Beispiel: install_havoc_teamserver.sh

# Wenn Sie interaktive Eingaben überspringen möchten:
TS_HOST="0.0.0.0"
TS_PORT="40056"
ADMIN_USER="admin"
ADMIN_PASS="MeinSuperSicheresPasswort123!"
LISTENER_HOST="ihre-domain.com"
LISTENER_PORT="443"

# Dann kommentieren Sie die read-Zeilen aus und nutzen Sie die Variablen direkt
```

### Automatisierung ohne Interaktion

Für vollautomatische Deployments (z.B. mit Terraform):

```bash
# Erstellen Sie ein Config-File
cat > /tmp/c2-config.env << EOF
TS_HOST=0.0.0.0
TS_PORT=40056
ADMIN_USER=admin
ADMIN_PASS=$(openssl rand -base64 20)
LISTENER_HOST=c2.example.com
LISTENER_PORT=443
EOF

# Modifizieren Sie Script um Config zu sourcen
source /tmp/c2-config.env
# ... Rest des Scripts
```

---

## 📝 Post-Installation Checklists

### Nach Teamserver-Installation:

- [ ] Service läuft: `systemctl status havoc-teamserver`
- [ ] Port erreichbar: `nc -zv TEAMSERVER_IP 40056`
- [ ] Firewall korrekt: `ufw status`
- [ ] Logs prüfen: `journalctl -u havoc-teamserver -n 50`
- [ ] Credentials sicher gespeichert
- [ ] Backup der Konfiguration erstellt

### Nach Redirector-Installation:

- [ ] Webserver läuft: `systemctl status apache2` / `nginx`
- [ ] DNS-Record korrekt: `dig ihre-domain.com`
- [ ] SSL-Zertifikat gültig: `curl https://ihre-domain.com/`
- [ ] Proxy funktioniert: Test-Request zu C2-URI
- [ ] Firewall korrekt: `ufw status`
- [ ] Logs rotieren: `ls -lh /var/log/apache2/` / `nginx/`

---

## 🛠️ Troubleshooting

### Problem: Script bricht mit Fehler ab

```bash
# Logs prüfen
sudo journalctl -xe

# Script im Debug-Modus ausführen
bash -x install_havoc_teamserver.sh
```

### Problem: Teamserver startet nicht

```bash
# Logs prüfen
sudo journalctl -u havoc-teamserver -n 100

# Port-Konflikt?
sudo netstat -tlnp | grep 40056

# Manuell starten (für Debugging)
cd /opt/Havoc
sudo ./havoc server --profile ./profiles/havoc.yaotl -v --debug
```

### Problem: Redirector leitet nicht weiter

```bash
# Apache: Test-Konfiguration
sudo apache2ctl configtest

# Nginx: Test-Konfiguration
sudo nginx -t

# Logs live ansehen
sudo tail -f /var/log/apache2/redirector_error.log
sudo tail -f /var/log/nginx/redirector_error.log

# Test-Request
curl -v http://ihre-domain.com/api/test
```

### Problem: SSL-Zertifikat schlägt fehl

```bash
# DNS prüfen
dig ihre-domain.com

# Port 80 erreichbar?
sudo netstat -tlnp | grep :80

# Manuell anfordern
sudo certbot certonly --standalone -d ihre-domain.com

# Oder mit Webroot
sudo certbot certonly --webroot -w /var/www/html -d ihre-domain.com
```

---

## 🔄 Updates & Wartung

### Havoc Teamserver aktualisieren

```bash
cd /opt/Havoc
sudo systemctl stop havoc-teamserver
sudo git pull
sudo make ts-build
sudo systemctl start havoc-teamserver
```

### Redirector-Konfiguration ändern

```bash
# Apache
sudo nano /etc/apache2/sites-available/redirector.conf
sudo apache2ctl configtest
sudo systemctl reload apache2

# Nginx
sudo nano /etc/nginx/sites-available/redirector
sudo nginx -t
sudo systemctl reload nginx
```

---

## 📚 Weitere Ressourcen

- **Hauptdokumentation:** `../HAVOC_C2_SETUP.md`
- **Infrastruktur:** `../INFRASTRUCTURE_SETUP.md`
- **SSL/TLS:** `../SSL_CERTIFICATE_SETUP.md`
- **OPSEC:** `../OPSEC_GUIDE.md`
- **Hosting:** `../HOSTING_GUIDE.md`

---

**Erstellt:** 2026-02-05
**Version:** 1.0
