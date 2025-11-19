# AIOS Vault Backup Script
# Run this to backup critical Vault files to USB or secure location

param(
    [Parameter(Mandatory=$false)]
    [string]$BackupPath = "D:\aios-vault-backup-$(Get-Date -Format 'yyyy-MM-dd-HHmm')"
)

Write-Host "`n🔐 AIOS Vault Backup Utility`n" -ForegroundColor Cyan

# Create backup directory
New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
Write-Host "✓ Created: $BackupPath" -ForegroundColor Green

# Critical files
$files = @(
    "C:\aios-supercell\config\vault-unseal-keys.json",
    "C:\aios-supercell\config\vault-root-token.txt",
    "C:\aios-supercell\config\vault-service-tokens.json"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Copy-Item $file $BackupPath -Force
        Write-Host "✓ Backed up: $(Split-Path $file -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "✗ Missing: $file" -ForegroundColor Red
    }
}

Write-Host "`n📋 Backup Summary:" -ForegroundColor Cyan
Get-ChildItem $BackupPath | Format-Table Name, Length, LastWriteTime -AutoSize

Write-Host "`n⚠️  Store this backup in:" -ForegroundColor Yellow
Write-Host "   • Encrypted USB drive" -ForegroundColor White
Write-Host "   • Password manager (1Password, Bitwarden)" -ForegroundColor White
Write-Host "   • Encrypted cloud storage (NOT plain GitHub)" -ForegroundColor White

Write-Host "`n✅ Backup complete: $BackupPath`n" -ForegroundColor Green
