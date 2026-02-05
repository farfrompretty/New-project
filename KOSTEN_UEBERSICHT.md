# Kosten-Übersicht: Havoc C2 Setup

> **Transparente Aufstellung aller Kosten für Ihre C2-Infrastruktur**

---

## 💰 Zusammenfassung

### Software-Kosten

**ALLE SOFTWARE IST KOSTENLOS! 🎉**

| Software | Kosten | Lizenz |
|----------|--------|--------|
| **Havoc C2 Framework** | €0 | Open Source (Custom License) |
| **Apache / Nginx / Caddy / Traefik** | €0 | Open Source |
| **Let's Encrypt SSL** | €0 | Kostenlos |
| **Terraform** | €0 | Open Source (MPL 2.0) |
| **Ansible** | €0 | Open Source (GPL) |
| **Alle Skripte in diesem Repo** | €0 | Open Source |

**→ KEINE Software-Lizenzkosten!**

---

## 🖥️ VPS-Hosting-Kosten

**Hier zahlen Sie nur für die Server (VPS), die Sie mieten.**

### Kosten-Optionen

#### Option 1: Lokales Lab (Nur zum Lernen)
```
💻 Ihr eigener PC/Laptop
├─ Havoc Teamserver
├─ Test-VM (Windows)
└─ Alle Tools lokal

KOSTEN: €0/Monat
```

**Perfekt für:**
- Training
- Lernen
- Payload-Entwicklung
- Lokale Tests

**Einrichtung:**
- Folgen Sie `LOCAL_SETUP_GUIDE.md`
- Keine VPS nötig
- Komplett kostenlos

---

#### Option 2: Minimal Setup (Einstieg)
```
🌐 1 VPS für alles
├─ Havoc Teamserver
└─ Nginx Redirector (auf gleichem Server)

KOSTEN: €4-6/Monat
```

**Empfohlene Provider:**
- **Hetzner CX11:** €4.15/Monat (2 GB RAM, 20 GB SSD)
- **Vultr $6:** $6/Monat (1 GB RAM, 25 GB SSD)
- **DigitalOcean:** $6/Monat (1 GB RAM, 25 GB SSD)

**Gut für:**
- Erste echte Tests
- Kleine Engagements
- Lab-Umgebung mit extern

---

#### Option 3: Standard Setup (Empfohlen)
```
🌐 2 VPS (getrennt für OPSEC)
├─ VPS 1: Teamserver (versteckt)
│   └─ Hetzner CX11: €4.15/Monat
└─ VPS 2: Redirector (öffentlich)
    └─ Vultr $6: $6/Monat

KOSTEN: ~€10/Monat
```

**Vorteile:**
- ✅ Teamserver-IP bleibt versteckt
- ✅ Redirector kann gewechselt werden
- ✅ Professioneller Aufbau

**Gut für:**
- Standard Pentests
- Echte Engagements
- Trainings mit externen Teilnehmern

---

#### Option 4: Professional Setup (Red Team)
```
🌐 4 VPS (Multi-Redirector)
├─ VPS 1: Teamserver
│   └─ Hetzner CX21: €5.40/Monat (4 GB RAM)
├─ VPS 2: Redirector Europa
│   └─ Vultr Frankfurt: $6/Monat
├─ VPS 3: Redirector USA
│   └─ Vultr New York: $6/Monat
└─ VPS 4: Redirector Asien
    └─ Vultr Singapore: $6/Monat

KOSTEN: ~€23/Monat
```

**Vorteile:**
- ✅ Geo-Distribution
- ✅ Failover/Redundanz
- ✅ Load Balancing
- ✅ Skalierbar

**Gut für:**
- Red Team Operationen
- Langzeit-Engagements
- Enterprise-Targets

---

