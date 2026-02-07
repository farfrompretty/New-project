# Skript-Probleme lösen - Diagnose & Reparatur

> **Sie können kein Script ausführen? Wir finden das Problem!**

---

## 🔍 DIAGNOSE: Was ist das Problem?

### Schritt 1: Bitte führen Sie diese Befehle aus

```bash
# In Ihrem Terminal (auf Kali Linux):

# 1. Wo sind Sie?
pwd

# 2. Was ist im Verzeichnis?
ls -la

# 3. Versuchen Sie ein Script auszuführen (was passiert?)
./auto_setup.sh

# Oder:
bash auto_setup.sh
```

**Kopieren Sie den kompletten Output hier!**

Aber ich zeige Ihnen schon mal die häufigsten Probleme und Lösungen:

---

## 🚨 HÄUFIGSTE PROBLEME & LÖSUNGEN

### ❌ Problem 1: "Datei oder Verzeichnis nicht gefunden"

**Fehler sieht so aus:**

```bash
./auto_setup.sh
bash: ./auto_setup.sh: No such file or directory
```

**Diagnose:**

```bash
# Prüfen ob Datei existiert:
ls -la auto_setup.sh

# Wenn "No such file" → Datei ist nicht da!
```

**LÖSUNG A: Skripte sind nicht heruntergeladen**

```bash
# Repository klonen:
cd ~
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4
cd scripts

# Jetzt nochmal probieren:
ls -la
# Sollte zeigen: auto_setup.sh, install_*.sh, etc.
```

**LÖSUNG B: Falsches Verzeichnis**

```bash
# Wo bin ich?
pwd

# Sollte zeigen: /root/New-project/scripts
# ODER: /home/USERNAME/New-project/scripts

# Falls nicht, navigieren Sie:
cd ~/New-project/scripts
```

---

### ❌ Problem 2: "Permission denied"

**Fehler sieht so aus:**

```bash
./auto_setup.sh
bash: ./auto_setup.sh: Permission denied
```

**Diagnose:**

```bash
ls -la auto_setup.sh

# Output zeigt:
# -rw-r--r-- 1 user user 25000 Feb 5 10:00 auto_setup.sh
#  ↑
#  Kein 'x' = NICHT ausführbar!
```

**LÖSUNG: Ausführungsrechte setzen**

```bash
# Einzelne Datei:
chmod +x auto_setup.sh

# ALLE Skripte auf einmal:
chmod +x *.sh

# Überprüfen:
ls -la auto_setup.sh
# Sollte jetzt zeigen:
# -rwxr-xr-x 1 user user 25000 Feb 5 10:00 auto_setup.sh
#  ↑↑↑
#  'x' = Ausführbar! ✓

# Jetzt nochmal probieren:
./auto_setup.sh
```

---

### ❌ Problem 3: Script hat .html oder .txt Endung

**Diagnose:**

```bash
ls -la

# Output zeigt:
# auto_setup.sh.html
# ODER
# auto_setup.sh.txt
```

**LÖSUNG: Umbenennen**

```bash
# Falls .html:
mv auto_setup.sh.html auto_setup.sh

# Falls .txt:
mv auto_setup.sh.txt auto_setup.sh

# Falls mehrere:
rename 's/\.html$//' *.sh.html
rename 's/\.txt$//' *.sh.txt

# Ausführbar machen:
chmod +x *.sh

# Überprüfen:
ls -la
# Sollte zeigen: auto_setup.sh (ohne .html/.txt)
```

---

### ❌ Problem 4: "bad interpreter" oder "^M" Fehler

**Fehler sieht so aus:**

```bash
./auto_setup.sh
bash: ./auto_setup.sh: /bin/bash^M: bad interpreter: No such file or directory
```

**Ursache:** Windows-Zeilenumbrüche (CRLF statt LF)

**LÖSUNG:**

```bash
# dos2unix installieren:
sudo apt update
sudo apt install dos2unix -y

# Skript konvertieren:
dos2unix auto_setup.sh

# ALLE Skripte:
dos2unix *.sh

# Nochmal probieren:
./auto_setup.sh
```

**Alternative Lösung (ohne dos2unix):**

```bash
# Mit sed:
sed -i 's/\r$//' auto_setup.sh

# Alle Skripte:
sed -i 's/\r$//' *.sh
```

---

### ❌ Problem 5: "command not found"

**Fehler:**

```bash
./auto_setup.sh
-bash: ./auto_setup.sh: command not found
```

**LÖSUNG:**

