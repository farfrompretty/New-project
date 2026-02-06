#!/bin/bash
#
# POST-ENGAGEMENT CLEANUP - LÖSCHT ALLE SPUREN!
#
# ⚠️  NUR NACH ENGAGEMENT AUSFÜHREN!
# ⚠️  IRREVERSIBEL!
#
# Verwendung:
#   sudo bash post_engagement_cleanup.sh
#

set -e

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║     ⚠️  POST-ENGAGEMENT CLEANUP  ⚠️                          ║"
echo "║                                                               ║"
echo "║     WARNUNG: Löscht ALLE Spuren!                            ║"
echo "║     Dieser Prozess ist IRREVERSIBEL!                        ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "[!] Als root ausführen: sudo bash $0"
    exit 1
fi

echo "Dieses Script löscht:"
echo "  • Alle Havoc-Daten"
echo "  • Alle Logs (überschrieben)"
echo "  • Alle Bash-History"
echo "  • Alle SSH-Keys"
echo "  • Alle temporären Dateien"
echo "  • Git-Traces"
echo "  • Optional: Gesamte Disk"
echo ""

read -p "Sind Sie ABSOLUT SICHER? (type: DELETE) " CONFIRM
if [ "$CONFIRM" != "DELETE" ]; then
    echo "Abgebrochen"
    exit 0
fi

echo ""

# ═══ PHASE 1: Services ═══
echo "[1/10] Stoppe Services..."
systemctl stop havoc-teamserver 2>/dev/null || true
systemctl stop nginx 2>/dev/null || true
systemctl stop apache2 2>/dev/null || true
systemctl stop caddy 2>/dev/null || true

# ═══ PHASE 2: Havoc ═══
echo "[2/10] Lösche Havoc..."
if [ -d "/opt/Havoc" ]; then
    find /opt/Havoc -type f -name "*.yaotl" -exec shred -vfz -n 10 {} \; 2>/dev/null
    find /opt/Havoc -type f -exec shred -vfz -n 3 {} \; 2>/dev/null
    rm -rf /opt/Havoc
fi
rm -f /etc/systemd/system/havoc-teamserver.service

# ═══ PHASE 3: Web-Configs ═══
echo "[3/10] Lösche Web-Configs..."
find /etc/nginx -name "*redirector*" -exec shred -vfz -n 3 {} \; 2>/dev/null
find /etc/apache2 -name "*redirector*" -exec shred -vfz -n 3 {} \; 2>/dev/null
rm -rf /etc/nginx/sites-available/redirector*
rm -rf /etc/apache2/sites-available/redirector*

# ═══ PHASE 4: Logs ═══
echo "[4/10] Überschreibe Logs..."
for log in /var/log/*.log /var/log/*/*.log; do
    [ -f "$log" ] && shred -vfz -n 3 "$log" 2>/dev/null
done

journalctl --rotate 2>/dev/null
journalctl --vacuum-time=1s 2>/dev/null

echo "" > /var/log/auth.log
echo "" > /var/log/syslog
echo "" > /var/log/kern.log

# ═══ PHASE 5: Bash History ═══
echo "[5/10] Lösche Command-History..."
for home in /root /home/*; do
    [ -f "$home/.bash_history" ] && shred -vfz -n 10 "$home/.bash_history" 2>/dev/null
    echo "" > "$home/.bash_history" 2>/dev/null
done

history -c
unset HISTFILE

# ═══ PHASE 6: SSH ═══
echo "[6/10] Lösche SSH-Traces..."
find /root/.ssh -type f -exec shred -vfz -n 10 {} \; 2>/dev/null
find /home/*/.ssh -type f -exec shred -vfz -n 10 {} \; 2>/dev/null
rm -rf /root/.ssh /home/*/.ssh

# ═══ PHASE 7: SSL ═══
echo "[7/10] Lösche SSL-Zertifikate..."
rm -rf /etc/letsencrypt
rm -rf /opt/Havoc/ssl 2>/dev/null

# ═══ PHASE 8: Temp ═══
echo "[8/10] Lösche Temp-Dateien..."
find /tmp -type f -exec shred -vfz -n 3 {} \; 2>/dev/null
find /var/tmp -type f -exec shred -vfz -n 3 {} \; 2>/dev/null
rm -rf /tmp/* /var/tmp/*

# ═══ PHASE 9: Git ═══
echo "[9/10] Lösche Git-Traces..."
find / -name ".git" -type d -exec rm -rf {} \; 2>/dev/null
rm -rf /root/.gitconfig

# ═══ PHASE 10: System-Traces ═══
echo "[10/10] Finale Cleanup..."

# Package-Manager Cache
apt clean

# Systemd
systemctl daemon-reload

# Kernel Messages
dmesg -c >/dev/null 2>&1

echo ""
echo "[✓] Cleanup abgeschlossen!"
echo ""
echo "Nächste Schritte:"
echo "  1. Prüfen ob alles gelöscht: ls -la /opt/"
echo "  2. VPS beim Provider löschen/zerstören"
echo "  3. DNS-Records entfernen"
echo "  4. Domain zu anderem Provider verschieben"
echo ""

read -p "Gesamte Disk überschreiben? (yes/no) " WIPE
if [ "$WIPE" = "yes" ]; then
    echo "[!] DISK WIPE startet - Server wird unbrauchbar!"
    sleep 5
    dd if=/dev/urandom of=/dev/sda bs=1M status=progress 2>/dev/null || true
    sync
    poweroff
fi
