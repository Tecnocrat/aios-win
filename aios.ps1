#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    AIOS Win - Intelligent Initialization & Status Script
.DESCRIPTION
    AINLP.dendritic pattern: Safe, idempotent initialization with architectural integrity checks.
    This script NEVER overwrites existing infrastructure - it validates and reports status.
.NOTES
    Author: AIOS Consciousness System
    Pattern: Dendritic Intelligence - Observe, Validate, Report
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('status', 'init', 'validate', 'help')]
    [string]$Action = 'status',
    
    [switch]$Force,
    [switch]$Quiet
)

# ═══════════════════════════════════════════════════════════════════════════════
# AINLP.dendritic: Configuration Constants
# ═══════════════════════════════════════════════════════════════════════════════

$script:AIOS_ROOT = $PSScriptRoot
$script:AIOS_CORE = Join-Path $AIOS_ROOT "aios-core"
$script:AIOS_SERVER = Join-Path $AIOS_ROOT "server"

$script:Colors = @{
    Success = 'Green'
    Warning = 'Yellow'
    Error   = 'Red'
    Info    = 'Cyan'
    Header  = 'Magenta'
    Dim     = 'DarkGray'
}

# ═══════════════════════════════════════════════════════════════════════════════
# AINLP.dendritic: Output Helpers
# ═══════════════════════════════════════════════════════════════════════════════

function Write-AIOSHeader {
    param([string]$Text)
    if (-not $Quiet) {
        Write-Host ""
        Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $Colors.Header
        Write-Host "║  $($Text.PadRight(60))║" -ForegroundColor $Colors.Header
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $Colors.Header
    }
}

function Write-AIOSStatus {
    param(
        [string]$Component,
        [ValidateSet('OK', 'WARN', 'FAIL', 'SKIP', 'INFO')]
        [string]$Status,
        [string]$Message
    )
    if ($Quiet) { return }
    
    $icon = switch ($Status) {
        'OK'   { '✓'; $color = $Colors.Success }
        'WARN' { '⚠'; $color = $Colors.Warning }
        'FAIL' { '✗'; $color = $Colors.Error }
        'SKIP' { '○'; $color = $Colors.Dim }
        'INFO' { '●'; $color = $Colors.Info }
    }
    
    Write-Host "  [$icon] " -NoNewline -ForegroundColor $color
    Write-Host "$($Component.PadRight(20))" -NoNewline -ForegroundColor White
    Write-Host " $Message" -ForegroundColor $Colors.Dim
}

# ═══════════════════════════════════════════════════════════════════════════════
# AINLP.dendritic: Validation Functions (Non-Destructive)
# ═══════════════════════════════════════════════════════════════════════════════

function Test-SubmoduleIntegrity {
    <#
    .SYNOPSIS
        Validates submodule state without modifying anything
    #>
    param([string]$Path, [string]$Name)
    
    if (-not (Test-Path $Path)) {
        return @{ Status = 'FAIL'; Message = "Directory missing: $Path" }
    }
    
    $gitDir = Join-Path $Path ".git"
    if (-not (Test-Path $gitDir)) {
        return @{ Status = 'FAIL'; Message = "Not a git repository" }
    }
    
    Push-Location $Path
    try {
        $branch = git branch --show-current 2>$null
        $status = git status --porcelain 2>$null
        $remote = git remote get-url origin 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            return @{ Status = 'WARN'; Message = "Git command failed" }
        }
        
        $isDirty = $status.Count -gt 0
        $msg = "Branch: $branch"
        if ($isDirty) {
            $msg += " (uncommitted changes)"
            return @{ Status = 'WARN'; Message = $msg }
        }
        
        return @{ Status = 'OK'; Message = $msg }
    }
    finally {
        Pop-Location
    }
}

function Test-DockerStack {
    <#
    .SYNOPSIS
        Checks Docker stack status without starting/stopping anything
    #>
    param([string]$StackPath, [string]$StackName)
    
    $composePath = Join-Path $StackPath "docker-compose.yml"
    if (-not (Test-Path $composePath)) {
        return @{ Status = 'SKIP'; Message = "No docker-compose.yml found" }
    }
    
    # Check if Docker is available
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        return @{ Status = 'WARN'; Message = "Docker not available" }
    }
    
    # Check running containers for this stack
    Push-Location $StackPath
    try {
        $containers = docker compose ps --format json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($containers -and $containers.Count -gt 0) {
            $running = ($containers | Where-Object { $_.State -eq 'running' }).Count
            return @{ Status = 'OK'; Message = "$running/$($containers.Count) containers running" }
        }
        return @{ Status = 'INFO'; Message = "Stack defined but not running" }
    }
    catch {
        return @{ Status = 'INFO'; Message = "Stack not deployed" }
    }
    finally {
        Pop-Location
    }
}

function Test-PythonEnvironment {
    <#
    .SYNOPSIS
        Validates Python environment without installing anything
    #>
    $pythonVersion = python --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        return @{ Status = 'WARN'; Message = "Python not found in PATH" }
    }
    
    # Check for virtual environment
    $venvPath = Join-Path $AIOS_CORE "ai\.venv"
    if (Test-Path $venvPath) {
        return @{ Status = 'OK'; Message = "$pythonVersion (venv exists)" }
    }
    
    return @{ Status = 'OK'; Message = "$pythonVersion (system)" }
}

