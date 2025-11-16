#Requires -RunAsAdministrator
<#
.SYNOPSIS
    AIOS Supercell - Complete Stack Deployment
.DESCRIPTION
    Deploys all AIOS stacks (Traefik, Observability, Vault) with prerequisites
.NOTES
    Run after Phase 1-4 of bootstrap (Windows hardened, WSL2, Docker Desktop ready)
#>

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Message)
    Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $Message" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

Write-Header "AIOS SUPERCELL - Stack Deployment"

# Step 1: Generate TLS certificates
Write-Info "Step 1: Generating TLS certificates..."
if (-not (Test-Path "C:\Users\jesus\server\stacks\ingress\certs\lan.crt")) {
    & "C:\aios-supercell\scripts\generate-tls-certs.ps1"
    Write-Success "TLS certificates generated"
} else {
    Write-Success "TLS certificates already exist"
}

# Step 2: Create acme.json with proper permissions
Write-Info "Step 2: Creating acme.json..."
$acmePath = "C:\Users\jesus\server\stacks\ingress\acme.json"
if (-not (Test-Path $acmePath)) {
    New-Item -ItemType File -Path $acmePath -Force | Out-Null
    $acl = Get-Acl $acmePath
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl -Path $acmePath -AclObject $acl
    Write-Success "acme.json created with restricted permissions"
} else {
    Write-Success "acme.json already exists"
}

# Step 3: Create Grafana dashboards config (if missing)
Write-Info "Step 3: Creating Grafana dashboards config..."
$dashboardsYml = "C:\Users\jesus\server\stacks\observability\grafana\provisioning\dashboards\dashboards.yml"
if (-not (Test-Path $dashboardsYml)) {
    New-Item -ItemType Directory -Force -Path (Split-Path $dashboardsYml) | Out-Null
    
    $dashboardsConfig = @"
apiVersion: 1

providers:
  - name: 'AIOS Dashboards'
    orgId: 1
    folder: 'AIOS'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
"@
    
    Set-Content -Path $dashboardsYml -Value $dashboardsConfig
    Write-Success "Grafana dashboards.yml created"
} else {
    Write-Success "Grafana dashboards.yml already exists"
}

# Step 4: Update hosts file
Write-Info "Step 4: Updating hosts file..."
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$hostsContent = Get-Content $hostsFile
$domains = @("traefik.lan", "grafana.lan", "prometheus.lan", "vault.lan", "loki.lan", "whoami.lan")
$toAdd = @()

foreach ($domain in $domains) {
    if ($hostsContent -notmatch $domain) {
        $toAdd += $domain
    }
}

if ($toAdd.Count -gt 0) {
    $entry = "127.0.0.1 " + ($toAdd -join " ")
    Add-Content -Path $hostsFile -Value "`n$entry"
    Write-Success "Added to hosts: $($toAdd -join ', ')"
} else {
    Write-Success "All domains already in hosts file"
}

# Step 5: Flush DNS
ipconfig /flushdns | Out-Null
Write-Success "DNS cache flushed"

# Step 6: Create Docker network
Write-Info "Step 5: Creating Docker network..."
$networkExists = docker network ls --filter "name=aios-ingress" --format "{{.Name}}" 2>$null
if (-not $networkExists) {
    docker network create aios-ingress | Out-Null
    Write-Success "Docker network 'aios-ingress' created"
} else {
    Write-Success "Docker network 'aios-ingress' already exists"
}

# Step 7: Deploy Traefik stack
Write-Header "Deploying Traefik Ingress Stack"
Push-Location "C:\Users\jesus\server\stacks\ingress"
try {
    docker compose up -d
    Start-Sleep -Seconds 10
    Write-Success "Traefik stack deployed"
    
    # Check Traefik logs
    Write-Info "Checking Traefik logs..."
    docker logs aios-traefik --tail 20
} catch {
    Write-Error "Failed to deploy Traefik: $_"
} finally {
    Pop-Location
}

# Step 8: Deploy Observability stack
Write-Header "Deploying Observability Stack"
Push-Location "C:\Users\jesus\server\stacks\observability"
try {
    docker compose up -d
    Start-Sleep -Seconds 15
    Write-Success "Observability stack deployed"
    
    # Check Grafana logs
    Write-Info "Checking Grafana logs..."
    docker logs aios-grafana --tail 20
} catch {
    Write-Error "Failed to deploy Observability: $_"
} finally {
    Pop-Location
}

# Step 9: Deploy Vault stack
Write-Header "Deploying Vault Stack"
Push-Location "C:\Users\jesus\server\stacks\secrets"
try {
    docker compose up -d
    Start-Sleep -Seconds 10
    Write-Success "Vault stack deployed"
} catch {
    Write-Error "Failed to deploy Vault: $_"
} finally {
    Pop-Location
}

# Step 10: Verify all containers
Write-Header "Verification"
Write-Info "Checking all AIOS containers..."
docker ps --filter "name=aios-*" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Step 11: Initialize Vault (if not already done)
Write-Header "Vault Initialization"
if (-not (Test-Path "C:\aios-supercell\config\vault-unseal-keys.json")) {
    Write-Info "Initializing Vault for first time..."
    Write-Host "⚠️  IMPORTANT: Backup the unseal keys immediately after initialization!" -ForegroundColor Red
    Start-Sleep -Seconds 3
    
    try {
        & "C:\aios-supercell\scripts\vault-manager.ps1" -Action init
    } catch {
        Write-Error "Failed to initialize Vault: $_"
    }
} else {
    Write-Success "Vault already initialized"
    Write-Info "Checking Vault status..."
    & "C:\aios-supercell\scripts\vault-manager.ps1" -Action status
}

# Step 12: Service URLs
Write-Header "AIOS Supercell - Deployment Complete"

Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "  Traefik:    https://traefik.lan    (admin:changeme)" -ForegroundColor White
Write-Host "  Grafana:    https://grafana.lan    (admin:changeme)" -ForegroundColor White
Write-Host "  Prometheus: https://prometheus.lan" -ForegroundColor White
Write-Host "  Vault:      https://vault.lan" -ForegroundColor White
Write-Host "  Loki:       https://loki.lan" -ForegroundColor White
Write-Host "  Whoami:     https://whoami.lan      (test service)" -ForegroundColor White

Write-Host "`nDirect Ports:" -ForegroundColor Cyan
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor Gray
Write-Host "  Grafana:    http://localhost:3000" -ForegroundColor Gray
Write-Host "  Vault:      http://localhost:8200" -ForegroundColor Gray
Write-Host "  Loki:       http://localhost:3100" -ForegroundColor Gray

Write-Host "`n⚠️  IMMEDIATE SECURITY ACTIONS:" -ForegroundColor Red
Write-Host "  1. Change Traefik password (edit ingress/docker-compose.yml)" -ForegroundColor Yellow
Write-Host "  2. Change Grafana password (https://grafana.lan → Profile)" -ForegroundColor Yellow
Write-Host "  3. Backup Vault keys: C:\aios-supercell\config\vault-*.* " -ForegroundColor Yellow

Write-Host "`nQuick Tests:" -ForegroundColor Cyan
Write-Host '  curl https://traefik.lan -k' -ForegroundColor Gray
Write-Host '  curl http://localhost:9090/api/v1/targets' -ForegroundColor Gray
Write-Host '  curl http://localhost:3000/api/health' -ForegroundColor Gray

Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Your AIOS supercell is now operational! 🧬" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
