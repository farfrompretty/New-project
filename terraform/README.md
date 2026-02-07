# Terraform-Automatisierung für Havoc C2

> **Ziel:** Komplette C2-Infrastruktur mit einem Befehl deployen.

---

## 📋 Übersicht

Diese Terraform-Konfigurationen ermöglichen:
- ✅ Automatisches Deployment von Teamserver + Redirectors
- ✅ Multi-Provider-Support (DigitalOcean, Vultr, AWS, Hetzner)
- ✅ DNS-Konfiguration (Cloudflare)
- ✅ SSL-Zertifikate (Let's Encrypt via Cloud-Init)
- ✅ Skalierbar (1-10+ Redirectors)

---

## Verfügbare Setups

| Setup | Beschreibung | Kosten/Monat |
|-------|--------------|--------------|
| **basic/** | 1 Teamserver + 1 Redirector | ~$10 |
| **standard/** | 1 Teamserver + 3 Redirectors | ~$20 |
| **multi-provider/** | Verschiedene Provider für OPSEC | ~$30 |
| **aws/** | AWS-basiertes Setup | ~$20-40 |

---

## Voraussetzungen

```bash
# Terraform installieren
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version

# Provider-API-Keys exportieren
export DIGITALOCEAN_TOKEN="your_do_token"
export VULTR_API_KEY="your_vultr_key"
export CLOUDFLARE_API_TOKEN="your_cf_token"
```

---

## Schnellstart

```bash
# 1. Setup wählen
cd terraform/basic/

# 2. Variablen anpassen
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 3. Initialisieren
terraform init

# 4. Plan prüfen
terraform plan

# 5. Deployen
terraform apply

# 6. Outputs anzeigen
terraform output

# 7. Nach Engagement zerstören
terraform destroy
```

---

## Weitere Informationen

Siehe Setup-spezifische READMEs:
- `basic/README.md`
- `standard/README.md`
- `multi-provider/README.md`
- `aws/README.md`