```bash
# Versuch 1: Mit bash explizit ausführen
bash auto_setup.sh

# Versuch 2: Mit sh
sh auto_setup.sh

# Versuch 3: Absolute Path
/bin/bash ./auto_setup.sh

# Versuch 4: Source
source auto_setup.sh
```

---

### ❌ Problem 6: Muss als root ausgeführt werden

**Fehler:**

```bash
./auto_setup.sh
[!] Fehler: Bitte als root ausführen (sudo)
```

**LÖSUNG:**

```bash
# Mit sudo:
sudo ./auto_setup.sh

# Oder als root einloggen:
sudo su -
cd /root/New-project/scripts
./auto_setup.sh
```

---

### ❌ Problem 7: Git nicht installiert

**Fehler:**

```bash
git clone ...
bash: git: command not found
```

**LÖSUNG:**

```bash
# Git installieren:
sudo apt update
sudo apt install git -y

# Nochmal probieren:
git clone https://github.com/farfrompretty/New-project.git
```

---

## 🔧 KOMPLETTE REPARATUR-PROZEDUR

**Führen Sie diese Befehle der Reihe nach aus:**

```bash
# 1. Zum Home-Verzeichnis
cd ~

# 2. Altes Verzeichnis löschen (falls vorhanden und kaputt)
rm -rf New-project

# 3. Git sicherstellen
sudo apt update
sudo apt install git dos2unix -y

# 4. Repository neu klonen
git clone https://github.com/farfrompretty/New-project.git

# 5. Branch wechseln
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4

# 6. Zu Scripts navigieren
cd scripts

# 7. CRLF-Problem beheben
dos2unix *.sh 2>/dev/null || true

# 8. Ausführbar machen
chmod +x *.sh

# 9. Überprüfen
ls -la *.sh

# Sollte zeigen:
# -rwxr-xr-x ... auto_setup.sh
# -rwxr-xr-x ... install_havoc_teamserver.sh
# etc.

# 10. Test-Ausführung
./auto_setup.sh --help 2>&1 || echo "Script existiert aber braucht root"

# Wenn "braucht root" erscheint = ✓ Script funktioniert!
# Dann mit sudo:
sudo ./auto_setup.sh
```

---

## 🧪 DIAGNOSE-SCRIPT

**Speichern Sie dies als `diagnose.sh` und führen Sie es aus:**

```bash
cat > diagnose.sh << 'EOF'
#!/bin/bash

echo "=== DIAGNOSE-REPORT ==="
echo ""

echo "1. Aktuelles Verzeichnis:"
pwd
echo ""

echo "2. Inhalt des Verzeichnisses:"
ls -la
echo ""

echo "3. Git installiert?"
which git
echo ""

echo "4. Bash installiert?"
which bash
echo ""

echo "5. Scripts vorhanden?"
ls -la *.sh 2>/dev/null || echo "Keine .sh Dateien gefunden!"
echo ""

echo "6. Datei-Typen:"
file *.sh 2>/dev/null || echo "Keine .sh Dateien!"
echo ""

echo "7. Erste Zeilen von auto_setup.sh:"
head -n 5 auto_setup.sh 2>/dev/null || echo "auto_setup.sh nicht gefunden!"
echo ""

echo "8. Berechtigungen von auto_setup.sh:"
ls -l auto_setup.sh 2>/dev/null || echo "Datei nicht gefunden!"
echo ""

echo "=== ENDE ==="
EOF

chmod +x diagnose.sh
./diagnose.sh
```

**Kopieren Sie den kompletten Output und ich sage Ihnen was los ist!**

---

## 🎯 SCHRITT-FÜR-SCHRITT FÜR KALI LINUX

### KOMPLETTE Neuinstallation (garantiert funktionierend):