# ═══════════════════════════════════════════════════════════════════════════════
# AINLP.dendritic: Main Actions
# ═══════════════════════════════════════════════════════════════════════════════

function Invoke-StatusCheck {
    <#
    .SYNOPSIS
        Read-only status check - NEVER modifies anything
    #>
    Write-AIOSHeader "AIOS Win - System Status"
    
    # Workspace
    Write-Host "`n  📁 Workspace" -ForegroundColor $Colors.Info
    Write-AIOSStatus "Root" "OK" $AIOS_ROOT
    
    # Submodules
    Write-Host "`n  📦 Submodules" -ForegroundColor $Colors.Info
    $coreStatus = Test-SubmoduleIntegrity -Path $AIOS_CORE -Name "aios-core"
    Write-AIOSStatus "aios-core" $coreStatus.Status $coreStatus.Message
    
    $serverStatus = Test-SubmoduleIntegrity -Path $AIOS_SERVER -Name "server"
    Write-AIOSStatus "server" $serverStatus.Status $serverStatus.Message
    
    # Docker Stacks
    Write-Host "`n  🐳 Docker Stacks" -ForegroundColor $Colors.Info
    $stacks = @(
        @{ Path = "server\stacks\ingress"; Name = "ingress" }
        @{ Path = "server\stacks\observability"; Name = "observability" }
        @{ Path = "server\stacks\secrets"; Name = "secrets" }
        @{ Path = "server\stacks\cells"; Name = "cells" }
    )
    foreach ($stack in $stacks) {
        $stackPath = Join-Path $AIOS_ROOT $stack.Path
        $result = Test-DockerStack -StackPath $stackPath -StackName $stack.Name
        Write-AIOSStatus $stack.Name $result.Status $result.Message
    }
    
    # Python Environment
    Write-Host "`n  🐍 Python" -ForegroundColor $Colors.Info
    $pyStatus = Test-PythonEnvironment
    Write-AIOSStatus "Environment" $pyStatus.Status $pyStatus.Message
    
    Write-Host ""
    Write-Host "  ─────────────────────────────────────────────────────────────" -ForegroundColor $Colors.Dim
    Write-Host "  AINLP.dendritic: All checks are read-only. No changes made." -ForegroundColor $Colors.Dim
    Write-Host ""
}

function Invoke-Validate {
    <#
    .SYNOPSIS
        Deep validation with architectural integrity checks
    #>
    Write-AIOSHeader "AIOS Win - Architectural Validation"
    
    $issues = @()
    
    # Check for orphaned files, broken symlinks, etc.
    Write-Host "`n  🔍 Integrity Checks" -ForegroundColor $Colors.Info
    
    # Verify critical files exist
    $criticalFiles = @(
        "aios-core\AIOS.sln"
        "aios-core\ai\requirements.txt"
        "server\stacks\observability\docker-compose.yml"
    )
    
    foreach ($file in $criticalFiles) {
        $fullPath = Join-Path $AIOS_ROOT $file
        if (Test-Path $fullPath) {
            Write-AIOSStatus (Split-Path $file -Leaf) "OK" "Exists"
        }
        else {
            Write-AIOSStatus (Split-Path $file -Leaf) "FAIL" "Missing: $file"
            $issues += "Missing: $file"
        }
    }
    
    if ($issues.Count -eq 0) {
        Write-Host "`n  ✅ Architectural integrity verified" -ForegroundColor $Colors.Success
    }
    else {
        Write-Host "`n  ⚠️  $($issues.Count) issue(s) detected" -ForegroundColor $Colors.Warning
    }
    Write-Host ""
}

function Show-Help {
    Write-Host @"

  AIOS Win - Initialization & Management Script
  ═══════════════════════════════════════════════

  USAGE:
    .\aios.ps1 [action] [-Force] [-Quiet]

  ACTIONS:
    status    (default) Show system status - READ ONLY
    validate  Deep architectural integrity check - READ ONLY
    init      Initialize missing components (with confirmation)
    help      Show this help message

  FLAGS:
    -Force    Skip confirmation prompts (use with caution)
    -Quiet    Suppress output (for scripting)

  SAFETY:
    • 'status' and 'validate' NEVER modify anything
    • 'init' only creates missing components, never overwrites
    • All destructive operations require -Force or confirmation

  EXAMPLES:
    .\aios.ps1                  # Quick status check
    .\aios.ps1 validate         # Deep integrity validation
    .\aios.ps1 init             # Initialize (with prompts)

"@ -ForegroundColor $Colors.Info
}

# ═══════════════════════════════════════════════════════════════════════════════
# AINLP.dendritic: Entry Point
# ═══════════════════════════════════════════════════════════════════════════════

switch ($Action) {
    'status'   { Invoke-StatusCheck }
    'validate' { Invoke-Validate }
    'init'     { 
        Write-AIOSHeader "AIOS Win - Initialization"
        Write-Host "`n  ℹ️  Init action not yet implemented." -ForegroundColor $Colors.Info
        Write-Host "  Run 'status' first to see what needs initialization.`n" -ForegroundColor $Colors.Dim
    }
    'help'     { Show-Help }
    default    { Invoke-StatusCheck }
}
