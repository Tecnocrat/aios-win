# AI Agent Vault Helper
# This script helps AI agents discover system configuration from Vault

param(
    [Parameter(Mandatory=$false)]
    [string]$Query = "all"
)

# Bootstrap: Get Vault token from known location
$vaultToken = Get-Content ".\config\vault-root-token.txt" -ErrorAction Stop
$env:VAULT_TOKEN = $vaultToken

function Get-VaultSecret {
    param([string]$Path)
    $result = docker exec -e VAULT_TOKEN=$env:VAULT_TOKEN aios-vault vault kv get -format=json $Path 2>$null
    if ($result) {
        return ($result | ConvertFrom-Json).data.data
    }
    return $null
}

Write-Host "`n🤖 AI Agent Configuration Discovery`n" -ForegroundColor Cyan

switch ($Query) {
    "all" {
        Write-Host "System Paths:" -ForegroundColor Yellow
        Get-VaultSecret "aios-secrets/system/paths" | Format-Table -AutoSize
        
        Write-Host "`nVault Configuration:" -ForegroundColor Yellow
        Get-VaultSecret "aios-secrets/system/vault" | Format-Table -AutoSize
        
        Write-Host "`nService Endpoints:" -ForegroundColor Yellow
        Get-VaultSecret "aios-secrets/system/endpoints" | Format-Table -AutoSize
        
        Write-Host "`nService Credentials:" -ForegroundColor Yellow
        Write-Host "  Grafana: $(Get-VaultSecret 'aios-secrets/grafana' | Select-Object -ExpandProperty username)" -ForegroundColor White
        Write-Host "  Traefik: $(Get-VaultSecret 'aios-secrets/traefik' | Select-Object -ExpandProperty username)" -ForegroundColor White
        
        Write-Host "`nBackup Configuration:" -ForegroundColor Yellow
        Get-VaultSecret "aios-secrets/system/backup" | Format-Table -AutoSize
    }
    "paths" {
        Get-VaultSecret "aios-secrets/system/paths"
    }
    "vault" {
        Get-VaultSecret "aios-secrets/system/vault"
    }
    "endpoints" {
        Get-VaultSecret "aios-secrets/system/endpoints"
    }
    "credentials" {
        Write-Host "Grafana:" -ForegroundColor Cyan
        Get-VaultSecret "aios-secrets/grafana"
        Write-Host "`nTraefik:" -ForegroundColor Cyan
        Get-VaultSecret "aios-secrets/traefik"
    }
    "backup" {
        Get-VaultSecret "aios-secrets/system/backup"
    }
    default {
        Write-Host "Usage: .\scripts\agent-helper.ps1 [-Query <all|paths|vault|endpoints|credentials|backup>]" -ForegroundColor Yellow
    }
}

Write-Host ""