```bash
# === SCHRITT 1: Terminal öffnen ===
# Klick auf Terminal-Icon in Kali

# === SCHRITT 2: Zum Home ===
cd ~

# === SCHRITT 3: Alte Downloads löschen (falls vorhanden) ===
rm -rf New-project

# === SCHRITT 4: System vorbereiten ===
sudo apt update
sudo apt install -y git curl wget dos2unix

# === SCHRITT 5: Repository klonen ===
git clone https://github.com/farfrompretty/New-project.git

# Sollte zeigen:
# Cloning into 'New-project'...
# remote: Enumerating objects...
# ... 
# Receiving objects: 100% ...

# === SCHRITT 6: Branch wechseln ===
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4

# Sollte zeigen:
# Branch 'cursor/c2-server-einrichtung-dbe4' set up to track...

# === SCHRITT 7: Zu Scripts navigieren ===
cd scripts
pwd
# Sollte zeigen: /home/kali/New-project/scripts

# === SCHRITT 8: Dateien überprüfen ===
ls -la

# Sollte MINDESTENS zeigen:
# auto_setup.sh
# config.example
# install_havoc_teamserver.sh
# install_redirector_nginx.sh
# etc.

# === SCHRITT 9: Encoding-Probleme beheben ===
dos2unix *.sh

# === SCHRITT 10: Ausführbar machen ===
chmod +x *.sh

# === SCHRITT 11: Überprüfen ===
ls -la auto_setup.sh

# Sollte zeigen:
# -rwxr-xr-x 1 kali kali 25000 ... auto_setup.sh
#  ^^^
#  x = ausführbar! ✓

# === SCHRITT 12: Erste Zeile prüfen ===
head -n 1 auto_setup.sh

# MUSS zeigen:
# #!/bin/bash

# Falls zeigt <!DOCTYPE html> → Datei ist HTML, nicht Script!

# === SCHRITT 13: Test-Ausführung ===
./auto_setup.sh

# Sollte zeigen:
# [!] Fehler: Bitte als root ausführen (sudo)

# Das ist GUT! Script funktioniert!

# === SCHRITT 14: Mit sudo ausführen ===
sudo ./auto_setup.sh

# Sollte jetzt zeigen:
# [!] Fehler: config Datei nicht gefunden!
# Bitte erstellen Sie die Konfigurationsdatei:
#   1. cp config.example config
#   ...

# Das ist auch GUT! Script funktioniert!

# === SCHRITT 15: Config erstellen ===
cp config.example config
nano config

# Minimal ausfüllen:
#   SERVER_TYPE="teamserver"
#   ADMIN_PASSWORD="Test123!"
#   LISTENER_HOST="localhost"

# Speichern: Ctrl+O, Enter, Ctrl+X

# === SCHRITT 16: Finale Test-Ausführung ===
sudo ./auto_setup.sh

# Sollte jetzt starten:
# ╔═══════════════════════════════════════════╗
# ║  HAVOC C2 - VOLLAUTOMATISCHES SETUP      ║
# ╚═══════════════════════════════════════════╝
# [+] Lade Konfiguration...
# ...

# ✅ FUNKTIONIERT!
```

---

## 🆘 NOTFALL-LÖSUNG

Falls **GAR NICHTS** funktioniert:

### Alternative 1: Manueller Download

```bash
# 1. Einzelnes Script direkt herunterladen
cd ~
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/auto_setup.sh

# 2. Prüfen
file auto_setup.sh
# Sollte zeigen: "Bourne-Again shell script"
# NICHT: "HTML document"

# 3. Falls HTML:
# Dann ist URL falsch oder GitHub hat Problem
# Nutzen Sie Alternative 2

# 4. Ausführbar machen
chmod +x auto_setup.sh

# 5. Testen
./auto_setup.sh
```

---

### Alternative 2: Download-Helper nutzen

```bash
# Dieser Eine Befehl lädt alles herunter:
cd ~
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/download_all_scripts.sh | bash

# Das erstellt Ordner: havoc-c2-scripts/
cd havoc-c2-scripts

# Alle Skripte sollten da sein:
ls -la
```

---

### Alternative 3: ZIP-Download (Notlösung)

**Falls Git/Curl nicht funktioniert:**

1. **Browser öffnen:**
   ```
   https://github.com/farfrompretty/New-project
   ```

2. **"Code" → "Download ZIP"**

3. **ZIP speichern in Downloads**

4. **Im Terminal:**
   ```bash
   cd ~/Downloads
   unzip New-project-cursor-c2-server-einrichtung-dbe4.zip
   cd New-project-cursor-c2-server-einrichtung-dbe4/scripts
   chmod +x *.sh
   ./auto_setup.sh
   ```

---

## 🔍 ERWEITERTE DIAGNOSE

### Test 1: Bash funktioniert?

```bash
# Simple Bash testen:
bash --version

# Sollte zeigen:
# GNU bash, version 5.x.x

# Test-Script erstellen:
echo '#!/bin/bash' > test.sh
echo 'echo "Bash works!"' >> test.sh
chmod +x test.sh
./test.sh

# Sollte zeigen:
# Bash works!

# Wenn das funktioniert → Bash ist OK
```

---

### Test 2: Git funktioniert?

```bash
git --version

# Sollte zeigen:
# git version 2.x.x

# Falls "command not found":
sudo apt update
sudo apt install git -y
```

