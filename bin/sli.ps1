<#
.SYNOPSIS
    S-li (Six Life Injoy / Shell Line Interface) 樣式與配置管理工具
.DESCRIPTION
    管理 S-li 終端提示符的主題、圖示、使用者識別與隱私設定。
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
    Write-Host "平時直接覆蓋終端提示符，`sli` 僅用於樣式與個人化切換。" -ForegroundColor Gray
    Write-Host ""
    Write-Host "用法:" -ForegroundColor Cyan
    Write-Host "  sli theme                  - 列出所有可用主題與當前主題"
    Write-Host "  sli theme <name>           - 切換至指定主題 (sunset, cyberpunk, nord)"
    Write-Host "  sli style <arrow|rounded>  - 切換分隔符號風格 (nerd_arrow, nerd_rounded, ascii)"
    Write-Host "  sli user <name>            - 設定第一段自訂使用者識別名稱 (例如 sixma)"
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
                Write-Host "錯誤: 找不到主題 '$targetTheme'。可用主題: sunset, cyberpunk, nord" -ForegroundColor Red
            }
        }
    }

    "style" {
        $validStyles = @("nerd_arrow", "nerd_rounded", "ascii")
        if ($validStyles -contains $SubCommand.ToLower()) {
            $cfg.symbolStyle = $SubCommand.ToLower()
            Save-Config $cfg
            Write-Host "✓ 已切換符號風格為: $SubCommand" -ForegroundColor Green
        } else {
            Write-Host "可用風格: nerd_arrow (預設箭頭), nerd_rounded (圓角膠囊), ascii (無字型平替)" -ForegroundColor Yellow
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
        $importCmd = ". `"$SliRoot\core\powershell\sli-prompt.ps1`""
        
        $alreadyInstalled = $false
        if (Test-Path $profilePath) {
            $content = Get-Content -Path $profilePath -Raw
            if ($content -match "sli-prompt\.ps1") {
                $alreadyInstalled = $true
            }
        }

        if (-not $alreadyInstalled) {
            Add-Content -Path $profilePath -Value "`n# S-li Terminal Prompt`n$importCmd`n"
            Write-Host "✓ 已成功將 S-li 寫入您的 PowerShell Profile: $profilePath" -ForegroundColor Green
            Write-Host "重新開啟 PowerShell 或輸入 . `$PROFILE 即可立即生效！" -ForegroundColor Gray
        } else {
            Write-Host "✓ S-li 已在您的 PowerShell Profile 中，無需重複寫入。" -ForegroundColor Yellow
        }
    }

    default {
        Show-Help
    }
}
