#!/bin/bash
#
# CLOUDZY OPTIMIERTES SETUP
# Speziell für: Cloudzy VPS + Domain
#
# Verwendung:
#   bash cloudzy_setup_optimiert.sh
#

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         CLOUDZY OPTIMIERTES SETUP                           ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Informationen sammeln
read -p "Cloudzy VPS IP: " CLOUDZY_IP
CLOUDZY_IP=${CLOUDZY_IP:-104.194.158.236}

read -p "Domain: " DOMAIN
DOMAIN=${DOMAIN:-librarymgmtsvc.com}

echo ""
echo "[?] Was soll Cloudzy VPS sein?"
echo "  1) Redirector (öffentlich, empfohlen)"
echo "  2) Teamserver (versteckt)"
echo ""
read -p "Auswahl [1-2]: " CHOICE

if [ "$CHOICE" = "1" ]; then
    # Cloudzy = Redirector
    echo ""
    echo "[*] Cloudzy wird REDIRECTOR"
    echo ""
    
    read -p "Teamserver-IP (separater VPS empfohlen): " TS_IP
    if [ -z "$TS_IP" ]; then
        echo "[!] Teamserver-IP erforderlich!"
        exit 1
    fi
    
    echo ""
    echo "[+] Installiere Redirector auf Cloudzy..."
    echo ""
    
    ssh -o StrictHostKeyChecking=no root@$CLOUDZY_IP bash << ENDREDIRECTOR
    curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_redirector_standalone.sh | bash << ENDINPUT
$DOMAIN
$TS_IP
admin@$DOMAIN
ENDINPUT
ENDREDIRECTOR
    
    echo ""
    echo "[✓] Redirector installiert!"
    echo ""
    echo "Nächste Schritte:"
    echo "  1. Installieren Sie Teamserver auf: $TS_IP"
    echo "     ssh root@$TS_IP"
    echo "     curl -s https://raw.../install_teamserver_standalone.sh | bash"
    echo ""
    echo "  2. DNS konfigurieren:"
    echo "     $DOMAIN → $CLOUDZY_IP"
    echo ""
    
elif [ "$CHOICE" = "2" ]; then
    # Cloudzy = Teamserver
    echo ""
    echo "[*] Cloudzy wird TEAMSERVER"
    echo ""
    
    read -p "Redirector-IP (separater VPS empfohlen): " RD_IP
    
    echo ""
    echo "[+] Installiere Teamserver auf Cloudzy..."
    echo ""
    
    ssh -o StrictHostKeyChecking=no root@$CLOUDZY_IP bash << ENDTEAMSERVER
    curl -s https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/install_teamserver_standalone.sh | bash << ENDINPUT
$DOMAIN
ENDINPUT
ENDTEAMSERVER
    
    echo ""
    echo "[✓] Teamserver installiert!"
    echo ""
    
    if [ -n "$RD_IP" ]; then
        echo "Nächste Schritte:"
        echo "  1. Installieren Sie Redirector auf: $RD_IP"
        echo "  2. DNS: $DOMAIN → $RD_IP"
    fi
else
    echo "[!] Ungültige Auswahl"
    exit 1
fi

echo ""
echo "[✓] Setup abgeschlossen!"
echo ""
