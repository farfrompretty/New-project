# Komplette Checkliste - Haben Sie alles?

> **Prüfen Sie ob Sie bereit sind für Havoc C2 Setup!**

---

## ✅ WAS SIE HABEN:

```
✅ 2 VPS bestellt (BuyVM + Njalla)
✅ Domain registriert
```

**Fast fertig! Aber es fehlen noch ein paar Dinge...**

---

## 📋 KOMPLETTE CHECKLISTE

### ✅ INFRASTRUKTUR (Server & Domain)

- [x] **VPS 1 - Teamserver** (BuyVM)
  - Provider: BuyVM
  - Plan: Slice 2048 (2 GB RAM)
  - Location: Luxembourg
  - OS: Ubuntu 22.04
  - IP-Adresse erhalten: _______________
  - SSH-Zugang funktioniert: [ ]

- [x] **VPS 2 - Redirector** (Njalla)
  - Provider: Njalla
  - Plan: VPS 1024 (1 GB RAM)
  - Location: Stockholm/Amsterdam
  - OS: Ubuntu 22.04
  - IP-Adresse erhalten: _______________
  - SSH-Zugang funktioniert: [ ]

- [x] **Domain**
  - Domain-Name: _______________
  - Registrar: Njalla/1984
  - DNS konfiguriert: [ ]
  - DNS propagiert (zeigt auf Redirector): [ ]

---

### ❓ ZUGANG & CREDENTIALS (Brauchen Sie noch!)

- [ ] **SSH-Key erstellt**
  ```bash
  ssh-keygen -t ed25519 -C "havoc-c2"
  cat ~/.ssh/id_ed25519.pub
  ```
  - Public Key zu VPS hinzugefügt: [ ]
  - Private Key sicher gespeichert: [ ]

- [ ] **Password Manager**
  - Für Teamserver-Credentials
  - Für Operator-Passwörter
  - Für VPS-Root-Passwörter
  - Empfehlung: Bitwarden, KeePassXC

- [ ] **Sichere Notizen**
  - VPS-IPs notiert
  - Domain notiert
  - Provider-Zugangsdaten notiert

---

### 💻 CLIENT-SOFTWARE (Auf IHREM PC - fehlt noch!)

- [ ] **Havoc Client installiert** (auf Ihrem Kali/Ubuntu PC)
  ```bash
  cd ~
  git clone https://github.com/HavocFramework/Havoc.git
  cd Havoc
  make client-build
  ```
  - Kompilierung erfolgreich: [ ]
  - Client startet: [ ]

- [ ] **SSH-Client**
  - Linux/Mac: Terminal (schon da ✅)
  - Windows: PuTTY oder PowerShell

- [ ] **Hilfs-Tools** (optional, aber nützlich)
  ```bash
  sudo apt install -y netcat-traditional curl wget dig nmap
  ```

---

### 🔐 SICHERHEIT (Wichtig!)

- [ ] **Anonyme Email**
  - ProtonMail / Tutanota
  - Für Provider-Registrierung
  - NICHT Ihre persönliche Email!

- [ ] **VPN oder Tor** (empfohlen)
  - Für Verbindung zu VPS
  - Nicht direkt von Heim-IP
  - Empfehlung: Mullvad VPN (akzeptiert XMR!)

- [ ] **Monero Wallet**
  - Für monatliche Zahlungen
  - Seed-Phrase gesichert
  - Ausreichend XMR für 2-3 Monate

---

### 📝 DOKUMENTATION (Haben Sie schon!)

- [x] **Installation-Skripte**
  - One-Liner Standalone-Skripte ✅
  - Keine Config nötig ✅

- [x] **Anleitungen**
  - SETUP_BUYVM_MONERO.md ✅
  - DOMAINS_MIT_MONERO.md ✅
  - Alle anderen Guides ✅

---

## ❌ WAS FEHLT NOCH:

### 1. **DNS-Konfiguration** ⚠️ WICHTIG!

