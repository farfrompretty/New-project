# Download-Anleitung: Skripte auf Ihren PC/Server laden

> **Problem:** GitHub zeigt HTML statt der Skript-Datei  
> **Lösung:** Richtige URLs und Download-Methoden verwenden

---

## 🎯 Die 4 Methoden zum Herunterladen

### ✅ Methode 1: Git Clone (EMPFOHLEN)

**Das gesamte Repository herunterladen:**

```bash
# Auf Linux/Mac/WSL:
cd ~
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4

# Alle Skripte sind jetzt in:
cd scripts/
ls -la

# Ausführbar machen:
chmod +x *.sh
```

**Vorteile:**
- ✅ Alles auf einmal
- ✅ Einfache Updates mit `git pull`
- ✅ Alle Dateien korrekt

---

### ✅ Methode 2: Einzelne Skripte mit curl/wget

**Wichtig: RAW-URLs verwenden!**

#### Die richtigen RAW-URLs:

```bash
# Master-Setup (Vollautomatisch)
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/master_setup_automated.sh

# Teamserver
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_havoc_teamserver.sh

# Nginx Redirector
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_redirector_nginx.sh

# Apache Redirector
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_redirector_apache.sh

# Caddy Redirector
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_redirector_caddy.sh

# Traefik Redirector
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_redirector_traefik.sh

# Server Härtung
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/harden_server.sh

# Cleanup
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/cleanup_infrastructure.sh
```

**Oder mit wget:**

```bash
wget https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/master_setup_automated.sh
```

**Ausführbar machen:**

```bash
chmod +x *.sh
```

---

### ✅ Methode 3: Browser-Download (Windows)

**Schritt-für-Schritt:**

1. **Gehen Sie zum GitHub Repository:**
   ```
   https://github.com/farfrompretty/New-project/tree/cursor/c2-server-einrichtung-dbe4/scripts
   ```

2. **Klicken Sie auf das Skript** (z.B. `master_setup_automated.sh`)

3. **WICHTIG: Klicken Sie auf "Raw"** Button (oben rechts)
   - URL ändert sich zu: `https://raw.githubusercontent.com/...`

4. **Rechtsklick → "Speichern unter"**
   - Datei speichern als: `master_setup_automated.sh` (ohne .txt oder .html!)
   - **Dateiformat: "Alle Dateien (*.*)"** auswählen

5. **Per SCP/SFTP auf Server übertragen:**
   ```powershell
   # Windows PowerShell / CMD
   scp master_setup_automated.sh root@IHRE_SERVER_IP:/root/
   
   # Oder WinSCP verwenden (GUI)
   ```

---

### ✅ Methode 4: ZIP-Download (Komplettes Repo)

**Komplettes Repository als ZIP:**

```
1. Gehen Sie zu:
   https://github.com/farfrompretty/New-project

2. Klicken Sie auf "Code" (grüner Button)

3. "Download ZIP"

4. Entpacken Sie das ZIP

5. Navigieren Sie zu:
   New-project/scripts/

6. Alle Skripte sind dort!
```

**Auf Server übertragen:**

```bash
# Zip auf Server kopieren
scp -r scripts/ root@IHRE_SERVER_IP:/root/

# Auf Server:
cd /root/scripts
chmod +x *.sh
```

---

## 🔧 Troubleshooting: Häufige Probleme

### Problem 1: "Datei nicht gefunden" / 404 Error

**Ursache:** Falsche URL (GitHub HTML statt RAW)

**Falsch:**
```
https://github.com/farfrompretty/New-project/blob/cursor/c2-server-einrichtung-dbe4/scripts/master_setup_automated.sh
```

**Richtig:**
```
https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/master_setup_automated.sh
```

**Unterschied:**
- `github.com` → `raw.githubusercontent.com`
- `/blob/` entfernen

---

### Problem 2: Datei endet mit .html oder .txt

**Ursache:** Browser fügt Extension hinzu

