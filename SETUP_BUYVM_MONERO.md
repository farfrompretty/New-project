# 2-VPS Setup mit Monero (XMR) - BuyVM + Njalla

> **Komplette Anleitung: Beide VPS mit Monero bezahlen!**  
> **Maximum Anonymität - Kein KYC!**

---

## 🎯 Ihr Setup

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  VPS 1: TEAMSERVER (BuyVM)                              │
│  ├─ Provider: BuyVM (Frantech)                          │
│  ├─ Location: Luxembourg (EU)                           │
│  ├─ Plan: Slice 2048 ($15/mo)                           │
│  ├─ Specs: 2 CPU, 2 GB RAM, 40 GB SSD                  │
│  └─ Bezahlung: Monero (XMR) ✅                          │
│                                                          │
│  VPS 2: REDIRECTOR (Njalla ODER 1984)                   │
│  ├─ Provider: Njalla (empfohlen) oder 1984 Hosting     │
│  ├─ Location: Stockholm/Amsterdam (Njalla) oder Island  │
│  ├─ Plan: VPS 1024 (€9/mo) oder €6/mo                  │
│  ├─ Specs: 1 CPU, 1-2 GB RAM                           │
│  └─ Bezahlung: Monero (XMR) ✅                          │
│                                                          │
│  TOTAL: ~$18-24/mo (~€17-22/mo)                         │
│  ANONYMITÄT: ⭐⭐⭐⭐⭐ MAXIMUM                           │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 💰 Kosten-Übersicht

| Komponente | Preis | XMR (~aktueller Kurs) |
|------------|-------|-----------------------|
| BuyVM Slice 2048 | $15/mo | ~0.08-0.10 XMR |
| Njalla VPS 1024 | €9/mo | ~0.05-0.06 XMR |
| **TOTAL** | **~€22/mo** | **~0.13-0.16 XMR/mo** |

**Hinweis:** XMR-Preis variiert, aktueller Kurs ~€150-180/XMR

---

## 📋 Voraussetzungen

### Was Sie brauchen:

- [ ] **~0.2 XMR** (~€35) für erste Zahlung + Reserve
- [ ] **Monero Wallet** (GUI oder CLI)
- [ ] **Domain** (optional, aber empfohlen)
- [ ] **SSH-Key** (erstellen wir gleich)
- [ ] **30-40 Minuten Zeit**

---

## 🔑 PHASE 1: Monero vorbereiten (15 Minuten)

### Schritt 1.1: Monero Wallet installieren

**Download:**
```
https://www.getmonero.org/downloads/
```

**Installation (Linux):**

```bash
# Auf Ihrem PC:
cd ~/Downloads
wget https://downloads.getmonero.org/gui/linux64
tar -xjf monero-gui-linux-x64-*.tar.bz2
cd monero-gui-*/
./monero-wallet-gui
```

**Wallet erstellen:**

```
1. "Neue Wallet erstellen"
2. Wallet-Name: "C2-Operations"
3. Seed-Phrase (25 Wörter) → SICHER AUFBEWAHREN!
4. Passwort setzen
5. "Wallet erstellen"
6. Warten auf Synchronisation (kann Stunden dauern)
```

**WICHTIG:** Für schnelleren Start:

```
Settings → Node
→ "Remote Node" wählen
→ node.moneroworld.com:18089
→ Sofort nutzbar!
```

### Schritt 1.2: Monero kaufen

**Option A: Kraken (KYC, aber einfach):**

```
1. Account auf Kraken.com
2. EUR einzahlen (SEPA)
3. XMR kaufen (0.2 XMR = ~€35)
4. Withdraw zu Ihrer Wallet-Adresse
5. Warten 20-30 Min
```

**Option B: LocalMonero (Kein KYC!):**

```
1. LocalMonero.co
2. Verkäufer mit guter Reputation wählen
3. Zahlungsmethode: Bank-Transfer, PayPal, Bar, etc.
4. XMR direkt zu Ihrer Wallet
```

✅ **Checkpoint:** ~0.2 XMR in Ihrer Wallet

---

## 🖥️ PHASE 2: BuyVM Teamserver (20 Minuten)

### Schritt 2.1: BuyVM Stock prüfen

**WICHTIG:** BuyVM ist oft ausverkauft!