**Sie MÜSSEN noch DNS konfigurieren:**

```bash
# Ihre Domain muss auf Redirector-IP zeigen!

Bei Cloudflare/Njalla/etc.:
DNS → Add Record:
  Type:    A
  Name:    cdn (oder @)
  Content: [REDIRECTOR-IP]
  TTL:     300

Test nach 5 Min:
  dig cdn-api-services.com
  → Sollte Ihre REDIRECTOR-IP zeigen
```

**Ohne DNS:** Payloads können nicht zu Redirector verbinden!

---

### 2. **Havoc Client** auf Ihrem PC ⚠️ WICHTIG!

**Sie brauchen den Client um zu verbinden:**

```bash
# Auf Ihrem Kali Linux PC:
cd ~
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc

# Dependencies
sudo apt install -y build-essential cmake qtbase5-dev \
    qtdeclarative5-dev libqt5websockets5-dev golang-go

# Kompilieren (10-15 Min)
make client-build

# Starten
cd Build/bin
./Havoc
```

**Ohne Client:** Sie können nicht zu Teamserver verbinden!

---

### 3. **Test-Umgebung** (Optional, aber empfohlen)

**Für Payload-Tests:**

- [ ] **Windows VM** (VirtualBox/VMware)
  - Windows 10/11 Evaluation (90 Tage kostenlos)
  - Download: https://www.microsoft.com/software-download/windows10
  - RAM: 4 GB
  - Disk: 40 GB

---

## 🎯 KOMPLETTE REIHENFOLGE:

### Was Sie JETZT machen müssen:

```
✅ 1. VPS bestellt (BuyVM + Njalla)         → HABEN SIE ✓
✅ 2. Domain registriert                    → HABEN SIE ✓

❗ 3. DNS konfigurieren                     → MÜSSEN SIE NOCH TUN!
     Domain → Redirector-IP

❗ 4. SSH-Keys erstellen                    → FALLS NOCH NICHT
     ssh-keygen

❗ 5. Teamserver installieren               → MÜSSEN SIE NOCH TUN!
     curl -s https://raw.../install_teamserver_standalone.sh | sudo bash

❗ 6. Redirector installieren               → MÜSSEN SIE NOCH TUN!
     curl -s https://raw.../install_redirector_standalone.sh | sudo bash

❗ 7. Havoc Client installieren (Ihr PC)   → MÜSSEN SIE NOCH TUN!
     git clone https://github.com/HavocFramework/Havoc.git
     make client-build

❗ 8. Client verbinden                      → MÜSSEN SIE NOCH TUN!
     Host: [Teamserver-IP], Port: 40056

✅ 9. FERTIG! Einsatzbereit!
```

---

## 🔍 FEHLENDE KOMPONENTEN IM DETAIL:

### 1️⃣ DNS-Konfiguration (5 Minuten)

**Wo:** Bei Ihrem Domain-Registrar (Njalla Dashboard)

```
Njalla Dashboard:
→ Domains
→ Ihre Domain anklicken
→ DNS Records
→ Add Record:
   Type: A
   Name: @ (für example.com)
         oder cdn (für cdn.example.com)
   Data: [REDIRECTOR-IP von Njalla]
→ Save

Warten 2-5 Minuten

Test:
  dig ihre-domain.com
  → Sollte REDIRECTOR-IP zeigen
```

**Ohne DNS:** Beacons können Domain nicht auflösen → Keine Sessions!

---

### 2️⃣ Havoc Client (15 Minuten Installation)

**Wo:** Auf Ihrem lokalen PC/Laptop (Kali Linux)

```bash
cd ~
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc

sudo apt install -y build-essential cmake qtbase5-dev \
    qtdeclarative5-dev libqt5websockets5-dev golang-go

make client-build

# Nach 10-15 Min:
cd Build/bin
./Havoc
```

**Ohne Client:** Sie können nicht zum Teamserver verbinden!

---

### 3️⃣ SSH-Keys (2 Minuten)

