# Automatisierte Installation - Komplettanleitung

> **Vollautomatische Installation OHNE jegliche Interaktion!**

---

## 🎯 Übersicht

Sie füllen **einmal** eine Config-Datei aus, der Rest läuft **komplett automatisch**!

**Keine Fragen während Installation!**  
**Keine manuellen Eingaben!**  
**Einfach starten und warten!**

---

## 📋 Inhaltsverzeichnis

1. [Schnellstart (TL;DR)](#schnellstart-tldr)
2. [Detaillierte Anleitung: Teamserver](#teamserver-installation)
3. [Detaillierte Anleitung: Redirector](#redirector-installation)
4. [Verwendung der Skripte](#verwendung-der-skripte)
5. [Troubleshooting](#troubleshooting)

---

## Schnellstart (TL;DR)

### Teamserver (Hetzner):

```bash
# 1. SSH zum Server
ssh root@IHRE_TEAMSERVER_IP

# 2. Skripte holen
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts

# 3. Config erstellen
cp config.example config
nano config

# WICHTIG: Ausfüllen:
#   SERVER_TYPE="teamserver"
#   ADMIN_PASSWORD="IhrPasswort123!"
#   LISTENER_HOST="cdn.example.com"  # IHRE Redirector-Domain!

# Speichern: Ctrl+O, Enter, Ctrl+X

# 4. Auto-Installation starten
chmod +x auto_setup.sh
sudo ./auto_setup.sh

# 5. Warten (10-15 Minuten)
# 6. Fertig! Credentials in /root/TEAMSERVER_CREDENTIALS.txt
```

### Redirector (Vultr):

```bash
# 1. SSH zum Server
ssh root@IHRE_REDIRECTOR_IP

# 2. Skripte holen
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts

# 3. Config erstellen
cp config.example config
nano config

# WICHTIG: Ausfüllen:
#   SERVER_TYPE="redirector"
#   REDIRECTOR_TYPE="nginx"
#   REDIRECTOR_DOMAIN="cdn.example.com"  # IHRE Domain!
#   C2_SERVER_IP="49.12.34.56"  # Teamserver-IP von oben!
#   ADMIN_EMAIL="admin@example.com"

# Speichern: Ctrl+O, Enter, Ctrl+X

# 4. Auto-Installation starten
chmod +x auto_setup.sh
sudo ./auto_setup.sh

# 5. Warten (5-10 Minuten)
# 6. Fertig! Credentials in /root/REDIRECTOR_CREDENTIALS.txt
```

**Das wars! Setup komplett automatisch!**

---

## Teamserver Installation

### Schritt 1: VPS vorbereiten

**Hetzner CX11 bestellen:**
- Website: https://console.hetzner.cloud/
- Image: Ubuntu 22.04 LTS
- Type: CX11 (€4.15/Monat)
- SSH-Key hinzufügen

**SSH-Verbindung:**

```bash
ssh root@IHRE_TEAMSERVER_IP
```

---

### Schritt 2: Skripte herunterladen

```bash
# Repository klonen
cd /root
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4
cd scripts

# Ausführbar machen
chmod +x *.sh
```

---

### Schritt 3: Config-Datei erstellen

```bash
# Config-Vorlage kopieren
cp config.example config

# Mit Editor öffnen
nano config
```

**Füllen Sie aus:**

```bash
# ════════════════════════════════════════════════════════════
# SERVER-TYP
# ════════════════════════════════════════════════════════════
SERVER_TYPE="teamserver"  # ← WICHTIG!

# ════════════════════════════════════════════════════════════
# TEAMSERVER KONFIGURATION
# ════════════════════════════════════════════════════════════

TS_HOST="0.0.0.0"         # Lassen Sie so
TS_PORT="40056"           # Lassen Sie so

ADMIN_USER="admin"        # Lassen Sie so
ADMIN_PASSWORD="MeinSuperSicheresPasswort123!"  # ← ÄNDERN SIE DIES!

OPERATOR_USER="operator1"
OPERATOR_PASSWORD="OperatorPasswort456!"  # ← Optional ändern

LISTENER_HOST="cdn.example.com"  # ← IHRE Redirector-Domain!
                                  # (kommt später, aber jetzt eintragen)
LISTENER_PORT="443"       # Lassen Sie so

# ════════════════════════════════════════════════════════════
# SICHERHEIT
# ════════════════════════════════════════════════════════════

AUTO_HARDEN="true"        # Empfohlen!
AUTO_FIREWALL="true"      # Empfohlen!
AUTO_UPDATES="true"       # Empfohlen!
```

**Speichern:**
- `Ctrl+O` (Write Out)
- `Enter` (bestätigen)
- `Ctrl+X` (Exit)

---

### Schritt 4: Auto-Installation starten

```bash
# Starten
sudo ./auto_setup.sh

# Output:
╔═══════════════════════════════════════════════════════════════╗
║        HAVOC C2 - VOLLAUTOMATISCHES SETUP                   ║
╚═══════════════════════════════════════════════════════════════╝

[+] Lade Konfiguration aus: ./config
[1/5] System wird vorbereitet...
[2/5] Installiere Teamserver-Dependencies...
[3/5] Klone und kompiliere Havoc...
[*] Kompiliere Teamserver (5-10 Minuten, bitte warten)...
[✓] Havoc kompiliert
[4/5] Erstelle Konfiguration...
[✓] Konfiguration erstellt
[5/5] Konfiguriere Firewall...
[✓] Firewall konfiguriert
[*] Starte Teamserver...
[✓] Teamserver läuft!

╔═══════════════════════════════════════════════════════════════╗
║          ✅  TEAMSERVER ERFOLGREICH INSTALLIERT!             ║
╚═══════════════════════════════════════════════════════════════╝
```

**Installation läuft 10-15 Minuten - NICHT unterbrechen!**

---

### Schritt 5: Credentials sichern

**Nach Installation wird angezeigt:**

```
╔═══════════════════════════════════════════════════════════════╗
║              TEAMSERVER ZUGANGSDATEN                         ║
╚═══════════════════════════════════════════════════════════════╝

SERVER-INFO:
  IP-Adresse:    49.12.34.56
  SSH:           ssh root@49.12.34.56

HAVOC TEAMSERVER:
  Host:          49.12.34.56
  Port:          40056
  
  Admin-Zugang:
    Username:    admin
    Password:    MeinSuperSicheresPasswort123!
```

**WICHTIG:**
1. **Kopieren Sie diese Informationen** in einen Password Manager
2. **Löschen Sie dann die Datei:**
   ```bash
   shred -vfz -n 10 /root/TEAMSERVER_CREDENTIALS.txt
   ```

✅ **Teamserver fertig!**

---

## Redirector Installation

### Schritt 1: VPS vorbereiten

**Vultr VPS bestellen:**
- Website: https://my.vultr.com/
- Location: Frankfurt (oder näher zu Hetzner)
- Size: $6/month (1 vCPU, 1 GB RAM)
- Image: Ubuntu 22.04 LTS
- SSH-Key hinzufügen

**SSH-Verbindung:**

```bash
ssh root@IHRE_REDIRECTOR_IP
```

---

### Schritt 2: DNS konfigurieren (VOR Installation!)

**Cloudflare (oder Ihr DNS-Provider):**

1. DNS-Record erstellen:
   - Type: **A**
   - Name: **cdn** (oder Ihr Subdomain)
   - Content: **IHRE_REDIRECTOR_IP**
   - TTL: **Auto**
   - Proxy: **🔴 DNS only** (NICHT proxied!)

2. Warten Sie 2-5 Minuten

3. Testen:
   ```bash
   dig cdn.example.com
   # Sollte Ihre REDIRECTOR_IP zeigen
   ```

✅ **DNS zeigt auf Redirector**

---

### Schritt 3: Skripte herunterladen

```bash
# Repository klonen
cd /root
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4
cd scripts

# Ausführbar machen
chmod +x *.sh
```

---

### Schritt 4: Config-Datei erstellen

```bash
# Config-Vorlage kopieren
cp config.example config

# Mit Editor öffnen
nano config
```

**Füllen Sie aus:**

```bash
# ════════════════════════════════════════════════════════════
# SERVER-TYP
# ════════════════════════════════════════════════════════════
SERVER_TYPE="redirector"  # ← WICHTIG!

# ════════════════════════════════════════════════════════════
# REDIRECTOR KONFIGURATION
# ════════════════════════════════════════════════════════════

REDIRECTOR_TYPE="nginx"   # nginx, apache, caddy, oder traefik

REDIRECTOR_DOMAIN="cdn.example.com"  # ← IHRE Domain!
ADMIN_EMAIL="admin@example.com"      # ← Ihre Email!

C2_SERVER_IP="49.12.34.56"  # ← TEAMSERVER-IP von oben!
C2_SERVER_PORT="443"        # Lassen Sie so

C2_URI="/api"               # Lassen Sie so

AUTO_SSL="true"             # SSL automatisch holen

# ════════════════════════════════════════════════════════════
# SICHERHEIT
# ════════════════════════════════════════════════════════════

AUTO_HARDEN="true"          # Empfohlen!
AUTO_FIREWALL="true"        # Empfohlen!
```

**Speichern:** `Ctrl+O`, Enter, `Ctrl+X`

---

### Schritt 5: Auto-Installation starten

```bash
# Starten
sudo ./auto_setup.sh

# Output:
╔═══════════════════════════════════════════════════════════════╗
║        HAVOC C2 - VOLLAUTOMATISCHES SETUP                   ║
╚═══════════════════════════════════════════════════════════════╝

[+] Lade Konfiguration aus: ./config
[1/5] System wird vorbereitet...
[2/5] Installiere Nginx...
[✓] Nginx installiert
[3/5] Konfiguriere Nginx Redirector...
[✓] Nginx konfiguriert
[4/5] Fordere SSL-Zertifikat an...
[✓] DNS korrekt - hole SSL-Zertifikat...
[✓] SSL-Zertifikat installiert!
[5/5] Konfiguriere Firewall...
[✓] Firewall konfiguriert

╔═══════════════════════════════════════════════════════════════╗
║          ✅  REDIRECTOR ERFOLGREICH INSTALLIERT!             ║
╚═══════════════════════════════════════════════════════════════╝
```

**Installation läuft 5-10 Minuten - NICHT unterbrechen!**

---

### Schritt 6: Credentials sichern

```
╔═══════════════════════════════════════════════════════════════╗
║              REDIRECTOR ZUGANGSDATEN                         ║
╚═══════════════════════════════════════════════════════════════╝

SERVER-INFO:
  IP-Adresse:    45.76.123.45
  Domain:        cdn.example.com

REDIRECTOR:
  Typ:           nginx
  C2-Server:     49.12.34.56:443

TEST:
  curl https://cdn.example.com/
```

**Kopieren und dann löschen:**

```bash
shred -vfz -n 10 /root/REDIRECTOR_CREDENTIALS.txt
```

✅ **Redirector fertig!**

---

## 🔗 Verwendung der Skripte

### Datei-Übersicht:

```
scripts/
├── config.example           ← Template (KOPIEREN!)
├── config                   ← IHRE Config (AUSFÜLLEN!)
└── auto_setup.sh           ← Haupt-Script (AUSFÜHREN!)
```

### Workflow:

```
1. config.example kopieren → config
2. config bearbeiten (Werte eintragen)
3. auto_setup.sh ausführen
4. Warten
5. Credentials notieren
6. Fertig!
```

---

## 📝 Config-Beispiele

### Beispiel 1: Teamserver-Config

```bash
# Datei: config

SERVER_TYPE="teamserver"

# Teamserver
TS_HOST="0.0.0.0"
TS_PORT="40056"

# Zugangsdaten
ADMIN_USER="admin"
ADMIN_PASSWORD="SuperSecure789!"

OPERATOR_USER="operator1"
OPERATOR_PASSWORD="OperPass456!"

# Listener (Redirector-Domain!)
LISTENER_HOST="cdn.mycorp.com"
LISTENER_PORT="443"

# Sicherheit
AUTO_HARDEN="true"
AUTO_FIREWALL="true"
AUTO_UPDATES="true"
```

---

### Beispiel 2: Redirector-Config (Nginx)

```bash
# Datei: config

SERVER_TYPE="redirector"

# Redirector
REDIRECTOR_TYPE="nginx"
REDIRECTOR_DOMAIN="cdn.mycorp.com"
ADMIN_EMAIL="admin@mycorp.com"

# C2-Server (Teamserver!)
C2_SERVER_IP="49.12.34.56"  # Ihre Teamserver-IP!
C2_SERVER_PORT="443"
C2_URI="/api"

# SSL
AUTO_SSL="true"

# Sicherheit
AUTO_HARDEN="true"
AUTO_FIREWALL="true"
```

---

### Beispiel 3: Redirector-Config (Caddy - automatisches HTTPS!)

```bash
# Datei: config

SERVER_TYPE="redirector"

# Redirector (CADDY = Automatisches HTTPS!)
REDIRECTOR_TYPE="caddy"
REDIRECTOR_DOMAIN="api.mycorp.com"
ADMIN_EMAIL="ops@mycorp.com"

# C2-Server
C2_SERVER_IP="78.46.12.34"
C2_SERVER_PORT="443"
C2_URI="/updates"

# SSL (Caddy macht automatisch!)
AUTO_SSL="true"

# Sicherheit
AUTO_HARDEN="true"
AUTO_FIREWALL="true"
```

---

## 🎬 Schritt-für-Schritt-Video-Anleitung

### Teamserver (Hetzner):

```bash
# Terminal 1: Teamserver

# Schritt 1: SSH-Verbindung
ssh root@49.12.34.56  # ← Ihre Teamserver-IP

# Schritt 2: Skripte holen
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts

# Schritt 3: Config erstellen und bearbeiten
cp config.example config
nano config

# Im Editor:
# - Ändern Sie: SERVER_TYPE="teamserver"
# - Ändern Sie: ADMIN_PASSWORD="IhrPasswort"
# - Ändern Sie: LISTENER_HOST="cdn.example.com"
# - Speichern: Ctrl+O, Enter, Ctrl+X

# Schritt 4: Installation starten
chmod +x auto_setup.sh
sudo ./auto_setup.sh

# Schritt 5: WARTEN (10-15 Min)
# ☕ Kaffee holen...

# Schritt 6: Credentials notieren
cat /root/TEAMSERVER_CREDENTIALS.txt

# WICHTIG: Notieren Sie:
# - IP-Adresse
# - Port (40056)
# - Username (admin)
# - Password

# Schritt 7: Credentials löschen
shred -vfz -n 10 /root/TEAMSERVER_CREDENTIALS.txt

# ✅ FERTIG! Teamserver läuft!
```

---

### Redirector (Vultr):

```bash
# Terminal 2: Redirector

# Schritt 1: SSH-Verbindung
ssh root@45.76.123.45  # ← Ihre Redirector-IP

# Schritt 2: Skripte holen
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts

# Schritt 3: Config erstellen und bearbeiten
cp config.example config
nano config

# Im Editor:
# - Ändern Sie: SERVER_TYPE="redirector"
# - Ändern Sie: REDIRECTOR_TYPE="nginx"
# - Ändern Sie: REDIRECTOR_DOMAIN="cdn.example.com"
# - Ändern Sie: C2_SERVER_IP="49.12.34.56" (Teamserver!)
# - Ändern Sie: ADMIN_EMAIL="admin@example.com"
# - Speichern: Ctrl+O, Enter, Ctrl+X

# Schritt 4: Installation starten
chmod +x auto_setup.sh
sudo ./auto_setup.sh

# Schritt 5: WARTEN (5-10 Min)

# Schritt 6: Credentials notieren
cat /root/REDIRECTOR_CREDENTIALS.txt

# Schritt 7: Testen
curl https://cdn.example.com/
# Sollte Webseite zeigen!

# Schritt 8: Credentials löschen
shred -vfz -n 10 /root/REDIRECTOR_CREDENTIALS.txt

# ✅ FERTIG! Redirector läuft!
```

---

## 🧪 Test nach Installation

### Von Ihrem PC:

```bash
# Test 1: Teamserver erreichbar?
nc -zv 49.12.34.56 40056
# → Connection succeeded! ✓

# Test 2: Redirector erreichbar?
curl https://cdn.example.com/
# → HTML-Webseite erscheint ✓

# Test 3: Redirector → Teamserver?
curl -v https://cdn.example.com/api/test 2>&1 | grep "Connected"
# → Zeigt Verbindung ✓
```

---

## 🎯 Verwendung nach Installation

### Havoc Client verbinden:

```
1. Havoc Client auf Ihrem PC starten
2. "New Profile" erstellen
3. Eingeben:
   Host:     49.12.34.56  ← Ihre TEAMSERVER-IP
   Port:     40056
   User:     admin
   Password: MeinSuperSicheresPasswort123!
4. "Connect"
5. ✓ Verbunden!
```

### Payload generieren:

```
1. "Attack" → "Payload"
2. Listener: "HTTPS Listener"
3. Arch: x64
4. Format: Windows Exe
5. "Generate"
6. Speichern

→ Payload verbindet sich zu: https://cdn.example.com:443
→ Redirector leitet weiter zu: Teamserver
→ Session erscheint in Havoc Client!
```

---

## 🔧 Troubleshooting

### Problem: "config Datei nicht gefunden"

**Lösung:**

```bash
# Prüfen ob config.example existiert:
ls -la config.example

# Falls ja:
cp config.example config
nano config

# Falls nein:
# Sind Sie im richtigen Verzeichnis?
pwd
# Sollte zeigen: /root/New-project/scripts

cd /root/New-project/scripts
```

---

### Problem: "SERVER_TYPE nicht gesetzt"

**Lösung:**

```bash
# Config prüfen:
cat config | grep SERVER_TYPE

# Sollte zeigen:
# SERVER_TYPE="teamserver"
# ODER
# SERVER_TYPE="redirector"

# Falls leer:
nano config
# Setzen Sie: SERVER_TYPE="teamserver"
```

---

### Problem: Installation bricht ab

**Lösung:**

```bash
# Log-Datei prüfen:
tail -n 50 /var/log/havoc_auto_setup_*.log

# Neustart:
sudo ./auto_setup.sh
# Script ist idempotent (kann mehrmals ausgeführt werden)
```

---

### Problem: SSL-Zertifikat fehlgeschlagen

**Ursache:** DNS nicht korrekt

**Lösung:**

```bash
# 1. DNS prüfen:
dig cdn.example.com

# 2. Sollte Ihre REDIRECTOR_IP zeigen

# 3. Falls nicht: Warten oder DNS korrigieren

# 4. SSL manuell nachholen:
sudo certbot --nginx -d cdn.example.com

# Oder in config:
# AUTO_SSL="false"
# Und später manuell
```

---

## 📊 Vergleich: Manual vs. Automatisiert

| Was | Manual | Automatisiert |
|-----|--------|---------------|
| **Config-Eingaben** | ~10x während Installation | 1x vorher in Datei |
| **Fehleranfällig** | Ja (Tippfehler) | Nein |
| **Reproduzierbar** | Schwer | Einfach (gleiche config) |
| **Zeit** | 20-30 Min | 10-15 Min |
| **Für Multiple Server** | Jedes Mal neu eingeben | Config kopieren |

---

## 🎉 Zusammenfassung

### **Verwendung in 3 Schritten:**

```bash
# 1. Config erstellen
cp config.example config && nano config

# 2. Werte ausfüllen (2 Minuten)

# 3. Script starten
sudo ./auto_setup.sh

# → Fertig! Alles automatisch!
```

### **Vorteile:**

✅ **Keine Interaktion** während Installation  
✅ **Reproduzierbar** (gleiche config = gleiches Ergebnis)  
✅ **Schneller** als manuelle Eingaben  
✅ **Weniger Fehler** (keine Tippfehler)  
✅ **Für Multiple Server** (config kopieren)  

---

**Alle Skripte sind gepusht und ready to use! 🚀**

---

**Erstellt:** 2026-02-05  
**Version:** 1.0
