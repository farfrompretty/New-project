#!/bin/bash
#
# Download-Helper: Lädt alle Havoc C2 Skripte herunter
#
# Verwendung: bash download_all_scripts.sh
#

set -e

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     Havoc C2 Scripts - Automatischer Download                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# GitHub Base URL
BASE_URL="https://raw.githubusercontent.com/farfrompretty/New-project/cursor/c2-server-einrichtung-dbe4/scripts"

# Zielverzeichnis
TARGET_DIR="havoc-c2-scripts"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

echo -e "${YELLOW}[*] Lade Skripte herunter nach: $(pwd)${NC}"
echo ""

# Liste der Skripte
declare -a SCRIPTS=(
    "master_setup_automated.sh"
    "install_havoc_teamserver.sh"
    "install_redirector_apache.sh"
    "install_redirector_nginx.sh"
    "install_redirector_caddy.sh"
    "install_redirector_traefik.sh"
    "harden_server.sh"
    "cleanup_infrastructure.sh"
)

# Download-Funktion
download_script() {
    local script=$1
    local url="${BASE_URL}/${script}"
    
    echo -n "[*] Lade ${script}... "
    
    if curl -sf -o "${script}" "${url}"; then
        chmod +x "${script}"
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ FEHLER${NC}"
        return 1
    fi
}

# Alle Skripte herunterladen
FAILED=0
for script in "${SCRIPTS[@]}"; do
    download_script "$script" || FAILED=$((FAILED + 1))
done

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}║  ✓ Alle Skripte erfolgreich heruntergeladen!                 ║${NC}"
else
    echo -e "${RED}║  ! ${FAILED} Skript(e) fehlgeschlagen!                          ║${NC}"
fi

echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Liste der Dateien
echo -e "${YELLOW}Heruntergeladene Skripte:${NC}"
ls -lh *.sh

echo ""
echo -e "${GREEN}Nächste Schritte:${NC}"
echo ""
echo "1. Wählen Sie ein Skript:"
echo "   - master_setup_automated.sh   → Vollautomatisches Setup"
echo "   - install_havoc_teamserver.sh → Nur Teamserver"
echo "   - install_redirector_*.sh     → Nur Redirector"
echo ""
echo "2. Ausführen:"
echo "   sudo ./master_setup_automated.sh"
echo ""
echo -e "${YELLOW}Dokumentation:${NC}"
echo "   https://github.com/farfrompretty/New-project/tree/cursor/c2-server-einrichtung-dbe4"
echo ""

# Optionaler README-Download
read -p "README.md auch herunterladen? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -sf -o README.md "${BASE_URL}/README.md" && echo -e "${GREEN}✓ README.md heruntergeladen${NC}"
fi

echo ""
echo -e "${GREEN}Fertig!${NC}"
