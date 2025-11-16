#Requires -RunAsAdministrator
<#
.SYNOPSIS
    AIOS Supercell - Vault Management Script
.DESCRIPTION
    Manages Vault lifecycle: init, unseal, seal, backup
.NOTES
    Run as Administrator
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('init', 'unseal', 'seal', 'status', 'backup')]
    [string]$Action = 'status'
)

$ErrorActionPreference = "Stop"
$VaultAddr = "http://localhost:8200"
$ConfigDir = "C:\aios-supercell\config"
$UnsealKeysFile = "$ConfigDir\vault-unseal-keys.json"
$RootTokenFile = "$ConfigDir\vault-root-token.txt"

function Write-Header {
    param([string]$Message)
    Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $Message" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
}

function Invoke-VaultInit {
    Write-Header "Initializing Vault"
    
    # Run initialization script in Ubuntu
    wsl -d Ubuntu bash /mnt/c/Users/jesus/server/stacks/secrets/vault-init.sh
    
    if (Test-Path $UnsealKeysFile) {
        Write-Host "✓ Vault initialized successfully" -ForegroundColor Green
        Write-Host "⚠️  CRITICAL: Backup these files securely:" -ForegroundColor Red
        Write-Host "   $UnsealKeysFile" -ForegroundColor Yellow
        Write-Host "   $RootTokenFile" -ForegroundColor Yellow
    }
}

function Invoke-VaultUnseal {
    Write-Header "Unsealing Vault"
    
    if (-not (Test-Path $UnsealKeysFile)) {
        Write-Host "✗ Unseal keys not found. Run: .\vault-manager.ps1 -Action init" -ForegroundColor Red
        exit 1
    }
    
    $unsealKeys = Get-Content $UnsealKeysFile | ConvertFrom-Json
    
    # Unseal with 3 keys
    for ($i = 0; $i -lt 3; $i++) {
        $key = $unsealKeys.keys[$i]
        $body = @{ key = $key } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$VaultAddr/v1/sys/unseal" -Method POST -Body $body -ContentType "application/json"
        Write-Host "  Key $($i+1)/3 applied" -ForegroundColor Yellow
        
        if (-not $response.sealed) {
            Write-Host "✓ Vault unsealed" -ForegroundColor Green
            return
        }
    }
}

function Invoke-VaultSeal {
    Write-Header "Sealing Vault"
    
    if (-not (Test-Path $RootTokenFile)) {
        Write-Host "✗ Root token not found" -ForegroundColor Red
        exit 1
    }
    
    $token = Get-Content $RootTokenFile
    $headers = @{ "X-Vault-Token" = $token }
    
    Invoke-RestMethod -Uri "$VaultAddr/v1/sys/seal" -Method POST -Headers $headers
    Write-Host "✓ Vault sealed" -ForegroundColor Green
}

function Get-VaultStatus {
    Write-Header "Vault Status"
    
    try {
        $status = Invoke-RestMethod -Uri "$VaultAddr/v1/sys/health"
        
        Write-Host "Initialized: " -NoNewline
        Write-Host $status.initialized -ForegroundColor $(if ($status.initialized) { "Green" } else { "Red" })
        
        Write-Host "Sealed:      " -NoNewline
        Write-Host $status.sealed -ForegroundColor $(if ($status.sealed) { "Red" } else { "Green" })
        
        Write-Host "Standby:     " -NoNewline
        Write-Host $status.standby -ForegroundColor $(if ($status.standby) { "Yellow" } else { "Green" })
        
        Write-Host "`nVersion:     " -NoNewline -ForegroundColor Gray
        Write-Host $status.version -ForegroundColor White
        
    } catch {
        Write-Host "✗ Cannot connect to Vault at $VaultAddr" -ForegroundColor Red
        Write-Host "  Is the Vault container running?" -ForegroundColor Yellow
    }
}

function Invoke-VaultBackup {
    Write-Header "Backing up Vault Data"
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = "C:\aios-supercell\data\backup\vault-$timestamp"
    
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    
    # Backup config files
    Copy-Item $UnsealKeysFile -Destination $backupDir -ErrorAction SilentlyContinue
    Copy-Item $RootTokenFile -Destination $backupDir -ErrorAction SilentlyContinue
    
    # Backup Vault data volume
    docker cp aios-vault:/vault/file "$backupDir\vault-data"
    
    Write-Host "✓ Backup created: $backupDir" -ForegroundColor Green
}

# Execute action
switch ($Action) {
    'init'   { Invoke-VaultInit }
    'unseal' { Invoke-VaultUnseal }
    'seal'   { Invoke-VaultSeal }
    'status' { Get-VaultStatus }
    'backup' { Invoke-VaultBackup }
}