**Falls noch nicht vorhanden:**

```bash
# Erstellen:
ssh-keygen -t ed25519 -C "havoc-c2-operations"

# Prompts:
# Enter file: [Enter]
# Passphrase: [Enter oder Passwort]

# Public Key anzeigen:
cat ~/.ssh/id_ed25519.pub

# Zu VPS hinzufügen:
# BuyVM/Njalla: Bei Bestellung oder später in Console
```

---

## 🎬 ABLAUF NACH VPS-ERHALT:

### Minute 0-5: DNS konfigurieren

```
1. Njalla Dashboard → DNS
2. A-Record: ihre-domain.com → REDIRECTOR-IP
3. Speichern
```

### Minute 5-20: Teamserver installieren

```bash
ssh root@BUYVM_IP
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh | sudo bash
# Eingabe: ihre-domain.com
# Warten...
```

### Minute 20-30: Redirector installieren

```bash
ssh root@NJALLA_IP
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_redirector_standalone.sh | sudo bash
# Eingaben: Domain, Teamserver-IP, Email
# Warten...
```

### Minute 30-45: Havoc Client (parallel auf Ihrem PC)

```bash
# Auf Ihrem PC:
cd ~
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc
make client-build
```

### Minute 45: Verbinden & Testen

```
Havoc Client → Connect → Teamserver
Payload generieren → Testen
✅ FERTIG!
```

---

## 📊 FINALE CHECKLISTE VOR START:

### Haben Sie alles?

```
HARDWARE:
✅ 2 VPS aktiv (BuyVM + Njalla)
✅ Domain registriert
✅ Ihr PC/Laptop mit Kali Linux

ZUGANG:
✅ VPS-IPs bekannt
✅ SSH-Keys erstellt
✅ Root-Zugang zu beiden VPS

SOFTWARE (auf Ihrem PC):
❓ Git installiert?        sudo apt install git
❓ SSH-Client?             (Standard in Linux ✅)
❓ Havoc Client?           Muss noch installiert werden!

CREDENTIALS:
✅ Monero Wallet
✅ Ausreichend XMR (~0.15 XMR für erste Monate)
✅ Password Manager

KONFIGURATION:
❓ DNS konfiguriert?       MUSS NOCH GEMACHT WERDEN!
❓ Domain propagiert?      Nach DNS-Config warten

DOKUMENTATION:
✅ Alle Guides vorhanden
✅ Installations-Skripte ready
```

---

## 🎯 WAS FEHLT NOCH:

### 🔴 Zwingend notwendig:

1. **DNS-Konfiguration** ⚠️
   - Domain → Redirector-IP
   - **OHNE:** Payloads können nicht verbinden!

2. **Havoc Client** ⚠️
   - Auf Ihrem PC installieren
   - **OHNE:** Sie können nicht zum Teamserver verbinden!

3. **Installations-Skripte ausführen** ⚠️
   - Teamserver installieren
   - Redirector installieren
   - **OHNE:** Server sind leer, keine C2-Software!

### 🟡 Sehr empfohlen:

4. **SSH-Keys**
   - Sicherer als Passwörter
   - Falls noch nicht vorhanden

5. **Password Manager**
   - Für Credentials
   - KeePassXC, Bitwarden, etc.

6. **VPN/Tor**
   - Für anonymen Zugriff
   - Mullvad VPN (akzeptiert XMR!)

### 🟢 Optional (aber nützlich):

7. **Windows Test-VM**
   - Für Payload-Tests
   - VirtualBox + Windows 10

8. **Monitoring-Tools**
   - Uptime-Monitoring
   - Log-Analyse

---

## 🚀 READY-TO-GO CHECKLISTE:

**Prüfen Sie diese Punkte ab:**

