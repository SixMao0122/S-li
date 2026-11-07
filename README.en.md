<div align="center">

# S-li (Six Life Injoy)

**Modern, aesthetic terminal prompt (Shell Line Interface) crafted for Windows and cross-platform workflows.**

*Empower your daily command line with elegant aesthetics, real-time context awareness, and personalized expressions.*

[English](README.en.md) | [繁體中文](README.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Security: Gitleaks](https://img.shields.io/badge/Security-Gitleaks%20Audited-brightgreen.svg)](SECURITY.md)
[![Shell: PowerShell | CMD | GitBash | WSL](https://img.shields.io/badge/Shell-PowerShell%20%7C%20CMD%20%7C%20Git%20Bash%20%7C%20WSL-purple.svg)](#cross-platform-terminal-support-and-installation)
[![Style: Powerline](https://img.shields.io/badge/Style-Powerline%20Pills-ff69b4.svg)](#theme-and-style-customization-sli-cli)
[![Themes: 7 Built-in](https://img.shields.io/badge/Themes-7%20Themes%20Included-orange.svg)](#multi-theme-gallery)

---

### Terminal Preview

#### Real Terminal Screenshot
![S-li Terminal Preview](docs/images/preview.png)

#### <a id="multi-theme-gallery"></a>Multi-Theme Showcase
![S-li Themes Showcase](docs/images/themes-showcase.svg)

</div>

---

### Core Architecture Breakdown

`S-li` does **not** require manual commands to inspect environment status. It natively hooks into your shell prompt (`Prompt` / `$PS1`). Every time you press Enter, change directories, or switch Git branches, the status updates dynamically:

```text
[ 🟣 User Identity ]  [ 🔴 Working Directory / Python venv ]  [ 🟠 Git Branch & Status ]  [ 🔵 Custom Icon & Time ]  |
```

1. **User Identity**: Defaults to your current Windows/Linux account username (e.g. `SxiMao`). Supports custom handles via `sli user <name>` and privacy masking via `sli privacy on`.
2. **Directory & Python Virtual Environment**:
   - Automatically detects active virtual environments (`.venv`, `venv`, `conda`, `poetry`, `pipenv`, `uv`) and displays them as `🐍 (venv_name)`.
   - Intelligently collapses user home directories into `~`, preserving clean directory names.
3. **Real-time Git Pulse**:
   - Instantly indicates current branch: `→ (master)`.
   - Highlights uncommitted changes: `* → (master)` with an alert status color.
4. **Custom Expressions & Clock**:
   - Freely switch between custom symbols and emojis (heart `♡`, fire `🔥`, rocket `🚀`, sakura `🌸`, lightning `⚡`, cat `🐱`, coffee `☕`, etc.).

---

## Font Configuration & Setup

To render Powerline capsule arrows (`` / ``), heart glyphs (`♡`), and branch symbols (`→`) without font-fallback glitches, a Nerd Font is recommended:

### Option A: One-Click Automated Font Installer (Recommended)
S-li includes a built-in automated installer. Run in PowerShell:
```powershell
sli font install
```
This script downloads the official, open-source **JetBrainsMono Nerd Font** directly from GitHub and registers it to your Windows font registry.

### Option B: Manual Installation
You may download any compatible Nerd Font manually:
- **[JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)** (Highly Recommended)
- **[Cascadia Code NF](https://github.com/microsoft/cascadia-code/releases)**

**Windows Terminal Font Setup**:
1. Open Windows Terminal ➜ Open **Settings (Ctrl + ,)**.
2. Navigate to **Defaults** ➜ **Appearance** ➜ Set **Font face** to `JetBrainsMono Nerd Font` or `Cascadia Code NF`.

> [!TIP]
> If you prefer not to install custom fonts, switch to ASCII mode via `sli style ascii` for 100% universal compatibility!

---

## Cross-Platform Terminal Support and Installation

Clone this repository to your local machine:

```powershell
git clone https://github.com/SixMao0122/S-li.git
cd S-li
```

### 1. PowerShell (7+ and Windows PowerShell 5.1)
Run the automated installation script:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```
*Manual Installation*: Add the following line to your `$PROFILE`:
```powershell
. "C:\Path\To\S-li\core\powershell\sli-prompt.ps1"
```

---

### 2. Git Bash (Windows MSYS2 / MinGW)
Add the prompt loader to your `~/.bashrc`:
```bash
echo '[ -f "/c/Path/To/S-li/core/bash/sli-prompt.sh" ] && source "/c/Path/To/S-li/core/bash/sli-prompt.sh"' >> ~/.bashrc
source ~/.bashrc
```

---

### 3. Linux WSL (Ubuntu / Debian / Arch)
Execute the installer inside your WSL terminal:
```bash
./install.sh
source ~/.bashrc
```

---

### 4. Windows CMD (Command Prompt)
Pair with **Clink** for identical Powerline visuals in CMD:
1. Install Clink:
   ```powershell
   winget install chrisant996.Clink
   ```
2. Copy `core\clink\sli.lua` into `%LocalAppData%\clink\`:
   ```powershell
   copy .\core\clink\sli.lua "$env:LOCALAPPDATA\clink\"
   ```
3. Open CMD to enjoy RGB colors and live Git tracking.

---

## Theme and Style Customization (sli CLI)

The prompt runs automatically in your shell; the `sli` CLI utility manages styling and personalization.

```powershell
sli <command> [options]
```

### 1. Themes
Includes 7 curated high-contrast and subtle gradient themes:
- `sli theme`: List all themes and show active theme
- `sli theme sunset`: Classic sunset gradient with warm pink & orange (Default)
- `sli theme cyberpunk`: Neon aesthetics (Cyberpunk 2077 inspired)
- `sli theme tokyo-night`: Deep blue nightscape (Tokyo Night)
- `sli theme sakura`: Delicate pastel cherry blossom (Sakura Bloom)
- `sli theme dracula`: Gothic purple & dark contrast (Dracula)
- `sli theme nord`: Arctic glacial chill palette (Nord Frost)
- `sli theme matrix`: Terminal hacker neon green (Matrix)

### 2. Icons & Emojis
- `sli icon`: View current icon settings and presets
- **Time segment expression**:
  ```powershell
  sli icon fire     # 🔥
  sli icon rocket   # 🚀
  sli icon star     # ✨
  sli icon coffee   # ☕
  sli icon cat      # 🐱
  sli icon sakura   # 🌸
  sli icon skull    # 💀
  sli icon heart    # ♡ (Default)
  sli icon 🦄       # Any custom Unicode emoji!
  ```
- **Custom Python Virtual Environment Icon**:
  ```powershell
  sli icon py ⚡    # Lightning bolt
  sli icon py 🐍    # Python snake (Default)
  sli icon py λ     # Lambda symbol
  ```
- **Custom Git Branch Icon**:
  ```powershell
  sli icon git →    # Clean arrow (Default)
  sli icon git     # Nerd Font branch glyph
  ```

### 3. Capsule Separator Styles
- `sli style`: Inspect all available separator styles and current active selection
- **Available Separator Presets**:
  - `sli style nerd_arrow`: Classic Powerline right arrow (``, Default)
  - `sli style nerd_rounded`: Rounded pill capsule (``, or shorthand `sli style round`)
  - `sli style slanted`: Right slanted triangle (``)
  - `sli style slant_down`: Downward slanted diagonal (``)
  - `sli style flame`: Dynamic flame wave (``, or shorthand `sli style fire`)
  - `sli style pixel`: 8-bit retro pixel blocks (``, or shorthand `sli style block`)
  - `sli style wave`: Elegant wave ripple (``)
  - `sli style flat`: Minimalist flat colorblocks with no arrows (` `, or shorthand `sli style none`)
  - `sli style ascii`: Universal plain-text ASCII mode (`>`)

### 4. Privacy Mode
Mask usernames and sensitive directory paths during screen sharing, live streaming, or presentations:
- `sli privacy on`: Enable privacy masking
- `sli privacy off`: Restore standard display

---

## Stargazers Over Time

<div align="center">

[![Star History Chart](https://api.star-history.com/svg?repos=SixMao0122/S-li&type=Date)](https://star-history.com/#SixMao0122/S-li&Date)

*If S-li elevates your terminal experience, please consider giving it a ⭐️ Star!*

</div>

---

## Frequently Asked Questions (FAQ)

<details>
<summary><b>Q1: Why do question marks or missing symbol blocks appear?</b></summary>
Your terminal font does not have Powerline glyphs. Run <code>sli font install</code> to automatically install JetBrainsMono Nerd Font, or run <code>sli style ascii</code> to switch to ASCII-compatible mode.
</details>

<details>
<summary><b>Q2: How do I know if my Python virtual environment is detected?</b></summary>
When you activate a virtual environment (e.g. <code>.venv\Scripts\Activate.ps1</code> or <code>conda activate env_name</code>), S-li detects <code>$env:VIRTUAL_ENV</code> or <code>$env:CONDA_DEFAULT_ENV</code> automatically. You can also run <code>sli preview</code> to check.
</details>

<details>
<summary><b>Q3: How do I completely uninstall S-li?</b></summary>
Simply open your <code>$PROFILE</code> (PowerShell) or <code>~/.bashrc</code> (Git Bash/WSL) and remove the line sourcing <code>sli-prompt</code>.
</details>

---

## Security & Transparency

S-li is architected with pure, readable shell scripts, contains no precompiled binaries, and undergoes automated secret auditing via Gitleaks. For details, see [`SECURITY.md`](SECURITY.md).

## License

This project is licensed under the [MIT License](LICENSE).
