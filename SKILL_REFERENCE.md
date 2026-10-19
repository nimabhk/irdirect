# `irdirect` — Operational Manual & AI Agent Integration Guide

## Overview
`irdirect` is a surgical macOS network bypass tool installed at `/usr/local/bin/irdirect`. It allows any command, script, cronjob, or browser automation tool to connect directly to the Internet using the host's native Iranian ISP IP address (Hamrah-e Aval / Nokia Modem on physical interface `en1`), completely bypassing active VPN tunnels (`AmneziaVPN`, `ProtonVPN`, `WireGuard`, `Hiddify`) and their firewall Kill Switches without disconnecting or disturbing the VPN for the rest of the operating system.

---

## Core Operational Rules (For Humans & AI Agents)

1. **Zero VPN Disruption:** NEVER disconnect or toggle AmneziaVPN, Little Snitch, or AdGuard to access Iranian domestic websites (`.ir`, government portals, banks, domestic APIs). Always wrap the command with `irdirect`.
2. **Ephemeral Lifecycle:** `irdirect` does NOT run as a permanent background service. It starts an in-memory proxy bound to the physical interface (`IP_BOUND_IF`) only for the duration of the command and tears everything down (including temporary firewall whitelist rules) as soon as the command finishes.
3. **Concurrency Safe:** Each invocation of `irdirect` allocates an independent ephemeral local port (`127.0.0.1:<random_port>`). Multiple cronjobs and agents can invoke `irdirect` simultaneously without port collisions.
4. **Hard Reverse Kill-Switch:** If the physical internet link (`en1`) is disconnected or fails verification, `irdirect` will **immediately abort with Exit Code `99`**. It will NEVER leak traffic over the foreign VPN IP.

---

## Command-Line Syntax & Flags

```bash
# Mode 1: Command Wrapper (Recommended for scripts, curl, git, python, node, cronjobs)
irdirect [OPTIONS] -- <COMMAND> [ARGS...]
irdirect <COMMAND> [ARGS...]

# Mode 2: Standalone Timed Listener (For external apps or multi-step agent workflows)
irdirect --listen [PORT] --idle-timeout <SECONDS>
```

### Supported CLI Flags
| Flag | Description | Default |
| :--- | :--- | :--- |
| `-p`, `--port <PORT>` | Bind the local proxy to a specific port instead of a random free port. | `0` (Auto-select) |
| `--interface <IF>` | Force a specific physical BSD interface (e.g., `en1`). | Auto-detected WAN |
| `--no-check` | Skip the pre-flight external IP check for ultra-fast (<30ms) startup. | `false` |
| `--listen [PORT]` | Run proxy in standalone foreground mode without a child command. | Disabled |
| `--idle-timeout <SEC>` | Automatically shut down `--listen` mode after `<SEC>` seconds of inactivity. | `60` |
| `--verbose` / `-v` | Log DNS resolutions, `IP_BOUND_IF` bindings, and PF table updates to `stderr`. | Quiet |
| `--doctor` | Run full self-diagnostic (DHCP check, `IFSCOPE` route, PF tables, DNS, IP comparison). | - |

---

## Automatically Injected Environment Variables

When `irdirect <COMMAND>` executes a child process, it automatically injects the following environment variables into the child process scope:

| Variable | Format | Purpose |
| :--- | :--- | :--- |
| `HTTP_PROXY` / `http_proxy` | `http://127.0.0.1:<PORT>` | Standard HTTP proxy (`curl`, `requests`, `axios`, `wget`) |
| `HTTPS_PROXY` / `https_proxy` | `http://127.0.0.1:<PORT>` | Standard HTTPS `CONNECT` tunnel |
| `ALL_PROXY` / `all_proxy` | `socks5h://127.0.0.1:<PORT>` | SOCKS5 with remote DNS resolution |
| `IRDIRECT_PROXY_URL` | `http://127.0.0.1:<PORT>` | Explicit variable for Playwright / Puppeteer / Selenium configs |
| `IRDIRECT_SOCKS_URL` | `socks5h://127.0.0.1:<PORT>` | Explicit SOCKS5h URL |
| `IRDIRECT_PORT` | `<PORT>` | Numeric local port of the active ephemeral proxy |
| `IRDIRECT_INTERFACE` | `en1` | Active physical interface name used for socket binding |
| `NO_PROXY` / `no_proxy` | `localhost,127.0.0.1,192.168.99.0/24` | Ensures local loopback and offline NAS (`en0`) bypass the proxy |