#### Option 5: High-OPSEC Setup (Maximale Anonymität)
```
🌐 4 VPS (Alle mit Crypto bezahlt)
├─ VPS 1: Teamserver
│   └─ BuyVM (Monero): $7/Monat
├─ VPS 2: Redirector 1
│   └─ Vultr (Bitcoin): $6/Monat
├─ VPS 3: Redirector 2
│   └─ BuyVM (Monero): $3.50/Monat
└─ VPS 4: Redirector 3
    └─ Njalla (Bitcoin): €15/Monat

KOSTEN: ~€30/Monat
```

**Besonderheiten:**
- ✅ Alle Provider akzeptieren Crypto
- ✅ Kein KYC bei Crypto-Zahlung
- ✅ Verschiedene Jurisdiktionen
- ✅ Offshore-Provider

**Gut für:**
- Sensitive Engagements
- High-Profile-Targets
- Maximale Anonymität

---

## 🔢 Detaillierte Kosten-Tabelle

### VPS-Provider-Vergleich

| Provider | Preis/Monat | CPU | RAM | SSD | Traffic | Crypto? | OPSEC |
|----------|-------------|-----|-----|-----|---------|---------|-------|
| **Hetzner CX11** | €4.15 | 1 | 2 GB | 20 GB | 20 TB | ❌ | ⭐⭐⭐⭐ |
| **Hetzner CX21** | €5.40 | 2 | 4 GB | 40 GB | 20 TB | ❌ | ⭐⭐⭐⭐ |
| **Vultr $6** | $6.00 | 1 | 2 GB | 55 GB | 3 TB | ✅ BTC | ⭐⭐⭐⭐ |
| **DigitalOcean $6** | $6.00 | 1 | 1 GB | 25 GB | 1 TB | ❌ | ⭐⭐⭐ |
| **Linode $5** | $5.00 | 1 | 1 GB | 25 GB | 1 TB | ❌ | ⭐⭐⭐⭐ |
| **OVH VPS** | €3.50 | 1 | 2 GB | 20 GB | 100M | ❌ | ⭐⭐⭐ |
| **BuyVM $7** | $7.00 | 2 | 2 GB | 40 GB | 1 TB | ✅ XMR | ⭐⭐⭐⭐⭐ |
| **Njalla €15** | €15.00 | 1 | 2 GB | 25 GB | 6 TB | ✅ BTC | ⭐⭐⭐⭐⭐ |
| **Contabo €5** | €4.50 | 4 | 6 GB | 100 GB | 32 TB | ❌ | ⭐⭐ |

**Legende:**
- BTC = Bitcoin
- XMR = Monero (beste Anonymität)
- OPSEC = Privacy/Anonymität-Rating

---

## 📊 Beispiel-Rechnungen

### Szenario 1: "Ich will nur lernen"
```
Lokales Lab auf Ihrem PC:
├─ Software: €0
├─ VPS: €0
└─ Total: €0/Monat

Einmalig:
└─ Ggf. Windows VM-Lizenz: €0 (Evaluation)
```

**→ Komplett kostenlos!**

---

### Szenario 2: "Mein erster echter Pentest"
```
1 VPS (All-in-One):
├─ Hetzner CX11: €4.15/Monat
├─ Domain (optional): €1/Monat
├─ SSL-Zertifikat: €0 (Let's Encrypt)
└─ Total: ~€5/Monat

Für 1 Monat Engagement: €5
```

---

### Szenario 3: "Standard Red Team Setup"
```
2 VPS + Domain:
├─ Hetzner CX11 (Teamserver): €4.15
├─ Vultr $6 (Redirector): €5.50
├─ Domain (.com): €1/Monat
├─ SSL: €0 (Let's Encrypt)
└─ Total: ~€11/Monat

Für 3 Monate Engagement: €33
```

---

### Szenario 4: "High-OPSEC, sensibles Engagement"
```
4 VPS + Domain (Crypto bezahlt):
├─ BuyVM $7 (Teamserver, Monero): €6.50
├─ Vultr $6 (Redirector 1, Bitcoin): €5.50
├─ BuyVM $3.50 (Redirector 2, Monero): €3.20
├─ Njalla €15 (Redirector 3, Bitcoin): €15
├─ Domain (Njalla): Inklusive
└─ Total: ~€30/Monat

Für 6 Monate: €180
```