**Lösung A (Linux/Mac):**
```bash
# Umbenennen
mv master_setup_automated.sh.html master_setup_automated.sh
mv master_setup_automated.sh.txt master_setup_automated.sh
```

**Lösung B (Windows):**
```powershell
# PowerShell
Rename-Item master_setup_automated.sh.html master_setup_automated.sh
```

**Lösung C (Browser):**
- "Speichern unter" Dialog
- Dateiformat: **"Alle Dateien"** wählen
- Dateiname: `master_setup_automated.sh` (ohne Extension!)

---

### Problem 3: "Permission denied" beim Ausführen

**Ursache:** Datei nicht ausführbar

**Lösung:**
```bash
chmod +x master_setup_automated.sh
```

---

### Problem 4: "Bad interpreter" oder "^M" Fehler

**Ursache:** Windows-Zeilenumbrüche (CRLF statt LF)

**Lösung:**
```bash
# dos2unix installieren
sudo apt install dos2unix

# Konvertieren
dos2unix master_setup_automated.sh

# Oder mit sed:
sed -i 's/\r$//' master_setup_automated.sh
```

---

### Problem 5: Git clone schlägt fehl

**Fehler:** `fatal: could not read Username`

**Lösung:**
```bash
# Public Repo, kein Login nötig:
git clone https://github.com/farfrompretty/New-project.git

# Falls trotzdem Problem:
# 1. HTTPS statt SSH verwenden
# 2. Branch explizit checkouten:
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git fetch origin cursor/c2-server-einrichtung-dbe4
git checkout cursor/c2-server-einrichtung-dbe4
```

---

## 📝 Quick-Start-Guide für verschiedene OS

### 🐧 Linux (Ubuntu/Kali/Debian)

```bash
# Methode 1: Git (empfohlen)
sudo apt install git -y
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4
cd scripts
chmod +x *.sh

# Methode 2: Direkt mit curl
mkdir -p ~/c2-scripts
cd ~/c2-scripts
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/master_setup_automated.sh
chmod +x master_setup_automated.sh

# Ausführen
sudo ./master_setup_automated.sh
```

---

### 🍎 macOS

```bash
# Git installieren (falls nicht vorhanden)
xcode-select --install

# Dann wie Linux:
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts
chmod +x *.sh
```

---

### 🪟 Windows (PowerShell)

```powershell
# Git für Windows installieren von:
# https://git-scm.com/download/win

# Dann:
git clone https://github.com/farfrompretty/New-project.git
cd New-project\scripts

# Auf Linux-Server übertragen:
scp *.sh root@IHRE_SERVER_IP:/root/scripts/

# Oder WSL2 verwenden:
wsl
cd /mnt/c/Users/IHR_NAME/Downloads/New-project/scripts
chmod +x *.sh
```

---

### 🪟 Windows (WSL2)

```bash
# In WSL2-Terminal:
cd ~
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4
cd scripts
chmod +x *.sh

# Direkt ausführen:
sudo ./master_setup_automated.sh
```

---

## 🎯 Empfohlene Methode nach Situation

### Situation 1: Ich will lokal auf meinem PC testen
```bash
# Git Clone (komplettes Repo)
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts
```

### Situation 2: Ich will auf einem VPS installieren
```bash
# SSH zum VPS
ssh root@IHRE_SERVER_IP

# Direkt wget/curl
wget https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/master_setup_automated.sh
chmod +x master_setup_automated.sh
sudo ./master_setup_automated.sh
```

### Situation 3: Ich bin auf Windows ohne Git
```
1. Browser: https://github.com/farfrompretty/New-project
2. "Code" → "Download ZIP"
3. Entpacken
4. WinSCP zum Server kopieren
```

---

## 🚀 Komplettes Beispiel (Start bis Ende)

### Auf einem frischen Ubuntu VPS:

