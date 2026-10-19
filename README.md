# irdirect 🇮🇷⚡

> **macOS Kernel-Scoped VPN Bypass & Direct Iranian ISP Proxy**  
> *دور زدن هوشمند و بدون اختلال VPN در مک برای اتصال مستقیم به اینترنت ایران*

[![Platform](https://img.shields.io/badge/Platform-macOS%20(Apple%20Silicon%20%2F%20Intel)-black?logo=apple)](https://apple.com)
[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](LICENSE)
[![Zero VPN Disruption](https://img.shields.io/badge/VPN-Zero%20Disruption-brightgreen)](#)

---

## English

### What is `irdirect`?
`irdirect` is an ephemeral macOS network routing wrapper and in-memory multiplexed proxy (`HTTP/HTTPS CONNECT` + `SOCKS5h`). It allows specific CLI commands, scripts, cronjobs, and browser sessions to route directly through the physical ISP interface (`en1` — e.g. Nokia 4G/5G SIM Modem on Hamrah-e Aval / MCI) via Darwin kernel socket binding (`IP_BOUND_IF = 25`).

**Zero VPN Disruption:** System-wide VPN tunnels (AmneziaVPN, WireGuard, Sing-box/Hiddify, ProtonVPN) and security extensions (Little Snitch, AdGuard) remain fully active and undisturbed for the rest of your operating system.

### Key Features
- **Hard Reverse Kill-Switch (Exit 99):** If the physical link is down or if traffic leaks toward the foreign VPN, `irdirect` immediately halts execution.
- **Multiplexed Ephemeral Proxy:** Allocates an independent random local port per invocation with automatic protocol detection (HTTP CONNECT & SOCKS5h). Concurrency-safe for parallel jobs.
- **Direct Chrome Runner (`irdirect-chrome`):** Launch an isolated Google Chrome GUI window bound to the direct Iranian link without profile conflicts.
- **Resilient DNS Engine:** Direct physical wire queries with automatic fallback to system resolver and PF table whitelisting.

### Quick Start & Installation

```bash
# Clone the repository
git clone https://github.com/nimabhk/irdirect.git
cd irdirect

# Install system-wide:
sudo ./install.sh

# Run self-diagnostic:
irdirect --doctor

# Run verification suite:
/usr/local/share/irdirect/verify_suite.sh
```

### Usage Examples

```bash
# 1. Wrap standard CLI commands (curl, git, wget)
irdirect curl -4 -s -I https://torob.com
irdirect curl -4 -s -I https://divar.ir
irdirect curl -k -4 -s -I https://bmi.ir

# 2. Launch Direct Iranian Google Chrome window (GUI)
irdirect-chrome https://torob.com
irdirect-chrome https://divar.ir

# 3. Python scripts (requests, httpx, aiohttp automatically pick up proxies)
irdirect python3 scraper.py

# 4. Standalone proxy listener mode (for external tools / Playwright)
irdirect -p 59999 --listen --idle-timeout 120
```

---

## فارسی (Persian)

### ابزار `irdirect` چیست؟
ابزار `irdirect` یک ابزار مسیریابی سطح کرنل و پروکسی چندمنظوره در حافظه برای سیستم‌عامل macOS است. با استفاده از این ابزار می‌توانید دستورات ترمینال، اسکریپت‌های پایتون، کران‌جاب‌ها و مرورگر گوگل کروم را مستقیماً از طریق لینک فیزیکی مودم سیم‌کارتی همراه اول (`en1`) به اینترنت داخلی ایران متصل کنید، **بدون آن‌که نیازی به خاموش کردن یا قطع وی‌پی‌ان (AmneziaVPN، Hiddify، WireGuard) یا فایروال سیستم باشد**.

### ویژگی‌های کلیدی
- **کیل‌سوئیچ معکوس سختگیرانه (Exit Code 99):** جلوگیری قطعی از هرگونه نشت ترافیک به سمت آی‌پی خارجی وی‌پی‌ان.
- **بدون تداخل با VPN کل سیستم:** وی‌پی‌ان و فایروال‌های سیستم برای سایر برنامه‌ها دست‌نخورده باقی می‌مانند.
- **اجرای مستقیم کروم (`irdirect-chrome`):** باز کردن یک پنجره کاملاً مستقل از گوگل کروم با آی‌پی ایران و بدون تداخل با پنجره‌های فعال قبلی.
- **پروکسی چندمنظوره گذرا:** اختصاص پورت رندوم برای هر اجرا، با پشتیبانی هم‌زمان از HTTP CONNECT و SOCKS5h بدون اشغال دائمی پورت.
- **موتور DNS ایزوله و مقاوم:** ارسال مستقیم درخواست‌های DNS با قابلیت پشتیبان خودکار.

### نصب و راه‌اندازی

```bash
# کلون کردن پروژه:
git clone https://github.com/nimabhk/irdirect.git
cd irdirect

# نصب سراسری در سیستم:
sudo ./install.sh

# اجرای تست تشخیصی سیستم:
irdirect --doctor

# اجرای آزمون جامع عملکرد:
/usr/local/share/irdirect/verify_suite.sh
```

### نمونه‌های کاربرد

```bash
# اجرای دستورات شبکه با آی‌پی بومی ایران:
irdirect curl -4 -s -I https://torob.com
irdirect curl -4 -s -I https://divar.ir
irdirect curl -k -4 -s -I https://bmi.ir

# باز کردن مرورگر کروم مستقیم با سایت دلخواه:
irdirect-chrome https://torob.com
irdirect-chrome https://divar.ir

# اجرای اسکریپت‌های پایتون:
irdirect python3 domestic_script.py

# حالت شنونده مستقل برای اتصال ابزارهای اتوماسیون (Playwright / Puppeteer):
irdirect -p 59999 --listen --idle-timeout 120
```

---

## License / لایسنس

This project is licensed under the **Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**.  
Free for personal, academic, and non-commercial use. Commercial usage requires prior written permission.

استفاده از این پروژه برای کلیه **مصارف شخصی، آموزشی و غیرتجاری** به صورت کاملاً آزاد و رایگان است.
