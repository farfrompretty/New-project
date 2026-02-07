# Master Orchestration - Ein Script für alles!

> **Ein Script richtet BEIDE VPS automatisch ein!**

---

## 🎯 Was macht das Master-Script?

Das `master_orchestration.sh` Script:

✅ Verbindet sich zu BEIDEN VPS  
✅ Installiert Teamserver automatisch  
✅ Installiert Redirector automatisch  
✅ Konfiguriert Firewall automatisch  
✅ Holt SSL-Zertifikate automatisch  
✅ Generiert sichere Passwörter  
✅ Testet die Verbindungen  
✅ Erstellt Credentials-Datei  

**Sie geben nur:** 3 Informationen (IPs + Domain)  
**Script macht:** ALLES andere!

---

## 🚀 VERWENDUNG (Super einfach!)

### Schritt 1: Auf Ihrem PC ausführen

```bash
# Download Script:
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/master_orchestration.sh

# Ausführbar machen:
chmod +x master_orchestration.sh

# Starten:
bash master_orchestration.sh
```

---

### Schritt 2: Informationen eingeben

**Das Script fragt nur 3 Dinge:**

```
Teamserver-IP (BuyVM):  78.46.123.45
Redirector-IP (Njalla): 194.76.123.45
Domain:                 cdn.example.com
Email:                  admin@example.com

Fortfahren? (y/n) y
```

**Das wars! Ab hier läuft ALLES automatisch!**

---

### Schritt 3: Warten (20-25 Minuten)

**Was passiert automatisch:**

```
[✓] Teste SSH-Verbindungen
[✓] Installiere Teamserver
    [1/6] System aktualisieren
    [2/6] Dependencies installieren
    [3/6] Havoc klonen
    [4/6] Kompilieren (15 Min)
    [5/6] Konfiguration erstellen
    [6/6] Firewall konfigurieren
    
[✓] Installiere Redirector
    [1/5] System aktualisieren
    [2/5] Nginx installieren
    [3/5] Konfiguration erstellen
    [4/5] Firewall konfigurieren
    [5/5] SSL-Zertifikat holen
    
[✓] Finale Tests
[✓] Credentials-Datei erstellen

✅ FERTIG!
```

---

### Schritt 4: Credentials erhalten

**Nach Installation wird angezeigt:**

```
╔═══════════════════════════════════════════════════════════════╗
║          ✅  INSTALLATION ERFOLGREICH!                       ║
╚═══════════════════════════════════════════════════════════════╝

VPS 1 - TEAMSERVER:
  IP:   78.46.123.45
  Port: 40056
  User: admin
  Pass: Xy9Kp2MqR4tL6vN8

VPS 2 - REDIRECTOR:
  Domain: cdn.example.com
  URL:    https://cdn.example.com/

HAVOC CLIENT:
  Host: 78.46.123.45
  Port: 40056
  User: admin
  Pass: Xy9Kp2MqR4tL6vN8

Credentials gespeichert in: ./HAVOC_ZUGANGSDATEN.txt
```

**Kopieren Sie in Password-Manager!**

---

## 📋 Voraussetzungen

**Auf Ihrem PC brauchen Sie:**

- [ ] **Linux/Mac/WSL** (für bash)
- [ ] **SSH-Key** auf beiden VPS hinterlegt
- [ ] **SSH-Client** (Standard in Linux/Mac)
- [ ] **Root-Zugang** zu beiden VPS

**Prüfen Sie SSH-Zugang VORHER:**

```bash
# Test Teamserver:
ssh root@TEAMSERVER_IP "echo OK"

# Test Redirector:
ssh root@REDIRECTOR_IP "echo OK"

# Beide sollten "OK" ausgeben!
```

---

## 🛠️ Wenn SSH-Keys fehlen

**Falls SSH-Verbindung nicht funktioniert:**

```bash
# 1. SSH-Key erstellen (auf Ihrem PC):
ssh-keygen -t ed25519 -C "havoc-c2"

# 2. Public Key anzeigen:
cat ~/.ssh/id_ed25519.pub

# 3. Zu VPS hinzufügen:

# Option A: Bei Provider (BuyVM/Njalla):
# Dashboard → SSH Keys → Add Key

# Option B: Manuell:
ssh-copy-id root@TEAMSERVER_IP
ssh-copy-id root@REDIRECTOR_IP

# 4. Testen:
ssh root@TEAMSERVER_IP "echo OK"
# → Sollte "OK" zeigen ohne Passwort-Eingabe
```

---

## 💡 Alternative: Mit Passwort (wenn kein SSH-Key)

**Installieren Sie sshpass:**

```bash
sudo apt install sshpass -y
```

**Dann Script anpassen:**

```bash
# Statt:
ssh root@$TEAMSERVER_IP "command"

# Nutzen:
sshpass -p 'IHR_ROOT_PASSWORT' ssh root@$TEAMSERVER_IP "command"
```

---

## 🎯 ZUSAMMENFASSUNG

### **JA! Ich habe Script erstellt das ALLES macht!**

**Script-Name:** `master_orchestration.sh`

**Was es braucht von Ihnen:**
1. Teamserver-IP
2. Redirector-IP
3. Domain

**Was es automatisch macht:**
- Teamserver installieren
- Redirector installieren
- Firewall konfigurieren
- SSL-Zertifikate
- Passwörter generieren
- Alles testen

**Verwendung:**

```bash
# Auf Ihrem PC:
curl -O https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/master_orchestration.sh
bash master_orchestration.sh

# Eingeben:
#   - Teamserver-IP
#   - Redirector-IP
#   - Domain

# Warten 25 Minuten...

# ✅ FERTIG!
```

---

## ❓ "Kann ICH (der Assistant) das für Sie machen?"

**Leider NEIN, weil:**
- ❌ Ich habe keinen Zugriff auf Ihre VPS (keine SSH-Keys)
- ❌ Ich kann keine SSH-Verbindungen aufbauen
- ❌ Ich kann nicht in Ihr Netzwerk

**ABER: Das Script macht es für Sie!**

**Sie müssen nur:**
1. Script auf Ihrem PC starten
2. 3 Informationen eingeben
3. Warten

**Script verbindet sich automatisch zu beiden VPS und richtet alles ein!**

---

## 🎁 BONUS: Noch einfacher geht's nicht!

**Alle Informationen in einer Datei:**

```bash
# Erstellen Sie: my_setup.txt
cat > my_setup.txt << 'EOF'
TEAMSERVER_IP=78.46.123.45
REDIRECTOR_IP=194.76.123.45
DOMAIN=cdn.example.com
EMAIL=admin@example.com
EOF

# Dann:
bash master_orchestration.sh < my_setup.txt

# Läuft komplett ohne Interaktion!
```

---

## 📚 Dokumentation:

**→ `MASTER_ORCHESTRATION_ANLEITUNG.md`** - Diese Datei  
**→ `master_orchestration.sh`** - Das Script

---

**Einfacher geht's wirklich nicht mehr! 🎯**

---

**Erstellt:** 2026-02-05  
**Version:** 1.0