```
PHASE 1 - VORBEREITUNG:
[ ] VPS 1 (BuyVM) läuft
[ ] VPS 2 (Njalla) läuft
[ ] Domain registriert
[ ] VPS-IPs notiert
[ ] SSH-Keys erstellt
[ ] Kann zu beiden VPS per SSH verbinden

PHASE 2 - DNS:
[ ] A-Record erstellt (Domain → Redirector-IP)
[ ] DNS propagiert (dig ihre-domain.com zeigt IP)
[ ] DNS funktioniert (curl http://ihre-domain.com)

PHASE 3 - INSTALLATION:
[ ] Teamserver-Installation gestartet
[ ] Teamserver läuft (systemctl status havoc-teamserver)
[ ] Teamserver-Port 40056 erreichbar (nc -zv IP 40056)
[ ] Teamserver-Credentials notiert

[ ] Redirector-Installation gestartet
[ ] Redirector läuft (systemctl status nginx)
[ ] SSL-Zertifikat installiert (https funktioniert)
[ ] Redirector leitet zu Teamserver (Test-Request)

PHASE 4 - CLIENT:
[ ] Havoc Client auf PC installiert
[ ] Client startet ohne Fehler
[ ] Profil erstellt (Teamserver-IP, Port, Credentials)
[ ] Verbindung erfolgreich
[ ] Listener sichtbar und gestartet

PHASE 5 - TEST:
[ ] Payload generiert (mit Redirector-Domain!)
[ ] Payload auf Test-VM ausgeführt
[ ] Session erscheint in Havoc Client
[ ] Kommandos funktionieren (whoami, etc.)

✅ WENN ALLE ABGEHAKT → EINSATZBEREIT!
```

---

## 🛠️ WAS SIE NOCH TUN MÜSSEN:

### Schritt 1: DNS konfigurieren (JETZT!)

```bash
# Bei Njalla (falls Domain dort):
1. Njalla Dashboard → Domains → Ihre Domain
2. DNS Records → Add Record
3. Type: A
   Name: @ (für root) oder cdn (für subdomain)
   Data: [Ihre NJALLA_REDIRECTOR_IP]
4. Save

# Bei anderem Provider:
# Ähnliches Vorgehen in deren DNS-Panel

# Testen (nach 5 Min):
dig ihre-domain.com

# Sollte zeigen:
;; ANSWER SECTION:
ihre-domain.com.  300  IN  A  194.XXX.XXX.XXX
                              ↑ Ihre Redirector-IP
```

✅ **Checkpoint:** DNS zeigt auf Redirector

---

### Schritt 2: Teamserver installieren

```bash
# SSH zu BuyVM:
ssh root@IHRE_BUYVM_IP

# ONE-LINER:
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh | sudo bash

# Eingabe wenn gefragt:
Listener Host: ihre-domain.com

# Warten 15 Min...

# Credentials notieren:
cat /root/TEAMSERVER_ZUGANGSDATEN.txt

# Kopieren in Password-Manager!
```

✅ **Checkpoint:** Teamserver läuft

---

### Schritt 3: Redirector installieren

```bash
# SSH zu Njalla:
ssh root@IHRE_NJALLA_IP

# ONE-LINER:
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_redirector_standalone.sh | sudo bash

# Eingaben:
Domain: ihre-domain.com
Teamserver-IP: [BuyVM-IP]
Email: admin@ihre-domain.com

# Warten 10 Min...

# Test:
curl https://ihre-domain.com/
```

✅ **Checkpoint:** Redirector läuft

---

### Schritt 4: Havoc Client installieren (Ihr PC)

```bash
# Auf Ihrem Kali Linux:
cd ~
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc

# Dependencies:
sudo apt install -y build-essential cmake qtbase5-dev \
    qtdeclarative5-dev libqt5websockets5-dev golang-go

# Kompilieren (10-15 Min):
make client-build

# Starten:
cd Build/bin
./Havoc
```

✅ **Checkpoint:** Client läuft

---

### Schritt 5: Verbinden

