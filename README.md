# Havoc C2 Server - Komplette Setup-Dokumentation

> **Vollständige, deutschsprachige Anleitung zur Einrichtung einer professionellen C2-Infrastruktur mit Havoc Framework**

⚠️ **RECHTLICHER HINWEIS:** Diese Dokumentation ist ausschließlich für autorisierte Penetrationstests, Red Team Übungen mit schriftlicher Genehmigung und Sicherheitsforschung in kontrollierten Laborumgebungen gedacht. Unbefugter Einsatz ist illegal.

---

## 📚 Dokumentations-Übersicht

### Haupt-Dokumentationen

| Dokument | Beschreibung | Schwierigkeit |
|----------|--------------|---------------|
| **[HAVOC_C2_SETUP.md](HAVOC_C2_SETUP.md)** | Hauptanleitung für Havoc Installation & Konfiguration | ⭐⭐ |
| **[INFRASTRUCTURE_SETUP.md](INFRASTRUCTURE_SETUP.md)** | Redirectors, Domain-Fronting, Traffic-Filterung | ⭐⭐⭐⭐ |
| **[SSL_CERTIFICATE_SETUP.md](SSL_CERTIFICATE_SETUP.md)** | Let's Encrypt, kommerzielle Zertifikate, Automation | ⭐⭐ |
| **[OPSEC_GUIDE.md](OPSEC_GUIDE.md)** | Operations Security, Anonymität, Best Practices | ⭐⭐⭐⭐⭐ |
| **[HOSTING_GUIDE.md](HOSTING_GUIDE.md)** | Budget-VPS-Vergleich, anonyme Zahlung, Empfehlungen | ⭐⭐ |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Problemlösungen, Wartung, Monitoring, Notfallprozeduren | ⭐⭐⭐ |

### Automatisierungs-Skripte

| Script | Beschreibung |
|--------|--------------|
| **[install_havoc_teamserver.sh](scripts/install_havoc_teamserver.sh)** | Automatische Teamserver-Installation |
| **[install_redirector_apache.sh](scripts/install_redirector_apache.sh)** | Apache Redirector Setup |
| **[install_redirector_nginx.sh](scripts/install_redirector_nginx.sh)** | Nginx Redirector Setup |
| **[harden_server.sh](scripts/harden_server.sh)** | Server-Härtung (SSH, Firewall, Fail2Ban) |
| **[cleanup_infrastructure.sh](scripts/cleanup_infrastructure.sh)** | Post-Engagement Cleanup |

📖 **[Scripts README](scripts/README.md)** - Detaillierte Anleitung für alle Skripte

---

## 🚀 Schnellstart

### Option 1: Einfaches Lab-Setup (für Training)

```bash
# 1. Miete einen VPS (min. 2 GB RAM)
# Empfehlung: Hetzner CX11 (€4.15/Monat) oder Vultr $6/Monat

# 2. Verbinde per SSH
ssh root@IHRE_SERVER_IP

# 3. Automatische Installation
wget https://raw.githubusercontent.com/.../install_havoc_teamserver.sh
sudo bash install_havoc_teamserver.sh

# 4. Notiere die Credentials!

# 5. Auf Ihrer Workstation: Verbinde mit Havoc Client
cd /opt/Havoc
./havoc client
# Host: IHRE_SERVER_IP, Port: 40056
```

**→ Lesen Sie:** [HAVOC_C2_SETUP.md](HAVOC_C2_SETUP.md)

---

### Option 2: Production Setup mit Redirectors (für echte Engagements)

```bash
# === TEAMSERVER (versteckt) ===
# VPS 1 - Hetzner, 2 GB RAM
ssh root@teamserver-ip
wget https://raw.githubusercontent.com/.../install_havoc_teamserver.sh
wget https://raw.githubusercontent.com/.../harden_server.sh
sudo bash harden_server.sh
sudo bash install_havoc_teamserver.sh
# Notiere Teamserver-IP

# === REDIRECTOR (öffentlich) ===
# VPS 2 - Vultr, 1 GB RAM, mit Domain
ssh root@redirector-ip
wget https://raw.githubusercontent.com/.../install_redirector_nginx.sh
sudo bash install_redirector_nginx.sh
# Domain: ihre-domain.com
# C2-IP: TEAMSERVER-IP (von oben)

# === DNS KONFIGURIEREN ===
# Setze A-Record: ihre-domain.com → redirector-ip

# === TESTEN ===
# Auf Ihrer Workstation
curl https://ihre-domain.com/  # Sollte Webseite zeigen

# Verbinde Havoc Client zu Teamserver
./havoc client
# Host: TEAMSERVER-IP, Port: 40056

# Generiere Payload mit Domain: ihre-domain.com
```

