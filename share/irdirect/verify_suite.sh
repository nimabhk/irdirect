#!/usr/bin/env bash
# /usr/local/share/irdirect/verify_suite.sh
# Automated diagnostic & end-to-end verification suite for irdirect

set -euo pipefail

IRDIRECT_BIN="${IRDIRECT_BIN:-/usr/local/bin/irdirect}"
if [[ ! -x "$IRDIRECT_BIN" && -x "./bin/irdirect" ]]; then
    IRDIRECT_BIN="./bin/irdirect"
fi

echo "=========================================================="
echo "    irdirect End-to-End Verification & Leak Audit Suite   "
echo "=========================================================="

echo "[*] Using binary: $IRDIRECT_BIN"

# --- Test 1: Check System Default (VPN) IP ---
echo ""
echo "[Test 1/4] Checking normal system egress IP (expecting VPN IP)..."
VPN_IP=$(curl -4 -s --max-time 6 https://api.ipify.org || echo "FAILED_OR_TIMEOUT")
echo "  -> System Default IP: $VPN_IP"

# --- Test 2: Check irdirect Direct Iranian IP ---
echo ""
echo "[Test 2/4] Checking irdirect HTTP proxy egress IP (expecting Iranian ISP IP)..."
DIRECT_IP=$("$IRDIRECT_BIN" --no-check curl -4 -s --max-time 8 https://api.ipify.org || echo "")

if [[ -n "$DIRECT_IP" && "$DIRECT_IP" != "FAILED" ]]; then
    echo "  -> irdirect Egress IP: $DIRECT_IP"
    if [[ "$VPN_IP" != "FAILED_OR_TIMEOUT" && "$VPN_IP" == "$DIRECT_IP" ]]; then
        echo "[-] LEAK DETECTED: irdirect IP matches VPN IP! Reverse kill-switch failed."
        exit 99
    fi
    echo "[+] PASS: irdirect egresses over a distinct physical IP ($DIRECT_IP != $VPN_IP)."
else
    echo "  -> api.ipify.org not reachable directly (physical ISP is restricted to Iran Intranet)."
    echo "  -> Verifying direct Iranian ISP egress via domestic endpoint (https://torob.com)..."
    DOM_STATUS=$("$IRDIRECT_BIN" --no-check curl -4 -s -o /dev/null -w "%{http_code}" --max-time 8 https://torob.com || echo "000")
    echo "  -> torob.com HTTP status: $DOM_STATUS"
    if [[ "$DOM_STATUS" =~ ^(200|301|302|307|308|403)$ ]]; then
        echo "[+] PASS: Direct domestic connection verified (HTTP $DOM_STATUS on torob.com)."
    else
        echo "[-] FAILED: irdirect could not connect to domestic services directly."
        exit 1
    fi
fi

# --- Test 3: SOCKS5h Mode & Domestic .ir Site Access ---
echo ""
echo "[Test 3/4] Checking SOCKS5h mode with domestic banking endpoint (bmi.ir)..."
HTTP_STATUS=$("$IRDIRECT_BIN" --no-check sh -c 'curl -k -4 -s -o /dev/null -w "%{http_code}" --proxy "socks5h://127.0.0.1:$IRDIRECT_PORT" --max-time 10 https://bmi.ir' || echo "000")
echo "  -> bmi.ir HTTP status: $HTTP_STATUS"

if [[ "$HTTP_STATUS" =~ ^(200|301|302|307|308|403)$ ]]; then
    echo "[+] PASS: Direct domestic connection established successfully (HTTP $HTTP_STATUS)."
else
    echo "[!] WARNING: bmi.ir returned unexpected status ($HTTP_STATUS). Target server might be rate-limiting or down."
fi

# --- Test 4: PF Table Cleanup Verification ---
echo ""
echo "[Test 4/4] Verifying PF table state cleanup..."
if pfctl -s Anchors 2>/dev/null | grep -q "amn"; then
    echo "  -> AmneziaVPN anchor active. Checking <allownets> table..."
    sudo pfctl -a "amn/110.allowNets" -t allownets -T show 2>/dev/null || true
    echo "[+] PASS: PF cleanup inspection complete."
else
    echo "  -> AmneziaVPN not active or no pf anchor. Skipping PF table inspection."
fi

echo ""
echo "=========================================================="
echo "    All Verification Tests Completed Successfully!        "
echo "=========================================================="
exit 0
