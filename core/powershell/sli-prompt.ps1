# S-li Prompt Engine for PowerShell (5.1 & 7+)
# Designed for Six Life Injoy / Shell Line Interface

$script:SliRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:ConfigFile = Join-Path $script:SliRoot "core\config.json"
$script:ThemesDir = Join-Path $script:SliRoot "themes"

function Convert-HexToRgb {
    param([string]$Hex)
    if ([string]::IsNullOrWhiteSpace($Hex)) {
        return @{ R = 255; G = 255; B = 255 }
    }
    $cleanHex = $Hex.Trim().TrimStart('#')
    if ($cleanHex.Length -eq 6) {
        $r = [Convert]::ToInt32($cleanHex.Substring(0, 2), 16)
        $g = [Convert]::ToInt32($cleanHex.Substring(2, 2), 16)
        $b = [Convert]::ToInt32($cleanHex.Substring(4, 2), 16)
        return @{ R = $r; G = $g; B = $b }
    }
    return @{ R = 255; G = 255; B = 255 }
}

function Get-SliConfig {
    if (Test-Path $script:ConfigFile) {
        try {
            $raw = [System.IO.File]::ReadAllText($script:ConfigFile, [System.Text.Encoding]::UTF8)
            return $raw | ConvertFrom-Json
        } catch {
            # Fallback below
        }
    }
    return [PSCustomObject]@{
        activeTheme = "sunset"
        symbolStyle = "nerd_arrow"
        customUserName = ""
        privacyMode = $false
        showVenv = $true
        showGit = $true
        showTime = $true
        timeIcon = [char]0x2661
    }
}

function Get-SliTheme {
    param([string]$ThemeName)
    $themeFile = Join-Path $script:ThemesDir "$ThemeName.json"
    if (Test-Path $themeFile) {
        try {
            $raw = [System.IO.File]::ReadAllText($themeFile, [System.Text.Encoding]::UTF8)
            return $raw | ConvertFrom-Json
        } catch {}
    }
    return [PSCustomObject]@{
        segments = [PSCustomObject]@{
            user = [PSCustomObject]@{ bg = "#7b2cbf"; fg = "#ffffff"; bold = $true }
            path = [PSCustomObject]@{ bg = "#d94676"; fg = "#ffffff"; bold = $false }
            git  = [PSCustomObject]@{ bg = "#f08a5d"; cleanBg = "#f08a5d"; dirtyBg = "#e26d5c"; fg = "#ffffff"; bold = $false }
            time = [PSCustomObject]@{ bg = "#4385be"; fg = "#ffffff"; bold = $false }
        }
    }
}

function Get-FastGitStatus {
    try {
        $gitBranch = git symbolic-ref --short HEAD 2>$null
        if (-not $gitBranch) {
            $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
        }
        if (-not $gitBranch -or $gitBranch -eq "HEAD") {
            # 檢查是否為剛 init 尚未 commit 的預設分支名
            $initBranch = git config init.defaultBranch 2>$null
            if (-not $initBranch) { $initBranch = "main" }
            $gitBranch = $initBranch
        }
        $gitBranch = $gitBranch.Trim()
        if ([string]::IsNullOrEmpty($gitBranch)) { return $null }

        $status = git status --porcelain 2>$null
        $isDirty = ($null -ne $status -and $status.Length -gt 0)

        return @{
            Branch = $gitBranch
            IsDirty = $isDirty
        }
    } catch {
        return $null
    }
}