**→ Lesen Sie:** [INFRASTRUCTURE_SETUP.md](INFRASTRUCTURE_SETUP.md)

---

## 📖 Empfohlene Lesereihenfolge

### Für Anfänger:

1. **[HAVOC_C2_SETUP.md](HAVOC_C2_SETUP.md)** - Verstehen Sie die Basics
2. **[HOSTING_GUIDE.md](HOSTING_GUIDE.md)** - Wählen Sie einen VPS-Anbieter
3. **[Scripts README](scripts/README.md)** - Nutzen Sie Automatisierungs-Skripte
4. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Bei Problemen

### Für Fortgeschrittene:

1. **[INFRASTRUCTURE_SETUP.md](INFRASTRUCTURE_SETUP.md)** - Redirectors & Domain-Fronting
2. **[SSL_CERTIFICATE_SETUP.md](SSL_CERTIFICATE_SETUP.md)** - Zertifikat-Management
3. **[OPSEC_GUIDE.md](OPSEC_GUIDE.md)** - Maximale Sicherheit
4. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Monitoring & Wartung

---

## 💰 Budget-Empfehlungen

### Lab/Training Setup (~€10/Monat)

```
Teamserver:   Hetzner CX11 (€4.15)
Redirector:   Vultr $6 (€5.50)
---
Total: ~€10/Monat
```

**Use-Case:** Lernen, eigenes Lab, Training

---

### Standard Red Team Setup (~€18/Monat)

```
Teamserver:   Hetzner CX21 (€5.40) - 4 GB RAM
Redirector 1: Vultr Frankfurt (€5.50)
Redirector 2: Vultr Singapore (€5.50)
Redirector 3: OVH (€3.50)
---
Total: ~€18/Monat
```

**Use-Case:** Standard Pentests, Red Team Engagements

---

### High-OPSEC Setup (~€28/Monat)

```
Teamserver:   BuyVM Slice 2048 ($7) - Monero bezahlt
Redirector 1: Vultr (€5.50) - Bitcoin bezahlt
Redirector 2: BuyVM ($3.50) - Monero bezahlt
Redirector 3: Njalla (€15) - Bitcoin bezahlt
---
Total: ~€28/Monat
```

**Use-Case:** Sensitive Engagements, maximale Anonymität

**→ Details:** [HOSTING_GUIDE.md](HOSTING_GUIDE.md)

---

## 🔐 OPSEC-Level

### Level 1: Basic (Lab/Training) ⭐

- ✅ Havoc Teamserver
- ✅ Gültiges SSL-Zertifikat
- ✅ Firewall-Konfiguration

**Schutz:** Minimal - Nur gegen gelegentliche Scans

---

### Level 2: Standard (Pentests) ⭐⭐⭐

- ✅ Teamserver (versteckt)
- ✅ 1-2 Redirectors
- ✅ Let's Encrypt SSL
- ✅ Traffic-Filterung (Scanner blocken)
- ✅ Server-Härtung

**Schutz:** Gut - Gegen Standard-Detection

---

### Level 3: Advanced (Red Team) ⭐⭐⭐⭐

- ✅ Segregierte Infrastruktur
- ✅ 3+ Redirectors (verschiedene Provider)
- ✅ Kategorisierte Domains
- ✅ Advanced Traffic-Filterung
- ✅ Beacon-Profiling (Jitter, WorkingHours)
- ✅ Payload-Obfuskation

**Schutz:** Sehr gut - Gegen erfahrene Blue Teams

---

### Level 4: Elite (APT-Simulation) ⭐⭐⭐⭐⭐

- ✅ Vollständig anonyme Infrastruktur (Crypto-Zahlung)
- ✅ Domain-Fronting / CDN
- ✅ JA3-Fingerprint-Filtering
- ✅ Geo-basierte Filterung
- ✅ Polymorphic Payloads
- ✅ Threat-Intel-Monitoring
- ✅ Infrastruktur-Rotation

**Schutz:** Maximal - Gegen Enterprise SOCs

**→ Details:** [OPSEC_GUIDE.md](OPSEC_GUIDE.md)

---

## 🛠️ Was diese Dokumentation abdeckt

### ✅ Enthalten

- **Installation:** Schritt-für-Schritt Havoc C2 Setup
- **Infrastruktur:** Redirectors, Domain-Fronting, Multi-Layer
- **Sicherheit:** SSL/TLS, OPSEC, Anonymität
- **Automatisierung:** Ready-to-use Bash-Skripte
- **Budget:** VPS-Vergleich mit konkreten Preisen
- **Troubleshooting:** Lösungen für häufige Probleme
- **Wartung:** Monitoring, Backups, Updates
- **Notfallprozeduren:** Was tun bei Detection/Kompromittierung

