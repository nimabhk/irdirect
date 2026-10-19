# `irdirect` — macOS Kernel-Scoped VPN Bypass & Iranian Direct ISP Proxy

## 1. Overview & Architectural Philosophy
`irdirect` is an ephemeral, on-demand CLI wrapper and in-memory multiplexed proxy (`HTTP/HTTPS CONNECT` + `SOCKS5h`) engineered for macOS (Darwin 26.x / Apple Silicon). It allows specific commands, scripts, cronjobs, and browser automation agents to route TCP and DNS traffic directly through the physical ISP interface (`en1` - Nokia SIM Modem on MCI/Hamrah-e Aval) while system-wide VPNs (AmneziaVPN, ProtonVPN, WireGuard, Sing-box/Hiddify) and security extensions (Little Snitch, AdGuard) remain fully active and uninterrupted.

---

## 2. Core Operational Rules (For Humans & AI Agents)
1. **Zero VPN Disruption:** NEVER disconnect or toggle AmneziaVPN, Little Snitch, or AdGuard to access Iranian domestic websites (`.ir`, government portals, banks, domestic APIs). Always wrap the command with `irdirect`.
2. **Ephemeral Lifecycle:** `irdirect` does NOT run as a permanent background service. It starts an in-memory proxy bound to the physical interface (`IP_BOUND_IF = 25`) only for the duration of the command and tears everything down (including temporary firewall whitelist rules) as soon as the command finishes.
3. **Concurrency Safe:** Each invocation of `irdirect` allocates an independent ephemeral local port (`127.0.0.1:<random_port>`). Multiple cronjobs and agents can invoke `irdirect` simultaneously without port collisions.
4. **Hard Reverse Kill-Switch:** If the physical internet link (`en1`) is disconnected or fails verification, `irdirect` will **immediately abort with Exit Code `99`**. It will NEVER leak traffic over the foreign VPN IP.

---

## 3. Command-Line Syntax & Flags

```bash
# Mode 1: Command Wrapper (Recommended for scripts, curl, git, python, node, cronjobs)
irdirect [OPTIONS] -- <COMMAND> [ARGS...]
irdirect <COMMAND> [ARGS...]

# Mode 2: Standalone Timed Listener (For external apps or multi-step agent workflows)
irdirect --listen [PORT] --idle-timeout <SECONDS>

# Mode 3: Self-Diagnostic
irdirect --doctor
```

### Supported CLI Flags
| Flag | Description | Default |
| :--- | :--- | :--- |
| `-p`, `--port <PORT>` | Bind the local proxy to a specific port instead of a random free port. | `0` (Auto-select) |
| `--interface <IF>` | Force a specific physical BSD interface (e.g., `en1`). | Auto-detected WAN |
| `--no-check` | Skip the pre-flight external IP check for ultra-fast (<30ms) startup. | `false` |
| `--listen [PORT]` | Run proxy in standalone foreground mode without a child command. | Disabled |
| `--idle-timeout <SEC>` | Automatically shut down `--listen` mode after `<SEC>` seconds of inactivity. | `60` |
| `-v`, `--verbose` | Log DNS resolutions, `IP_BOUND_IF` bindings, and PF table updates to `stderr`. | Quiet |
| `--doctor` | Run full self-diagnostic (DHCP check, `IFSCOPE` route, PF tables, DNS, IP comparison). | - |

---

## 4. Automatically Injected Environment Variables

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

## 5. Integration Recipes

### 1. Standard CLI Commands (`curl`, `git`, `wget`)
```bash
# Check current Iranian direct ISP IP vs VPN IP
curl -4 -s https://api.ipify.org          # Foreign VPN IP
irdirect curl -4 -s https://api.ipify.org # Direct Iranian MCI IP

# Access an Iranian domestic endpoint
irdirect curl -4 -s -I https://bmi.ir
```

### 2. Python Scripts (`requests`, `httpx`, `aiohttp`)
```bash
irdirect python3 my_script.py
```
Inside Python with `aiohttp`:
```python
import aiohttp
import asyncio

async def main():
    async with aiohttp.ClientSession(trust_env=True) as session:
        async with session.get("https://bmi.ir") as resp:
            print("Status:", resp.status)

asyncio.run(main())
```

### 3. Headless Browser Automation (Playwright / Puppeteer)
```python
import os
from playwright.sync_api import sync_playwright

proxy_url = os.environ.get("IRDIRECT_PROXY_URL")
with sync_playwright() as p:
    browser = p.chromium.launch(
        headless=True,
        proxy={"server": proxy_url} if proxy_url else None
    )
    page = browser.new_page()
    page.goto("https://my.gov.ir")
    print("Page Title:", page.title())
    browser.close()
```

### 4. Cronjobs (`crontab -e` or `launchd`)
```cron
30 8 * * * /usr/local/bin/irdirect /usr/bin/python3 /Users/nima/scripts/tsetmc_sync.py >> /tmp/tsetmc_cron.log 2>&1
```

---

## 6. Exit Codes

| Exit Code | Meaning | Required Agent Action |
| :--- | :--- | :--- |
| `0` | Success | Normal operation |
| `99` | **Reverse Kill-Switch Triggered** | Physical link down, route failed, or leaked to VPN. STOP immediately. |
| `98` | **Privilege / Helper Error** | Sudoers misconfigured or helper missing. |
| `97` | **Direct DNS Resolution Failure** | Upstream DNS servers failed on physical link. |
| `*` | Child command exit code | Application-level error. |