function global:prompt {
    $esc = [char]27
    $reset = "$esc[0m"

    $config = Get-SliConfig
    $themeName = if ($config.activeTheme) { $config.activeTheme } else { "sunset" }
    $theme = Get-SliTheme -ThemeName $themeName

    # 符號與圖示設定
    $styleKey = if ($config.symbolStyle) { $config.symbolStyle } else { "nerd_arrow" }
    $sep = [char]0xe0b0
    $branchIcon = if ($config.gitIcon) { $config.gitIcon } else { [char]0x2192 }   # →
    $dirtyIcon = "*"
    $venvIcon = if ($config.pythonIcon) { $config.pythonIcon } else { [char]::ConvertFromUtf32(0x1F40D) } # 🐍

    if ($config.symbols -and $config.symbols.$styleKey) {
        $curSym = $config.symbols.$styleKey
        if ($curSym.separator) { $sep = $curSym.separator }
        if (-not $config.gitIcon -and $curSym.branch) { $branchIcon = $curSym.branch }
        if ($curSym.dirty) { $dirtyIcon = $curSym.dirty }
        if (-not $config.pythonIcon -and $curSym.venv) { $venvIcon = $curSym.venv }
    }

    # 1. Segment 1: User / Identity
    $userText = if ($config.privacyMode) {
        "user"
    } elseif ($config.customUserName) {
        $config.customUserName
    } else {
        $env:USERNAME
    }
    $userBg = Convert-HexToRgb $theme.segments.user.bg
    $userFg = Convert-HexToRgb $theme.segments.user.fg

    # 2. Segment 2: Path & Python Venv
    $currentPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    $homeDir = [Environment]::GetFolderPath("UserProfile")
    if ($currentPath.StartsWith($homeDir, [System.StringComparison]::OrdinalIgnoreCase)) {
        $displayPath = "~" + $currentPath.Substring($homeDir.Length)
    } else {
        $displayPath = $currentPath
    }

    $leaf = Split-Path -Leaf $currentPath
    if ([string]::IsNullOrEmpty($leaf)) { $leaf = $displayPath }

    $venvText = ""
    if ($config.showVenv) {
        if ($env:VIRTUAL_ENV) {
            $venvName = Split-Path -Leaf $env:VIRTUAL_ENV
            $venvText = "$venvIcon ($venvName) "
        } elseif ($env:CONDA_DEFAULT_ENV) {
            $venvText = "$venvIcon ($($env:CONDA_DEFAULT_ENV)) "
        }
    }
    $pathText = "$venvText$leaf"
    $pathBg = Convert-HexToRgb $theme.segments.path.bg
    $pathFg = Convert-HexToRgb $theme.segments.path.fg

    # 3. Segment 3: Git Status
    $gitInfo = if ($config.showGit) { Get-FastGitStatus } else { $null }
    $gitText = ""
    $gitBg = $null
    if ($gitInfo) {
        if ($gitInfo.IsDirty) {
            $gitText = "$dirtyIcon $branchIcon ($($gitInfo.Branch))"
            $gitBgHex = if ($theme.segments.git.dirtyBg) { $theme.segments.git.dirtyBg } else { $theme.segments.git.cleanBg }
        } else {
            $gitText = "$branchIcon ($($gitInfo.Branch))"
            $gitBgHex = $theme.segments.git.cleanBg
        }
        $gitBg = Convert-HexToRgb $gitBgHex
    }
    $gitFg = Convert-HexToRgb $theme.segments.git.fg

    # 4. Segment 4: Time
    $tIcon = if ($config.timeIcon) { "$($config.timeIcon) " } else { "" }
    $timeText = "$tIcon$(Get-Date -Format 'HH:mm')"
    $timeBg = Convert-HexToRgb $theme.segments.time.bg
    $timeFg = Convert-HexToRgb $theme.segments.time.fg

    # 組合 ANSI 代碼
    $sb = [System.Text.StringBuilder]::new()

    # User
    [void]$sb.Append(("{0}[48;2;{1};{2};{3}m" -f $esc, $userBg.R, $userBg.G, $userBg.B))
    [void]$sb.Append(("{0}[38;2;{1};{2};{3}m" -f $esc, $userFg.R, $userFg.G, $userFg.B))
    [void]$sb.Append(" $userText ")

    # User -> Path
    [void]$sb.Append(("{0}[48;2;{1};{2};{3}m" -f $esc, $pathBg.R, $pathBg.G, $pathBg.B))
    [void]$sb.Append(("{0}[38;2;{1};{2};{3}m" -f $esc, $userBg.R, $userBg.G, $userBg.B))
    [void]$sb.Append($sep)

    # Path
    [void]$sb.Append(("{0}[48;2;{1};{2};{3}m" -f $esc, $pathBg.R, $pathBg.G, $pathBg.B))
    [void]$sb.Append(("{0}[38;2;{1};{2};{3}m" -f $esc, $pathFg.R, $pathFg.G, $pathFg.B))
    [void]$sb.Append(" $pathText ")

    if ($gitInfo) {
        # Path -> Git
        [void]$sb.Append(("{0}[48;2;{1};{2};{3}m" -f $esc, $gitBg.R, $gitBg.G, $gitBg.B))
        [void]$sb.Append(("{0}[38;2;{1};{2};{3}m" -f $esc, $pathBg.R, $pathBg.G, $pathBg.B))
        [void]$sb.Append($sep)

        # Git
        [void]$sb.Append(("{0}[48;2;{1};{2};{3}m" -f $esc, $gitBg.R, $gitBg.G, $gitBg.B))
        [void]$sb.Append(("{0}[38;2;{1};{2};{3}m" -f $esc, $gitFg.R, $gitFg.G, $gitFg.B))
        [void]$sb.Append(" $gitText ")

        # Git -> Time
        [void]$sb.Append(("{0}[48;2;{1};{2};{3}m" -f $esc, $timeBg.R, $timeBg.G, $timeBg.B))
        [void]$sb.Append(("{0}[38;2;{1};{2};{3}m" -f $esc, $gitBg.R, $gitBg.G, $gitBg.B))
        [void]$sb.Append($sep)
    } else {
        # Path -> Time
        [void]$sb.Append(("{0}[48;2;{1};{2};{3}m" -f $esc, $timeBg.R, $timeBg.G, $timeBg.B))
        [void]$sb.Append(("{0}[38;2;{1};{2};{3}m" -f $esc, $pathBg.R, $pathBg.G, $pathBg.B))
        [void]$sb.Append($sep)
    }

    # Time
    [void]$sb.Append(("{0}[48;2;{1};{2};{3}m" -f $esc, $timeBg.R, $timeBg.G, $timeBg.B))
    [void]$sb.Append(("{0}[38;2;{1};{2};{3}m" -f $esc, $timeFg.R, $timeFg.G, $timeFg.B))
    [void]$sb.Append(" $timeText ")

    # Closing arrow
    [void]$sb.Append($reset)
    [void]$sb.Append(("{0}[38;2;{1};{2};{3}m" -f $esc, $timeBg.R, $timeBg.G, $timeBg.B))
    [void]$sb.Append($sep)
    [void]$sb.Append($reset)
    [void]$sb.Append(" ")

    return $sb.ToString()
}