### ❌ Nicht enthalten

- Payload-Entwicklung (siehe Havoc Docs)
- Post-Exploitation-Techniken (siehe MITRE ATT&CK)
- Social Engineering (nicht C2-spezifisch)
- Spezifische Target-Exploitation (out of scope)

---

## 🎯 Zielgruppe

Diese Dokumentation ist für:

- ✅ **Penetrationstester** mit autorisierten Engagements
- ✅ **Red Teams** in Unternehmen
- ✅ **Sicherheitsforscher** in kontrollierten Umgebungen
- ✅ **Cybersecurity-Studenten** für Lernzwecke
- ✅ **IT-Security-Professionals** für Lab-Setups

**Nicht für:**
- ❌ Illegale Aktivitäten
- ❌ Unbefugte Systeme angreifen
- ❌ Malware-Operationen

---

## 📊 Projekt-Struktur

```
/workspace/
├── README.md                          # Diese Datei
├── HAVOC_C2_SETUP.md                  # Haupt-Setup-Guide
├── INFRASTRUCTURE_SETUP.md            # Redirectors & Domain-Fronting
├── SSL_CERTIFICATE_SETUP.md           # SSL/TLS Management
├── OPSEC_GUIDE.md                     # Operations Security
├── HOSTING_GUIDE.md                   # VPS-Provider-Vergleich
├── TROUBLESHOOTING.md                 # Problemlösungen
└── scripts/
    ├── README.md                      # Script-Dokumentation
    ├── install_havoc_teamserver.sh    # Teamserver-Installation
    ├── install_redirector_apache.sh   # Apache Redirector
    ├── install_redirector_nginx.sh    # Nginx Redirector
    ├── harden_server.sh               # Server-Härtung
    └── cleanup_infrastructure.sh      # Post-Engagement Cleanup
```

---

## 🔗 Wichtige Links

- **Havoc Framework:** https://github.com/HavocFramework/Havoc
- **Havoc Dokumentation:** https://havocframework.com/docs
- **Havoc Discord:** https://discord.gg/havoc
- **Red Team Infrastructure Wiki:** https://github.com/bluscreenofjeff/Red-Team-Infrastructure-Wiki
- **MITRE ATT&CK (C2):** https://attack.mitre.org/tactics/TA0011/

---

## 🤝 Contribution

Verbesserungsvorschläge? Issues? Öffnen Sie ein Issue oder Pull Request!

**Bereiche für Contributions:**
- Zusätzliche Redirector-Profile (Nginx, Caddy, etc.)
- Terraform/Ansible-Automatisierung
- Docker/Kubernetes-Deployments
- Weitere Hosting-Provider-Reviews
- Übersetzungen in andere Sprachen

---

## 📝 Changelog

**Version 1.0 (2026-02-05)**
- ✅ Initiale Version
- ✅ Vollständige Havoc C2 Setup-Dokumentation
- ✅ Redirector-Guides (Apache & Nginx)
- ✅ SSL/TLS-Setup mit Let's Encrypt
- ✅ OPSEC Best Practices
- ✅ Budget Hosting-Vergleich
- ✅ 5 Automatisierungs-Skripte
- ✅ Umfassender Troubleshooting-Guide

---

## ⚖️ Disclaimer

Diese Dokumentation wird "wie besehen" zur Verfügung gestellt, ohne jegliche Garantie. Die Autoren übernehmen keine Haftung für:

- Schäden durch Missbrauch
- Fehlerhafte Konfigurationen
- Sicherheitsvorfälle
- Rechtliche Konsequenzen

**Sie sind verantwortlich für:**
- Einhaltung lokaler Gesetze
- Einholung schriftlicher Genehmigungen
- Ethisches Verhalten
- Sichere Handhabung der Infrastruktur

---

## 📞 Support

**Bei Problemen:**
1. Lesen Sie [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Durchsuchen Sie Havoc GitHub Issues
3. Fragen Sie in der Havoc Discord Community
4. Öffnen Sie ein Issue in diesem Repository

---

**Viel Erfolg mit Ihren autorisierten Red Team Operations! 🎯**

---

**Erstellt:** 2026-02-05  
**Version:** 1.0  
**Sprache:** Deutsch  
**Lizenz:** MIT (für die Dokumentation)  
**Framework-Lizenz:** Havoc Framework (siehe original Repository)