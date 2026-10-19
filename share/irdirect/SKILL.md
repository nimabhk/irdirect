---
name: irdirect
description: macOS kernel-scoped VPN bypass and direct Iranian ISP routing tool (`irdirect` and `irdirect-chrome`). Use whenever interacting with Iranian domestic internet services (.ir domains, banks, government/national portals, domestic APIs, Torob, Divar, etc.) without disabling or disturbing active system VPNs (AmneziaVPN, WireGuard, Sing-box/Hiddify, ProtonVPN) or their firewall kill-switches.
---

# `irdirect` — macOS VPN Bypass & Direct Iranian ISP Routing Skill

`irdirect` is an ephemeral macOS network routing tool that allows any CLI command, script, cronjob, or browser to route directly through the physical ISP interface (`en1` - Nokia SIM Modem on MCI/Hamrah-e Aval) using kernel socket binding (`IP_BOUND_IF = 25`), completely bypassing active system VPNs and firewall kill-switches without disconnecting the VPN for the rest of the OS.

---

## 🚨 Mandatory Operational Rules for AI Agents

1. **NEVER Disable or Toggle the VPN:**
   Under NO circumstances should you ask the user to disconnect AmneziaVPN, turn off Little Snitch, or pause AdGuard to access Iranian domestic websites. Always prefix the command with `irdirect`.
2. **Reverse Kill-Switch Protection (Exit 99):**
   If the physical link is down or if traffic leaks to the VPN, `irdirect` immediately aborts with Exit Code `99`. Never attempt to retry without `irdirect` if code 99 is returned.
3. **Strict IPv4 Focus:**
   The tool binds strictly to IPv4. Do not force IPv6 (`-6`) flags in child tools.
4. **Isolated Chrome Profiles:**
   To open a real Chrome window via the Iranian IP, use `irdirect-chrome <url>` which automatically sets up an isolated user profile so existing open Chrome instances do not hijack the session.

---

## CLI Command Reference

### 1. Command Wrapper Mode (Standard)
```bash
# Wrap any command to route via Iranian ISP
irdirect <COMMAND> [ARGS...]

# Examples:
irdirect curl -4 -s -I https://torob.com
irdirect curl -4 -s -I https://divar.ir
irdirect curl -k -4 -s -I https://bmi.ir
irdirect python3 my_domestic_scraper.py
irdirect git clone https://git.domestic.ir/repo.git
```

### 2. GUI Google Chrome Runner (`irdirect-chrome`)
```bash
# Open an isolated Chrome window directly routing over Iranian ISP
irdirect-chrome [URL]

# Examples:
irdirect-chrome https://torob.com
irdirect-chrome https://divar.ir
irdirect-chrome https://bmi.ir
```

### 3. Standalone Proxy Listener Mode
```bash
# Start standalone proxy for external apps (Playwright, Selenium, etc.)
irdirect --listen [PORT] --idle-timeout <SECONDS>

# Example: Run on port 59999 and auto-terminate after 120s of inactivity
irdirect -p 59999 --listen --idle-timeout 120
```

### 4. Self-Diagnostic & System Health
```bash
# Run comprehensive health diagnostic
irdirect --doctor

# Run verification test suite
/usr/local/share/irdirect/verify_suite.sh
```

---

## Injected Environment Variables

When executing a wrapped command, `irdirect` automatically sets and exports:
- `HTTP_PROXY` / `http_proxy`: `http://127.0.0.1:<PORT>`
- `HTTPS_PROXY` / `https_proxy`: `http://127.0.0.1:<PORT>`
- `ALL_PROXY` / `all_proxy`: `socks5h://127.0.0.1:<PORT>`
- `IRDIRECT_PORT`: Numeric ephemeral port allocated for the session
- `IRDIRECT_PROXY_URL`: `http://127.0.0.1:<PORT>`
- `IRDIRECT_SOCKS_URL`: `socks5h://127.0.0.1:<PORT>`
- `IRDIRECT_INTERFACE`: Active physical WAN interface (e.g., `en1`)
- `NO_PROXY` / `no_proxy`: `localhost,127.0.0.1,192.168.99.0/24`

---

## Python Integration Example

```python
import os
import requests

# Python requests automatically picks up HTTP_PROXY and HTTPS_PROXY
response = requests.get("https://torob.com", timeout=10)
print("Status Code:", response.status_code)
```
Run with:
```bash
irdirect python3 script.py
```

For `aiohttp`, pass `trust_env=True`:
```python
import aiohttp
import asyncio

async def fetch():
    async with aiohttp.ClientSession(trust_env=True) as session:
        async with session.get("https://torob.com") as resp:
            print(resp.status)

asyncio.run(fetch())
```

---

## Headless Browser Automation (Playwright)

```python
import os
from playwright.sync_api import sync_playwright

proxy_server = os.environ.get("IRDIRECT_PROXY_URL")
with sync_playwright() as p:
    browser = p.chromium.launch(
        headless=True,
        proxy={"server": proxy_server} if proxy_server else None
    )
    page = browser.new_page()
    page.goto("https://torob.com")
    print("Title:", page.title())
    browser.close()
```
Run with:
```bash
irdirect python3 playwright_script.py
```

---

## Exit Codes for AI Agents

| Exit Code | Meaning | Required Agent Action |
| :---: | :--- | :--- |
| `0` | Success | Normal operation. |
| `99` | **Reverse Kill-Switch Triggered** | Reverse routing failed or physical link disconnected. **STOP immediately**. Never retry without `irdirect`. Run `irdirect --doctor`. |
| `98` | **Helper / Sudoers Failure** | Sudoers permission error or helper missing. |
| `97` | **Direct DNS Failure** | All DNS servers failed. |
| `*` | Child exit code | Handled by child application. |
