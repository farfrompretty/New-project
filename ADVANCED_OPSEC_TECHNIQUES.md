# Advanced OPSEC Techniques - Elite Red Team

> **Fortgeschrittene Techniken für maximale Stealth und Detection Avoidance**

---

## 📋 Inhaltsverzeichnis

1. [Domain Fronting & CloudFronting](#domain-fronting--cloudfronting)
2. [Advanced Redirectors (RedGuard)](#advanced-redirectors-redguard)
3. [Header-basierte Traffic-Validierung](#header-basierte-traffic-validierung)
4. [C2-Profil-Härtung (JA3/JA3S)](#c2-profil-härtung-ja3ja3s)
5. [Side-Channel Monitoring (ELK-Stack)](#side-channel-monitoring-elk-stack)
6. [Expiring Domains (<2€)](#expiring-domains-2)
7. [Firewall-Konfiguration VPS-to-VPS](#firewall-konfiguration-vps-to-vps)
8. [Infrastructure-as-Code Burners](#infrastructure-as-code-burners)

---

## 🌐 Domain Fronting & CloudFronting

### Was ist Domain Fronting?

**Prinzip:** CDN-Dienste nutzen um echte Ziel-Domain zu verschleiern.

```
┌─────────────┐
│   Target    │
└──────┬──────┘
       │ HTTPS Request
       │ SNI: www.google.com (Tarnung)
       │ Host: cdn.example.com (Echtes Ziel)
       ↓
┌──────────────┐
│     CDN      │ → Routet basierend auf Host-Header
│  (Cloudflare)│    NICHT SNI!
└──────┬───────┘
       │
       ↓
┌──────────────┐
│  Ihr C2      │
│  Server      │
└──────────────┘

Verteidiger sieht: Verbindung zu Google/Amazon/Cloudflare
Realität: Traffic geht zu Ihrem C2!
```

---

### Cloudflare Domain Fronting (Funktioniert teilweise)

**Setup:**

```bash
# 1. Domain zu Cloudflare hinzufügen
# cloudflare.com → Add Site → ihre-domain.com

# 2. DNS-Record erstellen
A-Record:
  Name: c2
  Content: [Redirector-IP]
  Proxy: ☁️ Proxied (ORANGE CLOUD!)  ← Wichtig!

# 3. SSL/TLS Settings
Encryption Mode: Full (strict)
Always Use HTTPS: ON
TLS 1.3: ON

# 4. Page Rules (Optional)
Rule: *c2.ihre-domain.com/api/*
Settings:
  - Cache Level: Bypass
  - Security Level: Essentially Off (für C2-Traffic)
```

**Havoc Listener-Config:**

```yaml
Listeners:
  - Name: "Cloudflare Fronted"
    Protocol: https
    Hosts:
      - "c2.ihre-domain.com"  # Ihre Domain durch Cloudflare
    Port: 443
    
    Http:
      Headers:
        Host: "c2.ihre-domain.com"
        User-Agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
```

**Vorteil:**
- ✅ Traffic sieht aus wie zu Cloudflare (legitim)
- ✅ Cloudflare-IPs sind überall erlaubt
- ✅ DDoS-Protection inklusive

**Nachteil:**
- ❌ Cloudflare kann Traffic analysieren
- ❌ Echtes Domain Fronting (SNI-Mismatch) blockiert
- ❌ Performance-Overhead

---

### AWS CloudFront Domain Fronting (Advanced)

**⚠️ Warnung:** AWS blockiert aktiv Domain Fronting seit 2018, aber Workarounds existieren!

**Alternative: Edge-Function-Routing**

```javascript
// CloudFront Edge Function
function handler(event) {
    var request = event.request;
    var headers = request.headers;
    
    // Prüfe custom Header
    if (headers['x-custom-routing'] && 
        headers['x-custom-routing'].value === 'SECRET_VALUE_XYZ') {
        
        // Leite zu C2 weiter
        request.origin = {
            custom: {
                domainName: 'c2-backend.example.com',
                port: 443,
                protocol: 'https',
                path: '',
                keepaliveTimeout: 5,
                readTimeout: 30
            }
        };
    } else {
        // Leite zu S3 Bucket (Fallback)
        request.origin = {
            s3: {
                domainName: 'legitimate-content.s3.amazonaws.com'
            }
        };
    }
    
    return request;
}
```

---

### CDN-Kategorisierungs-Trick

**Statt Domain Fronting: Nutzen Sie bereits kategorisierte CDN-Domains**

```bash
# 1. Kaufen Sie alte Domain mit guter Kategorisierung
# ExpiredDomains.net → Filter: Age > 5 Jahre, Kategorisiert

# 2. Prüfen Sie Kategorisierung
https://sitereview.bluecoat.com/
# Sollte zeigen: "Technology/Internet", "Business", etc.

# 3. Hosten Sie legitimen Content
# - WordPress Blog
# - Unternehmens-Webseite
# - Portfolio

# 4. Verstecken Sie C2-Endpoints
https://ihre-domain.com/              → Normale Webseite
https://ihre-domain.com/blog/         → WordPress
https://ihre-domain.com/api/v2/sync   → C2 Endpoint!

# 5. Firewalls lassen durch (bereits kategorisiert!)
```

---

## 🛡️ Advanced Redirectors: RedGuard

### Was ist RedGuard?

**RedGuard** ist ein intelligenter C2-Traffic-Filter (wie Smart Bouncer vor Nightclub).

**Features:**
- ✅ Blockt bekannte Scanner-IPs (VirusTotal, Shodan, etc.)
- ✅ JA3-Fingerprint-Validierung
- ✅ Geo-Blocking
- ✅ Time-based Filtering
- ✅ Cookie/Header-Validierung

**GitHub:** https://github.com/wikiZ/RedGuard

---

### RedGuard Installation

```bash
# Auf Redirector-VPS:

# Dependencies
apt install -y golang-go git redis-server

# RedGuard klonen
cd /opt
git clone https://github.com/wikiZ/RedGuard.git
cd RedGuard

# Konfiguration
cp config.yaml.example config.yaml
nano config.yaml
```

**Config-Beispiel:**

```yaml
# RedGuard Configuration

# Proxy-Einstellungen
proxy:
  port: 443
  ssl:
    cert: /etc/letsencrypt/live/ihre-domain.com/fullchain.pem
    key: /etc/letsencrypt/live/ihre-domain.com/privkey.pem

# Backend (Ihr Teamserver)
backend:
  host: 78.46.12.34  # Teamserver-IP
  port: 443
  ssl: true

# Blockierungs-Regeln
blocking:
  # Bekannte Scanner-IPs
  ip_blacklist:
    - 192.0.2.0/24      # Reserved
    - 77.240.32.0/20    # VirusTotal
    - 104.131.0.0/16    # Shodan
    - 162.159.246.0/24  # Shodan
    
  # User-Agent Blacklist
  user_agent_blacklist:
    - ".*bot.*"
    - ".*spider.*"
    - ".*crawler.*"
    - ".*scanner.*"
    - "curl.*"
    - "wget.*"
    - "python.*"
  
  # GeoIP Filtering (optional)
  country_whitelist:
    - DE
    - AT
    - CH
    # Nur Traffic aus DACH-Region

# JA3 Fingerprint Whitelist (Advanced!)
ja3_whitelist:
  - "e7d705a3286e19ea42f587b344ee6865"  # Chrome 120
  - "ac1c84371c1e0e72dc69c10b1b8b4b4e"  # Firefox 122
  - "YOUR_HAVOC_BEACON_JA3_HERE"        # Ihr Beacon!

# Time-Based Filtering
time_filtering:
  enabled: true
  allowed_hours:
    - start: "08:00"
      end: "18:00"
  allowed_days:
    - monday
    - tuesday
    - wednesday
    - thursday
    - friday
  # Nur Geschäftszeiten Mo-Fr 8-18 Uhr!

# Fallback bei Block
fallback:
  redirect: "https://www.google.com"  # Redirect zu Google
  # Oder zeige 404
```

**Starten:**

```bash
# Build
cd /opt/RedGuard
go build

# Als Service
cat > /etc/systemd/system/redguard.service << 'EOF'
[Unit]
Description=RedGuard C2 Traffic Filter
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/RedGuard
ExecStart=/opt/RedGuard/RedGuard -config /opt/RedGuard/config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable redguard
systemctl start redguard
```

---

## 🔒 Header-basierte Traffic-Validierung

### Nginx mit Custom-Header-Check

**Nur Traffic mit geheimem Header wird weitergeleitet!**

```nginx
# /etc/nginx/sites-available/secured-redirector

upstream c2_backend {
    server 78.46.12.34:443;
}

# Map für Header-Validierung
map $http_x_custom_token $allow_c2 {
    default 0;
    "SECRET_TOKEN_XYZ_123456" 1;
}

server {
    listen 443 ssl http2;
    server_name cdn.example.com;
    
    ssl_certificate /etc/letsencrypt/live/cdn.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/cdn.example.com/privkey.pem;
    
    # Nur /api/* Pfade prüfen
    location ~ ^/api/ {
        
        # Prüfe Custom-Header
        if ($allow_c2 = 0) {
            return 404;  # Kein Header → 404
        }
        
        # Header korrekt → Weiterleiten
        proxy_pass https://c2_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_ssl_verify off;
    }
    
    # Alles andere → Normale Webseite
    location / {
        root /var/www/html;
        index index.html;
    }
}
```

**Havoc Beacon mit Custom-Header:**

```yaml
# In havoc.yaotl:

Listeners:
  - Name: "Secured Listener"
    Protocol: https
    Hosts:
      - "cdn.example.com"
    
    Http:
      Headers:
        X-Custom-Token: "SECRET_TOKEN_XYZ_123456"  # Geheimer Header!
        User-Agent: "Mozilla/5.0 ..."
```

**Vorteil:** Scanner ohne korrekten Header bekommen 404!

---

### Cookie-basierte Validierung

**Noch sicherer: Rotierender Cookie**

```nginx
# Nginx mit Cookie-Check

map $cookie_session_id $valid_session {
    default 0;
    "~^[a-f0-9]{32}$" 1;  # Regex: 32 Hex-Zeichen
}

location ~ ^/api/ {
    
    if ($valid_session = 0) {
        return 404;
    }
    
    # Validierung erfolgreich
    proxy_pass https://c2_backend;
}
```

**Beacon generiert zufälligen Cookie:**

```yaml
Http:
  Cookies:
    session_id: "a1b2c3d4e5f6789012345678901234ab"  # 32 Hex
```

**Rotate Cookie täglich für maximale Sicherheit!**

---

## 🔐 C2-Profil-Härtung: JA3/JA3S

### Was sind JA3/JA3S?

**JA3:** TLS Client Fingerprint  
**JA3S:** TLS Server Fingerprint

**Problem:** Standard-C2-Tools haben bekannte JA3-Signaturen!

**Lösung:** JA3 Ihres Beacons ändern/randomisieren

---

### JA3-Fingerprint Ihres Beacons ermitteln

```bash
# Auf Redirector (während Beacon aktiv ist):

# Mit tcpdump
tcpdump -i eth0 -w capture.pcap port 443

# Download capture.pcap

# Analysieren mit ja3
pip3 install pyja3
python3 -m pyja3 capture.pcap

# Output:
# JA3: e7d705a3286e19ea42f587b344ee6865
# Das ist Ihr Beacon-Fingerprint!
```

---

### JA3-Whitelisting im Redirector

**Nur erlaubte JA3-Fingerprints durchlassen:**

```python
#!/usr/bin/env python3
# ja3_filter.py - Nginx + Python für JA3-Filterung

from http.server import HTTPSServer, BaseHTTPRequestHandler
import ssl
import hashlib
import socket

ALLOWED_JA3 = [
    "e7d705a3286e19ea42f587b344ee6865",  # Ihr Havoc Beacon
    "ac1c84371c1e0e72dc69c10b1b8b4b4e",  # Backup-Beacon
]

C2_BACKEND = ("78.46.12.34", 443)

class JA3FilterHandler(BaseHTTPRequestHandler):
    
    def do_GET(self):
        # JA3 berechnen
        ja3_hash = self.calculate_ja3()
        
        if ja3_hash in ALLOWED_JA3:
            # Erlaubt → Proxy zu C2
            self.proxy_to_c2()
        else:
            # Blockiert
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not Found")
    
    def calculate_ja3(self):
        # TLS-Parameter extrahieren
        # Vereinfachte Implementierung
        # In Production: nutzen Sie pyja3 Library
        
        ssl_socket = self.connection
        cipher = ssl_socket.cipher()
        version = ssl_socket.version()
        
        # JA3-String zusammenbauen
        ja3_str = f"{version},{cipher[0]},..."
        
        # MD5-Hash
        return hashlib.md5(ja3_str.encode()).hexdigest()
    
    def proxy_to_c2(self):
        # Verbindung zu C2
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(C2_BACKEND)
        
        # Request forwarden
        # ...

# Server starten
server = HTTPSServer(('0.0.0.0', 443), JA3FilterHandler)
server.socket = ssl.wrap_socket(
    server.socket,
    certfile='/etc/letsencrypt/live/ihre-domain.com/fullchain.pem',
    server_side=True
)
server.serve_forever()
```

---

### JA3 Ihres Beacons randomisieren

**Havoc unterstützt dies nicht nativ, aber Sie können:**

1. **TLS-Library im Beacon ändern:**
   ```c
   // payloads/Demon/Source/Core/Transport.c
   
   // Statt WinHTTP, nutzen Sie:
   // - OpenSSL (kompiliert ins Beacon)
   // - mbedTLS
   // - Custom TLS-Stack
   
   // Randomisiere Cipher-Suites
   ```

2. **Oder: Proxy durch legitimen Browser**
   ```
   Beacon → Chrome/Firefox (als Proxy) → C2
   
   JA3 ist dann von Chrome (legitim!)
   ```

---

## 🚨 Side-Channel Monitoring: ELK-Stack

### Warum ELK-Stack?

**Sehen Sie wenn Blue Team Ihre Infrastruktur scannt!**

```
ELK = Elasticsearch + Logstash + Kibana

Logs von:
├─ Redirector (Nginx/Apache)
├─ Teamserver (Havoc)
├─ Firewall (UFW/iptables)
└─ SSH (auth.log)

→ Zentrale Visualisierung
→ Alerts bei verdächtiger Aktivität
→ Erkennen Sie Detection-Versuche!
```

---

### ELK-Stack Installation (auf separatem VPS!)

**Empfehlung:** Eigener VPS für Monitoring (€4-6/Monat)

```bash
# Auf Monitoring-VPS (Ubuntu 22.04):

# 1. Java installieren
apt update
apt install -y openjdk-11-jdk

# 2. Elasticsearch installieren
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-8.x.list
apt update
apt install -y elasticsearch

# Konfiguration
nano /etc/elasticsearch/elasticsearch.yml
```

**elasticsearch.yml:**

```yaml
cluster.name: c2-monitoring
node.name: monitor-1
network.host: 0.0.0.0
http.port: 9200

# Sicherheit
xpack.security.enabled: true
xpack.security.enrollment.enabled: true
```

```bash
# Start
systemctl enable elasticsearch
systemctl start elasticsearch

# 3. Logstash installieren
apt install -y logstash

# Config
nano /etc/logstash/conf.d/c2-logs.conf
```

**logstash config:**

```ruby
input {
  # Nginx-Logs vom Redirector
  tcp {
    port => 5044
    codec => json
  }
  
  # Syslog
  syslog {
    port => 5140
  }
}

filter {
  # Parse Nginx Access Logs
  if [type] == "nginx-access" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    
    geoip {
      source => "clientip"
    }
    
    # Markiere verdächtige IPs
    if [clientip] in ["77.240.32.0/20", "104.131.0.0/16"] {
      mutate {
        add_tag => ["scanner", "virustotal"]
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "c2-logs-%{+YYYY.MM.dd}"
  }
}
```

```bash
# Start
systemctl enable logstash
systemctl start logstash

# 4. Kibana installieren
apt install -y kibana

# Config
nano /etc/kibana/kibana.yml
```

**kibana.yml:**

```yaml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]

# Sicherheit
xpack.security.enabled: true
```

```bash
systemctl enable kibana
systemctl start kibana

# Firewall (nur von Ihrer IP!)
ufw allow from IHRE_IP to any port 5601
```

**Zugriff:**
```
http://MONITORING_VPS_IP:5601
```

---

### Redirector-Logs zu ELK senden

**Auf Redirector (Nginx):**

```bash
# Filebeat installieren
apt install -y filebeat

# Konfiguration
nano /etc/filebeat/filebeat.yml
```

```yaml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/nginx/access.log
      - /var/log/nginx/error.log
    fields:
      type: nginx-access
      server: redirector-1

output.logstash:
  hosts: ["MONITORING_VPS_IP:5044"]
```

```bash
systemctl enable filebeat
systemctl start filebeat
```

---

### Kibana Dashboards

**Erstellen Sie Dashboards für:**

1. **Scanner-Detection:**
   ```
   Visualization: Scanner-IPs (letzte 24h)
   Query: tags:scanner
   Chart: Geo-Map mit IP-Locations
   ```

2. **Failed C2-Callbacks:**
   ```
   Query: response:404 AND path:/api/*
   Alert: Wenn > 10 in 1 Stunde
   ```

3. **Erfolgreiche Sessions:**
   ```
   Query: response:200 AND path:/api/*
   Chart: Timeline
   ```

4. **Geo-Distribution:**
   ```
   Map: Woher kommt Traffic?
   Alert: Traffic aus unerwarteten Ländern
   ```

---

## 💰 Expiring Domains (<2€)

### Wo finden?

**1. Expiring Domain Marketplaces:**

```
GoDaddy Auctions:
  https://auctions.godaddy.com/
  Filter: Price < €5
  Bid: €2-5
  
NameJet:
  https://www.namejet.com/
  Pre-release Domains
  
DropCatch:
  https://www.dropcatch.com/
  Backorder Domains für $69 (aber kann günstiger sein)
```

**2. Expired Domains Tools:**

```bash
# ExpiredDomains.net
https://www.expireddomains.net/

Filter:
- Price: < $5
- Age: > 1 Jahr (besser > 5 Jahre)
- Backlinks: > 5
- Archive.org: Has Historie
- Availability: Available for Registration

Sortiere: Alphabetisch oder nach Backlinks
```

**3. Drop Lists:**

```
TLD-Listen.com:
  Täglich aktualisierte Listen
  Filter nach TLD (.com, .net)
  Bulk-Check Verfügbarkeit
```

---

### Günstige TLDs für C2:

| TLD | Preis/Jahr | Gut für C2? | Provider mit XMR |
|-----|-----------|-------------|------------------|
| **.xyz** | €1-2 | ⚠️ Oft blockiert | Njalla |
| **.top** | €1-3 | ⚠️ Oft blockiert | - |
| **.site** | €2-4 | ✅ Weniger bekannt | Njalla |
| **.online** | €3-5 | ✅ Legitim aussehend | Njalla |
| **.store** | €2-4 | ✅ Business-ähnlich | Njalla |
| **.tech** | €4-6 | ✅ Tech-Firmen | Njalla |
| **.com** | €10-15 | ✅✅ Beste Wahl | Njalla, 1984 |

**Empfehlung:**
- **Für Production:** .com (€10-15/Jahr)
- **Für Tests/Burners:** .site, .online (€2-4/Jahr)

---

### Expiring Domain Strategie:

```bash
# 1. Suche auf ExpiredDomains.net
Filter:
  - TLD: .com
  - Price: Deleted (free to register)
  - Archive.org: YES
  - Alexa Rank: < 1,000,000
  - Backlinks: > 10

# 2. Prüfe Historie
Archive.org: https://web.archive.org/web/*/domain.com
→ War legitime Business-Webseite? ✅

# 3. Prüfe Kategorisierung
Bluecoat: https://sitereview.bluecoat.com/
→ Kategorisiert als "Business"? ✅

# 4. Prüfe Reputation
VirusTotal: https://www.virustotal.com/gui/domain/domain.com
→ Clean (0 detections)? ✅

# 5. Registrieren bei Njalla
€15/Jahr mit Monero

# 6. WHOIS bleibt anonym (Njalla)

# 7. Nutzen für C2
→ Bereits vertrauenswürdig!
→ Firewalls lassen durch!
```

---

## 🔥 Firewall: VPS-to-VPS Only

### Teamserver: NUR von Redirector erreichbar

**Problem:** Teamserver Port 443 ist offen für alle

**Lösung:** Nur Redirector-IP erlauben

```bash
# Auf Teamserver (BuyVM):

# Port 443 für alle löschen
ufw delete allow 443/tcp

# NUR von Redirector-IP erlauben
ufw allow from 194.XXX.XXX.XXX to any port 443 proto tcp comment "Redirector Only"

# Verifizieren
ufw status numbered

# Sollte zeigen:
# [1] 22/tcp         ALLOW IN    Anywhere
# [2] 40056/tcp      ALLOW IN    Anywhere
# [3] 443/tcp        ALLOW IN    194.XXX.XXX.XXX  ← NUR Redirector!
```

**Test:**

```bash
# Von Redirector (sollte funktionieren):
ssh root@REDIRECTOR_IP
nc -zv TEAMSERVER_IP 443
# → Connection succeeded ✅

# Von Ihrem PC (sollte NICHT funktionieren):
nc -zv TEAMSERVER_IP 443
# → Connection refused ✅ (Gut!)

# Von Random-IP (sollte NICHT funktionieren):
# → Blocked by firewall ✅
```

**Advanced: Auch Source-Port validieren**

```bash
# Nur von Redirector + nur wenn Source-Port > 1024
iptables -A INPUT -p tcp --dport 443 -s REDIRECTOR_IP --sport 1024: -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j DROP
```

---

## 🤖 Infrastructure-as-Code: Burner Redirectors

### Terraform für schnelles Deployment

**Ein Befehl = neuer Redirector in 2 Minuten!**

```hcl
# burner_redirector.tf

variable "redirector_count" {
  default = 3  # 3 Redirectors auf einmal!
}

resource "vultr_instance" "redirector" {
  count = var.redirector_count
  
  plan   = "vc2-1c-1gb"
  region = element(["fra", "ams", "lon"], count.index)
  os_id  = 1743  # Ubuntu 22.04
  label  = "redirector-${count.index + 1}"
  
  user_data = templatefile("cloud-init-redirector.yml", {
    c2_ip = var.teamserver_ip
    index = count.index
  })
}

# Outputs
output "redirector_ips" {
  value = vultr_instance.redirector[*].main_ip
}
```

**Verwendung:**

```bash
# Deployment (3 Redirectors gleichzeitig!)
terraform apply

# Output:
redirector_ips = [
  "45.76.12.34",
  "45.76.56.78",
  "45.76.90.12"
]

# Nach Engagement: Alle löschen
terraform destroy

# → In 1 Minute alle weg!
```

---

### Ansible für Rotation

**Automatisches Redirector-Rotation:**

```yaml
# rotate_redirectors.yml

- name: Rotate Redirectors
  hosts: localhost
  vars:
    old_redirector: redirector-1.example.com
    new_redirector: redirector-2.example.com
  
  tasks:
    # 1. Deploy neuer Redirector
    - name: Deploy new redirector
      vultr_server:
        name: "redirector-new"
        plan: vc2-1c-1gb
        region: fra
        state: present
      register: new_server
    
    # 2. DNS umschalten
    - name: Update DNS
      cloudflare_dns:
        zone: example.com
        record: cdn
        type: A
        value: "{{ new_server.main_ip }}"
    
    # 3. Warten auf DNS-Propagation
    - name: Wait for DNS
      wait_for:
        timeout: 300
    
    # 4. Alten Redirector zerstören
    - name: Destroy old redirector
      vultr_server:
        name: "{{ old_redirector }}"
        state: absent
    
    # 5. Cleanup Logs
    - name: Clean local logs
      file:
        path: /var/log/nginx/
        state: absent
```

**Ausführung:**

```bash
# Redirector rotieren (alle 24h):
ansible-playbook rotate_redirectors.yml

# Cron-Job (täglich um 3 Uhr):
0 3 * * * ansible-playbook /opt/rotate_redirectors.yml
```

---

## 🎯 Apache Advanced Rewrite Rules

### Intelligente Traffic-Filterung

```apache
# /etc/apache2/sites-available/advanced-redirector.conf

<VirtualHost *:443>
    ServerName cdn.example.com
    
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/cdn.example.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/cdn.example.com/privkey.pem
    
    RewriteEngine On
    
    # === 1. WHITELIST: Nur von Ziel-Organisation ===
    # Beispiel: Nur von 192.168.0.0/16 (Ziel-Netzwerk)
    RewriteCond %{REMOTE_ADDR} !^192\.168\.
    RewriteRule ^/api/.* - [F,L]
    
    # === 2. TIME-BASED: Nur während Geschäftszeiten ===
    # Montag-Freitag, 08:00-18:00
    RewriteCond %{TIME_WDAY} ^(0|6)$ [OR]
    RewriteCond %{TIME_HOUR} ^(0[0-7]|1[8-9]|2[0-3])$
    RewriteRule ^/api/.* - [F,L]
    
    # === 3. USER-AGENT-VALIDATION ===
    # Nur spezifische User-Agents
    RewriteCond %{HTTP_USER_AGENT} !^Mozilla/5\.0.*Windows.*Chrome
    RewriteRule ^/api/.* - [F,L]
    
    # === 4. CUSTOM-HEADER-CHECK ===
    RewriteCond %{HTTP:X-Custom-Auth} !^SecretKey123$
    RewriteRule ^/api/.* - [F,L]
    
    # === 5. RATE-LIMITING ===
    # Max 10 Requests pro Minute pro IP
    RewriteMap requests "txt:/var/www/request_counts.txt"
    RewriteCond ${requests:%{REMOTE_ADDR}|0} >10
    RewriteRule ^/api/.* - [F,L]
    
    # === 6. URI-VALIDATION ===
    # Nur erlaubte URI-Patterns
    RewriteCond %{REQUEST_URI} ^/api/v2/(auth|sync|update)$
    RewriteRule ^.*$ https://TEAMSERVER_IP:443%{REQUEST_URI} [P,L]
    
    # === 7. FALLBACK: Alles andere → Normale Webseite ===
    ProxyPass / !
    DocumentRoot /var/www/html
    
    # Proxy-Config
    SSLProxyEngine On
    SSLProxyVerify none
    ProxyPreserveHost On
</VirtualHost>
```

---

### ModSecurity für Web Application Firewall

```bash
# ModSecurity installieren
apt install -y libapache2-mod-security2

# Aktivieren
a2enmod security2

# Config
nano /etc/modsecurity/modsecurity.conf
```

**Custom Rules für C2:**

```apache
# /etc/modsecurity/custom-rules.conf

# Blockiere bekannte Scanner
SecRule REMOTE_ADDR "@ipMatch 77.240.32.0/20,104.131.0.0/16" \
    "id:1001,phase:1,deny,status:404,msg:'Scanner blocked'"

# Nur erlaubte User-Agents
SecRule REQUEST_HEADERS:User-Agent "!@rx ^Mozilla/5\.0.*(Windows|Macintosh)" \
    "id:1002,phase:1,deny,status:404,msg:'Invalid User-Agent'"

# Custom-Header erforderlich
SecRule &REQUEST_HEADERS:X-Custom-Auth "@eq 0" \
    "id:1003,phase:1,deny,status:404,msg:'Missing auth header'"
```

---

## 🎨 Komplettes Advanced Setup

### Elite Red Team Infrastructure:

```
┌─────────────────────────────────────────────────────────────┐
│                     ELITE SETUP                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Operator PC] ──VPN/Tor──► [Teamserver (BuyVM)]          │
│                               │                             │
│                               │ Nur von Redirectors!        │
│                               │                             │
│                ┌──────────────┴──────────────┐             │
│                │                             │              │
│                ↓                             ↓              │
│         [RedGuard R1]              [RedGuard R2]           │
│         (Njalla)                   (1984)                   │
│         - JA3 Filter               - JA3 Filter            │
│         - Header Check             - Geo Filter            │
│         - Time-Based               - Time-Based            │
│                │                             │              │
│                ↓                             ↓              │
│         [Cloudflare]              [AWS CloudFront]         │
│         Domain Fronting           Domain Fronting          │
│                │                             │              │
│                └─────────┬───────────────────┘             │
│                          ↓                                  │
│                     [Target Network]                        │
│                          │                                  │
│                          ↓                                  │
│                   [Monitoring VPS]                          │
│                   ELK-Stack                                 │
│                   - Scanner-Detection                       │
│                   - Blue Team Activity                      │
│                   - Traffic-Analysis                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 INSTALLATIONS-SCRIPT für Advanced Setup

```bash
#!/bin/bash
# advanced_c2_setup.sh

# === TEAMSERVER (BuyVM) ===
ssh root@BUYVM_IP << 'ENDTEAMSERVER'
# Basis-Installation
curl -s https://raw.githubusercontent.com/.../install_teamserver_standalone.sh | bash

# Firewall: NUR Redirectors
ufw delete allow 443/tcp
ufw allow from REDIRECTOR1_IP to any port 443
ufw allow from REDIRECTOR2_IP to any port 443
ENDTEAMSERVER

# === REDIRECTOR 1 (Njalla) mit RedGuard ===
ssh root@NJALLA_IP << 'ENDREDIRECTOR1'
# RedGuard installieren
cd /opt
git clone https://github.com/wikiZ/RedGuard.git
cd RedGuard
go build

# Config anpassen (JA3-Whitelist, Time-Based)
# Start als Service
ENDREDIRECTOR1

# === REDIRECTOR 2 (1984) mit Apache + ModSecurity ===
ssh root@1984_IP << 'ENDREDIRECTOR2'
# Apache + ModSecurity
apt install -y apache2 libapache2-mod-security2

# Advanced Rewrite Rules
# ModSecurity Custom Rules
ENDREDIRECTOR2

# === MONITORING VPS (Separater VPS) ===
ssh root@MONITORING_IP << 'ENDMONITORING'
# ELK-Stack installieren
# Filebeat auf allen Servern konfigurieren
ENDMONITORING

echo "[+] Advanced Setup komplett!"
```

---

## 🎯 ZUSAMMENFASSUNG: Was Sie noch brauchen

### Für BASIC Setup (Ihr aktueller Plan):

```
✅ 2 VPS (haben Sie)
✅ Domain (haben Sie)
❗ DNS-Config (5 Min)
❗ Installations-Skripte ausführen (25 Min)
❗ Havoc Client auf PC (15 Min)

Total zusätzlich: 45 Min
Kosten zusätzlich: €0
```

### Für ADVANCED Setup (wie oben):

```
✅ 2 VPS (haben Sie)
✅ Domain (haben Sie)
❗ +1 VPS für Monitoring (€4/mo)
❗ RedGuard installieren
❗ ELK-Stack installieren
❗ ModSecurity konfigurieren
❗ JA3-Fingerprinting einrichten
❗ Domain-Fronting-Setup

Total zusätzlich: 3-4 Stunden
Kosten zusätzlich: €4/mo (Monitoring-VPS)
```

---

## 💡 MEINE EMPFEHLUNG:

### **Phase 1: Starten Sie mit Basic Setup**

```
1. DNS konfigurieren
2. Teamserver + Redirector installieren (One-Liner)
3. Client installieren
4. Testen

→ Funktioniert? ✅
```

### **Phase 2: Dann upgraden zu Advanced**

```
Nach erfolgreichem Basic-Setup:
1. RedGuard hinzufügen
2. Header-Checks implementieren
3. Firewall verschärfen
4. Optional: ELK-Stack

→ Schrittweise verbessern!
```

---

**Möchten Sie zuerst Basic aufsetzen oder direkt Advanced?** 🎯

---

**Erstellt:** 2026-02-05  
**Version:** 1.0
