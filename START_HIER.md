# ⚡ START HIER - 3-Schritte-Anleitung

> **Vollautomatisches Setup in 3 einfachen Schritten!**

---

## 🎯 Für 2-VPS-Setup (Hetzner + Vultr)

### Sie brauchen:
- ✅ 2 VPS bestellt (Hetzner + Vultr)
- ✅ Optional: Domain (z.B. example.com)
- ✅ 20 Minuten Zeit

**Kosten:** ~€10/Monat, Software komplett kostenlos!

---

## 📦 VPS 1: TEAMSERVER (Hetzner)

### 🔹 Schritt 1: Verbinden

```bash
ssh root@IHRE_TEAMSERVER_IP
```

---

### 🔹 Schritt 2: Skripte holen + Config ausfüllen

```bash
# Skripte downloaden
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts

# Config erstellen
cp config.example config
nano config
```

**Im Editor, ändern Sie NUR diese Zeilen:**

```bash
SERVER_TYPE="teamserver"

ADMIN_PASSWORD="IhrSicheresPasswort123!"

LISTENER_HOST="cdn.example.com"  # ← IHRE Domain (oder später Redirector-IP)
```

**Speichern:** `Ctrl+O`, `Enter`, `Ctrl+X`

---

### 🔹 Schritt 3: Installation starten

```bash
chmod +x auto_setup.sh
sudo ./auto_setup.sh
```

**Warten Sie 10-15 Minuten ☕**

**Fertig wenn erscheint:**
```
✅  TEAMSERVER ERFOLGREICH INSTALLIERT!
```

**Credentials notieren:**

```bash
cat /root/TEAMSERVER_CREDENTIALS.txt
```

**Wichtig kopieren:**
- IP: _______________
- Port: 40056
- User: admin
- Pass: _______________

**Dann löschen:**

```bash
shred -vfz -n 10 /root/TEAMSERVER_CREDENTIALS.txt
```

✅ **Teamserver fertig!**

---

## 🌐 VPS 2: REDIRECTOR (Vultr)

### ⚠️ VOR Installation: DNS konfigurieren!

**Bei Cloudflare (oder Ihrem DNS-Provider):**

```
1. A-Record erstellen:
   Name: cdn
   Value: IHRE_REDIRECTOR_IP
   
2. Warten: 2-5 Minuten

3. Testen:
   dig cdn.example.com
   → Sollte Ihre Redirector-IP zeigen
```

---

### 🔹 Schritt 1: Verbinden

```bash
ssh root@IHRE_REDIRECTOR_IP
```

---

### 🔹 Schritt 2: Skripte holen + Config ausfüllen

```bash
# Skripte downloaden
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts

# Config erstellen
cp config.example config
nano config
```

**Im Editor, ändern Sie NUR diese Zeilen:**

```bash
SERVER_TYPE="redirector"

REDIRECTOR_TYPE="nginx"  # oder "caddy" (automatisches HTTPS!)

REDIRECTOR_DOMAIN="cdn.example.com"  # ← IHRE Domain!
ADMIN_EMAIL="admin@example.com"      # ← Ihre Email!

C2_SERVER_IP="49.12.34.56"  # ← TEAMSERVER-IP von oben!
```

**Speichern:** `Ctrl+O`, `Enter`, `Ctrl+X`

---

### 🔹 Schritt 3: Installation starten

```bash
chmod +x auto_setup.sh
sudo ./auto_setup.sh
```

**Warten Sie 5-10 Minuten ☕**

**Fertig wenn erscheint:**
```
✅  REDIRECTOR ERFOLGREICH INSTALLIERT!
```

**Credentials notieren:**

```bash
cat /root/REDIRECTOR_CREDENTIALS.txt
```

**Testen:**

```bash
curl https://cdn.example.com/
# → Webseite erscheint ✓
```

**Credentials löschen:**

```bash
shred -vfz -n 10 /root/REDIRECTOR_CREDENTIALS.txt
```