```
Im Havoc Client:
1. "+" oder "Havoc" → "Connect"
2. New Profile:
   Host: [BuyVM Teamserver-IP]
   Port: 40056
   User: admin
   Pass: [Generiertes Passwort]
3. Connect

✅ Verbunden!
```

---

## 📦 ZUSÄTZLICH EMPFOHLEN:

### Nützliche Tools auf Ihrem PC:

```bash
# SSH-Tools
sudo apt install -y openssh-client sshpass

# Netzwerk-Tools
sudo apt install -y netcat-traditional nmap curl wget dnsutils

# Monitoring
sudo apt install -y htop iftop

# Payload-Handling
sudo apt install -y upx-ucl yara python3-pefile

# Optional: Obfuskation
sudo apt install -y mingw-w64 wine64
pip3 install pefile pyinstaller
```

---

## 🎁 BONUS: Was Sie NICHT brauchen

### ❌ NICHT nötig:

- ❌ Zusätzliche Software-Lizenzen (alles Open Source!)
- ❌ Code-Signing-Zertifikat (optional)
- ❌ Kommerzielle SSL (Let's Encrypt reicht!)
- ❌ Load Balancer (bei 2 VPS nicht nötig)
- ❌ Backup-Service (manuell reicht)
- ❌ CDN-Service (Redirector IST Ihr CDN)
- ❌ Weitere Domains (1 reicht für Start)

---

## 💡 QUICK-START nach VPS-Erhalt:

```bash
# === AUF IHREM KALI PC (einmalig) ===

# 1. Havoc Client installieren
cd ~ && git clone https://github.com/HavocFramework/Havoc.git && cd Havoc && sudo apt install -y build-essential cmake qtbase5-dev qtdeclarative5-dev libqt5websockets5-dev golang-go && make client-build

# === AUF TEAMSERVER (BuyVM) ===

# 2. SSH verbinden
ssh root@BUYVM_IP

# 3. Installation
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh | sudo bash

# === AUF REDIRECTOR (Njalla) ===

# 4. SSH verbinden  
ssh root@NJALLA_IP

# 5. Installation
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_redirector_standalone.sh | sudo bash

# === VERBINDEN ===

# 6. Havoc Client starten
cd ~/Havoc/Build/bin && ./Havoc

# 7. Connect zu Teamserver

# ✅ FERTIG!
```

---

## 📊 ZUSAMMENFASSUNG:

### ✅ WAS SIE HABEN:

- VPS 1 (BuyVM Teamserver)
- VPS 2 (Njalla Redirector)  
- Domain

### ❗ WAS NOCH FEHLT:

1. **DNS-Konfiguration** (5 Min) ⚠️ Wichtig!
2. **Teamserver-Installation** (15 Min)
3. **Redirector-Installation** (10 Min)
4. **Havoc Client auf Ihrem PC** (15 Min)

### ⏱️ ZEITPLAN:

```
DNS-Config:           5 Min
Teamserver-Install:   15 Min
Redirector-Install:   10 Min
Client-Install:       15 Min (parallel möglich)
Verbinden & Testen:   5 Min
──────────────────────────────
TOTAL:                45-50 Min
```

### 💰 KEINE WEITEREN KOSTEN:

- ✅ Software: €0 (Open Source)
- ✅ SSL: €0 (Let's Encrypt)
- ✅ Installation: €0 (Skripte kostenlos)

**Nur monatlich:** ~€23/Monat für VPS + Domain

---

## 🎯 IHR NÄCHSTER SCHRITT:

**1. DNS KONFIGURIEREN (jetzt gleich!):**

```
Njalla Dashboard → DNS → A-Record hinzufügen
ihre-domain.com → NJALLA_REDIRECTOR_IP
```

**2. Dann VPS installieren (wenn DNS propagiert ist):**

Folgen Sie: `SETUP_BUYVM_MONERO.md` ab "PHASE 4: Installation"

---

**Sie haben fast alles! Nur noch DNS + Installationen ausführen! 🚀**

---

**Erstellt:** 2026-02-05  
**Version:** 1.0