---

## Integration Examples & Recipes

### 1. Standard CLI Commands (`curl`, `git`, `wget`)
```bash
# Fetch an Iranian banking or government endpoint directly
irdirect curl -4 -s [https://my.gov.ir](https://my.gov.ir)

# Check your current direct Iranian ISP IP vs VPN IP
curl -4 -s [https://api.ipify.org](https://api.ipify.org)          # Returns Foreign VPN IP
irdirect curl -4 -s [https://api.ipify.org](https://api.ipify.org) # Returns Iranian MCI IP
```

### 2. Python Scripts (`requests`, `httpx`, `aiohttp`)
Standard Python HTTP libraries automatically honor `HTTP_PROXY` and `HTTPS_PROXY`:
```bash
irdirect python3 /path/to/my_iranian_scraper.py
```
If using `aiohttp` (which requires `trust_env=True` to read environment proxies):
```python
import aiohttp
import asyncio

async def main():
    # Always pass trust_env=True when running inside irdirect
    async with aiohttp.ClientSession(trust_env=True) as session:
        async with session.get("[https://bmi.ir](https://bmi.ir)") as resp:
            print(resp.status)

asyncio.run(main())
```

### 3. Headless Browser Automation (Playwright / Puppeteer / Selenium)
Headless browsers often ignore shell proxy variables unless explicitly passed in the launch configuration. Read `os.environ.get("IRDIRECT_PROXY_URL")` inside your script and run the script with `irdirect`:

```python
# script: gov_portal_automation.py
import os
from playwright.sync_api import sync_playwright

proxy_url = os.environ.get("IRDIRECT_PROXY_URL")
if not proxy_url:
    raise RuntimeError("This script must be executed via: irdirect python3 gov_portal_automation.py")

with sync_playwright() as p:
    browser = p.chromium.launch(
        headless=True,
        proxy={"server": proxy_url}
    )
    page = browser.new_page()
    page.goto("[https://my.gov.ir](https://my.gov.ir)", timeout=30000)
    print(page.title())
    browser.close()
```
Execute with:
```bash
irdirect python3 gov_portal_automation.py
```

### 4. Cronjobs (`crontab -e` or `launchd`)
Always use absolute paths in cronjobs:
```cron
# Run domestic financial sync every day at 08:30 AM Tehran time using Iranian IP
30 8 * * * /usr/local/bin/irdirect /opt/homebrew/bin/python3 /Users/nima/scripts/tsetmc_sync.py >> /tmp/tsetmc_cron.log 2>&1
```

### 5. Launch Direct Google Chrome Window (`irdirect-chrome`)
Open a dedicated, fully isolated GUI Google Chrome window that routes directly through the Iranian ISP link:
```bash
# Launch Chrome with default URL (torob.com)
irdirect-chrome

# Launch Chrome with specific domestic URL
irdirect-chrome https://divar.ir
irdirect-chrome https://bmi.ir
```
Under the hood, this uses an isolated profile (`~/Library/Application Support/Google/Chrome-irdirect`) to ensure existing open Chrome windows do not hijack or bypass the proxy tunnel.

---

## Exit Codes & Troubleshooting for AI Agents

| Exit Code | Meaning | Required Agent Action |
| :--- | :--- | :--- |
| `0` | Target command succeeded via Iranian IP. | Proceed normally. |
| `99` | **Reverse Kill-Switch Triggered:** Physical link down, `IFSCOPE` route failed, or egress leaked to VPN IP. | **STOP immediately.** Do NOT retry without `irdirect`. Run `irdirect --doctor` to inspect physical network status. |
| `98` | **Privilege / Helper Error:** `/usr/local/libexec/irdirect-helper` failed or `sudoers` misconfigured. | Check `sudo -n /usr/local/libexec/irdirect-helper` permissions (`root:wheel`, `/etc/sudoers.d/irdirect`). |
| `97` | **Direct DNS Resolution Failure:** Neither Nokia Modem (`192.168.1.1`) nor MCI fallback DNS responded on `en1`. | Run `irdirect --doctor` to check `amn/310.blockDNS` `<dnsaddr>` table and modem connectivity. |
| `*` (Other) | Exact exit code returned by the wrapped `<COMMAND>`. | Debug the child application/script itself. |