# SUPER EINFACHE ANLEITUNG - Nur Copy & Paste!

> **Keine Config-Dateien! Keine komplizierten Schritte! Einfach Copy & Paste!**

---

## 🎯 Für TEAMSERVER (Hetzner):

### EINE ZEILE - Das reicht:

```bash
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh | sudo bash
```

**Das wars!** Script lädt herunter und installiert automatisch!

**Fragt nur 1x nach:** Listener-Domain (geben Sie Ihre Redirector-Domain ein, z.B. `cdn.example.com`)

**Läuft dann 15 Minuten automatisch!**

---

## 🌐 Für REDIRECTOR (Vultr):

### EINE ZEILE - Das reicht:

```bash
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_redirector_standalone.sh | sudo bash
```

**Das wars!** Script lädt herunter und installiert automatisch!

**Fragt 3x nach:**
1. Domain (z.B. `cdn.example.com`)
2. Teamserver-IP (z.B. `49.12.34.56`)
3. Email (z.B. `admin@example.com`)

**Läuft dann 10 Minuten automatisch!**

---

## 📝 Schritt-für-Schritt:

### VPS 1 - TEAMSERVER (Hetzner):

```bash
# 1. SSH-Verbindung
ssh root@IHRE_TEAMSERVER_IP

# 2. Dieser EINE Befehl:
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh | sudo bash

# 3. Eingabe wenn gefragt:
#    Listener Host: cdn.example.com
#    (Ihre Redirector-Domain, die später kommt)

# 4. Warten ☕ (15 Minuten)

# 5. Passwörter werden angezeigt - NOTIEREN!

# ✅ FERTIG!
```

---

### VPS 2 - REDIRECTOR (Vultr):

```bash
# 0. DNS ZUERST konfigurieren!
#    A-Record: cdn.example.com → IHRE_REDIRECTOR_IP

# 1. SSH-Verbindung
ssh root@IHRE_REDIRECTOR_IP

# 2. Dieser EINE Befehl:
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_redirector_standalone.sh | sudo bash

# 3. Eingaben wenn gefragt:
#    Domain: cdn.example.com
#    Teamserver-IP: 49.12.34.56 (von oben)
#    Email: admin@example.com

# 4. Warten ☕ (10 Minuten)

# 5. Testen:
#    curl https://cdn.example.com/

# ✅ FERTIG!
```

---

## 🎉 Zusammenfassung:

**Teamserver:**
```bash
curl -s https://raw.githubusercontent.com/.../install_teamserver_standalone.sh | sudo bash
```

**Redirector:**
```bash
curl -s https://raw.githubusercontent.com/.../install_redirector_standalone.sh | sudo bash
```

**Keine Config-Dateien!**  
**Keine git clone!**  
**Einfach nur diese EINE Zeile!**

---

## 🔒 Obfuskation:

Die Skripte beinhalten bereits:
- ✅ Versteckte Server-Header (tarnen als nginx/PHP)
- ✅ Traffic-Filterung (blockiert Scanner)
- ✅ Automatische Passwort-Generierung
- ✅ Sichere Speicherung

**Mehr Obfuskation?** Siehe unten ↓

---

**Erstellt:** 2026-02-05
