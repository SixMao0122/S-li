# S-li Automated Font Downloader & Installer
# Automatically installs JetBrainsMono Nerd Font for Windows

[CmdletBinding()]
param(
    [string]$FontName = "JetBrainsMono"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "   S-li Nerd Font 自動下載與安裝精靈      " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host ""

$fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontName.zip"
$tempDir = Join-Path $env:TEMP "sli_fonts_$FontName"
$zipPath = Join-Path $env:TEMP "$FontName.zip"

try {
    Write-Host "1. 正在從官方 GitHub 下載 $FontName Nerd Font..." -ForegroundColor Cyan
    Write-Host "   來源: $fontZipUrl" -ForegroundColor Gray
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $fontZipUrl -OutFile $zipPath -UseBasicParsing

    Write-Host "✓ 下載完成！大小: $([math]::Round((Get-Item $zipPath).Length / 1MB, 2)) MB" -ForegroundColor Green

    Write-Host "2. 正在解壓縮字型檔..." -ForegroundColor Cyan
    if (Test-Path $tempDir) { Remove-Item -Path $tempDir -Recurse -Force }
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

    Write-Host "3. 正在將字型安裝至 Windows 系統字型庫..." -ForegroundColor Cyan
    $shellApp = New-Object -ComObject Shell.Application
    $fontsFolder = $shellApp.Namespace(0x14) # 0x14 = Fonts Special Folder

    $fontFiles = Get-ChildItem -Path $tempDir -Include "*Regular*.ttf", "*Bold*.ttf" -Recurse
    if (-not $fontFiles) {
        $fontFiles = Get-ChildItem -Path $tempDir -Filter "*.ttf" | Select-Object -First 4
    }

    foreach ($font in $fontFiles) {
        Write-Host "   正在註冊: $($font.Name)" -ForegroundColor Gray
        $fontsFolder.CopyHere($font.FullName, 16) # 16 = 無對話框自動覆寫
    }

    Write-Host ""
    Write-Host "🎉 $FontName Nerd Font 安裝成功！" -ForegroundColor Green
    Write-Host "提示: 請開啟 Windows Terminal 設定，將字型選為 '$FontName Nerd Font' 即可享受完美圖示效果！" -ForegroundColor Yellow
} catch {
    Write-Error "字型安裝過程發生錯誤: $_"
    Write-Host "`n備選方案: 您可以直接點選以下官方網址手動下載安裝:" -ForegroundColor Yellow
    Write-Host "https://www.nerdfonts.com/font-downloads" -ForegroundColor Cyan
} finally {
    if (Test-Path $zipPath) { Remove-Item -Force $zipPath -ErrorAction SilentlyContinue }
    if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue }
}
