#!/usr/bin/env bash
# uninstall.sh — Removes irdirect from macOS
# Usage: sudo ./uninstall.sh

set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
    echo "[-] Error: uninstall.sh must be executed as root (e.g. sudo ./uninstall.sh)" >&2
    exit 1
fi

echo "=== Uninstalling irdirect ==="

rm -f /usr/local/bin/irdirect
rm -f /usr/local/bin/irdirect-chrome
rm -f /usr/local/libexec/irdirect-helper
rm -f /etc/sudoers.d/irdirect
rm -rf /usr/local/share/irdirect
rm -rf /tmp/irdirect-state

echo "[+] irdirect has been completely removed from system directories."