```
1. Gehen Sie zu: https://buyvm.net/stock-checker/

2. Prüfen Sie Verfügbarkeit:
   - Luxembourg (EU) - Slice 2048
   - Oder andere Standorte

3. Falls VERFÜGBAR:
   → SOFORT bestellen! (verkauft sich in Minuten)

4. Falls AUSVERKAUFT:
   → Email-Benachrichtigung aktivieren
   → Warten auf Stock-Alert
   → DANN sofort bestellen
```

---

### Schritt 2.2: BuyVM Account erstellen

```
1. Gehen Sie zu: https://my.frantech.ca/register.php

2. Registrierung:
   Email:    Nutzen Sie anonyme Email!
             - ProtonMail (protonmail.com)
             - Tutanota (tutanota.com)
             - Guerrilla Mail (guerrillamail.com)
   
   Password: Starkes Passwort
   
   Name:     Optional (kann fake sein bei Crypto)
   Country:  Beliebig

3. Email verifizieren

4. Einloggen: https://my.frantech.ca/clientarea.php
```

✅ **Checkpoint:** BuyVM Account aktiv

---

### Schritt 2.3: Slice 2048 bestellen (Luxembourg)

```
1. Gehen Sie zu: https://my.frantech.ca/cart.php?gid=7

2. Plan wählen:
   ┌─────────────────────────────────────┐
   │ Slice 2048                          │
   │ 2 CPU, 2 GB RAM, 40 GB SSD         │
   │ 3 TB Bandwidth                      │
   │ $15.00/month                        │
   │ [Order Now]                         │
   └─────────────────────────────────────┘

3. Location wählen:
   ☑️ Luxembourg (empfohlen für EU)
   ☐ New York
   ☐ Las Vegas
   ☐ Miami

4. Operating System:
   ☑️ Ubuntu 22.04 x64

5. Hostname:
   teamserver-001

6. SSH Key:
   [Ihr SSH Public Key einfügen]
   
   Falls noch nicht vorhanden:
   ssh-keygen -t ed25519
   cat ~/.ssh/id_ed25519.pub
   → Kopieren und einfügen

7. Addons:
   ☐ Keine (Standard reicht)

8. Billing Cycle:
   ☑️ Monthly

9. Klick "Continue"

10. Review → "Checkout"
```

---

### Schritt 2.4: Mit Monero bezahlen

```
1. Payment Method:
   ☑️ CoinPayments (Bitcoin/Litecoin/Monero)

2. "Complete Order"

3. CoinPayments-Seite öffnet sich:
   
   ┌─────────────────────────────────────────┐
   │ Select Currency: [Monero (XMR)    ▼]   │
   │ [Next]                                  │
   └─────────────────────────────────────────┘

4. Payment-Details werden angezeigt:
   
   Amount Due:    $15.00 USD
   XMR to Send:   0.0876 XMR (Beispiel, variiert!)
   
   Send to Address:
   4AdUndHvY9m6ehYhV2iUAKNsANZHCjPNkXPmF...
   (48 Zeichen)
   
   Payment ID:    [Optional]
   
   Time Limit:    60 minutes

5. Kopieren Sie die XMR-Adresse!

6. Öffnen Sie Ihre Monero Wallet:
   
   - GUI Wallet: "Send" Tab
   - Destination: [Kopierte Adresse einfügen]
   - Amount: [Exakter XMR-Betrag] (z.B. 0.0876)
   - Payment ID: [Falls vorhanden, einfügen]
   - "Send"

7. Bestätigen in Wallet

8. Zurück zu CoinPayments-Seite:
   - Status: "Waiting for payment"
   - Nach 2-3 Minuten: "Payment detected"
   - Nach ~20 Minuten: "Payment confirmed" ✅

9. Email von BuyVM:
   Subject: "New Server Information"
   
   Inhalt:
   Server IP:      78.46.XXX.XXX
   SSH Username:   root
   SSH Port:       22
   Root Password:  [Falls kein SSH-Key]
```

✅ **Checkpoint:** BuyVM VPS aktiv, IP-Adresse erhalten

---

### Schritt 2.5: Teamserver installieren

```bash
# 1. SSH-Verbindung zu BuyVM VPS:
ssh root@IHRE_BUYVM_IP

# 2. ONE-LINER Installation:
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh | sudo bash

# 3. Eingabe wenn gefragt:
Listener Host: cdn.example.com
(Ihre Redirector-Domain, die gleich kommt)

# 4. Warten 15 Minuten ☕

# 5. Passwörter werden angezeigt - NOTIEREN:
Admin Password:    [Automatisch generiert]
Operator Password: [Automatisch generiert]

# 6. IP notieren:
TEAMSERVER_IP = 78.46.XXX.XXX
```

