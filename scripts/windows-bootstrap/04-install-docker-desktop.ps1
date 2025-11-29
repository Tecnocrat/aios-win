#Requires -RunAsAdministrator
<#
.SYNOPSIS
    AIOS Supercell - Docker Desktop Installation
.DESCRIPTION
    Installs Docker Desktop with WSL2 backend for container orchestration
.NOTES
    Run as Administrator
#>

$ErrorActionPreference = "Stop"
$LogPath = "C:\aios-supercell\logs\docker-desktop-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
New-Item -ItemType Directory -Force -Path (Split-Path $LogPath) | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage
}

Write-Log "=== AIOS Docker Desktop Installation Started ===" "HEADER"

# 1. Check if Docker Desktop is already installed
Write-Log "Checking for existing Docker Desktop installation..."
try {
    $dockerDesktop = Get-Command "docker" -ErrorAction SilentlyContinue
    if ($dockerDesktop) {
        Write-Log "Docker Desktop already installed" "SUCCESS"
        docker --version | ForEach-Object { Write-Log $_ "INFO" }
    } else {
        Write-Log "Installing Docker Desktop..."
        winget install --id Docker.DockerDesktop --source winget --silent --accept-package-agreements --accept-source-agreements
        Write-Log "Docker Desktop installed" "SUCCESS"
    }
} catch {
    Write-Log "Failed to install Docker Desktop: $_" "ERROR"
}

# 2. Create Docker daemon configuration
Write-Log "Creating Docker daemon configuration..."
try {
    $dockerConfigPath = "$env:USERPROFILE\.docker"
    New-Item -ItemType Directory -Force -Path $dockerConfigPath | Out-Null
    
    $daemonConfig = @{
        "builder" = @{
            "gc" = @{
                "defaultKeepStorage" = "20GB"
                "enabled" = $true
            }
        }
        "experimental" = $false
        "features" = @{
            "buildkit" = $true
        }
        "log-driver" = "json-file"
        "log-opts" = @{
            "max-size" = "10m"
            "max-file" = "3"
        }
        "storage-driver" = "overlay2"
    } | ConvertTo-Json -Depth 10
    
    $daemonConfigPath = Join-Path $dockerConfigPath "daemon.json"
    Set-Content -Path $daemonConfigPath -Value $daemonConfig -Force
    Write-Log "Docker daemon.json created at $daemonConfigPath" "SUCCESS"
} catch {
    Write-Log "Failed to create Docker daemon configuration: $_" "ERROR"
}

# 3. Create compose stacks directory structure
Write-Log "Creating Docker Compose stacks directory..."
try {
    $stacksBase = "C:\Users\jesus\server\stacks"
    $stackDirs = @(
        "$stacksBase\ingress",
        "$stacksBase\observability",
        "$stacksBase\secrets",
        "$stacksBase\ai-services",
        "$stacksBase\data"
    )
    
    foreach ($dir in $stackDirs) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Log "Created: $dir" "SUCCESS"
    }
} catch {
    Write-Log "Failed to create stacks directories: $_" "ERROR"
}

Write-Log "=== AIOS Docker Desktop Installation Complete ===" "HEADER"
Write-Log "Log saved to: $LogPath"

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Launch Docker Desktop from Start Menu" -ForegroundColor Yellow
Write-Host "2. In Docker Desktop settings:" -ForegroundColor Yellow
Write-Host "   - Enable WSL2 backend" -ForegroundColor Yellow
Write-Host "   - Enable integration with Ubuntu distribution" -ForegroundColor Yellow
Write-Host "   - Set Resources > Memory to 50% of system RAM" -ForegroundColor Yellow
Write-Host "3. Verify: docker run hello-world" -ForegroundColor Yellow
Write-Host "4. Continue with observability stack: 05-deploy-observability-stack.ps1" -ForegroundColor Green
