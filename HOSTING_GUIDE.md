# Budget Hosting für C2-Infrastruktur

> **Ziel:** Die besten, günstigsten und anonymsten VPS-Anbieter für Ihre C2-Server und Redirectors.

---

## 📋 Inhaltsverzeichnis

1. [Anforderungen](#anforderungen)
2. [Top Provider-Vergleich](#top-provider-vergleich)
3. [Kategorien](#kategorien)
4. [Anonyme Zahlungsmethoden](#anonyme-zahlungsmethoden)
5. [Setup-Anleitungen](#setup-anleitungen)
6. [Tipps & Tricks](#tipps--tricks)

---

## Anforderungen

### Teamserver (C2 Server)

| Komponente | Minimum | Empfohlen |
|------------|---------|-----------|
| **CPU** | 2 Cores | 4 Cores |
| **RAM** | 2 GB | 4 GB |
| **Storage** | 20 GB SSD | 40 GB SSD |
| **Bandwidth** | 1 TB | 2 TB |
| **OS** | Ubuntu 20.04+ | Ubuntu 22.04 LTS |

**Preis-Range:** €5-15/Monat

### Redirector (Proxy Server)

| Komponente | Minimum | Empfohlen |
|------------|---------|-----------|
| **CPU** | 1 Core | 2 Cores |
| **RAM** | 512 MB | 1 GB |
| **Storage** | 10 GB SSD | 20 GB SSD |
| **Bandwidth** | 500 GB | 1 TB |
| **OS** | Ubuntu 20.04+ | Ubuntu 22.04 LTS |

**Preis-Range:** €2.50-6/Monat

---

## Top Provider-Vergleich

### 🥇 Beste Budget-Optionen

| Provider | Preis/Monat | Specs | Standorte | Crypto? | OPSEC-Rating |
|----------|-------------|-------|-----------|---------|--------------|
| **Vultr** | $2.50-6 | 1-2 CPU, 0.5-2 GB RAM | 32+ weltweit | ✅ Bitcoin | ⭐⭐⭐⭐ |
| **Hetzner Cloud** | €4.15 | 1 CPU, 2 GB RAM | 3 (DE, FI, US) | ❌ | ⭐⭐⭐⭐ |
| **DigitalOcean** | $4-6 | 1-2 CPU, 0.5-2 GB RAM | 15 weltweit | ❌ | ⭐⭐⭐ |
| **Linode/Akamai** | $5 | 1 CPU, 1 GB RAM | 11 weltweit | ❌ | ⭐⭐⭐⭐ |
| **OVH** | €3.50 | 1 CPU, 2 GB RAM | EU, CA | ❌ | ⭐⭐⭐ |
| **BuyVM** | $3.50 | 1 CPU, 1 GB RAM | 3 (US, LU) | ✅ Crypto | ⭐⭐⭐⭐⭐ |
| **Contabo** | €4.50 | 4 CPU, 6 GB RAM | 7 weltweit | ❌ | ⭐⭐ |
| **Hostwinds** | $4.99 | 1 CPU, 1 GB RAM | US, NL | ✅ Bitcoin | ⭐⭐⭐ |

---

## Kategorien

### 🏆 KATEGORIE 1: Budget Champions (€3-6/Monat)

#### 1. Hetzner Cloud

**Preis:** €4.15/Monat (CX11)
**Specs:**
- 1 vCore (AMD/Intel)
- 2 GB RAM
- 20 GB SSD
- 20 TB Traffic
- Standorte: Deutschland, Finnland, USA

**Vorteile:**
- ✅ Exzellentes Preis-Leistungs-Verhältnis
- ✅ Schnelle Server
- ✅ Europäischer Anbieter (DSGVO)
- ✅ Sehr gute Performance

**Nachteile:**
- ❌ Keine Crypto-Zahlung
- ❌ Benötigt valide Email/Zahlungsdaten
- ❌ Begrenzte Standorte

**OPSEC-Bewertung:** ⭐⭐⭐⭐
**Empfohlen für:** Teamserver (versteckt hinter Redirectors)

**Registrierung:**
```bash
# Website
https://www.hetzner.com/cloud

# CLI
curl -O https://raw.githubusercontent.com/hetznercloud/cli/main/scripts/install.sh
bash install.sh
hcloud server create --name c2-teamserver --type cx11 --image ubuntu-22.04
```

---

#### 2. Vultr

**Preis:** $2.50-6/Monat
**Specs (Regular Cloud - $6):**
- 1 vCPU
- 1 GB RAM
- 25 GB SSD
- 2 TB Bandwidth
- Standorte: 32+ weltweit

**Specs (Intel High Performance - $6):**
- 1 vCPU
- 2 GB RAM
- 50 GB SSD
- 3 TB Bandwidth

**Vorteile:**
- ✅ Akzeptiert Bitcoin
- ✅ Sehr viele Standorte
- ✅ Gute Performance
- ✅ Hourly Billing (nur zahlen wenn aktiv)
- ✅ Schnelle Bereitstellung (< 60 Sekunden)

**Nachteile:**
- ❌ $2.50 Plan oft ausverkauft
- ❌ IPv4 kostet extra bei manchen Plänen

**OPSEC-Bewertung:** ⭐⭐⭐⭐
**Empfohlen für:** Redirectors

**Registrierung:**
```bash
# Website
https://www.vultr.com/

# API-basiertes Setup
# 1. Account erstellen
# 2. API Key generieren
# 3. vultr-cli installieren
curl -L https://github.com/vultr/vultr-cli/releases/latest/download/vultr-cli_linux_amd64.tar.gz -o vultr-cli.tar.gz
tar -xf vultr-cli.tar.gz
export VULTR_API_KEY="Ihr_API_Key"
./vultr-cli instance create --region fra --plan vc2-1c-1gb --os 1743 --label "redirector-1"
```

---

#### 3. OVH

**Preis:** €3.50/Monat (VPS Starter)
**Specs:**
- 1 vCore
- 2 GB RAM
- 20 GB SSD
- 100 Mbps unmetered
- Standorte: Frankreich, Deutschland, UK, Polen, Kanada

**Vorteile:**
- ✅ Sehr günstig
- ✅ Unmetered Bandwidth
- ✅ Europäischer Anbieter
- ✅ Gute DDoS-Protection

**Nachteile:**
- ❌ Keine Crypto-Zahlung
- ❌ Slow Provisioning (kann Stunden dauern)
- ❌ Interface/Support manchmal schwierig

**OPSEC-Bewertung:** ⭐⭐⭐
**Empfohlen für:** Budget-Redirectors

**Registrierung:**
```
https://www.ovhcloud.com/de/vps/
```

---

### 🔐 KATEGORIE 2: Anonymity-Focused (€3-10/Monat)

#### 1. BuyVM (EMPFOHLEN für OPSEC!)

**Preis:** $3.50/Monat (Slice 512)
**Specs:**
- 1 CPU Core
- 512 MB RAM
- 10 GB SSD
- 1 TB Bandwidth (1 Gbps)
- Standorte: Las Vegas, New York, Luxembourg, Miami

**Vorteile:**
- ✅ Akzeptiert Crypto (Bitcoin, Litecoin, Monero)
- ✅ Privacy-respektierend
- ✅ DDoS-Protection inklusive
- ✅ Kein KYC für Crypto-Zahlungen
- ✅ "Stallion" Storage add-ons (günstig)

**Nachteile:**
- ❌ Oft ausverkauft (Stock Alerts nutzen!)
- ❌ Begrenzte Standorte

**OPSEC-Bewertung:** ⭐⭐⭐⭐⭐
**Empfohlen für:** Alles (Teamserver + Redirectors)

**Registrierung:**
```bash
# Website
https://buyvm.net/

# Stock Checker (sie sind oft ausverkauft!)
https://buyvm.net/stock-checker/

# Strategie: Email-Benachrichtigung aktivieren, schnell buchen wenn verfügbar
```

---

#### 2. Njalla

**Preis:** €15/Monat (VPS 2048)
**Specs:**
- 1 CPU
- 2 GB RAM
- 25 GB SSD
- 6 TB Bandwidth
- Standorte: Schweden, Niederlande

**Vorteile:**
- ✅ Akzeptiert Crypto (Bitcoin, Monero, Zcash)
- ✅ Extreme Privacy (kein WHOIS bei Domains)
- ✅ Domain + VPS in einem
- ✅ Offshore (Schweden)

**Nachteile:**
- ❌ Teurer als Konkurrenz
- ❌ Begrenzte Standorte
- ❌ Performance nicht beste

**OPSEC-Bewertung:** ⭐⭐⭐⭐⭐
**Empfohlen für:** High-Risk Engagements

**Registrierung:**
```
https://njal.la/
```

---

#### 3. 1984 Hosting (Island)

**Preis:** €6/Monat (Cloud 1GB)
**Specs:**
- 1 CPU
- 1 GB RAM
- 20 GB SSD
- Standort: Island

**Vorteile:**
- ✅ Akzeptiert Bitcoin
- ✅ Island (starke Privacy-Gesetze)
- ✅ Free Speech Hoster
- ✅ Domains + VPS

**Nachteile:**
- ❌ Nur 1 Standort (Island)
- ❌ Höhere Latenz
- ❌ Begrenzte Specs

**OPSEC-Bewertung:** ⭐⭐⭐⭐⭐
**Empfohlen für:** Hochsensible Operationen

**Registrierung:**
```
https://1984.hosting/
```

---

### ⚡ KATEGORIE 3: Performance & Mainstream (€5-15/Monat)

#### 1. DigitalOcean

**Preis:** $4-6/Monat (Basic Droplet)
**Specs ($6 plan):**
- 1 vCPU
- 1 GB RAM
- 25 GB SSD
- 1 TB Transfer
- Standorte: 15+ weltweit

**Vorteile:**
- ✅ Hervorragende Dokumentation
- ✅ API/CLI sehr gut
- ✅ Snapshots & Backups einfach
- ✅ Große Community
- ✅ Promo: $200 Credit für neue User

**Nachteile:**
- ❌ Keine Crypto-Zahlung
- ❌ Benötigt Kreditkarte für Registrierung
- ❌ US-Firma (Subpoenas möglich)

**OPSEC-Bewertung:** ⭐⭐⭐
**Empfohlen für:** Lab/Testing

**Registrierung:**
```bash
# Website (mit $200 Promo)
https://www.digitalocean.com/

# doctl CLI installieren
curl -LO https://github.com/digitalocean/doctl/releases/latest/download/doctl-*-linux-amd64.tar.gz
tar xf doctl-*-linux-amd64.tar.gz
sudo mv doctl /usr/local/bin
doctl auth init
doctl compute droplet create redirector-1 --size s-1vcpu-1gb --image ubuntu-22-04-x64 --region fra1
```

---

#### 2. Linode (jetzt Akamai)

**Preis:** $5/Monat (Nanode 1GB)
**Specs:**
- 1 CPU
- 1 GB RAM
- 25 GB SSD
- 1 TB Transfer
- Standorte: 11 weltweit

**Vorteile:**
- ✅ Langjährige Reputation
- ✅ Jetzt Teil von Akamai (DDoS-Schutz)
- ✅ Gute Performance
- ✅ $100 Credit für neue User

**Nachteile:**
- ❌ Keine Crypto
- ❌ US-Firma

**OPSEC-Bewertung:** ⭐⭐⭐⭐
**Empfohlen für:** Teamserver

**Registrierung:**
```
https://www.linode.com/
```

---

### 💰 KATEGORIE 4: Extreme Budget (€2-4/Monat)

#### 1. Contabo

**Preis:** €4.50/Monat (Cloud VPS S)
**Specs:**
- 4 vCPU Cores
- 6 GB RAM
- 100 GB SSD
- 32 TB Traffic (!!)
- Standorte: Deutschland, USA, UK, Singapur, Australien, Japan, Indien

**Vorteile:**
- ✅ Unschlagbares Preis-Leistungs-Verhältnis
- ✅ Massive Specs für den Preis
- ✅ Viel Bandwidth
- ✅ Viele Standorte

**Nachteile:**
- ❌ Oft überlastet (Performance inkonsistent)
- ❌ Support langsam
- ❌ Shared CPU (nicht dediziert)
- ❌ IP-Reputation oft schlecht (viele Spammer)

**OPSEC-Bewertung:** ⭐⭐
**Empfohlen für:** Lab/Testing (nicht Production!)

**Registrierung:**
```
https://contabo.com/en/vps/
```

**⚠️ Warnung:** Nur für Labs verwenden! IPs oft auf Blacklists.

---

## Anonyme Zahlungsmethoden

### 1. Kryptowährungen (EMPFOHLEN)

| Crypto | Anonymität | Akzeptanz | Bemerkungen |
|--------|-----------|-----------|-------------|
| **Monero (XMR)** | ⭐⭐⭐⭐⭐ | Niedrig | Beste Privacy, wenige Anbieter |
| **Bitcoin (BTC)** | ⭐⭐⭐ | Hoch | Pseudo-anonym, viele Anbieter |
| **Litecoin (LTC)** | ⭐⭐⭐ | Mittel | Ähnlich Bitcoin |
| **Zcash (ZEC)** | ⭐⭐⭐⭐ | Niedrig | Privacy-Coin |

**Anbieter die Crypto akzeptieren:**
- ✅ Vultr (Bitcoin)
- ✅ BuyVM (Bitcoin, Litecoin, Monero)
- ✅ Njalla (Bitcoin, Monero, Zcash)
- ✅ 1984 Hosting (Bitcoin)
- ✅ Hostwinds (Bitcoin)

**Best Practice:**

1. **Monero verwenden** (beste Anonymität)
2. **Oder: Bitcoin mit Mixing:**
   ```
   Ihre Wallet → CoinJoin/Mixer → Neue Wallet → Zahlung
   ```
   - **Wasabi Wallet:** CoinJoin integriert
   - **Samourai Wallet:** Whirlpool Mixing

3. **Niemals direkt von Exchange:**
   ```
   ❌ Coinbase → VPS Provider (traceable!)
   ✅ Coinbase → Ihre Wallet → Mixer → Neue Wallet → VPS
   ```

---

### 2. Prepaid-Kreditkarten / Gutscheine

**Paysafecard:**
- Bar kaufbar in Tankstellen, Kiosks
- Kein KYC für kleinere Beträge
- Problem: Wenige Hoster akzeptieren es direkt

**Virtuelle Prepaid-Kreditkarten:**
- Neteller, Skrill (benötigen jedoch ID-Verifikation)

**Privacy.com (USA):**
- Virtuelle Einweg-Kreditkarten
- Nur für US-Bürger

---

### 3. VPS mit Gutscheinen kaufen

Kaufen Sie VPS-Gutscheine mit Crypto:

**Beispiel:**
1. Kaufen Sie DigitalOcean/Vultr-Gutschein auf:
   - Bitrefill.com (akzeptiert Crypto)
   - Coinsbee.com (akzeptiert Crypto)
2. Nutzen Sie Gutschein für VPS-Registrierung
3. Account nicht direkt mit persönlichen Daten verknüpft

---

## Setup-Anleitungen

### Vultr mit Bitcoin

```bash
# 1. Account erstellen
https://www.vultr.com/register/

# 2. Email verifizieren

# 3. Billing → Add Funds → Bitcoin
# 4. Senden Sie BTC an angezeigte Adresse (min $10)

# 5. Warten auf Bestätigung (3-6 Confirmations)

# 6. Instance erstellen
# Products → Cloud Compute
# Location: Frankfurt (oder gewünscht)
# Server Type: Cloud Compute - Shared CPU
# Server Size: $6/month (1 CPU, 2 GB)
# Operating System: Ubuntu 22.04 LTS
# Deploy Now

# 7. Zugriff via SSH
ssh root@IHRE_VULTR_IP
```

---

### Hetzner Cloud

```bash
# 1. Registrierung
https://accounts.hetzner.com/signUp

# 2. Email & Zahlungsmethode verifizieren

# 3. Cloud Console
https://console.hetzner.cloud/

# 4. Neues Projekt erstellen: "C2-Infrastructure"

# 5. Server erstellen
# Location: Falkenstein (DE) / Helsinki (FI) / Ashburn (US)
# Image: Ubuntu 22.04
# Type: CX11 (€4.15/mo)
# SSH Key hinzufügen (vorher generieren!)
# Create & Buy now

# 6. SSH-Zugriff
ssh root@IHRE_HETZNER_IP
```

---

### BuyVM (mit Crypto)

```bash
# 1. Stock prüfen
https://buyvm.net/stock-checker/

# 2. Wenn verfügbar: SCHNELL registrieren!
https://my.frantech.ca/cart.php

# 3. Service wählen
# Location: Luxembourg (EU), Las Vegas, New York, Miami
# Plan: Slice 512 ($3.50) oder Slice 1024 ($7)

# 4. Checkout → Cryptocurrency (Bitcoin/Litecoin/Monero)

# 5. Nach Zahlung: Email mit Server-Details

# 6. SSH-Zugriff
ssh root@IHRE_BUYVM_IP
```

---

## Tipps & Tricks

### 1. Geo-Distribution

**Strategie:** Verteilen Sie Ihre Infrastruktur geografisch.

```
Teamserver:     Hetzner (Deutschland)
Redirector 1:   Vultr (USA - New York)
Redirector 2:   Vultr (Singapore)
Redirector 3:   OVH (Frankreich)
Payload Server: BuyVM (Luxembourg)
```

**Vorteil:** Schwerer zu korrelieren, Resilienz bei Regional-Blocks.

---

### 2. IP-Rotation

**Billige VPS nur kurzzeitig nutzen:**

```bash
# Day 1-7: Redirector auf Vultr Frankfurt
# Day 8-14: Neuer Redirector auf Vultr London (alter gelöscht)
# Day 15-21: Neuer Redirector auf Vultr Paris
```

Bei Vultr mit hourly billing kostet das fast nichts extra!

---

### 3. Snapshots & Backups

**Automatisierung:**

```bash
# DigitalOcean Snapshot
doctl compute droplet-action snapshot DROPLET_ID --snapshot-name "c2-backup-$(date +%Y%m%d)"

# Hetzner Snapshot
hcloud server create-image --description "c2-backup" c2-teamserver

# Vultr Snapshot
vultr-cli snapshot create --instance-id INSTANCE_ID --description "c2-backup"
```

**Vorteil:** Schnelle Wiederherstellung wenn Server kompromittiert.

---

### 4. Kosten-Optimierung

**Beispiel-Setup für $15-20/Monat:**

| Server | Provider | Specs | Preis |
|--------|----------|-------|-------|
| Teamserver | Hetzner CX21 | 2 vCPU, 4 GB | €5.40 |
| Redirector 1 | Vultr | 1 vCPU, 2 GB | $6 |
| Redirector 2 | BuyVM | 1 CPU, 1 GB | $3.50 |
| Redirector 3 | OVH | 1 vCore, 2 GB | €3.50 |
| **TOTAL** | - | - | **~€18/mo** |

**High-OPSEC Setup für €25-30/Monat:**

| Server | Provider | Specs | Preis |
|--------|----------|-------|-------|
| Teamserver | BuyVM | 2 CPU, 2 GB | $7 |
| Redirector 1 | Vultr (paid crypto) | 1 vCPU, 2 GB | $6 |
| Redirector 2 | BuyVM | 1 CPU, 1 GB | $3.50 |
| Redirector 3 | Njalla | 1 CPU, 2 GB | €15 |
| **TOTAL** | - | - | **~€28/mo** |

---

### 5. Automatisches Deployment

**Terraform-Beispiel (für schnelle Infrastruktur):**

```hcl
# providers.tf
terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.17.1"
    }
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}

# variables.tf
variable "vultr_api_key" {}

# main.tf
resource "vultr_instance" "redirector1" {
  plan        = "vc2-1c-2gb"
  region      = "fra"
  os_id       = 1743  # Ubuntu 22.04
  label       = "redirector-1"
  hostname    = "redirector-1"
  enable_ipv6 = false
  
  ssh_key_ids = [var.ssh_key_id]
}

output "redirector1_ip" {
  value = vultr_instance.redirector1.main_ip
}
```

Deploy:
```bash
terraform init
terraform plan
terraform apply -auto-approve

# Nach Engagement: Alles zerstören
terraform destroy -auto-approve
```

---

### 6. Provider-Kombinationen (Best Practices)

**❌ NICHT:**
```
Alle Server bei Hetzner → Leicht zu korrelieren
```

**✅ GUT:**
```
Teamserver:   Hetzner (Zahlungsmethode A)
Redirector 1: Vultr (Bitcoin)
Redirector 2: BuyVM (Monero)
Redirector 3: DigitalOcean (Gutschein)
```

---

## Checkliste: VPS-Auswahl

- [ ] Provider akzeptiert Crypto (für OPSEC) oder anonyme Zahlung
- [ ] Verschiedene Provider für verschiedene Rollen
- [ ] Specs ausreichend für Havoc (min 2 GB RAM für Teamserver)
- [ ] Standort passt zur Cover-Story (europäisch für EU-Target)
- [ ] IP-Reputation geprüft (nicht auf Blacklists)
- [ ] Hourly oder Monthly Billing (Flexibilität)
- [ ] Snapshot/Backup-Funktionen vorhanden
- [ ] API vorhanden für Automatisierung

---

## Empfohlene Setups

### 💼 Beginner Lab Setup (~€10/Monat)

```
Teamserver:   Hetzner CX11 (€4.15)
Redirector:   Vultr $6 (€5.50)
---
Total: ~€10/Monat
```

**Use-Case:** Training, eigenes Lab, Learning.

---

### 🎯 Standard Red Team (~€18/Monat)

```
Teamserver:   Hetzner CX21 (€5.40) - 4 GB RAM
Redirector 1: Vultr Frankfurt (€5.50)
Redirector 2: Vultr Singapore (€5.50)
Redirector 3: OVH (€3.50)
---
Total: ~€18/Monat
```

**Use-Case:** Standard Pentests, Red Team Engagements.

---

### 🔐 High-OPSEC Setup (~€28/Monat)

```
Teamserver:   BuyVM Slice 2048 ($7) - Monero paid
Redirector 1: Vultr (€5.50) - Bitcoin paid
Redirector 2: BuyVM ($3.50) - Monero paid
Redirector 3: Njalla (€15) - Bitcoin paid
---
Total: ~€28/Monat
```

**Use-Case:** Sensitive Engagements, High-Stealth.

---

### 🌍 Global Infrastructure (~€35/Monat)

```
Teamserver:     Hetzner CX31 (€10) - 8 GB RAM
Redirector US:  Vultr New York (€5.50)
Redirector EU:  Vultr Frankfurt (€5.50)
Redirector ASIA: Vultr Singapore (€5.50)
Redirector AUS: Vultr Sydney (€5.50)
---
Total: ~€32/Monat
```

**Use-Case:** Multi-Region Targets, Load Balancing.

---

## Weitere Ressourcen

- **Vultr $100 Promo:** https://www.vultr.com/promo/
- **DigitalOcean $200 Credit:** https://try.digitalocean.com/
- **Linode $100 Credit:** https://www.linode.com/lp/free-credit/
- **LowEndBox** (Deals): https://lowendbox.com/
- **VPS Benchmarks:** https://www.vpsbenchmarks.com/

---

**Erstellt:** 2026-02-05
**Version:** 1.0
