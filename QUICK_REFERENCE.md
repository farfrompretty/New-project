# Quick Reference Card - 2-VPS-Setup

> **Zum Ausdrucken oder auf zweitem Monitor offen lassen während Setup**

---

## 🎯 Ihr Setup auf einen Blick

```
[Ihr PC] → [Hetzner Teamserver] ← [Vultr Redirector] ← [Targets]
            €4.15/Monat             $6/Monat
            Port 40056              Port 443
            VERSTECKT               ÖFFENTLICH
```

---

## 📋 Installations-Reihenfolge

```
1. VPS bestellen (Hetzner + Vultr)              → 10 Min
2. Teamserver installieren (Hetzner)            → 15 Min
3. DNS konfigurieren (Redirector-Domain)        → 5 Min
4. Redirector installieren (Vultr)              → 10 Min
5. Havoc Client installieren (Ihr PC)           → 10 Min
6. Verbinden & Testen                           → 5 Min
───────────────────────────────────────────────────────────
TOTAL:                                          → 55 Min
```

---

## 🔑 Wichtige IPs & Zugangsdaten

**Während Setup ausfüllen:**

```
┌─────────────────────────────────────────────────────┐
│ TEAMSERVER (Hetzner)                                │
├─────────────────────────────────────────────────────┤
│ IP:        ___.___.___.___                          │
│ SSH:       ssh root@___.___.___.___ [Port: 22]     │
│ Location:  [Falkenstein/Helsinki]                   │
│ Kosten:    €4.15/Monat                              │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ REDIRECTOR (Vultr)                                  │
├─────────────────────────────────────────────────────┤
│ IP:        ___.___.___.___                          │
│ SSH:       ssh root@___.___.___.___ [Port: 22]     │
│ Domain:    ______________.com                       │
│ Location:  [Frankfurt/Amsterdam]                    │
│ Kosten:    $6/Monat                                 │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ HAVOC TEAMSERVER                                    │
├─────────────────────────────────────────────────────┤
│ Host:      [TEAMSERVER_IP]                          │
│ Port:      40056                                     │
│ User:      admin                                     │
│ Password:  _______________________                  │
└─────────────────────────────────────────────────────┘
```

---

## 💻 Wichtigste Befehle

### Teamserver (Hetzner):

```bash
# SSH-Verbindung
ssh root@TEAMSERVER_IP

# Script herunterladen
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts

# Installation
./install_havoc_teamserver.sh

# Status prüfen
systemctl status havoc-teamserver

# Logs ansehen
journalctl -u havoc-teamserver -f

# Neustart
systemctl restart havoc-teamserver
```

### Redirector (Vultr):

```bash
# SSH-Verbindung
ssh root@REDIRECTOR_IP

# Script herunterladen
git clone https://github.com/farfrompretty/New-project.git
cd New-project/scripts

# Installation (Nginx)
./install_redirector_nginx.sh

# Status prüfen
systemctl status nginx

# Logs ansehen
tail -f /var/log/nginx/redirector_access.log

# Config bearbeiten
nano /etc/nginx/sites-available/redirector

# Neustart
systemctl reload nginx
```

### Havoc Client (Ihr PC):

```bash
# Installation
cd ~
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc
make client-build

# Starten
cd Build/bin
./Havoc

# Im GUI: Havoc → Connect
# Host: TEAMSERVER_IP
# Port: 40056
# User: admin
# Pass: [Ihr Passwort]
```

---

## 🔥 Quick-Troubleshooting

| Problem | Lösung |
|---------|--------|
| **"Connection refused" zu Teamserver** | `systemctl restart havoc-teamserver` |
| **Keine Session von Payload** | Prüfe Redirector-Logs, Listener-Status |
| **SSL-Fehler** | `certbot renew`, dann `systemctl reload nginx` |
| **Firewall blockiert** | `ufw allow PORT/tcp` |
| **DNS funktioniert nicht** | Warte 5-30 Min, prüfe mit `dig DOMAIN` |
| **Payload wird als Virus erkannt** | Normal! Obfuskation verbessern, siehe PAYLOAD_DEVELOPMENT.md |

---

## 🌐 URLs zum Kopieren

**Skript-Downloads (RAW-URLs):**

```bash
# Alle Skripte:
https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/download_all_scripts.sh

# Teamserver:
https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_havoc_teamserver.sh

# Nginx Redirector:
https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_redirector_nginx.sh

# Caddy Redirector:
https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts/install_redirector_caddy.sh
```

**Dokumentation:**

```
Haupt-Anleitung:
https://github.com/farfrompretty/New-project/blob/cursor/c2-server-einrichtung-dbe4/SETUP_2VPS_ANLEITUNG.md

Download-Hilfe:
https://github.com/farfrompretty/New-project/blob/cursor/c2-server-einrichtung-dbe4/DOWNLOAD_ANLEITUNG.md

Kosten:
https://github.com/farfrompretty/New-project/blob/cursor/c2-server-einrichtung-dbe4/KOSTEN_UEBERSICHT.md
```

---

## 🔒 Sicherheits-Checkliste

**NACH Installation, vor erstem Engagement:**

- [ ] SSH-Passwort-Login deaktiviert (nur Keys)
- [ ] Teamserver Port 443 NUR von Redirector erreichbar
- [ ] UFW auf beiden Servern aktiv
- [ ] Fail2Ban installiert (`./harden_server.sh`)
- [ ] SSL-Zertifikat gültig und automatische Erneuerung aktiv
- [ ] Credentials NICHT in Cloud/Git gespeichert
- [ ] Backup der Konfigurationen erstellt
- [ ] Monitoring eingerichtet (optional)

---

## 📞 Hilfe bekommen

**Reihenfolge:**

1. **Troubleshooting-Guide:** `TROUBLESHOOTING.md`
2. **Download-Probleme:** `DOWNLOAD_ANLEITUNG.md`
3. **GitHub Issues:** https://github.com/farfrompretty/New-project/issues
4. **Havoc Discord:** https://discord.gg/havoc

---

## 💰 Kosten-Reminder

```
VPS 1 (Hetzner):      €4.15/Monat
VPS 2 (Vultr):        $6.00/Monat  (~€5.50)
Domain (optional):    ~€1/Monat
SSL:                  €0 (Let's Encrypt)
Software:             €0 (Open Source)
─────────────────────────────────────
TOTAL:                ~€10-11/Monat

Monatlich kündbar!
Keine versteckten Kosten!
```

---

## 🎯 Nach dem Setup

**Payload generieren:**

```
1. Havoc Client: Attack → Payload
2. Listener: Ihr HTTPS Listener
3. Arch: x64
4. Format: Windows Exe
5. Generate → Speichern
```

**Session erwarten:**

```
Payload ausführen → Warten 10-30 Sek → Session erscheint
```

**Interagieren:**

```
Rechtsklick Session → Interact
Kommandos: whoami, hostname, screenshot, download, etc.
```

---

**Quick Reference v1.0 - 2026-02-05**
