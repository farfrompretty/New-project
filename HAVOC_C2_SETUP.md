# Havoc C2 Server - Komplette Einrichtungsanleitung

> **⚠️ RECHTLICHER HINWEIS:**
> Diese Dokumentation ist ausschließlich für autorisierte Penetrationstests, Red Team Übungen mit schriftlicher Genehmigung und Sicherheitsforschung in kontrollierten Laborumgebungen gedacht. Unbefugter Einsatz ist illegal.

---

## 📋 Inhaltsverzeichnis

1. [Übersicht](#übersicht)
2. [Systemanforderungen](#systemanforderungen)
3. [Infrastruktur-Planung](#infrastruktur-planung)
4. [Havoc C2 Installation](#havoc-c2-installation)
5. [Teamserver Konfiguration](#teamserver-konfiguration)
6. [Client Installation](#client-installation)
7. [Listener Konfiguration](#listener-konfiguration)
8. [Nächste Schritte](#nächste-schritte)

---

## Übersicht

**Havoc** ist ein modernes, open-source Command & Control Framework für Red Team Operationen. Es bietet:

- ✅ Moderne, intuitive GUI
- ✅ Mehrere Listener-Typen (HTTP/HTTPS, SMB, etc.)
- ✅ Vollständig anpassbare Agents (Demons)
- ✅ Post-Exploitation Module
- ✅ Team-Kollaboration
- ✅ Aktive Community

**Projekt-Repository:** https://github.com/HavocFramework/Havoc

---

## Systemanforderungen

### Teamserver (C2 Server)

**Minimum:**
- **OS:** Ubuntu 20.04/22.04 LTS oder Debian 11/12
- **CPU:** 2 Cores
- **RAM:** 2 GB
- **Storage:** 20 GB SSD
- **Netzwerk:** Dedizierte IP-Adresse

**Empfohlen:**
- **CPU:** 4 Cores
- **RAM:** 4 GB
- **Storage:** 40 GB SSD
- **Netzwerk:** Dedizierte IP + Domain

### Client (Operator Workstation)

- **OS:** Kali Linux, Ubuntu, oder Windows 10/11
- **RAM:** 4 GB minimum
- **Qt5 Dependencies**

---

## Infrastruktur-Planung

### Architektur-Optionen

#### Option 1: Einfaches Setup (Lab/Training)
```
[Operator] → [Havoc Teamserver] ← [Target]
```

#### Option 2: Mit Redirector (Empfohlen für echte Engagements)
```
[Operator] → [Havoc Teamserver] ← [Redirector/Proxy] ← [Target]
```

#### Option 3: Mit Domain Fronting (Maximale OPSEC)
```
[Operator] → [Havoc Teamserver] ← [CDN/Cloudflare] ← [Target]
```

**Siehe:** `INFRASTRUCTURE_SETUP.md` für Details zu Redirectors und Domain-Fronting.

---

## Havoc C2 Installation

### Schritt 1: Server Vorbereitung

Aktualisieren Sie Ihr System:

```bash
sudo apt update && sudo apt upgrade -y
```

Installieren Sie erforderliche Dependencies:

```bash
sudo apt install -y git build-essential apt-utils cmake libfontconfig1 \
    libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev \
    libncurses5-dev libgdbm-dev libssl-dev libreadline-dev libffi-dev \
    libsqlite3-dev libbz2-dev mesa-common-dev qtbase5-dev qtchooser \
    qt5-qmake qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev \
    qtdeclarative5-dev golang-go qtbase5-dev libqt5websockets5-dev \
    libspdlog-dev python3-dev libboost-all-dev mingw-w64 nasm
```

### Schritt 2: Havoc Framework klonen

```bash
cd /opt
sudo git clone https://github.com/HavocFramework/Havoc.git
cd Havoc
```

### Schritt 3: Teamserver kompilieren

```bash
cd teamserver
sudo go mod download golang.org/x/sys
sudo go mod download github.com/ugorji/go
cd ..
```

Kompilieren:

```bash
sudo make ts-build
```

### Schritt 4: Client kompilieren (auf Ihrer Workstation)

```bash
cd /opt/Havoc
sudo make client-build
```

---

## Teamserver Konfiguration

### Profil erstellen

Erstellen Sie eine Konfigurationsdatei:

```bash
sudo nano /opt/Havoc/profiles/havoc.yaotl
```

**Basis-Konfiguration:**

```yaml
Teamserver:
  Host: 0.0.0.0
  Port: 40056
  
  Build:
    Compiler64: "x86_64-w64-mingw32-gcc"
    Compiler86: "i686-w64-mingw32-gcc"
    Nasm: "/usr/bin/nasm"

Operators:
  - Name: admin
    Password: "IhrSicheresPasswort123!"
  
  - Name: operator1
    Password: "Operator1Passwort!"

Listeners:
  - Name: "HTTPS Listener"
    Protocol: https
    Hosts:
      - "ihre-domain.com"
    Port: 443
    HostBind: 0.0.0.0
    PortBind: 443
    Secure: true
    
    Response:
      Headers:
        Server: "Apache/2.4.49 (Unix)"
        Content-Type: "text/html; charset=UTF-8"
```

**Für SSL/TLS-Konfiguration siehe:** `SSL_CERTIFICATE_SETUP.md`

### Teamserver starten

```bash
cd /opt/Havoc
sudo ./havoc server --profile ./profiles/havoc.yaotl -v --debug
```

**Als systemd Service (empfohlen):**

Erstellen Sie Service-Datei:

```bash
sudo nano /etc/systemd/system/havoc-teamserver.service
```

Inhalt:

```ini
[Unit]
Description=Havoc C2 Teamserver
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/Havoc
ExecStart=/opt/Havoc/havoc server --profile /opt/Havoc/profiles/havoc.yaotl -v
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Service aktivieren:

```bash
sudo systemctl daemon-reload
sudo systemctl enable havoc-teamserver
sudo systemctl start havoc-teamserver
sudo systemctl status havoc-teamserver
```

---

## Client Installation

### Auf Kali Linux / Ubuntu

```bash
cd /opt/Havoc
./havoc client
```

### Verbindung zum Teamserver

1. Starten Sie den Havoc Client
2. Klicken Sie auf **"Profiles" → "New Profile"**
3. Geben Sie ein:
   - **Profile Name:** "Main Teamserver"
   - **Host:** IP-Adresse oder Domain Ihres Teamservers
   - **Port:** 40056 (Standard)
   - **User:** admin
   - **Password:** IhrSicheresPasswort123!
4. Klicken Sie auf **"Save"** und dann **"Connect"**

---

## Listener Konfiguration

### HTTPS Listener erstellen

1. Im Havoc Client: **"View" → "Listeners"**
2. Klicken Sie **"Add"**
3. Konfiguration:
   - **Name:** "Main HTTPS"
   - **Protocol:** HTTPS
   - **Host:** Ihre Domain oder IP
   - **Port:** 443
   - **Host (Bind):** 0.0.0.0
   - **Port (Bind):** 443

### Payload generieren

1. **"Attack" → "Payload"**
2. Wählen Sie:
   - **Listener:** "Main HTTPS"
   - **Arch:** x64 oder x86
   - **Format:** Windows Exe, Shellcode, DLL, etc.
3. Klicken Sie **"Generate"**
4. Speichern Sie die Payload

### Session-Management

Wenn ein Agent sich verbindet:
- Sessions erscheinen im **"Sessions"** Tab
- Rechtsklick auf Session für Interaktion
- **"Interact"** öffnet Shell
- **"Explore"** für File Browser

---

## Nächste Schritte

1. ✅ **Redirectors einrichten:** Siehe `INFRASTRUCTURE_SETUP.md`
2. ✅ **SSL-Zertifikate:** Siehe `SSL_CERTIFICATE_SETUP.md`
3. ✅ **OPSEC-Härtung:** Siehe `OPSEC_GUIDE.md`
4. ✅ **Budget-Hosting:** Siehe `HOSTING_GUIDE.md`
5. ✅ **Automatisierung:** Siehe `scripts/` Verzeichnis

---

## Wichtige Kommandos

### Teamserver Management

```bash
# Status prüfen
sudo systemctl status havoc-teamserver

# Logs anzeigen
sudo journalctl -u havoc-teamserver -f

# Neustart
sudo systemctl restart havoc-teamserver

# Stoppen
sudo systemctl stop havoc-teamserver
```

### Firewall-Konfiguration

```bash
# UFW aktivieren
sudo ufw enable

# Teamserver Port (nur von Ihrer IP)
sudo ufw allow from IHRE_IP to any port 40056

# HTTPS Listener
sudo ufw allow 443/tcp

# SSH (ändern Sie 22 zu Ihrem Port)
sudo ufw allow 22/tcp

# Status
sudo ufw status
```

---

## Troubleshooting

### Problem: Teamserver startet nicht

**Lösung:**
```bash
# Logs prüfen
sudo journalctl -u havoc-teamserver -n 50

# Ports prüfen
sudo netstat -tlnp | grep 40056

# Prozess killen falls hängend
sudo pkill -9 havoc
```

### Problem: Client kann sich nicht verbinden

**Checkliste:**
- [ ] Ist der Teamserver gestartet?
- [ ] Sind Firewall-Regeln korrekt?
- [ ] Stimmen Host/Port/Credentials?
- [ ] Netzwerk-Konnektivität vorhanden?

```bash
# Verbindung testen
nc -zv TEAMSERVER_IP 40056
```

### Problem: SSL/TLS Fehler

Siehe ausführliche Anleitung in: `SSL_CERTIFICATE_SETUP.md`

---

## Weitere Ressourcen

- **Offizielle Dokumentation:** https://havocframework.com/docs
- **GitHub Issues:** https://github.com/HavocFramework/Havoc/issues
- **Discord Community:** https://discord.gg/havoc
- **Payload Development:** https://havocframework.com/docs/dev

---

## Sicherheitshinweise

⚠️ **WICHTIG:**

1. **Niemals** auf öffentlichen IP-Adressen ohne Absicherung betreiben
2. **Starke Passwörter** für alle Operators verwenden
3. **Firewall-Regeln** strikt konfigurieren
4. **Logs regelmäßig** überprüfen und rotieren
5. **VPN-Zugang** für Operator-Verbindungen erwägen
6. **Backups** der Teamserver-Konfiguration erstellen
7. **Post-Engagement Cleanup** nicht vergessen

---

**Erstellt:** 2026-02-05
**Version:** 1.0
**Autor:** C2 Infrastructure Setup Guide
