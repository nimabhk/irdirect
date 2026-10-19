#!/usr/bin/env bash
# install.sh — Installs irdirect and privileged helper on macOS
# Usage: sudo ./install.sh

set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
    echo "[-] Error: install.sh must be executed as root (e.g. sudo ./install.sh)" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing irdirect ==="

# 1. Create target directories
mkdir -p /usr/local/bin
mkdir -p /usr/local/libexec
mkdir -p /usr/local/share/irdirect
mkdir -p /etc/sudoers.d
mkdir -p /tmp/irdirect-state
chmod 0777 /tmp/irdirect-state

# 2. Install main executables
echo "[*] Installing /usr/local/bin/irdirect..."
cp "$SCRIPT_DIR/bin/irdirect" /usr/local/bin/irdirect
chown root:wheel /usr/local/bin/irdirect
chmod 0755 /usr/local/bin/irdirect

if [[ -f "$SCRIPT_DIR/bin/irdirect-chrome" ]]; then
    echo "[*] Installing /usr/local/bin/irdirect-chrome..."
    cp "$SCRIPT_DIR/bin/irdirect-chrome" /usr/local/bin/irdirect-chrome
    chown root:wheel /usr/local/bin/irdirect-chrome
    chmod 0755 /usr/local/bin/irdirect-chrome
fi

# 3. Install privileged helper
echo "[*] Installing /usr/local/libexec/irdirect-helper..."
cp "$SCRIPT_DIR/libexec/irdirect-helper" /usr/local/libexec/irdirect-helper
chown root:wheel /usr/local/libexec/irdirect-helper
chmod 0755 /usr/local/libexec/irdirect-helper

# 4. Install sudoers rule safely with visudo validation
echo "[*] Installing /etc/sudoers.d/irdirect..."
TMP_SUDOERS="/tmp/irdirect_sudoers.$$"
cp "$SCRIPT_DIR/etc/sudoers.d/irdirect" "$TMP_SUDOERS"
chmod 0440 "$TMP_SUDOERS"
chown root:wheel "$TMP_SUDOERS"

if visudo -c -f "$TMP_SUDOERS" >/dev/null 2>&1; then
    mv "$TMP_SUDOERS" /etc/sudoers.d/irdirect
    chown root:wheel /etc/sudoers.d/irdirect
    chmod 0440 /etc/sudoers.d/irdirect
    echo "[+] Sudoers rule validated and installed."
else
    rm -f "$TMP_SUDOERS"
    echo "[-] Sudoers syntax validation failed! Aborting." >&2
    exit 1
fi

# 5. Install share files
echo "[*] Installing documentation and verification suite in /usr/local/share/irdirect/..."
cp "$SCRIPT_DIR/share/irdirect/README.md" /usr/local/share/irdirect/README.md
cp "$SCRIPT_DIR/share/irdirect/SKILL.md" /usr/local/share/irdirect/SKILL.md
cp "$SCRIPT_DIR/share/irdirect/verify_suite.sh" /usr/local/share/irdirect/verify_suite.sh
chmod 0644 /usr/local/share/irdirect/README.md /usr/local/share/irdirect/SKILL.md
chmod 0755 /usr/local/share/irdirect/verify_suite.sh

# 6. Initialize scoped routing and DNS tables
echo "[*] Running initial hardware route injection & PF DNS unlock..."
WAN_IF=$(ipconfig getifaddr en1 >/dev/null 2>&1 && echo "en1" || echo "")
if [[ -n "$WAN_IF" ]]; then
    GW=$(ipconfig getoption "$WAN_IF" router 2>/dev/null || echo "192.168.1.1")
    /usr/local/libexec/irdirect-helper ensure-route "$WAN_IF" "$GW"
    DHCP_DNS=$(ipconfig getoption "$WAN_IF" domain_name_server 2>/dev/null || echo "")
    /usr/local/libexec/irdirect-helper pf-allow-dns "$GW" $DHCP_DNS 217.218.127.127 217.218.155.155 || true
    echo "[+] Hardware route for $WAN_IF via $GW initialized."
fi

echo ""
echo "=== Installation Completed Successfully! ==="
echo "You can now run 'irdirect --doctor' to verify system health."
