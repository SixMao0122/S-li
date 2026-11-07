# S-li Windows One-Click Installer
# Designed for Six Life Injoy / Shell Line Interface

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$SliRoot = $PSScriptRoot
Write-Host ""
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "    S-li (Six Life Injoy) 自動安裝程式   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "正在為您的環境配置現代化終端提示符..." -ForegroundColor Gray
Write-Host ""

# 1. 註冊至 PowerShell Profile
try {
    $psProfilePath = $PROFILE
    $psProfileDir = Split-Path -Parent $psProfilePath
    if (-not (Test-Path $psProfileDir)) {
        New-Item -ItemType Directory -Path $psProfileDir -Force | Out-Null
    }

    $psTargetScript = Join-Path $SliRoot "core\powershell\sli-prompt.ps1"
    $importLine = ". `"$psTargetScript`""

    if (Test-Path $psProfilePath) {
        $content = Get-Content -Path $psProfilePath -Raw
        if ($content -match "\.\s+[\`"'].*sli-prompt\.ps1[\`"']") {
            if ($content -match [regex]::Escape($importLine) -and -not $Force) {
                Write-Host "ℹ [PowerShell] 您的 Profile 已是最新 S-li 配置: $psProfilePath" -ForegroundColor Yellow
            } else {
                $newContent = [regex]::Replace($content, "\.\s+[\`"'].*?sli-prompt\.ps1[\`"']", $importLine)
                [System.IO.File]::WriteAllText($psProfilePath, $newContent, [System.Text.Encoding]::UTF8)
                Write-Host "✓ [PowerShell] 已成功更新 S-li 路徑為: $psTargetScript" -ForegroundColor Green
            }
        } else {
            Add-Content -Path $psProfilePath -Value "`n# S-li Terminal Prompt Engine`n$importLine`n" -Encoding UTF8
            Write-Host "✓ [PowerShell] 已成功註冊至: $psProfilePath" -ForegroundColor Green
        }
    } else {
        Set-Content -Path $psProfilePath -Value "# S-li Terminal Prompt Engine`n$importLine`n" -Encoding UTF8
        Write-Host "✓ [PowerShell] 已成功建立並註冊至: $psProfilePath" -ForegroundColor Green
    }
} catch {
    Write-Warning "PowerShell Profile 註冊失敗: $_"
}

# 2. 註冊至 Git Bash (~/.bashrc)
try {
    $homeDir = [Environment]::GetFolderPath("UserProfile")
    $bashrcPath = Join-Path $homeDir ".bashrc"
    
    # 支援 POSIX 路徑格式 (例如 /c/Users/... )
    $rawBashScript = (Join-Path $SliRoot "core/bash/sli-prompt.sh") -replace '\\', '/'
    $bashTargetScript = if ($rawBashScript -match '^([a-zA-Z]):/(.*)$') {
        "/" + $Matches[1].ToLower() + "/" + $Matches[2]
    } else {
        $rawBashScript
    }
    $bashImportLine = "[ -f `"$bashTargetScript`" ] && source `"$bashTargetScript`""

    if (Test-Path $bashrcPath) {
        $bContent = Get-Content -Path $bashrcPath -Raw
        if ($bContent -match "sli-prompt\.sh") {
            if ($bContent -match [regex]::Escape($bashImportLine) -and -not $Force) {
                Write-Host "ℹ [Git Bash] 您的 ~/.bashrc 已是最新 S-li 配置。" -ForegroundColor Yellow
            } else {
                $newBContent = [regex]::Replace($bContent, "\[\s+-f\s+[\`"'].*?sli-prompt\.sh[\`"']\s+\]\s+&&\s+source\s+[\`"'].*?sli-prompt\.sh[\`"']", $bashImportLine)
                [System.IO.File]::WriteAllText($bashrcPath, $newBContent, [System.Text.Encoding]::UTF8)
                Write-Host "✓ [Git Bash] 已成功更新 S-li 路徑為: $bashTargetScript" -ForegroundColor Green
            }
        } else {
            Add-Content -Path $bashrcPath -Value "`n# S-li Terminal Prompt Engine`n$bashImportLine`n" -Encoding UTF8
            Write-Host "✓ [Git Bash] 已成功註冊至: $bashrcPath" -ForegroundColor Green
        }
    } else {
        Set-Content -Path $bashrcPath -Value "# S-li Terminal Prompt Engine`n$bashImportLine`n" -Encoding UTF8
        Write-Host "✓ [Git Bash] 已成功建立並註冊至: $bashrcPath" -ForegroundColor Green
    }
} catch {
    Write-Warning "Git Bash 註冊失敗: $_"
}

# 3. 檢查與配置 Clink (針對 CMD)
try {
    $localAppData = [Environment]::GetFolderPath("LocalApplicationData")
    $clinkDir = Join-Path $localAppData "clink"
    if (Test-Path $clinkDir) {
        $luaSource = Join-Path $SliRoot "core\clink\sli.lua"
        $luaDest = Join-Path $clinkDir "sli.lua"
        Copy-Item -Path $luaSource -Destination $luaDest -Force
        Write-Host "✓ [CMD / Clink] 已成功安裝 Lua 腳本至: $luaDest" -ForegroundColor Green
    } else {
        Write-Host "ℹ [CMD] 尚未偵測到 Clink 目錄。若 CMD 需使用 Powerline 效果，建議安裝 Clink 並將 core/clink/sli.lua 置入。" -ForegroundColor Gray
    }
} catch {
    Write-Warning "Clink 設定失敗: $_"
}

# 4. 加入使用者環境變數 PATH
try {
    $binPath = Join-Path $SliRoot "bin"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$binPath*") {
        $newPath = "$currentPath;$binPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "✓ [CLI PATH] 已將 S-li 輔助指令 ('$binPath') 加入使用者 PATH！" -ForegroundColor Green
    } else {
        Write-Host "ℹ [CLI PATH] '$binPath' 已在使用者 PATH 中。" -ForegroundColor Yellow
    }

    # 同步刷新當前 Process 的 PATH，確保當前視窗立即可以使用 sli 指令
    if ($env:Path -notlike "*$binPath*") {
        $env:Path = "$env:Path;$binPath"
    }
} catch {
    Write-Warning "PATH 設定失敗: $_"
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "🎉 安裝完成！現在您可以：" -ForegroundColor Green
Write-Host "1. 重新開啟 Windows Terminal 或輸入 '. `$PROFILE' 即可立即看見效果！" -ForegroundColor Cyan
Write-Host "2. 輸入 'sli theme' 探索並切換主題" -ForegroundColor Cyan
Write-Host "3. 輸入 'sli --help' 查看所有樣式切換指令" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