✅ **Checkpoint:** Teamserver läuft auf BuyVM

---

## 🌐 PHASE 3: Redirector mit Monero (15 Minuten)

### Option A: Njalla (Empfohlen)

**Warum Njalla?**
- ✅ Akzeptiert Monero
- ✅ Kein KYC
- ✅ EU-Standorte
- ✅ Domain-Service inkl.
- ✅ Maximum Privacy

#### Schritt 3.1: Njalla Account

```
1. Gehen Sie zu: https://njal.la/signup/

2. Registrierung:
   Email:    anon@protonmail.com (anonyme Email!)
   Username: beliebig
   Password: stark!
   
   Kein Name, keine Adresse nötig!

3. Einloggen: https://njal.la/login/
```

#### Schritt 3.2: VPS bestellen

```
1. Dashboard → "Servers" → "Add a server"

2. Server Type: VPS

3. Location:
   ☑️ Stockholm, Sweden (empfohlen)
   ☐ Amsterdam, Netherlands

4. Plan:
   ☑️ VPS 1024 (€9/month)
   1 CPU, 1 GB RAM, 15 GB SSD

5. Operating System:
   ☑️ Ubuntu 22.04

6. SSH Key:
   [Ihr Public Key einfügen]

7. Hostname: redirector-001

8. Klick "Order"
```

#### Schritt 3.3: Mit Monero bezahlen

```
1. Payment Method:
   ☑️ Cryptocurrency

2. Currency:
   ☑️ Monero (XMR)

3. Payment-Details:
   Amount:   €9.00
   XMR:      ~0.052 XMR
   Address:  8[...95 Zeichen...]

4. Monero Wallet öffnen:
   - Send
   - Destination: [Njalla XMR-Adresse]
   - Amount: 0.052 (exakt wie angezeigt!)
   - Send

5. Warten ~20 Minuten

6. VPS erscheint im Dashboard:
   Status: Active ✅
   IP: 194.XXX.XXX.XXX
```

✅ **Checkpoint:** Njalla VPS aktiv

---

### Option B: 1984 Hosting (Alternative)

**Günstiger, aber nur 1 Standort (Island):**

```
Website: https://1984.hosting/
Preis:   €6/month
Crypto:  Bitcoin, Monero
KYC:     Nein

1. Account: https://1984.hosting/cart.php?a=add&domain=register
2. VPS wählen: Cloud 1GB
3. Location: Iceland
4. Checkout → Cryptocurrency → Monero
5. XMR senden
6. VPS-Details per Email
```

---

## 🔧 PHASE 4: Installation (20 Minuten)

### Schritt 4.1: DNS konfigurieren (falls Domain vorhanden)

**Bei Cloudflare (oder Ihrem DNS-Provider):**

```
1. Cloudflare Dashboard → Ihre Domain

2. DNS → "Add record":
   Type:    A
   Name:    cdn
   Content: [IHRE NJALLA/1984 REDIRECTOR-IP]
   TTL:     Auto
   Proxy:   🔴 DNS only (NICHT proxied!)

3. Save

4. Warten 2-5 Minuten

5. Test:
   dig cdn.example.com
   → Sollte Redirector-IP zeigen
```

---

### Schritt 4.2: Teamserver installieren (BuyVM)

```bash
# SSH zu BuyVM Teamserver:
ssh root@BUYVM_IP

# ONE-LINER Installation:
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh | sudo bash

# Eingabe:
Listener Host: cdn.example.com
(Ihre Redirector-Domain)

# Warten 15 Minuten...

# Passwörter werden angezeigt - NOTIEREN!
Admin:    [Automatisch generiert]
Operator: [Automatisch generiert]

# Credentials in Datei:
cat /root/TEAMSERVER_ZUGANGSDATEN.txt

# WICHTIG: Kopieren Sie in Password-Manager!

# Dann löschen:
shred -vfz -n 10 /root/TEAMSERVER_ZUGANGSDATEN.txt
```

**Credentials notieren:**

```
TEAMSERVER (BuyVM):
IP:   78.46.XXX.XXX
Port: 40056
User: admin
Pass: [Generiertes Passwort]
```

✅ **Checkpoint:** Teamserver läuft auf BuyVM

---

### Schritt 4.3: Redirector installieren (Njalla/1984)

