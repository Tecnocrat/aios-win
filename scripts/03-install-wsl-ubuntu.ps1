#Requires -RunAsAdministrator
<#
.SYNOPSIS
    AIOS Supercell - WSL2 Ubuntu Installation
.DESCRIPTION
    Installs and configures Ubuntu on WSL2 as the Linux execution layer
.NOTES
    Run as Administrator after system restart
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$LogPath = "$RootDir\logs\wsl-ubuntu-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
New-Item -ItemType Directory -Force -Path (Split-Path $LogPath) | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage
}

Write-Log "=== AIOS WSL2 Ubuntu Installation Started ===" "HEADER"

# 1. Check if Ubuntu is already installed
Write-Log "Checking for existing Ubuntu installation..."
try {
    $ubuntu = wsl --list --quiet | Select-String "Ubuntu"
    if ($ubuntu) {
        Write-Log "Ubuntu already installed: $ubuntu" "SUCCESS"
        Write-Log "To reinstall, run: wsl --unregister Ubuntu" "INFO"
    } else {
        Write-Log "Installing Ubuntu..."
        wsl --install -d Ubuntu
        Write-Log "Ubuntu installation initiated" "SUCCESS"
        Write-Log "Follow the prompts to create a user account" "INFO"
    }
} catch {
    Write-Log "Failed to install Ubuntu: $_" "ERROR"
}

# 2. Create .wslconfig
Write-Log "Creating .wslconfig for resource management..."
try {
    $wslConfigPath = "$env:USERPROFILE\.wslconfig"
    $totalRAM = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
    $wslRAM = [math]::Floor($totalRAM / 1GB / 2) # Allocate 50% of system RAM
    $wslCPU = (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors / 2 # Allocate 50% of CPUs
    
    $wslConfig = @"
# AIOS Supercell WSL2 Configuration
[wsl2]
# Memory allocation (50% of system RAM)
memory=${wslRAM}GB

# Processor allocation (50% of logical cores)
processors=$wslCPU

# Swap file
swap=8GB
swapfile=$($RootDir -replace '\\', '\\')\\data\\wsl-swap.vhdx

# Networking
localhostForwarding=true
networkingMode=mirrored

# Enable systemd for Docker and service management
[boot]
systemd=true
"@
    
    Set-Content -Path $wslConfigPath -Value $wslConfig -Force
    Write-Log ".wslconfig created at $wslConfigPath" "SUCCESS"
    Write-Log "Allocated: ${wslRAM}GB RAM, $wslCPU CPUs" "INFO"
} catch {
    Write-Log "Failed to create .wslconfig: $_" "ERROR"
}

# 3. Create mount directories
Write-Log "Creating persistent mount directories..."
try {
    $mountDirs = @(
        "$RootDir\data\wsl-home",
        "$RootDir\data\docker-volumes",
        "$RootDir\data\backup"
    )
    
    foreach ($dir in $mountDirs) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Log "Created: $dir" "SUCCESS"
    }
} catch {
    Write-Log "Failed to create mount directories: $_" "ERROR"
}

# 4. WSL Ubuntu bootstrap script
Write-Log "Creating Ubuntu bootstrap script..."
try {
    $ubuntuBootstrap = @'
#!/bin/bash
# AIOS Supercell - Ubuntu Bootstrap Script

set -e
LOG_FILE="/mnt/c/dev/aios-win/logs/ubuntu-bootstrap-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== AIOS Ubuntu Bootstrap Started ==="

# Update system
log "Updating package lists..."
sudo apt update -qq

log "Upgrading packages..."
sudo apt upgrade -y -qq

# Install essential tools
log "Installing essential tools..."
sudo apt install -y -qq \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential

# Install Docker (will be used if Docker Desktop not preferred)
log "Installing Docker prerequisites..."
sudo apt install -y -qq apt-transport-https

log "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

log "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

log "Installing Docker Engine..."
sudo apt update -qq
sudo apt install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin

log "Adding user to docker group..."
sudo usermod -aG docker $USER

# Create symbolic links to Windows AIOS directories
log "Creating symbolic links..."
ln -sf /mnt/c/dev/aios-win ~/aios-supercell
ln -sf /mnt/c/Users/jesus/server ~/server

log "=== AIOS Ubuntu Bootstrap Complete ==="
log "Log saved to: $LOG_FILE"
echo ""
echo "Next steps:"
echo "1. Log out and back in for docker group to take effect"
echo "2. Test Docker: docker run hello-world"
echo "3. Install Docker Desktop on Windows for better integration"
'@
    
    $bootstrapPath = "$RootDir\scripts\ubuntu-bootstrap.sh"
    Set-Content -Path $bootstrapPath -Value $ubuntuBootstrap -Force
    Write-Log "Ubuntu bootstrap script created: $bootstrapPath" "SUCCESS"
} catch {
    Write-Log "Failed to create Ubuntu bootstrap script: $_" "ERROR"
}

Write-Log "=== AIOS WSL2 Ubuntu Installation Complete ===" "HEADER"
Write-Log "Log saved to: $LogPath"

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Complete Ubuntu user setup if prompted" -ForegroundColor Yellow
Write-Host "2. Restart WSL: wsl --shutdown" -ForegroundColor Yellow
Write-Host "3. Launch Ubuntu: wsl -d Ubuntu" -ForegroundColor Yellow
Write-Host "4. Run bootstrap: bash /mnt/c/dev/aios-win/scripts/ubuntu-bootstrap.sh" -ForegroundColor Yellow
Write-Host "5. Install Docker Desktop: Run 04-install-docker-desktop.ps1" -ForegroundColor Green