✅ **Redirector fertig!**

---

## 🎮 Havoc Client verwenden

### Auf Ihrem PC/Laptop:

```bash
# 1. Havoc Client installieren
cd ~
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc
make client-build

# 2. Starten
cd Build/bin
./Havoc

# 3. Mit Teamserver verbinden:
#    New Profile:
#      Host: [IHRE TEAMSERVER-IP]
#      Port: 40056
#      User: admin
#      Pass: [Ihr Passwort]
#    → Connect

# 4. Payload generieren:
#    Attack → Payload
#    Listener: "HTTPS Listener"
#    Arch: x64
#    Format: Windows Exe
#    → Generate

# 5. Payload in Test-VM ausführen
#    → Session erscheint nach ~30 Sekunden!

# ✅ Erfolgreich!
```

---

## 📋 Komplette Befehls-Übersicht

### Teamserver (Hetzner):

```bash
ssh root@TEAMSERVER_IP
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts
cp config.example config
nano config  # SERVER_TYPE="teamserver", ADMIN_PASSWORD, LISTENER_HOST
chmod +x auto_setup.sh
sudo ./auto_setup.sh
cat /root/TEAMSERVER_CREDENTIALS.txt  # Notieren!
shred -vfz -n 10 /root/TEAMSERVER_CREDENTIALS.txt
```

### Redirector (Vultr):

```bash
# ZUERST: DNS konfigurieren (cdn.example.com → REDIRECTOR_IP)

ssh root@REDIRECTOR_IP
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts
cp config.example config
nano config  # SERVER_TYPE="redirector", DOMAIN, C2_SERVER_IP
chmod +x auto_setup.sh
sudo ./auto_setup.sh
cat /root/REDIRECTOR_CREDENTIALS.txt  # Notieren!
curl https://cdn.example.com/  # Testen!
shred -vfz -n 10 /root/REDIRECTOR_CREDENTIALS.txt
```

---

## ⏱️ Zeitplan

```
00:00 - Hetzner VPS bestellen               (5 Min)
00:05 - Vultr VPS bestellen                 (5 Min)
00:10 - DNS konfigurieren                   (2 Min)
00:12 - Teamserver: auto_setup.sh starten   (15 Min laufen lassen)
00:27 - Redirector: auto_setup.sh starten   (10 Min laufen lassen)
00:37 - Tests durchführen                   (3 Min)
00:40 - Havoc Client verbinden              (2 Min)
───────────────────────────────────────────────────
TOTAL: 40 Minuten
```

---

## 💰 Kosten-Reminder

```
Hetzner CX11:     €4.15/Monat
Vultr $6:         ~€5.50/Monat
Domain:           ~€1/Monat (optional)
────────────────────────────────
TOTAL:            ~€10-11/Monat

Software:         €0 (alles kostenlos!)
SSL:              €0 (Let's Encrypt)
```

**Monatlich kündbar, keine Mindestlaufzeit!**

---

## 📚 Weitere Dokumentation

**Wenn Sie mehr wissen wollen:**

| Was | Datei |
|-----|-------|
| **Ausführliche 2-VPS-Anleitung** | `SETUP_2VPS_ANLEITUNG.md` |
| **Download-Hilfe** | `DOWNLOAD_ANLEITUNG.md` |
| **Kosten-Details** | `KOSTEN_UEBERSICHT.md` |
| **Troubleshooting** | `TROUBLESHOOTING.md` |
| **Quick Reference** | `QUICK_REFERENCE.md` |

**Aber für Schnellstart: Diese Datei reicht!** ✅

---

## 🆘 Hilfe?

1. **Troubleshooting:** `TROUBLESHOOTING.md`
2. **GitHub Issues:** https://github.com/farfrompretty/New-project/issues
3. **Havoc Discord:** https://discord.gg/havoc

---

**Los geht's! 🚀**

---

**Version:** 1.0  
**Datum:** 2026-02-05