```bash
# SSH zu Njalla/1984 Redirector:
ssh root@NJALLA_IP

# ONE-LINER Installation:
curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_redirector_standalone.sh | sudo bash

# Eingaben:
1. Ihre Domain: cdn.example.com
2. Teamserver-IP: 78.46.XXX.XXX (BuyVM-IP von oben!)
3. Email: admin@example.com

# Warten 10 Minuten...

# SSL wird automatisch geholt!

# Info in Datei:
cat /root/REDIRECTOR_INFO.txt
```

**Test:**

```bash
# Vom Redirector aus:
curl https://cdn.example.com/

# Sollte Webseite zeigen!

# Test Verbindung zu Teamserver:
nc -zv 78.46.XXX.XXX 443
# Sollte: Connection succeeded
```

✅ **Checkpoint:** Redirector läuft und leitet zu Teamserver

---

### Schritt 4.4: Firewall verschärfen (Wichtig!)

**Auf dem Teamserver (BuyVM):**

```bash
ssh root@BUYVM_IP

# Port 443 NUR von Redirector erlauben:
ufw delete allow 443/tcp
ufw allow from NJALLA_IP to any port 443 proto tcp comment "Redirector Only"
ufw reload

# Verifizieren:
ufw status numbered
```

**Sollte zeigen:**

```
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
40056/tcp                  ALLOW       Anywhere
443/tcp                    ALLOW       194.XXX.XXX.XXX  # Nur Redirector!
```

✅ **Checkpoint:** Teamserver nur von Redirector erreichbar

---

## 🎮 PHASE 5: Havoc Client verbinden (5 Minuten)

### Schritt 5.1: Havoc Client installieren (auf Ihrem PC)

```bash
# Auf Ihrem Kali/Ubuntu PC:
cd ~
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc

# Dependencies
sudo apt install -y build-essential cmake qtbase5-dev \
    libqt5websockets5-dev golang-go

# Kompilieren (10-15 Min)
make client-build

# Starten
cd Build/bin
./Havoc
```

---

### Schritt 5.2: Mit Teamserver verbinden

**Im Havoc Client (GUI):**

```
1. Klick auf "+" (oben) oder "Havoc" → "Connect"

2. New Profile:
   Profile Name: BuyVM Production
   Host:         78.46.XXX.XXX (Ihre BuyVM Teamserver-IP)
   Port:         40056
   User:         admin
   Password:     [Ihr generiertes Passwort]

3. "Save"

4. "Connect"

5. Verbindung erfolgreich! ✅
```

---

### Schritt 5.3: Listener prüfen

```
1. Im Havoc Client:
   View → Listeners

2. Sollte zeigen:
   Name:   "HTTPS Listener"
   Host:   cdn.example.com
   Port:   443
   Status: Started ✅

3. Falls "Stopped":
   Rechtsklick → "Start"
```

---

## 🎯 PHASE 6: Erste Payload testen (5 Minuten)

### Schritt 6.1: Payload generieren

```
1. Attack → Payload

2. Konfiguration:
   Listener:          HTTPS Listener
   Arch:              x64
   Format:            Windows Exe
   Indirect Syscalls: ✅ ON
   Sleep:             10 (Sekunden)
   Jitter:            30 (%)

3. "Generate"

4. Speichern als: beacon.exe
```

---

### Schritt 6.2: Payload testen

**Windows-VM oder Windows-PC:**

```
1. Windows Defender temporär aus
2. beacon.exe ausführen
3. Warten 10-30 Sekunden
```

**Im Havoc Client:**

```
View → Sessions

Nach ~30 Sek sollte erscheinen:
┌──────────────────────────────────┐
│ Computer: WIN10-TEST             │
│ User:     Administrator          │
│ Process:  beacon.exe             │
│ Status:   🟢 Active              │
└──────────────────────────────────┘
```

**Interagieren:**

```
Rechtsklick → "Interact"

Kommandos:
> whoami
> hostname
> ipconfig
> screenshot

✅ Funktioniert!
```

---

## 📊 Finale Übersicht

### Ihre Infrastruktur:

