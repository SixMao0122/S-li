<div align="center">

# S-li (Six Life Injoy)

**專為 Windows 與跨平台打造的現代化美學終端提示符 (Shell Line Interface)**

*讓每一天的終端機，都兼具極致美感、即時狀態感知與個性化表情體驗。*

[English](README.en.md) | [繁體中文](README.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Security: Gitleaks](https://img.shields.io/badge/Security-Gitleaks%20Audited-brightgreen.svg)](SECURITY.md)
[![Shell: PowerShell | CMD | GitBash | WSL](https://img.shields.io/badge/Shell-PowerShell%20%7C%20CMD%20%7C%20Git%20Bash%20%7C%20WSL-purple.svg)](#四大終端支援與安裝指南)
[![Style: Powerline](https://img.shields.io/badge/Style-Powerline%20Pills-ff69b4.svg)](#自訂主題與外觀切換-sli-cli)
[![Themes: 7 Built-in](https://img.shields.io/badge/Themes-7%20Themes%20Included-orange.svg)](#多主題展示-themes-gallery)

---

### 終端效果展示 (Terminal Preview)

#### 截圖實測 (Real Terminal Screenshot)
![S-li Terminal Preview](docs/images/preview.png)

#### <a id="多主題展示-themes-gallery"></a>六大精選主題預覽 (Multi-Themes Showcase)
![S-li Themes Showcase](docs/images/themes-showcase.svg)

</div>

---

### 核心架構解析 (Segment Breakdown)

`S-li` **不需要**您額外下指令查詢狀態，而是**直接原生覆蓋**您現有的各類 CLI 提示符（Prompt / PS1）。每一次按 Enter、切換目錄或變更分支，都會即時動態呈現：

```text
[ 🟣 使用者身份 ]  [ 🔴 工作目錄 / Python venv ]  [ 🟠 Git 分支與變更 ]  [ 🔵 自訂表情與時間 ]  |
```

1. **使用者識別 (Identity)**：預設顯示當前 Windows / Linux 帳號（如 `SxiMao`），支援 `sli user <name>` 自訂代號，並提供一鍵 `sli privacy on` 隱私遮蔽。
2. **目錄與 Python 虛擬環境 (Path & Python Venv)**：
   - 自動即時偵測 `.venv`、`venv`、`conda`、`poetry`、`pipenv`、`uv` 等虛擬環境，以 `🐍 (環境名)` 優雅標示。
   - 智慧簡化家目錄長路徑為 `~`，保留清晰工作目錄名稱。
3. **Git 即時狀態 (Git Pulse)**：
   - 即時顯示當前分支 `→ (master)`。
   - 若程式碼有未提交的變更，自動加上醒目標記 `* → (master)` 並切換為警示色段落。
4. **個性表情與時間 (Time & Custom Icons)**：
   - 支援自由切換數十種表情（愛心 `♡`、火焰 `🔥`、火箭 `🚀`、櫻花 `🌸`、閃電 `⚡`、貓貓 `🐱`、咖啡 `☕` 等）。

---

## 前置準備與字型配置 (Font Setup)

為了讓 Powerline 膠囊箭頭（`` / ``）、愛心（`♡`）與分支符號（`→`）完美渲染而不破圖，需要搭配支援符號的字型：

### 方案 A：一鍵指令自動下載安裝（最推薦）
本專案已內建自動安裝精靈，只需在 PowerShell 執行：
```powershell
sli font install
```
腳本將自動自官方 GitHub 下載開源免費商用之 **JetBrainsMono Nerd Font** 並直接註冊至 Windows 系統字型庫！

### 方案 B：手動下載官方字型
您也可以至官方站點下載安裝喜歡的 Nerd Font：
- **[JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)** (極力推薦)
- **[Cascadia Code NF](https://github.com/microsoft/cascadia-code/releases)**

**Windows Terminal 字型設定步驟**：
1. 開啟 Windows Terminal ➜ 點選下拉選單進入 **「設定」 (Ctrl + ,)**。
2. 點選左側「預設值」➜「外觀」➜ 將 **字型** 改為 `JetBrainsMono Nerd Font` 或 `Cascadia Code NF`。

> [!TIP]
> 如果您暫時不想安裝任何字型，也可以執行 `sli style ascii` 切換至「免字型純文字相容模式」，保證 100% 不破圖！

---

## 四大終端支援與安裝指南

克隆本專案至您的本地目錄：

```powershell
git clone https://github.com/SixMao0122/S-li.git
cd S-li
```

### 1. PowerShell (7+ 及 Windows PowerShell 5.1)
執行專案隨附的一鍵安裝腳本：
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```
*或是手動安裝*：在您的 `$PROFILE` 檔案中加入以下一行即可：
```powershell
. "C:\路徑\到\S-li\core\powershell\sli-prompt.ps1"
```

---

### 2. Git Bash (Windows MSYS2 / MinGW)
在 `~/.bashrc` 中加入引用：
```bash
echo '[ -f "/c/路徑/到/S-li/core/bash/sli-prompt.sh" ] && source "/c/路徑/到/S-li/core/bash/sli-prompt.sh"' >> ~/.bashrc
source ~/.bashrc
```

---

### 3. Linux WSL (Ubuntu / Debian / Arch)
在 WSL 終端執行：
```bash
./install.sh
source ~/.bashrc
```

---

### 4. Windows CMD (命令提示字元)
搭配 Windows 終端必備神器 **Clink** 即可獲得 100% 相同美感：
1. 安裝 Clink：
   ```powershell
   winget install chrisant996.Clink
   ```
2. 將本專案中的 `core\clink\sli.lua` 複製到 `%LocalAppData%\clink\` 目錄：
   ```powershell
   copy .\core\clink\sli.lua "$env:LOCALAPPDATA\clink\"
   ```
3. 開啟 CMD，即可享受與 PowerShell 毫無二致的色彩與即時 Git 狀態！

---

## <a id="自訂主題與外觀切換-sli-cli"></a>自訂主題、表情與個人化 (sli CLI)

日常敲指令由**原生覆蓋的提示符**全自動運作；而 `sli` 指令工具專職負責外觀風格與個人化調整。

```powershell
sli <指令> [選項]
```

### 1. 主題切換 (Themes)
內建 7 款高對比與低飽和度漸層主題：
- `sli theme`：列出所有主題與當前主題
- `sli theme sunset`：經典落日粉紫暖橙漸層（預設，對齊截圖）
- `sli theme cyberpunk`：賽博朋克霓虹風 (Cyberpunk 2077)
- `sli theme tokyo-night`：東京之夜 (Tokyo Night)
- `sli theme sakura`：浪漫櫻花粉嫩風 (Sakura Bloom)
- `sli theme dracula`：經典吸血鬼紫黑風 (Dracula)
- `sli theme nord`：北歐極地冰霜冷調 (Nord Frost)
- `sli theme matrix`：極客駭客螢光綠 (Matrix Hacker)

### 2. 表情符號與圖示自訂 (Icons & Emojis)
- `sli icon`：檢視當前圖示與推薦清單
- **時間段表情切換**：
  ```powershell
  sli icon fire     # 🔥
  sli icon rocket   # 🚀
  sli icon star     # ✨
  sli icon coffee   # ☕
  sli icon cat      # 🐱
  sli icon sakura   # 🌸
  sli icon skull    # 💀
  sli icon heart    # ♡ (預設)
  sli icon 🦄       # 傳入任意您喜愛的 Emoji！
  ```
- **自訂 Python 虛擬環境圖示**：
  ```powershell
  sli icon py ⚡    # 切換為閃電
  sli icon py 🐍    # 切換為 Python 蛇標 (預設)
  sli icon py λ     # 切換為 Lambda 符號
  ```
- **自訂 Git 分支圖示**：
  ```powershell
  sli icon git →    # 簡約箭頭 (預設)
  sli icon git     # Nerd Font 分支符號
  ```

### 3. 膠囊分隔風格 (Separator Styles)
- `sli style`：檢視所有可用風格與當前設定
- **多樣化分隔樣式庫**：
  - `sli style nerd_arrow`：Powerline 經典尖角箭頭 (``，預設)
  - `sli style nerd_rounded`：圓角膠囊風格 (``，或簡寫 `sli style round`)
  - `sli style slanted`：上斜切幾何風 (``)
  - `sli style slant_down`：下斜切導流風 (``)
  - `sli style flame`：動感火焰波浪 (``，或簡寫 `sli style fire`)
  - `sli style pixel`：8-bit 像素積木 (``，或簡寫 `sli style block`)
  - `sli style wave`：海浪波紋造型 (``)
  - `sli style flat`：極簡純色平鋪，無任何箭頭符號 (` `，或簡寫 `sli style none`)
  - `sli style ascii`：純文字免字型相容模式 (`>`)

### 4. 隱私模式 (Privacy Mode)
在進行實況錄影、線上會議分享螢幕或截圖時，一鍵隱藏使用者名稱與絕對路徑：
- `sli privacy on`：開啟隱私遮蔽
- `sli privacy off`：恢復正常顯示

---

## Star 成長趨勢 (Stargazers over time)

<div align="center">

[![Star History Chart](https://api.star-history.com/svg?repos=SixMao0122/S-li&type=Date)](https://star-history.com/#SixMao0122/S-li&Date)

*若 S-li 讓您的終端機煥然一新，歡迎右上角點個 ⭐️ Star 給予支持！*

</div>

---

## 常見問題 (FAQ)

<details>
<summary><b>Q1: 為什麼終端機出現問號或方塊亂碼？</b></summary>
這代表終端機尚未使用支援 Powerline 的字型。請執行 <code>sli font install</code> 一鍵安裝 JetBrainsMono Nerd Font，或執行 <code>sli style ascii</code> 切換成免特殊符號的相容模式。
</details>

<details>
<summary><b>Q2: 啟動 Python 虛擬環境時如何確認有被偵測到？</b></summary>
當您在終端機啟動虛擬環境（如 <code>.venv\Scripts\Activate.ps1</code> 或 <code>conda activate env_name</code>）時，S-li 會自動感知 <code>$env:VIRTUAL_ENV</code> 並顯示。您也可以輸入 <code>sli preview</code> 檢視識別狀態。
</details>

<details>
<summary><b>Q3: 如何徹底解除安裝並還原？</b></summary>
只需開啟您的 <code>$PROFILE</code>（PowerShell）或 <code>~/.bashrc</code>（Git Bash/WSL），將包含 <code>sli-prompt</code> 的那一列刪除並儲存即可，完全不留垃圾。
</details>

---

## 安全與開源政策

本專案採透明純腳本架構，無預編譯二進位執行檔，並經 Gitleaks 安全審計。詳情請參閱 [`SECURITY.md`](SECURITY.md)。

## 授權條款 (License)

本專案採用 [MIT License](LICENSE) 條款開放原始碼。