---

### Test 3: Dateien sind wirklich Shell-Skripte?

```bash
file auto_setup.sh

# KORREKT:
# auto_setup.sh: Bourne-Again shell script, ASCII text executable

# FALSCH:
# auto_setup.sh: HTML document, ASCII text
# → Datei ist HTML, nicht Bash-Script!

# FALSCH:
# auto_setup.sh: data
# → Datei ist beschädigt
```

**Falls HTML-Dokument:**

Die Datei ist falsch heruntergeladen!

```bash
# Lösche die falsche Datei:
rm auto_setup.sh

# Lade korrekt herunter:
wget https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/auto_setup.sh

# Prüfe nochmal:
file auto_setup.sh
# Jetzt sollte: "shell script" zeigen

# Ausführbar machen:
chmod +x auto_setup.sh
```

---

### Test 4: Erste Zeilen überprüfen

```bash
# Erste 10 Zeilen ansehen:
head -n 10 auto_setup.sh

# KORREKT sollte zeigen:
# #!/bin/bash
# #
# # VOLLAUTOMATISCHES HAVOC C2 SETUP
# #
# ...

# FALSCH würde zeigen:
# <!DOCTYPE html>
# <html>
# ...
# → Das ist HTML, kein Script!
```

---

## 🛠️ KOMPLETTE REPARATUR (Copy & Paste)

**Dieser Block behebt die häufigsten Probleme:**

```bash
#!/bin/bash
# Kopieren Sie diesen KOMPLETTEN Block und führen Sie ihn aus

echo "=== HAVOC C2 SCRIPTS - KOMPLETTE REPARATUR ==="
echo ""

# Cleanup
cd ~
rm -rf New-project havoc-c2-scripts

# System vorbereiten
echo "[1/6] Installiere benötigte Tools..."
sudo apt update -qq
sudo apt install -y git curl wget dos2unix file

# Repository klonen
echo "[2/6] Klone Repository..."
git clone https://github.com/farfrompretty/New-project.git
cd New-project
git checkout cursor/c2-server-einrichtung-dbe4

# Zu Scripts
echo "[3/6] Navigiere zu Scripts..."
cd scripts

# CRLF-Problem beheben
echo "[4/6] Behebe Encoding-Probleme..."
dos2unix *.sh 2>/dev/null || true

# Ausführbar machen
echo "[5/6] Setze Ausführungsrechte..."
chmod +x *.sh

# Überprüfen
echo "[6/6] Überprüfe Installation..."
echo ""
echo "Scripts gefunden:"
ls -lh *.sh
echo ""

echo "Datei-Typen:"
file auto_setup.sh install_havoc_teamserver.sh
echo ""

echo "Erste Zeile von auto_setup.sh:"
head -n 1 auto_setup.sh
echo ""

echo "=== REPARATUR ABGESCHLOSSEN ==="
echo ""
echo "Test-Ausführung:"
echo "  sudo ./auto_setup.sh"
echo ""
```

**Kopieren Sie den KOMPLETTEN Block oben und fügen Sie in Terminal ein!**

---

## 📱 BITTE SENDEN SIE MIR:

**Damit ich helfen kann, führen Sie aus:**

```bash
cd ~/New-project/scripts
ls -la
file auto_setup.sh
head -n 3 auto_setup.sh
./auto_setup.sh
```

**Und kopieren Sie den KOMPLETTEN Output!**

Dann kann ich genau sagen was das Problem ist.

---

## 💡 HÄUFIGSTE URSACHE

In 90% der Fälle ist das Problem:

**1. Nicht ausführbar** → `chmod +x *.sh`  
**2. Falsches Verzeichnis** → `cd ~/New-project/scripts`  
**3. HTML statt Script** → Neu downloaden mit RAW-URL  

---

## ✅ ERFOLGREICH, WENN:

```bash
./auto_setup.sh

# Zeigt:
╔═══════════════════════════════════════════════════════════════╗
║        HAVOC C2 - VOLLAUTOMATISCHES SETUP                   ║
╚═══════════════════════════════════════════════════════════════╝

[!] Fehler: config Datei nicht gefunden!
Bitte erstellen Sie die Konfigurationsdatei:
  1. cp config.example config
  ...
```

**Diese Fehlermeldung ist GUT!**  
Sie zeigt: Script läuft, braucht nur die Config!

Dann:
```bash
cp config.example config
nano config
# Ausfüllen...
sudo ./auto_setup.sh
```

---

**Erstellt:** 2026-02-05  
**Version:** 1.0
