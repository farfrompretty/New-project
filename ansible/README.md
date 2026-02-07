# Ansible-Automatisierung für Havoc C2

> **Ziel:** Havoc C2-Infrastruktur mit Ansible automatisiert konfigurieren und verwalten.

---

## 📋 Übersicht

Diese Ansible-Playbooks ermöglichen:
- ✅ Automatische Installation von Havoc auf bestehenden VPS
- ✅ Redirector-Setup (Apache, Nginx, Caddy)
- ✅ Server-Härtung (SSH, Firewall, Fail2Ban)
- ✅ SSL-Zertifikate (Let's Encrypt)
- ✅ Update-Management
- ✅ Multi-Host-Orchestrierung

---

## Voraussetzungen

```bash
# Ansible installieren
sudo apt update
sudo apt install ansible -y

# Oder via pip
pip3 install ansible

# Version prüfen
ansible --version
```

---

## Schnellstart

```bash
# 1. Inventory anpassen
cp inventory.ini.example inventory.ini
nano inventory.ini

# 2. Variables setzen
cp group_vars/all.yml.example group_vars/all.yml
nano group_vars/all.yml

# 3. SSH-Keys verteilen (falls nicht vorhanden)
ansible all -i inventory.ini -m ping

# 4. Komplette Infrastruktur deployen
ansible-playbook -i inventory.ini site.yml

# 5. Oder einzelne Rollen
ansible-playbook -i inventory.ini playbooks/install-teamserver.yml
ansible-playbook -i inventory.ini playbooks/install-redirector.yml
```

---

## Verfügbare Playbooks

| Playbook | Beschreibung |
|----------|--------------|
| `site.yml` | Komplettes Deployment (alle Komponenten) |
| `playbooks/install-teamserver.yml` | Nur Teamserver |
| `playbooks/install-redirector.yml` | Nur Redirector(s) |
| `playbooks/harden-servers.yml` | Security-Härtung |
| `playbooks/update-all.yml` | System-Updates |
| `playbooks/cleanup.yml` | Post-Engagement Cleanup |

---

## Struktur

```
ansible/
├── README.md
├── inventory.ini                 # Server-Liste
├── ansible.cfg                   # Ansible-Konfiguration
├── site.yml                      # Main Playbook
├── group_vars/
│   ├── all.yml                   # Globale Variablen
│   ├── teamservers.yml          # Teamserver-spezifisch
│   └── redirectors.yml           # Redirector-spezifisch
├── host_vars/                    # Host-spezifische Vars
├── roles/
│   ├── common/                   # Basis-Setup
│   ├── havoc-teamserver/         # Teamserver-Installation
│   ├── redirector-nginx/         # Nginx Redirector
│   ├── redirector-apache/        # Apache Redirector
│   ├── redirector-caddy/         # Caddy Redirector
│   ├── harden/                   # Security-Härtung
│   └── ssl-letsencrypt/          # SSL-Zertifikate
└── playbooks/                    # Spezifische Playbooks
```

---

## Beispiel-Workflows

### Workflow 1: Neue Infrastruktur

```bash
# Full deployment
ansible-playbook -i inventory.ini site.yml

# Mit Tags (nur bestimmte Teile)
ansible-playbook -i inventory.ini site.yml --tags "teamserver"
ansible-playbook -i inventory.ini site.yml --tags "redirector"
```

### Workflow 2: Nur Updates

```bash
ansible-playbook -i inventory.ini playbooks/update-all.yml
```

### Workflow 3: Neue Redirector hinzufügen

```bash
# 1. inventory.ini erweitern
# 2. Nur Redirectors deployen
ansible-playbook -i inventory.ini playbooks/install-redirector.yml --limit new-redirector-host
```

### Workflow 4: Post-Engagement Cleanup

```bash
ansible-playbook -i inventory.ini playbooks/cleanup.yml
```

---

## Weitere Informationen

- Beispiel-Inventory: `inventory.ini.example`
- Beispiel-Variables: `group_vars/all.yml.example`
- Role-Dokumentationen: `roles/*/README.md`