---

## 🆓 Was ist KOSTENLOS?

### Komplett kostenlose Komponenten:

✅ **Havoc C2 Framework** - Core Software  
✅ **Apache / Nginx / Caddy / Traefik** - Webserver/Redirectors  
✅ **Let's Encrypt** - SSL/TLS-Zertifikate  
✅ **Certbot** - Automatische SSL-Verwaltung  
✅ **UFW** - Firewall  
✅ **Fail2Ban** - Intrusion Prevention  
✅ **Terraform** - Infrastructure-as-Code  
✅ **Ansible** - Configuration Management  
✅ **Alle Skripte dieses Repos** - Automatisierung  
✅ **Alle Dokumentationen** - Guides & Tutorials  

---

## 💳 Wann zahlen Sie?

### Sie zahlen NUR für:

1. **VPS-Hosting** (Server-Miete)
   - Monatlich kündbar bei den meisten Providern
   - Hourly Billing bei Vultr/DigitalOcean
   - Nur zahlen wenn Server läuft

2. **Domain-Registrierung** (optional)
   - ~€1-10/Jahr
   - Nur nötig wenn Sie echte Domain wollen
   - Kann auch kostenlose Subdomains nutzen (DuckDNS, etc.)

3. **Kommerzielle SSL-Zertifikate** (optional)
   - €0 mit Let's Encrypt (empfohlen!)
   - €50-500/Jahr für EV-Zertifikate (nur für spezielle Fälle)

### Sie zahlen NICHT für:

