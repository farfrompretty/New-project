# OPSEC Best Practices für C2-Infrastruktur

> **Operations Security (OPSEC):** Maßnahmen zum Schutz Ihrer C2-Infrastruktur vor Entdeckung und Attribution.

---

## 📋 Inhaltsverzeichnis

1. [OPSEC Grundlagen](#opsec-grundlagen)
2. [Infrastruktur-Trennung](#infrastruktur-trennung)
3. [Domain & IP Attribution Prevention](#domain--ip-attribution-prevention)
4. [Traffic-Profiling & Beaconing](#traffic-profiling--beaconing)
5. [Payload OPSEC](#payload-opsec)
6. [Monitoring & Detection Avoidance](#monitoring--detection-avoidance)
7. [Post-Engagement Cleanup](#post-engagement-cleanup)

---

## OPSEC Grundlagen

### Die 3 Säulen der C2-OPSEC

1. **Verschleierung (Obfuscation)**
   - Infrastruktur nicht zurückverfolgbar
   - Traffic sieht legitim aus
   - Payloads sind nicht erkennbar

2. **Täuschung (Deception)**
   - False Flags
   - Mehrere Infrastruktur-Layer
   - Honeypot-Resistance

3. **Resilienz (Resilience)**
   - Schneller Infrastruktur-Wechsel möglich
   - Backup-Listener
   - Keine Single Point of Failure

### OPSEC-Phasen

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 1: PLANUNG     │ Infrastruktur-Design                 │
│                      │ Domain-Auswahl                       │
│                      │ Hosting-Provider                     │
├─────────────────────────────────────────────────────────────┤
│ Phase 2: AUFBAU      │ Server-Härtung                       │
│                      │ Redirectors                          │
│                      │ SSL-Zertifikate                      │
├─────────────────────────────────────────────────────────────┤
│ Phase 3: BETRIEB     │ Traffic-Management                   │
│                      │ Payload-Delivery                     │
│                      │ Session-Handling                     │
├─────────────────────────────────────────────────────────────┤
│ Phase 4: WARTUNG     │ Monitoring                           │
│                      │ Log-Management                       │
│                      │ Infrastruktur-Rotation               │
├─────────────────────────────────────────────────────────────┤
│ Phase 5: ABBAU       │ Cleanup                              │
│                      │ Log-Deletion                         │
│                      │ Server-Destruction                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Infrastruktur-Trennung

### Segmentierung

**NIEMALS alles auf einem Server!**

```
┌─────────────────┐
│ Operator PC     │ ← Ihre Workstation (isoliert!)
└────────┬────────┘
         │ VPN/Tor
         ↓
┌─────────────────┐
│ Teamserver      │ ← Management-Server (versteckt!)
└────────┬────────┘
         │
    ┌────┴────┬────────┬────────┐
    ↓         ↓        ↓        ↓
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│ Redir1 │ │ Redir2 │ │ Redir3 │ │ Redir4 │ ← Public-facing
└────────┘ └────────┘ └────────┘ └────────┘
```

**Empfohlene Segmentierung:**

| Komponente | Provider | Bezahlung | IP-Range |
|------------|----------|-----------|----------|
| **Operator** | Lokal/VPN | - | Privat |
| **Teamserver** | Provider A | Crypto | IP-Range A |
| **Redirector 1** | Provider B | Prepaid | IP-Range B |
| **Redirector 2** | Provider C | Prepaid | IP-Range C |
| **Payload Hosting** | Provider D | Crypto | IP-Range D |

**Warum?**
- ✅ Wenn Redirector 1 verbrannt → Wechsel zu Redirector 2
- ✅ Teamserver bleibt unentdeckt
- ✅ Verschiedene Provider = schwerer zu korrelieren

---

## Domain & IP Attribution Prevention

### Domain-Auswahl

**❌ SCHLECHT:**
- Neue Domains (< 30 Tage alt)
- Offensichtliche Namen: `c2-server.com`, `havoc-team.net`
- Free TLDs: `.tk`, `.ml`, `.ga` (verbrannt)
- Privacy-Protected WHOIS ohne Historie

**✅ GUT:**
- Aged Domains (> 1 Jahr alt)
- Kategorisiert als "Business", "Technology"
- Historische Backlinks
- WHOIS mit realistischen Daten
- Mainstream TLDs: `.com`, `.net`, `.org`, `.io`

### Domain-Quellen

**Empfohlene Marktplätze:**

1. **ExpiredDomains.net**
   - Filtert nach: Alter, Backlinks, Kategorisierung
   - Preis: €10-100+

2. **Dynadot Domain Auctions**
   - Expiring Domains
   - Preis: €5-50

3. **GoDaddy Auctions**
   - Große Auswahl
   - Preis: €20-500+

**Prüfung vor Kauf:**

```bash
# WHOIS-Historie
https://whois-history.whoisxmlapi.com/

# Wayback Machine (Hat Domain Historie?)
https://web.archive.org/

# Kategorisierung prüfen
https://sitereview.bluecoat.com/
https://www.fortiguard.com/webfilter

# Reputation prüfen
https://www.virustotal.com/gui/domain/ihre-domain.com
https://talosintelligence.com/reputation_center

# DNS-Historie
https://securitytrails.com/
```

### WHOIS-Schutz

**Optionen:**

1. **WHOIS Privacy Protection**
   - Bei Domain-Registrar erhältlich
   - Verbirgt persönliche Daten
   - Preis: €5-10/Jahr (oft kostenlos)

2. **Fake aber plausible Daten**
   - Firmenname statt Privatperson
   - Business-Adresse (nicht Wohnadresse!)
   - Generische Email (nicht persönlich)

3. **Offshore Registrar**
   - Beispiele: Njalla, 1984 Hosting (Island)
   - Akzeptiert Crypto
   - Starker Privacy-Fokus

**⚠️ Wichtig:** Konsistenz in den Daten über mehrere Domains hinweg vermeiden!

---

### IP-Adress-Attribution

**Problematik:** VPS-IPs können zu Provider → Zahlungsmethode → Ihnen zurückverfolgt werden.

**Gegenmaßnahmen:**

1. **Verschiedene Hosting-Provider**
   - Niemals alle Server bei einem Provider
   - Verschiedene Länder/Jurisdiktionen

2. **Anonyme Bezahlung**
   - **Kryptowährungen:** Bitcoin, Monero (Monero bevorzugt!)
   - **Prepaid-Kreditkarten:** Paysafecard, etc.
   - **Gutscheine:** Einige Provider akzeptieren Gutscheine

3. **IP-Reputation prüfen**
   ```bash
   # AbuseIPDB
   curl "https://api.abuseipdb.com/api/v2/check?ipAddress=IHRE_IP" \
     -H "Key: IHR_API_KEY"
   
   # Shodan
   https://www.shodan.io/host/IHRE_IP
   
   # VirusTotal
   https://www.virustotal.com/gui/ip-address/IHRE_IP
   ```

4. **Neue IPs bevorzugen**
   - "Frische" IPs ohne Historie
   - Bei Provider anfragen: "Gib mir eine neue IP"

---

## Traffic-Profiling & Beaconing

### Malleable C2 Profiles (für Cobalt Strike-ähnliche Systeme)

Havoc unterstützt keine vollständigen Malleable Profiles wie Cobalt Strike, aber Sie können dennoch Traffic anpassen.

### Beacon-Strategie

**❌ SCHLECHT:**
```
Beacon alle 60 Sekunden, fix
→ Extrem auffällig!
→ Netzwerk-Monitoring erkennt regelmäßige Verbindungen
```

**✅ GUT:**
```
Beacon-Intervall: 300-600 Sekunden (5-10 Min)
Jitter: 30-50%
→ Unregelmäßig
→ Passt zu normaler User-Aktivität
```

### Beispiel-Konfiguration in Havoc

```yaml
Demon:
  Sleep: 300          # 5 Minuten
  Jitter: 40          # 40% Variation (180-420 Sekunden)
  
  # Nur während Geschäftszeiten beaconen (optional)
  WorkingHours: "08:00-18:00"
  KillDate: "2026-12-31"  # Agent deaktiviert sich nach diesem Datum
```

### User-Agent Rotation

**Statt statischem User-Agent:**

```
User-Agent: Mozilla/5.0 (Havoc C2 Client)  ← SCHLECHT!
```

**Nutzen Sie realistische, rotierende User-Agents:**

```python
user_agents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/120.0.0.0",
]
```

In Havoc yaotl-Profil:

```yaml
Http:
  Headers:
    User-Agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
```

**Besser:** Rotieren Sie User-Agents in Ihren Redirector-Regeln oder nutzen Sie Havoc's eingebaute Funktionen.

---

### Traffic-Verschleierung

**HTTP/HTTPS Headers anpassen:**

```yaml
Http:
  Headers:
    Server: "nginx/1.18.0 (Ubuntu)"
    X-Powered-By: "PHP/7.4.3"
    Content-Type: "application/json"
    Cache-Control: "no-cache, no-store, must-revalidate"
```

**URI-Pfade realistisch gestalten:**

❌ SCHLECHT:
```
/stage
/download
/upload
/beacon
```

✅ GUT:
```
/api/v2/users/authenticate
/api/v2/data/sync
/content/updates/check
/analytics/events
```

---

## Payload OPSEC

### Payload-Lieferung

**❌ NIEMALS:**
- Von C2-Server direkt hosten
- Von Redirector-Servern hosten
- Über offensichtliche Dateinamen: `payload.exe`, `beacon.dll`

**✅ STATTDESSEN:**

1. **Separater Payload-Server**
   - Eigener VPS, anderer Provider
   - Nach Delivery: Server zerstören

2. **Legitime Hosting-Dienste**
   - **GitHub Releases:** (Öffentliche Repos, tarnen als Tool)
   - **Pastebin/Hastebin:** (Für Stager)
   - **Dropbox/Google Drive:** (Zeit-limitierte Links)
   - **Discord/Slack CDN:** (Upload als "Attachment")

3. **Dateinamen-Tarnung**
   ```
   ❌ payload.exe
   ❌ beacon.dll
   ❌ c2-agent.bin
   
   ✅ windows-update-kb5034441.exe
   ✅ adobe-reader-installer.exe
   ✅ msvcr120.dll
   ```

4. **Signierung (Code Signing)**
   - Kaufen Sie ein Code-Signing-Zertifikat
   - Oder stehlen Sie ein gültiges Zertifikat (fortgeschritten)
   - Signierte Executables werden weniger oft blockiert

### Payload-Härtung

**Checklist:**

- [ ] **Obfuskation:** Code verschleiert
- [ ] **Packing:** UPX, Themida, VMProtect
- [ ] **Anti-Debugging:** Verhindert Analyse
- [ ] **Anti-VM:** Erkennt virtuelle Umgebungen
- [ ] **Sandbox-Evasion:** Wartet, prüft Interaktion
- [ ] **String-Verschlüsselung:** Keine Klartext-Strings
- [ ] **Import-Hiding:** Dynamisches Laden von APIs
- [ ] **Entropy-Reduktion:** Binaries sehen "normal" aus

**Havoc Demon Build-Optionen:**

Bei der Payload-Generierung in Havoc:
- **Indirect Syscalls:** Aktivieren (weniger EDR-Detection)
- **Sleep Obfuscation:** Aktivieren
- **Stack Duplication:** Aktivieren
- **Payload Format:** Wählen Sie Shellcode + Loader statt EXE

---

## Monitoring & Detection Avoidance

### Was Verteidiger sehen

Wenn Ihr Beacon aktiv ist, könnten Verteidiger Folgendes bemerken:

1. **Netzwerk-Traffic:**
   - Regelmäßige HTTPS-Verbindungen zu unbekannter Domain
   - Große Daten-Uploads (Exfiltration)
   - Ungewöhnliche TLS-Fingerprints

2. **Endpoint-Detection:**
   - Prozess mit ungewöhnlichem Verhalten
   - Injizierte Threads
   - Ungewöhnliche API-Aufrufe (CreateRemoteThread, etc.)

3. **Log-Analyse:**
   - Firewall-Logs zeigen neue Verbindungen
   - Proxy-Logs zeigen unbekannte Domains
   - DNS-Logs zeigen neue Lookups

### Gegenmaßnahmen

#### 1. Traffic-Blending

**Ziel:** Ihr C2-Traffic sieht aus wie normaler Business-Traffic.

```yaml
# Beispiel: Tarnung als Slack
Http:
  Headers:
    Host: "hooks.slack.com"  # Aber tatsächlich zu Ihrem C2
    Content-Type: "application/json"
    
  Uris:
    - "/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX"
```

#### 2. Domain-Fronting (siehe INFRASTRUCTURE_SETUP.md)

#### 3. Sleep-Maskierung

Havoc's Demons können während des "Sleeps" (zwischen Beacons) Speicher verschleiern:

```yaml
Demon:
  Sleep: 600
  SleepMask: true  # Verschleiert Payload im Speicher während Sleep
```

#### 4. Prozess-Injection in legitime Prozesse

Injizieren Sie Ihren Beacon in legitime Prozesse:

- `explorer.exe`
- `svchost.exe`
- `RuntimeBroker.exe`
- `SearchProtocolHost.exe`

**In Havoc:**
```
session> inject [PID]
```

#### 5. AMSI/ETW-Bypass

AMSI (Antimalware Scan Interface) und ETW (Event Tracing for Windows) werden von EDRs genutzt.

Havoc beinhaltet einige Bypasses, aber halten Sie diese aktuell!

---

### Vermeiden Sie IoC-Korrelationen

**Indicators of Compromise (IoCs):**

Was Verteidiger sammeln:
- C2-Domain/IP
- Payload-Hashes (SHA256)
- Mutex-Namen
- Registry-Keys
- Dateipfade
- Named Pipes

**Maßnahmen:**

1. **Randomisierung:**
   - Jeder Payload hat anderen Hash (Polymorphic)
   - Zufällige Mutex-Namen
   - Zufällige Named Pipes

2. **Keine Wiederverwendung:**
   - Nach Detection: Neue Domains
   - Neue IP-Adressen
   - Neue Payload-Varianten

3. **Threat-Intelligence-Monitoring:**
   Prüfen Sie, ob Ihre IoCs öffentlich sind:
   ```bash
   # VirusTotal
   https://www.virustotal.com/gui/domain/ihre-domain.com
   
   # AlienVault OTX
   https://otx.alienvault.com/indicator/domain/ihre-domain.com
   
   # URLhaus
   https://urlhaus.abuse.ch/
   ```

---

## Post-Engagement Cleanup

### Nach Abschluss des Engagements

**Checkliste:**

#### Auf Ziel-Systemen:

- [ ] Alle Payloads/Artifacts gelöscht
- [ ] Alle Backdoors geschlossen
- [ ] Registry-Keys entfernt
- [ ] Scheduled Tasks entfernt
- [ ] Persistence-Mechanismen deaktiviert
- [ ] Log-Einträge bereinigt (falls Scope erlaubt)

**Havoc-Kommandos:**

```
session> exit     # Beacon beenden
session> clear    # Artifacts löschen (wenn implementiert)
```

#### Auf Ihren Servern:

- [ ] **Teamserver:**
  - Havoc-Logs löschen: `/opt/Havoc/logs/`
  - Session-Datenbank bereinigen
  - Credentials aus Konfiguration entfernen

- [ ] **Redirectors:**
  - Apache/Nginx Logs löschen:
    ```bash
    sudo rm -f /var/log/apache2/redirector*.log*
    sudo rm -f /var/log/nginx/redirector*.log*
    ```
  - Bash-History löschen:
    ```bash
    history -c
    rm ~/.bash_history
    ```

- [ ] **Server zerstören:**
  ```bash
  # Daten überschreiben (optional)
  sudo dd if=/dev/urandom of=/dev/sda bs=1M
  
  # Oder: Bei Provider VPS zerstören
  # DigitalOcean: doctl compute droplet delete DROPLET_ID
  # Vultr: vultr-cli instance delete INSTANCE_ID
  ```

#### DNS & Domains:

- [ ] DNS-Records löschen (A, AAAA, CNAME)
- [ ] Domains zu neuem Nameserver umziehen (trennt Historie)
- [ ] Oder: Domains für 1+ Jahre parken (verwässert IoCs)

#### Zahlungsspuren:

- [ ] Krypto-Wallets leeren
- [ ] Email-Accounts löschen (für Provider-Registrierung)
- [ ] VPN/Proxy-Accounts kündigen

---

## OPSEC-Checklisten

### Pre-Engagement Checklist

- [ ] Infrastruktur-Plan dokumentiert
- [ ] Domains gecheckt (Historie, Reputation)
- [ ] Verschiedene Provider für C2/Redirectors
- [ ] Anonyme Bezahlung (Crypto)
- [ ] Keine persönlichen Daten in WHOIS
- [ ] SSL-Zertifikate von Let's Encrypt
- [ ] Redirectors mit Traffic-Filterung konfiguriert
- [ ] Payloads obfuskiert & gepackt
- [ ] Beacon-Intervalle realistisch (5-10 Min, Jitter)
- [ ] Backup-Listener konfiguriert

### During-Engagement Checklist

- [ ] Logs regelmäßig rotieren
- [ ] Threat-Intel-Feeds prüfen (sind Ihre IoCs bekannt?)
- [ ] Infrastruktur-Rotation bei Bedarf
- [ ] Keine logs auf lokalem Operator-PC
- [ ] Verschlüsselte Kommunikation zum Teamserver (VPN)

### Post-Engagement Checklist

- [ ] Alle Backdoors/Artifacts entfernt
- [ ] Server-Logs gelöscht
- [ ] VPS-Instanzen zerstört
- [ ] DNS-Records entfernt
- [ ] Report erstellt (für Kunden)
- [ ] IoCs dokumentiert (für Kunden)

---

## Red Flags: Was Sie vermeiden müssen

### 🚩 Offensichtliche Fehler

| Fehler | Konsequenz | Vermeidung |
|--------|-----------|-----------|
| **C2 direkt exponiert** | Teamserver-IP bekannt | Redirectors nutzen |
| **Self-Signed SSL** | Sofort verdächtig | Let's Encrypt |
| **Statisches Beaconing** | Netzwerk-Anomalie | Jitter verwenden |
| **Default User-Agent** | "Havoc/1.0" in Logs | Anpassen |
| **Neue Domain** | Reputation fehlt | Aged Domains |
| **Port 50050** | Bekannter C2-Port | Standard-Ports (443) |
| **Gleiche Infra für alle Engagements** | Korrelation möglich | Neue Infra pro Kunde |

---

## Advanced OPSEC: Further Reading

**Empfohlene Ressourcen:**

- **Red Team Infrastructure Wiki:** https://github.com/bluscreenofjeff/Red-Team-Infrastructure-Wiki
- **C2 Matrix:** https://www.thec2matrix.com/
- **MITRE ATT&CK - Command and Control:** https://attack.mitre.org/tactics/TA0011/
- **SpecterOps Blog:** https://posts.specterops.io/
- **Red Team Notes:** https://www.ired.team/

**Bücher:**

- "Red Team Development and Operations" - Joe Vest, James Tubberville
- "Operator Handbook" - Joshua Picolet
- "How to Hack Like a Ghost" - Sparc Flow

---

**Erstellt:** 2026-02-05
**Version:** 1.0
