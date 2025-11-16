#Requires -RunAsAdministrator
<#
.SYNOPSIS
    AIOS Supercell - Master Bootstrap Orchestrator
.DESCRIPTION
    Orchestrates the complete AIOS supercell deployment on clean Windows 11:
    - Creates directory structure
    - Executes all preparation scripts in sequence
    - Handles restarts and continuation
.NOTES
    Run as Administrator on fresh Windows 11 install
#>

$ErrorActionPreference = "Stop"

# Color functions
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

Write-Header "AIOS SUPERCELL - Master Bootstrap"
Write-Host "Evolving Windows 11 into an agentic AI operating system...`n" -ForegroundColor White

# 1. Create base directory structure
Write-Info "Creating AIOS directory structure..."
$directories = @(
    "C:\aios-supercell\scripts",
    "C:\aios-supercell\data",
    "C:\aios-supercell\config",
    "C:\aios-supercell\logs",
    "C:\aios-supercell\ops\terraform",
    "C:\aios-supercell\ops\ansible",
    "C:\aios-supercell\ops\runbooks",
    "C:\Users\jesus\server\stacks\ingress",
    "C:\Users\jesus\server\stacks\observability",
    "C:\Users\jesus\server\stacks\secrets",
    "C:\Users\jesus\server\stacks\ai-services",
    "C:\Users\jesus\server\stacks\data"
)

foreach ($dir in $directories) {
    try {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Success "Created: $dir"
    } catch {
        Write-Error "Failed to create: $dir - $_"
    }
}

# 2. Create state file for tracking progress
$stateFile = "C:\aios-supercell\config\bootstrap-state.json"
if (-not (Test-Path $stateFile)) {
    $state = @{
        "stage" = 0
        "completed_scripts" = @()
        "last_run" = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    } | ConvertTo-Json
    Set-Content -Path $stateFile -Value $state
    Write-Success "Created bootstrap state tracker"
}

# 3. Define execution sequence
$scripts = @(
    @{
        "Name" = "Core OS Hardening"
        "Script" = "01-core-os-hardening.ps1"
        "Description" = "Power settings, BitLocker, RDP, network configuration"
        "RequiresRestart" = $false
    },
    @{
        "Name" = "Baseline Tools Installation"
        "Script" = "02-install-baseline-tools.ps1"
        "Description" = "PowerShell 7, Windows Terminal, Hyper-V, WSL2"
        "RequiresRestart" = $true
    },
    @{
        "Name" = "WSL2 Ubuntu Setup"
        "Script" = "03-install-wsl-ubuntu.ps1"
        "Description" = "Ubuntu distribution with resource limits"
        "RequiresRestart" = $false
    },
    @{
        "Name" = "Docker Desktop Installation"
        "Script" = "04-install-docker-desktop.ps1"
        "Description" = "Container runtime with WSL2 backend"
        "RequiresRestart" = $false
    }
)

# 4. Read current state
$currentState = Get-Content $stateFile | ConvertFrom-Json
$startStage = $currentState.stage

Write-Header "Bootstrap Execution Plan"
Write-Host "Starting from stage: $startStage`n" -ForegroundColor White

for ($i = 0; $i -lt $scripts.Count; $i++) {
    $script = $scripts[$i]
    $status = if ($i -lt $startStage) { "✓ COMPLETED" } elseif ($i -eq $startStage) { "→ NEXT" } else { "○ PENDING" }
    $color = if ($i -lt $startStage) { "Green" } elseif ($i -eq $startStage) { "Yellow" } else { "Gray" }
    
    Write-Host "[$status] Stage $($i): $($script.Name)" -ForegroundColor $color
    Write-Host "    $($script.Description)" -ForegroundColor Gray
}