❌ Havoc C2 Software (Open Source)  
❌ Redirector-Software (Open Source)  
❌ SSL-Zertifikate (Let's Encrypt kostenlos)  
❌ Automatisierungs-Skripte (in diesem Repo)  
❌ Terraform/Ansible (Open Source)  
❌ Support/Dokumentation (GitHub kostenlos)  

---

## 🎯 Empfehlungen nach Budget

### Budget: €0/Monat
```
→ Lokales Lab-Setup
→ Alles auf Ihrem PC
→ Perfekt zum Lernen
→ Anleitung: LOCAL_SETUP_GUIDE.md
```

### Budget: €5-10/Monat
```
→ 1-2 VPS (Hetzner + Vultr)
→ Gut für erste echte Tests
→ Kleine Engagements
→ Setup: Standard
```

### Budget: €20-30/Monat
```
→ 3-4 VPS (Multi-Redirector)
→ Red Team Setup
→ Professional Operations
→ Setup: Professional mit Crypto
```

### Budget: Unbegrenzt
```
→ Skalieren Sie beliebig
→ Terraform macht Deployment einfach
→ 10+ Redirectors möglich
→ Load Balancing & Geo-Distribution
```

---

## 💡 Kosten-Spar-Tipps

### Tipp 1: Hourly Billing nutzen
```
Vultr/DigitalOcean = Hourly Billing

Beispiel:
- Server nur während Engagement (40 Stunden)
- Kosten: $6/730 Stunden = $0.008/Stunde
- 40 Stunden = $0.32 statt $6!

→ Nach Engagement: terraform destroy
→ Keine weiteren Kosten
```

### Tipp 2: Promo-Credits
```
DigitalOcean: $200 gratis für neue User
Vultr: $100 gratis (manchmal)
Linode: $100 gratis

→ Mehrere Monate kostenlos testen!
```

### Tipp 3: VPS-Sharing
```
1 VPS für Teamserver + Redirector
→ Spart 1 VPS (~€5/Monat)

Aber: Schlechtere OPSEC!
Nur für Tests empfohlen.
```

### Tipp 4: Günstigere Provider
```
Contabo: €4.50/Monat (6 GB RAM!)

Aber: 
- Performance inkonsistent
- IPs oft auf Blacklists
- Nur für Labs verwenden!
```

### Tipp 5: Langzeit-Commitments
```
Hetzner: Kein Discount (fair)
OVH: Bis -20% bei Jahresvertrag

Aber: Weniger flexibel
Nur wenn Sie langfristig planen
```

---

## 🧮 Kosten-Kalkulator

### Ihre Konfiguration:

```bash
# Anzahl Teamserver
TEAMSERVER=1

# Anzahl Redirectors
REDIRECTORS=2

# Provider-Auswahl (Durchschnitt €5/VPS)
COST_PER_VPS=5

# Domain (optional)
DOMAIN_COST=1

# Total
TOTAL=$(( (TEAMSERVER + REDIRECTORS) * COST_PER_VPS + DOMAIN_COST ))

echo "Geschätzte Kosten: €${TOTAL}/Monat"
```

**Beispiele:**
- 1 Teamserver + 0 Redirectors + keine Domain = €5/Monat
- 1 Teamserver + 1 Redirector + Domain = €11/Monat
- 1 Teamserver + 3 Redirectors + Domain = €21/Monat

---

## 📞 Support-Kosten

### Community-Support (Kostenlos)
- ✅ GitHub Issues
- ✅ Havoc Discord
- ✅ Dokumentation in diesem Repo
- ✅ Online-Tutorials

### Kommerzieller Support (Optional)
- Havoc bietet keinen kommerziellen Support
- Alternativen:
  - Red Team Consultants (€100-300/Stunde)
  - Managed C2 Services (nicht empfohlen für OPSEC)

**→ In 99% der Fälle reicht Community-Support!**

---

## ⚖️ Rechtliche Kosten

### Penetrationstester-Zertifizierungen (Optional)
- OSCP: ~€1.000
- CRTO: ~€500
- PNPT: ~€300

**Nicht erforderlich für die Software!**  
Aber hilfreich für professionelle Karriere.

### Versicherung (Empfohlen für Professionals)
- Cyber-Haftpflicht: €500-2.000/Jahr
- Nur nötig wenn Sie kommerziell arbeiten

---

## 📊 Zusammenfassung: Wo geht Ihr Geld hin?

```
╔═══════════════════════════════════════════════════════════╗
║  KOSTEN-AUFSCHLÜSSELUNG                                   ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  SOFTWARE:               €0/Monat  (100% kostenlos!)     ║
║  ├─ Havoc C2:            €0                              ║
║  ├─ Redirectors:         €0                              ║
║  ├─ SSL:                 €0 (Let's Encrypt)              ║
║  └─ Automatisierung:     €0                              ║
║                                                           ║
║  INFRASTRUKTUR:          €5-30/Monat                     ║
║  ├─ VPS-Hosting:         €4-7 pro Server                 ║
║  ├─ Domain:              €1/Monat (optional)             ║
║  └─ Bandbreite:          Inklusive                       ║
║                                                           ║
║  OPTIONAL:                                                ║
║  ├─ Zertifizierungen:    €300-1.000 (einmalig)          ║
║  └─ Versicherung:        €500-2.000/Jahr                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 🎉 Fazit

### Minimale Kosten für Production:
**€5-11/Monat** (1-2 VPS)

### Empfohlene Kosten für Professional:
**€20-30/Monat** (Multi-Redirector, Crypto)

### Zum Lernen:
**€0/Monat** (Lokales Lab auf Ihrem PC)

---

**WICHTIG:**
- ✅ Alle Software ist kostenlos (Open Source)
- ✅ Sie zahlen nur für Server-Hosting
- ✅ Monatlich kündbar
- ✅ Keine versteckten Kosten
- ✅ Keine Vendor Lock-In

---

**Weitere Fragen zu Kosten?**  
→ Siehe `HOSTING_GUIDE.md` für detaillierte Provider-Vergleiche  
→ Siehe `terraform/` für automatische Kosten-Kalkulation

---

**Erstellt:** 2026-02-05  
**Version:** 1.0
