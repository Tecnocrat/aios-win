#Requires -RunAsAdministrator
<#
.SYNOPSIS
    AIOS Supercell - Baseline Tools Installation
.DESCRIPTION
    Installs foundational tools for AIOS:
    - PowerShell 7 (pwsh)
    - Windows Terminal
    - Node.js (for VSCode extensions)
    - Hyper-V
    - WSL2 with Ubuntu
    - winget (if not present)
.NOTES
    Run as Administrator
#>

$ErrorActionPreference = "Stop"
$LogPath = "C:\aios-supercell\logs\baseline-tools-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
New-Item -ItemType Directory -Force -Path (Split-Path $LogPath) | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage
}

Write-Log "=== AIOS Baseline Tools Installation Started ===" "HEADER"

# 1. Install winget if not present
Write-Log "Checking for winget..."
try {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Log "winget not found. Installing from Microsoft Store..." "WARN"
        Write-Log "Please install 'App Installer' from Microsoft Store and re-run this script." "ERROR"
        exit 1
    } else {
        Write-Log "winget found: $($winget.Version)" "SUCCESS"
    }
} catch {
    Write-Log "Failed to check winget: $_" "ERROR"
}

# 2. Install PowerShell 7
Write-Log "Installing PowerShell 7..."
try {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if (-not $pwsh) {
        winget install --id Microsoft.PowerShell --source winget --silent --accept-package-agreements --accept-source-agreements
        Write-Log "PowerShell 7 installed" "SUCCESS"
    } else {
        Write-Log "PowerShell 7 already installed: $($pwsh.Version)" "SUCCESS"
    }
} catch {
    Write-Log "Failed to install PowerShell 7: $_" "ERROR"
}

# 3. Install Windows Terminal
Write-Log "Installing Windows Terminal..."
try {
    $terminal = Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue
    if (-not $terminal) {
        winget install --id Microsoft.WindowsTerminal --source winget --silent --accept-package-agreements --accept-source-agreements
        Write-Log "Windows Terminal installed" "SUCCESS"
    } else {
        Write-Log "Windows Terminal already installed: $($terminal.Version)" "SUCCESS"
    }
} catch {
    Write-Log "Failed to install Windows Terminal: $_" "ERROR"
}

# 4. Install Node.js
Write-Log "Installing Node.js..."
try {
    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) {
        winget install --id OpenJS.NodeJS --source winget --silent --accept-package-agreements --accept-source-agreements
        Write-Log "Node.js installed" "SUCCESS"
        # Refresh PATH for current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        $nodeVersion = & node --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Node.js version: $nodeVersion" "SUCCESS"
        }
    } else {
        Write-Log "Node.js already installed: $($node.Version)" "SUCCESS"
    }
} catch {
    Write-Log "Failed to install Node.js: $_" "ERROR"
}

# 5. Enable Hyper-V
Write-Log "Enabling Hyper-V..."
try {
    $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
    if ($hyperv.State -ne "Enabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
        Write-Log "Hyper-V enabled (restart required)" "SUCCESS"
        $script:RestartRequired = $true
    } else {
        Write-Log "Hyper-V already enabled" "SUCCESS"
    }
} catch {
    Write-Log "Failed to enable Hyper-V: $_" "ERROR"
}

# 6. Enable Virtual Machine Platform
Write-Log "Enabling Virtual Machine Platform..."
try {
    $vmp = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    if ($vmp.State -ne "Enabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
        Write-Log "Virtual Machine Platform enabled (restart required)" "SUCCESS"
        $script:RestartRequired = $true
    } else {
        Write-Log "Virtual Machine Platform already enabled" "SUCCESS"
    }
} catch {
    Write-Log "Failed to enable Virtual Machine Platform: $_" "ERROR"
}

# 7. Enable WSL
Write-Log "Enabling WSL..."
try {
    $wsl = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    if ($wsl.State -ne "Enabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        Write-Log "WSL enabled (restart required)" "SUCCESS"
        $script:RestartRequired = $true
    } else {
        Write-Log "WSL already enabled" "SUCCESS"
    }
} catch {
    Write-Log "Failed to enable WSL: $_" "ERROR"
}

# 8. Download and install WSL2 kernel update
Write-Log "Checking WSL2 kernel..."
try {
    $kernelPath = "$env:TEMP\wsl_update_x64.msi"
    if (-not (Test-Path $kernelPath)) {
        Write-Log "Downloading WSL2 kernel update..."
        Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile $kernelPath
        Write-Log "Installing WSL2 kernel update..."
        Start-Process msiexec.exe -ArgumentList "/i `"$kernelPath`" /quiet /norestart" -Wait
        Write-Log "WSL2 kernel update installed" "SUCCESS"
    } else {
        Write-Log "WSL2 kernel update already downloaded" "SUCCESS"
    }
} catch {
    Write-Log "Failed to install WSL2 kernel: $_" "ERROR"
}

# 9. Set WSL2 as default
Write-Log "Setting WSL2 as default version..."
try {
    wsl --set-default-version 2
    Write-Log "WSL2 set as default" "SUCCESS"
} catch {
    Write-Log "Failed to set WSL2 as default: $_" "ERROR"
}

Write-Log "=== AIOS Baseline Tools Installation Complete ===" "HEADER"
Write-Log "Log saved to: $LogPath"

if ($script:RestartRequired) {
    Write-Host "`n⚠️  RESTART REQUIRED" -ForegroundColor Red
    Write-Host "After restart, run: 03-install-wsl-ubuntu.ps1" -ForegroundColor Yellow
    Write-Host "`nRestart now? (Y/N): " -ForegroundColor Cyan -NoNewline
    $response = Read-Host
    if ($response -eq "Y" -or $response -eq "y") {
        Write-Log "Initiating system restart..." "WARN"
        Restart-Computer -Force
    }
} else {
    Write-Host "`nNext step: Run 03-install-wsl-ubuntu.ps1" -ForegroundColor Green
}