```
╔═══════════════════════════════════════════════════════════════╗
║              IHRE C2-INFRASTRUKTUR (ANONYM)                  ║
╚═══════════════════════════════════════════════════════════════╝

VPS 1 - TEAMSERVER:
  Provider:   BuyVM (Frantech)
  Location:   Luxembourg, EU
  IP:         78.46.XXX.XXX
  Bezahlung:  Monero (XMR) - $15/mo
  SSH:        ssh root@78.46.XXX.XXX

HAVOC TEAMSERVER:
  Host:       78.46.XXX.XXX
  Port:       40056
  Admin:      admin / [Ihr Passwort]
  Operator:   operator1 / [Ihr Passwort]

VPS 2 - REDIRECTOR:
  Provider:   Njalla
  Location:   Stockholm, Sweden
  IP:         194.XXX.XXX.XXX
  Domain:     cdn.example.com
  Bezahlung:  Monero (XMR) - €9/mo
  SSH:        ssh root@194.XXX.XXX.XXX

LISTENER:
  URL:        https://cdn.example.com:443

TOTAL KOSTEN:
  $15 + €9 ≈ €22/Monat
  ~0.13-0.16 XMR/Monat

ANONYMITÄT: ⭐⭐⭐⭐⭐ MAXIMUM
  - Beide mit Monero bezahlt
  - Kein KYC
  - Verschiedene Provider
  - Verschiedene Jurisdiktionen (LU + SE)
  - Offshore
```

---

## 🔒 Sicherheits-Checkliste

Nach dem Setup:

- [ ] SSH-Passwort-Login deaktiviert (nur Keys)
- [ ] Firewall auf beiden VPS aktiv
- [ ] Teamserver Port 443 NUR von Redirector
- [ ] SSL-Zertifikat gültig (bei Domain)
- [ ] Credentials nicht in Cloud gespeichert
- [ ] Monero-Wallet gesichert (Seed aufbewahrt)
- [ ] Beide VPS mit verschiedenen Emails registriert
- [ ] Keine persönlichen Daten in WHOIS (bei Domain)

---

## 💡 OPSEC-Tipps

### Maximale Anonymität:

1. **VPN/Tor für Management:**
   ```bash
   # Nutzen Sie VPN/Tor wenn Sie sich zu VPS verbinden
   # Nicht direkt von Ihrer Heim-IP!
   ```

2. **Verschiedene Emails:**
   ```
   BuyVM:  anon1@protonmail.com
   Njalla: anon2@tutanota.com
   Domain: anon3@guerrillamail.com
   ```

3. **Monero-Churning:**
   ```
   Exchange → Wallet 1 → Wallet 2 → Payment
   (Extra Mixing für mehr Privacy)
   ```

4. **Keine Wiederverwendung:**
   ```
   Nach Engagement:
   - VPS zerstören
   - Neue VPS für nächstes Engagement
   - Neue Monero-Wallet
   ```

---

## 🆘 Troubleshooting

### BuyVM ausverkauft?

**Lösung:**

```
1. Stock-Checker: https://buyvm.net/stock-checker/
2. Email-Alert aktivieren
3. Wenn Alert kommt: SOFORT bestellen (binnen 5-10 Min weg!)

Alternative:
- 1984 Hosting (Island, €6/mo, Monero)
- FlokiNET (Island/Rumänien, €5/mo, Monero)
```

### Monero-Zahlung nicht bestätigt?

**Prüfen:**

```bash
# In Monero Wallet:
# Transactions → Details
# Confirmations: 10/10 ✅

# Falls < 10: Warten
# Falls 10 aber nicht bestätigt bei Provider:
# → Support kontaktieren mit TX-ID
```

### Teamserver nicht erreichbar von Redirector?

```bash
# Auf Teamserver:
ufw allow from REDIRECTOR_IP to any port 443

# Test vom Redirector:
ssh root@REDIRECTOR_IP
nc -zv TEAMSERVER_IP 443
# Sollte: Connection succeeded
```

---

## 📞 Support

**BuyVM:**
- Tickets: https://my.frantech.ca/submitticket.php
- Discord: https://discord.gg/buyvm

**Njalla:**
- Dashboard → Support Ticket
- Email: support@njal.la

---

## 🎉 Zusammenfassung

### Ihr Setup (mit Monero):

```
✅ Teamserver:  BuyVM Luxembourg ($15/mo, XMR)
✅ Redirector:  Njalla Stockholm (€9/mo, XMR)
✅ Total:       ~€22/mo (~0.13-0.16 XMR/mo)
✅ Anonymität:  Maximum (kein KYC, Offshore, Crypto)
```

### Installation (One-Liner):

**Teamserver:**
```bash
curl -s https://raw.githubusercontent.com/.../install_teamserver_standalone.sh | sudo bash
```

**Redirector:**
```bash
curl -s https://raw.githubusercontent.com/.../install_redirector_standalone.sh | sudo bash
```

**Fertig in ~40 Minuten!**

---

**Erstellt:** 2026-02-05  
**Version:** 1.0
