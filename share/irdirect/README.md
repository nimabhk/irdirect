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

### 🤖 AI Agent Integration & Self-Installation

If you use AI coding assistants or autonomous agents (such as **ZCode**, **Claude Code**, **Cursor**, **Windsurf**, or **Aider**), you can instruct them to install and adopt this skill.

#### Method A: Prompt to Feed into Any AI Agent
Copy and paste this prompt to your agent:

```markdown
# Iranian Domestic Network Routing Skill (irdirect)

This system runs an active foreign VPN (e.g. AmneziaVPN) while also connected to an Iranian physical ISP link (en1 via Nokia 4G/5G modem).

When interacting with any Iranian domestic internet service, banking portal, .ir domain, or domestic API (e.g. Torob, Divar, MCI, BMI):
1. NEVER suggest or attempt to disconnect or toggle the system VPN.
2. ALWAYS route traffic through the `irdirect` tool installed at `/usr/local/bin/irdirect`.
   - Command wrapper: `irdirect <COMMAND> [ARGS...]` (e.g., `irdirect curl -4 -s -I https://torob.com`)
   - Direct Google Chrome GUI runner: `irdirect-chrome [URL]` (e.g., `irdirect-chrome https://divar.ir`)
   - Standalone proxy listener: `irdirect -p 59999 --listen --idle-timeout 120`
3. Read the complete skill reference file located at `/usr/local/share/irdirect/SKILL.md` (or `~/.zcode/skills/irdirect/SKILL.md`).
4. Install this skill into your agent workspace/skills directory if supported.
```

#### Method B: One-Liner Skill Installation for Agents
Agents with terminal access can automatically register the skill into their environment:

```bash
# For ZCode:
mkdir -p ~/.zcode/skills/irdirect
cp /usr/local/share/irdirect/SKILL.md ~/.zcode/skills/irdirect/SKILL.md

# For Claude Code / Cursor / Windsurf:
# Simply refer to /usr/local/share/irdirect/SKILL.md or append it to your project rules (.cursorrules / CLAUDE.md)
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

### 🤖 راهنمای یکپارچه‌سازی و نصب اسکیل برای ایجنت‌های هوش مصنوعی (AI Agents)

اگر از دستیارهای هوش مصنوعی برنامه‌نویسی یا ایجنت‌های خودکار (مانند **ZCode**, **Claude Code**, **Cursor**, **Windsurf**, **Aider**) استفاده می‌کنید، می‌توانید این مهارت را به آن‌ها معرفی کنید تا به صورت خودکار در مواجهه با سرویس‌های ایرانی از این ابزار استفاده کنند.

#### روش اول: پرامپت آماده جهت ارسال به هوش مصنوعی
کافی است متن زیر را کپی کرده و به چت ایجنت هوش مصنوعی خود بفرستید:

```markdown
# راهنمای اتصال به اینترنت داخلی ایران (مهارت irdirect)

روی این سیستم یک VPN خارجی فعال است و هم‌زمان اینترنت مودم سیم‌کارتی همراه اول روی کارت شبکه فیزیکی en1 متصل می‌باشد.

در هر زمان که قصد برقراری ارتباط با سایت‌ها، درگاه‌های بانکی، دامنه‌های .ir یا APIهای داخلی ایران (مانند ترب، دیوار، همراه اول، بانک ملی و غیره) را داری:
۱. به هیچ وجه درخواست یا تلاش برای خاموش کردن یا قطع کردن VPN سیستم نکن.
۲. همیشه دستورات را از طریق ابزار `irdirect` نصب‌شده در `/usr/local/bin/irdirect` اجرا کن:
   - اجرای دستورات ترمینال: `irdirect <COMMAND> [ARGS...]` (مثال: `irdirect curl -4 -s -I https://torob.com`)
   - باز کردن گوگل کروم مستقیم با محیط ایزوله: `irdirect-chrome [URL]` (مثال: `irdirect-chrome https://divar.ir`)
   - اجرای حالت شنونده پروکسی: `irdirect -p 59999 --listen --idle-timeout 120`
۳. اسکریپت‌های پایتون یا اتوماسیون Playwright را نیز از طریق `irdirect python3 script.py` اجرا کن (متغیرهای پروکسی به صورت خودکار تزریق می‌شوند).
۴. برای مطالعه جزئیات کامل و قوانین ایجنت، فایل مستندات را در `/usr/local/share/irdirect/SKILL.md` (یا `~/.zcode/skills/irdirect/SKILL.md`) بخوان و در صورت پشتیبانی، این اسکیل را در محیط خود ثبت کن.
```

#### روش دوم: دستور تک‌خطی نصب خودکار اسکیل توسط ایجنت
ایجنت‌هایی که دسترسی به ترمینال دارند می‌توانند اسکیل را مستقیماً در مسیر مهارت‌های خود ثبت کنند:

```bash
# برای ZCode:
mkdir -p ~/.zcode/skills/irdirect
cp /usr/local/share/irdirect/SKILL.md ~/.zcode/skills/irdirect/SKILL.md

# برای Cursor / Claude Code / Windsurf:
# کافیست مسیر /usr/local/share/irdirect/SKILL.md را به فایل قوانین ایجنت (.cursorrules یا CLAUDE.md) ضمیمه کنید.
```

---

## License / لایسنس

This project is licensed under the **Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**.  
Free for personal, academic, and non-commercial use. Commercial usage requires prior written permission.

استفاده از این پروژه برای کلیه **مصارف شخصی، آموزشی و غیرتجاری** به صورت کاملاً آزاد و رایگان است.