```bash
# 1. SSH-Verbindung
ssh root@IHRE_SERVER_IP

# 2. Git installieren (falls nicht vorhanden)
apt update
apt install git -y

# 3. Repository klonen
cd /root
git clone https://github.com/farfrompretty/New-project.git
cd New-project

# 4. Branch wechseln
git checkout cursor/c2-server-einrichtung-dbe4

# 5. Zu Scripts navigieren
cd scripts

# 6. Ausführbar machen
chmod +x *.sh

# 7. Liste anzeigen
ls -lh

# Ausgabe sollte sein:
# -rwxr-xr-x 1 root root  20K cleanup_infrastructure.sh
# -rwxr-xr-x 1 root root  15K harden_server.sh
# -rwxr-xr-x 1 root root  18K install_havoc_teamserver.sh
# -rwxr-xr-x 1 root root  16K install_redirector_apache.sh
# -rwxr-xr-x 1 root root  17K install_redirector_caddy.sh
# -rwxr-xr-x 1 root root  16K install_redirector_nginx.sh
# -rwxr-xr-x 1 root root  19K install_redirector_traefik.sh
# -rwxr-xr-x 1 root root  25K master_setup_automated.sh
# -rw-r--r-- 1 root root  12K README.md

# 8. Master-Setup ausführen
sudo ./master_setup_automated.sh

# Fertig! 🎉
```

---

## 📦 Alternative: Offizieller Download-Link

Ich erstelle Ihnen auch ein **Download-Script** das alles automatisch lädt:

```bash
# Speichern Sie dies als download.sh:
curl -o download.sh https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/download_all_scripts.sh
chmod +x download.sh
./download.sh

# Dieser Script lädt automatisch alle anderen Skripte herunter!
```

---

## 🔍 Verifizierung

Nach dem Download, prüfen Sie:

```bash
# 1. Datei-Typ prüfen
file master_setup_automated.sh
# Sollte zeigen: "Bourne-Again shell script"
# NICHT: "HTML document"

# 2. Erste Zeilen ansehen
head -n 5 master_setup_automated.sh
# Sollte zeigen: #!/bin/bash
# NICHT: <!DOCTYPE html>

# 3. Ausführbar?
ls -l master_setup_automated.sh
# Sollte zeigen: -rwxr-xr-x (x = executable)

# 4. Test-Ausführung
./master_setup_automated.sh --help
# Sollte Script starten, nicht "command not found"
```

---

## 💡 Profi-Tipp: Direkter One-Liner

**Für erfahrene User (lädt und führt aus):**

```bash
# WARNUNG: Nur bei vertrauenswürdigen Quellen!
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/master_setup_automated.sh | sudo bash
```

**Sicherer: Erst prüfen, dann ausführen:**

```bash
# 1. Herunterladen
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/master_setup_automated.sh

# 2. Inhalt prüfen
less master_setup_automated.sh

# 3. Ausführen
chmod +x master_setup_automated.sh
sudo ./master_setup_automated.sh
```

---

## 📞 Hilfe bekommen

Falls weiterhin Probleme:

1. **GitHub Issues öffnen:**
   ```
   https://github.com/farfrompretty/New-project/issues
   ```

2. **Fehlermeldung posten:**
   ```bash
   # Output des Befehls kopieren:
   wget URL 2>&1 | tee error.log
   # error.log hochladen
   ```

3. **System-Info angeben:**
   ```bash
   cat /etc/os-release
   uname -a
   ```

---

## ✅ Checkliste: Download erfolgreich?

- [ ] Datei endet mit `.sh` (NICHT .html oder .txt)
- [ ] `file` Befehl zeigt "shell script"
- [ ] Erste Zeile ist `#!/bin/bash`
- [ ] Datei ist ausführbar (`chmod +x`)
- [ ] `./script.sh --help` zeigt Script-Output

Wenn alle ✅ → Bereit zum Ausführen! 🚀

---

**Erstellt:** 2026-02-05  
**Version:** 1.0
