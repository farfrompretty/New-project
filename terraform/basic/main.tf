# Basic Havoc C2 Setup: 1 Teamserver + 1 Redirector (DigitalOcean)
#
# Usage:
#   terraform init
#   terraform plan
#   terraform apply

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# ===  VARIABLES ===

variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "cf_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Domain for C2 (must be managed by Cloudflare)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for redirector"
  type        = string
  default     = "cdn"
}

variable "ssh_keys" {
  description = "List of SSH key IDs/fingerprints"
  type        = list(string)
}

variable "admin_password" {
  description = "Havoc Teamserver admin password"
  type        = string
  sensitive   = true
  default     = ""  # Will be generated if empty
}

variable "region_teamserver" {
  description = "Region for Teamserver"
  type        = string
  default     = "fra1"  # Frankfurt
}

variable "region_redirector" {
  description = "Region for Redirector"
  type        = string
  default     = "ams3"  # Amsterdam
}

# === PROVIDERS ===

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  api_token = var.cf_api_token
}

# === LOCALS ===

locals {
  admin_password = var.admin_password != "" ? var.admin_password : random_password.admin_password[0].result
}

# === RANDOM PASSWORD ===

resource "random_password" "admin_password" {
  count   = var.admin_password == "" ? 1 : 0
  length  = 20
  special = true
}

# === TEAMSERVER ===

resource "digitalocean_droplet" "teamserver" {
  name   = "c2-teamserver-${random_id.suffix.hex}"
  region = var.region_teamserver
  size   = "s-2vcpu-2gb"  # $18/month
  image  = "ubuntu-22-04-x64"
  
  ssh_keys = var.ssh_keys
  
  user_data = templatefile("${path.module}/cloud-init-teamserver.yml", {
    admin_password = local.admin_password
  })
  
  tags = ["c2", "teamserver"]
}

# === REDIRECTOR ===

resource "digitalocean_droplet" "redirector" {
  name   = "c2-redirector-${random_id.suffix.hex}"
  region = var.region_redirector
  size   = "s-1vcpu-1gb"  # $6/month
  image  = "ubuntu-22-04-x64"
  
  ssh_keys = var.ssh_keys
  
  user_data = templatefile("${path.module}/cloud-init-redirector.yml", {
    domain          = "${var.subdomain}.${var.domain}"
    c2_ip           = digitalocean_droplet.teamserver.ipv4_address_private
    c2_port         = 443
    admin_email     = "admin@${var.domain}"
  })
  
  tags = ["c2", "redirector"]
  
  depends_on = [digitalocean_droplet.teamserver]
}

# === DNS (CLOUDFLARE) ===

data "cloudflare_zone" "main" {
  name = var.domain
}

resource "cloudflare_record" "redirector" {
  zone_id = data.cloudflare_zone.main.id
  name    = var.subdomain
  value   = digitalocean_droplet.redirector.ipv4_address
  type    = "A"
  ttl     = 300
  proxied = false  # Set to true for Cloudflare proxy (extra OPSEC)
}

# === FIREWALL ===

resource "digitalocean_firewall" "teamserver" {
  name = "c2-teamserver-fw-${random_id.suffix.hex}"
  
  droplet_ids = [digitalocean_droplet.teamserver.id]
  
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]  # SSH from anywhere (change for production!)
  }
  
  inbound_rule {
    protocol         = "tcp"
    port_range       = "40056"
    source_addresses = ["0.0.0.0/0"]  # Operator access
  }
  
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = [digitalocean_droplet.redirector.ipv4_address]  # Only from redirector
  }
  
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_firewall" "redirector" {
  name = "c2-redirector-fw-${random_id.suffix.hex}"
  
  droplet_ids = [digitalocean_droplet.redirector.id]
  
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# === RANDOM ID FOR UNIQUE NAMES ===

resource "random_id" "suffix" {
  byte_length = 4
}

# === OUTPUTS ===

output "teamserver_ip" {
  value       = digitalocean_droplet.teamserver.ipv4_address
  description = "Teamserver Public IP"
}

output "redirector_ip" {
  value       = digitalocean_droplet.redirector.ipv4_address
  description = "Redirector Public IP"
}

output "redirector_domain" {
  value       = "${var.subdomain}.${var.domain}"
  description = "Redirector Domain"
}

output "admin_password" {
  value       = local.admin_password
  sensitive   = true
  description = "Havoc Admin Password (use: terraform output -raw admin_password)"
}

output "connection_info" {
  value = <<-EOT
  
  === HAVOC C2 INFRASTRUCTURE DEPLOYED ===
  
  Teamserver:
    IP:       ${digitalocean_droplet.teamserver.ipv4_address}
    Port:     40056
    User:     admin
    Password: ${local.admin_password}
  
  Redirector:
    IP:     ${digitalocean_droplet.redirector.ipv4_address}
    Domain: ${var.subdomain}.${var.domain}
    Status: Deploying (wait 5-10 minutes for full setup)
  
  SSH Access:
    Teamserver:  ssh root@${digitalocean_droplet.teamserver.ipv4_address}
    Redirector:  ssh root@${digitalocean_droplet.redirector.ipv4_address}
  
  Next Steps:
    1. Wait 5-10 minutes for cloud-init to complete
    2. Check teamserver: ssh root@${digitalocean_droplet.teamserver.ipv4_address} "systemctl status havoc-teamserver"
    3. Check redirector: curl https://${var.subdomain}.${var.domain}/
    4. Connect Havoc Client to ${digitalocean_droplet.teamserver.ipv4_address}:40056
  
  EOT
  
  description = "Connection Information"
}
