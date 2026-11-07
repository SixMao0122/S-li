<#
.SYNOPSIS
    S-li (Six Life Injoy / Shell Line Interface) 樣式與配置管理工具
.DESCRIPTION
    管理 S-li 終端提示符的主題、圖示、表情符號、字型與隱私設定。
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Command = "help",

    [Parameter(Position = 1)]
    [string]$SubCommand = "",

    [Parameter(Position = 2)]
    [string]$Value = ""
)

$SliRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ConfigFile = Join-Path $SliRoot "core\config.json"
$ThemesDir = Join-Path $SliRoot "themes"

function Get-Config {
    if (Test-Path $ConfigFile) {
        return [System.IO.File]::ReadAllText($ConfigFile, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
    }
    return $null
}

function Save-Config {
    param($Config)
    $json = $Config | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllText($ConfigFile, $json, [System.Text.Encoding]::UTF8)
}

function Show-Help {
    $e = [char]27
    Write-Host ""
    Write-Host "$e[1;35mS-li (Six Life Injoy)$e[0m - 現代終端提示符樣式管理工具" -ForegroundColor Magenta
    Write-Host "平時直接原生覆蓋終端提示符，`sli` 指令專職負責外觀切換與自訂。" -ForegroundColor Gray
    Write-Host ""
    Write-Host "常用指令:" -ForegroundColor Cyan
    Write-Host "  sli theme                  - 檢視所有可用主題與當前主題"
    Write-Host "  sli theme <name>           - 切換主題 (sunset, cyberpunk, nord, tokyo-night, sakura, dracula, matrix)"
    Write-Host "  sli icon                   - 檢視當前表情符號與熱門清單"
    Write-Host "  sli icon <emoji|name>      - 自訂時間區段表情 (例如: 🔥, 🚀, ✨, ☕, 🐱, 🌸, skull, heart)"
    Write-Host "  sli icon py <symbol>       - 自訂 Python 虛擬環境符號 (例如: 🐍, ⚡, λ, [py])"
    Write-Host "  sli icon git <symbol>      - 自訂 Git 分支圖示 (例如: →, , ⌥)"
    Write-Host "  sli style                  - 檢視所有可用分隔符風格清單與當前樣式"
    Write-Host "  sli style <name>           - 切換提示符分隔樣式 (arrow, rounded, slanted, flame, pixel, wave, flat, ascii)"
    Write-Host "  sli font install           - 一鍵自動下載並安裝 JetBrainsMono Nerd Font"
    Write-Host "  sli user <name>            - 設定第一段自訂使用者識別名稱 (例如 SxiMao)"
    Write-Host "  sli privacy <on|off>       - 開啟或關閉隱私遮蔽模式"
    Write-Host "  sli preview                - 即時展示當前提示符樣式"
    Write-Host "  sli install                - 一鍵將 S-li 整合至當前終端設定檔"
    Write-Host ""
}

$cfg = Get-Config
if (-not $cfg) {
    Write-Error "無法載入 S-li 設定檔: $ConfigFile"
    exit 1
}

switch ($Command.ToLower()) {
    "theme" {
        if ([string]::IsNullOrWhiteSpace($SubCommand)) {
            Write-Host "`n當前主題: $($cfg.activeTheme)`n" -ForegroundColor Green
            Write-Host "可用主題庫:" -ForegroundColor Cyan
            Get-ChildItem -Path $ThemesDir -Filter *.json | ForEach-Object {
                $tName = $_.BaseName
                $isCurrent = ($tName -eq $cfg.activeTheme)
                $prefix = if ($isCurrent) { "* " } else { "  " }
                $fgColor = if ($isCurrent) { "Green" } else { "White" }
                Write-Host "$prefix$tName" -ForegroundColor $fgColor
            }
            Write-Host "`n使用指令切換: sli theme <主題名稱>`n" -ForegroundColor Gray
        } else {
            $targetTheme = $SubCommand.ToLower()
            $themeFile = Join-Path $ThemesDir "$targetTheme.json"
            if (Test-Path $themeFile) {
                $cfg.activeTheme = $targetTheme
                Save-Config $cfg
                Write-Host "✓ 已成功切換主題為: $targetTheme" -ForegroundColor Green
                Write-Host "請在終端機按下 Enter 即可查看即時變更！" -ForegroundColor Gray
            } else {
                Write-Host "錯誤: 找不到主題 '$targetTheme'。可輸入 'sli theme' 查看完整清單。" -ForegroundColor Red
            }
        }
    }

    "icon" {
        $presetIcons = @{
            "heart"   = "♡"
            "love"    = "♥"
            "fire"    = "🔥"
            "star"    = "✨"
            "sparkle" = "⭐"
            "rocket"  = "🚀"
            "coffee"  = "☕"
            "cat"     = "🐱"
            "sakura"  = "🌸"
            "skull"   = "💀"
            "bolt"    = "⚡"
            "music"   = "🎵"
        }

        if ([string]::IsNullOrWhiteSpace($SubCommand)) {
            Write-Host "`n當前圖示設定:" -ForegroundColor Cyan
            Write-Host "  時間段表情: $($cfg.timeIcon)" -ForegroundColor Green
            Write-Host "  Python 符號: $($cfg.pythonIcon)" -ForegroundColor Green
            Write-Host "  Git 分支符號: $($cfg.gitIcon)" -ForegroundColor Green
            Write-Host "`n熱門推薦表情捷徑:" -ForegroundColor Yellow
            $presetIcons.GetEnumerator() | ForEach-Object {
                Write-Host "  sli icon $($_.Key.PadRight(8)) ➜ $($_.Value)"
            }
            Write-Host "`n您也可以傳入任意 Emoji 或字元，例如: sli icon 🦄 或 sli icon 🔥`n" -ForegroundColor Gray
        } elseif ($SubCommand.ToLower() -eq "py") {
            if (-not [string]::IsNullOrWhiteSpace($Value)) {
                $cfg.pythonIcon = $Value
                Save-Config $cfg
                Write-Host "✓ 已設定 Python 虛擬環境符號為: $Value" -ForegroundColor Green
            } else {
                Write-Host "當前 Python 符號: $($cfg.pythonIcon) (用法: sli icon py <符號>)" -ForegroundColor Cyan
            }
        } elseif ($SubCommand.ToLower() -eq "git") {
            if (-not [string]::IsNullOrWhiteSpace($Value)) {
                $cfg.gitIcon = $Value
                Save-Config $cfg
                Write-Host "✓ 已設定 Git 分支符號為: $Value" -ForegroundColor Green
            } else {
                Write-Host "當前 Git 符號: $($cfg.gitIcon) (用法: sli icon git <符號>)" -ForegroundColor Cyan
            }
        } else {
            $newIcon = $SubCommand
            if ($presetIcons.ContainsKey($SubCommand.ToLower())) {
                $newIcon = $presetIcons[$SubCommand.ToLower()]
            }
            $cfg.timeIcon = $newIcon
            Save-Config $cfg
            Write-Host "✓ 已成功將時間段表情切換為: $newIcon" -ForegroundColor Green
            Write-Host "請在終端機按下 Enter 即可查看即時變更！" -ForegroundColor Gray
        }
    }

    "font" {
        if ($SubCommand.ToLower() -eq "install") {
            $fontScript = Join-Path $SliRoot "scripts\install-nerd-font.ps1"
            if (Test-Path $fontScript) {
                & $fontScript
            } else {
                Write-Error "找不到字型安裝腳本: $fontScript"
            }
        } else {
            Write-Host "`n字型管理指令:" -ForegroundColor Cyan
            Write-Host "  sli font install   - 自動下載並安裝 JetBrainsMono Nerd Font 字型" -ForegroundColor Green
            Write-Host "手動下載官方連結: https://www.nerdfonts.com/font-downloads`n" -ForegroundColor Gray
        }
    }

    "style" {
        $stylePresets = [ordered]@{
            "nerd_arrow"   = @{ glyph = ""; desc = "Powerline 經典尖角箭頭 (預設)" }
            "nerd_rounded" = @{ glyph = ""; desc = "圓角膠囊風格 (Rounded Pills)" }
            "slanted"      = @{ glyph = ""; desc = "上斜切幾何風 (Right Slanted)" }
            "slant_down"   = @{ glyph = ""; desc = "下斜切導流風 (Slant Downward)" }
            "flame"        = @{ glyph = ""; desc = "動感火焰波浪 (Powerline Flame)" }
            "pixel"        = @{ glyph = ""; desc = "8-bit 像素積木 (Pixel Squares)" }
            "wave"         = @{ glyph = ""; desc = "海浪波紋造型 (Wave Ripple)" }
            "flat"         = @{ glyph = " "; desc = "極簡純色色塊 (Flat Colorblocks)" }
            "ascii"        = @{ glyph = ">"; desc = "免字型相容文字模式 (Universal ASCII)" }
        }

        # 支援別名映射 (Aliases)
        $aliases = @{
            "arrow"     = "nerd_arrow"
            "round"     = "nerd_rounded"
            "rounded"   = "nerd_rounded"
            "pill"      = "nerd_rounded"
            "pills"     = "nerd_rounded"
            "fire"      = "flame"
            "block"     = "pixel"
            "ripple"    = "wave"
            "none"      = "flat"
            "simple"    = "flat"
        }

        if ([string]::IsNullOrWhiteSpace($SubCommand) -or $SubCommand.ToLower() -eq "list") {
            Write-Host "`n當前分隔風格: $($cfg.symbolStyle)`n" -ForegroundColor Green
            Write-Host "可用分隔風格庫 (Separator Styles):" -ForegroundColor Cyan
            foreach ($k in $stylePresets.Keys) {
                $isCurrent = ($k -eq $cfg.symbolStyle)
                $prefix = if ($isCurrent) { "* " } else { "  " }
                $fgColor = if ($isCurrent) { "Green" } else { "White" }
                $item = $stylePresets[$k]
                $glyphDisplay = if ($item.glyph -eq " ") { "[無]" } else { $item.glyph }
                Write-Host "$prefix$($k.PadRight(14)) ➜ $($glyphDisplay.PadRight(4)) $($item.desc)" -ForegroundColor $fgColor
            }
            Write-Host "`n使用指令切換: sli style <風格名稱>" -ForegroundColor Yellow
            Write-Host "範例: sli style slanted 或 sli style flame 或 sli style rounded`n" -ForegroundColor Gray
        } else {
            $targetStyle = $SubCommand.ToLower()
            if ($aliases.ContainsKey($targetStyle)) {
                $targetStyle = $aliases[$targetStyle]
            }

            if ($cfg.symbols -and $cfg.symbols.PSObject.Properties[$targetStyle]) {
                $cfg.symbolStyle = $targetStyle
                Save-Config $cfg
                Write-Host "✓ 已成功切換提示符分隔風格為: $targetStyle" -ForegroundColor Green
                Write-Host "請在終端機按下 Enter 即可查看即時變更，或輸入 'sli preview' 預覽！" -ForegroundColor Gray
            } else {
                Write-Host "錯誤: 找不到風格 '$SubCommand'。可輸入 'sli style' 檢視完整風格庫。" -ForegroundColor Red
            }
        }
    }

    "user" {
        if (-not [string]::IsNullOrWhiteSpace($SubCommand)) {
            $cfg.customUserName = $SubCommand
            Save-Config $cfg
            Write-Host "✓ 已設定使用者顯示名稱為: $SubCommand" -ForegroundColor Green
        } else {
            $displayName = if ($cfg.customUserName) { $cfg.customUserName } else { "(預設系統帳號: " + $env:USERNAME + ")" }
            Write-Host "當前使用者顯示名稱: $displayName" -ForegroundColor Cyan
        }
    }

    "privacy" {
        if ($SubCommand.ToLower() -eq "on") {
            $cfg.privacyMode = $true
            Save-Config $cfg
            Write-Host "✓ 隱私模式已開啟 (真實使用者名稱與路徑已被遮蔽)" -ForegroundColor Yellow
        } elseif ($SubCommand.ToLower() -eq "off") {
            $cfg.privacyMode = $false
            Save-Config $cfg
            Write-Host "✓ 隱私模式已關閉" -ForegroundColor Green
        } else {
            $pStatus = if ($cfg.privacyMode) { "開啟 (ON)" } else { "關閉 (OFF)" }
            Write-Host "隱私模式狀態: $pStatus" -ForegroundColor Cyan
            Write-Host "切換指令: sli privacy on 或 sli privacy off" -ForegroundColor Gray
        }
    }

    "preview" {
        Write-Host "`n=== S-li 提示符效果預覽 ===`n" -ForegroundColor Cyan
        . (Join-Path $SliRoot "core\powershell\sli-prompt.ps1")
        $p = prompt
        Write-Host -NoNewline $p
        Write-Host "git status`n"
    }

    "install" {
        Write-Host "正在為 PowerShell 註冊 S-li..." -ForegroundColor Cyan
        $profilePath = $PROFILE
        $profileDir = Split-Path -Parent $profilePath
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        $targetScript = Join-Path $SliRoot "core\powershell\sli-prompt.ps1"
        $importCmd = ". `"$targetScript`""
        
        if (Test-Path $profilePath) {
            $content = Get-Content -Path $profilePath -Raw
            if ($content -match "\.\s+[\`"'].*sli-prompt\.ps1[\`"']") {
                if ($content -match [regex]::Escape($importCmd)) {
                    Write-Host "✓ S-li 已是最新配置，無需重複寫入: $profilePath" -ForegroundColor Yellow
                } else {
                    $newContent = [regex]::Replace($content, "\.\s+[\`"'].*?sli-prompt\.ps1[\`"']", $importCmd)
                    [System.IO.File]::WriteAllText($profilePath, $newContent, [System.Text.Encoding]::UTF8)
                    Write-Host "✓ 已成功將 S-li 路徑更新為當前位置: $targetScript" -ForegroundColor Green
                }
            } else {
                Add-Content -Path $profilePath -Value "`n# S-li Terminal Prompt`n$importCmd`n" -Encoding UTF8
                Write-Host "✓ 已成功將 S-li 寫入您的 PowerShell Profile: $profilePath" -ForegroundColor Green
            }
        } else {
            Set-Content -Path $profilePath -Value "# S-li Terminal Prompt`n$importCmd`n" -Encoding UTF8
            Write-Host "✓ 已成功建立並寫入您的 PowerShell Profile: $profilePath" -ForegroundColor Green
        }
        Write-Host "重新開啟 PowerShell 或輸入 . `$PROFILE 即可立即生效！" -ForegroundColor Gray
    }

    default {
        Show-Help
    }
}