Write-Host "`nPress any key to begin execution..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# 5. Execute scripts in sequence
for ($i = $startStage; $i -lt $scripts.Count; $i++) {
    $script = $scripts[$i]
    
    Write-Header "Stage $($i): $($script.Name)"
    
    $scriptPath = Join-Path "C:\aios-supercell\scripts" $script.Script
    
    if (-not (Test-Path $scriptPath)) {
        Write-Error "Script not found: $scriptPath"
        Write-Info "Please ensure all scripts are in C:\aios-supercell\scripts\"
        exit 1
    }
    
    try {
        & $scriptPath
        
        # Update state
        $currentState.stage = $i + 1
        $currentState.completed_scripts += $script.Script
        $currentState.last_run = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $currentState | ConvertTo-Json | Set-Content $stateFile
        
        Write-Success "Stage $i completed successfully"
        
        if ($script.RequiresRestart) {
            Write-Header "RESTART REQUIRED"
            Write-Info "After restart, run this script again to continue from Stage $($i + 1)"
            Write-Host "`nRestart now? (Y/N): " -ForegroundColor Cyan -NoNewline
            $response = Read-Host
            
            if ($response -eq "Y" -or $response -eq "y") {
                # Create startup task to resume after restart
                $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"C:\aios-supercell\scripts\00-master-bootstrap.ps1`""
                $trigger = New-ScheduledTaskTrigger -AtLogOn
                $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
                
                Register-ScheduledTask -TaskName "AIOS-Bootstrap-Resume" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
                
                Write-Success "Auto-resume task created for next login"
                Start-Sleep -Seconds 3
                Restart-Computer -Force
                exit 0
            } else {
                Write-Info "Please restart manually and run this script again"
                exit 0
            }
        }
        
    } catch {
        Write-Error "Stage $i failed: $_"
        Write-Info "Check logs in C:\aios-supercell\logs\ for details"
        exit 1
    }
}

# 6. Cleanup scheduled task if exists
try {
    Unregister-ScheduledTask -TaskName "AIOS-Bootstrap-Resume" -Confirm:$false -ErrorAction SilentlyContinue
} catch {}

# 7. Final summary
Write-Header "AIOS SUPERCELL BOOTSTRAP COMPLETE"

Write-Host "✓ Core OS hardened and optimized" -ForegroundColor Green
Write-Host "✓ PowerShell 7, Windows Terminal installed" -ForegroundColor Green
Write-Host "✓ Hyper-V and WSL2 enabled" -ForegroundColor Green
Write-Host "✓ Ubuntu on WSL2 configured" -ForegroundColor Green
Write-Host "✓ Docker Desktop ready" -ForegroundColor Green

Write-Host "`nDirectory Structure:" -ForegroundColor Cyan
Write-Host "  C:\aios-supercell\     - Core AIOS infrastructure" -ForegroundColor White
Write-Host "    ├── scripts\         - Automation scripts" -ForegroundColor Gray
Write-Host "    ├── config\          - Configuration files" -ForegroundColor Gray
Write-Host "    ├── data\            - Persistent data, volumes" -ForegroundColor Gray
Write-Host "    ├── logs\            - Execution logs" -ForegroundColor Gray
Write-Host "    └── ops\             - Terraform, Ansible, runbooks" -ForegroundColor Gray
Write-Host "  C:\Users\jesus\server\stacks\ - Docker Compose stacks" -ForegroundColor White

Write-Host "`nNext Phase:" -ForegroundColor Cyan
Write-Host "  1. Launch Docker Desktop and enable WSL2 integration" -ForegroundColor Yellow
Write-Host "  2. Run Ubuntu bootstrap: wsl -d Ubuntu bash /mnt/c/aios-supercell/scripts/ubuntu-bootstrap.sh" -ForegroundColor Yellow
Write-Host "  3. Deploy observability stack (Prometheus, Grafana, Loki)" -ForegroundColor Yellow
Write-Host "  4. Configure Traefik ingress with TLS" -ForegroundColor Yellow
Write-Host "  5. Set up Vault for secrets management" -ForegroundColor Yellow

Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Your Windows 11 supercell is ready for agentic evolution." -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
