<#
.SYNOPSIS
    AIOS Multi-Venv Manager - Manage multiple Python virtual environments

.DESCRIPTION
    Manages the AIOS multi-venv architecture:
    - primary (.venv): Python 3.14t FREE-THREADED for AIOS core
    - legacy (.venvs/legacy): Python 3.12 for SDKs with compatibility issues

.PARAMETER Action
    Action to perform: status, activate-primary, activate-legacy, start-bridge, stop-bridge, test

.EXAMPLE
    .\scripts\venv_manager.ps1 -Action status
    .\scripts\venv_manager.ps1 -Action start-bridge
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("status", "activate-primary", "activate-legacy", "start-bridge", "stop-bridge", "test")]
    [string]$Action
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

$PrimaryVenv = Join-Path $Root ".venv"
$LegacyVenv = Join-Path $Root ".venvs\legacy"
$BridgeScript = Join-Path $LegacyVenv "legacy_sdk_bridge.py"
$BridgePort = 8099

function Get-Status {
    Write-Host "`n=== AIOS Multi-Venv Status ===" -ForegroundColor Cyan
    
    # Primary venv
    $primaryPython = Join-Path $PrimaryVenv "Scripts\python.exe"
    if (Test-Path $primaryPython) {
        $version = & $primaryPython --version 2>&1
        Write-Host "✅ Primary (.venv): $version" -ForegroundColor Green
    } else {
        Write-Host "❌ Primary (.venv): NOT FOUND" -ForegroundColor Red
    }
    
    # Legacy venv
    $legacyPython = Join-Path $LegacyVenv "Scripts\python.exe"
    if (Test-Path $legacyPython) {
        $version = & $legacyPython --version 2>&1
        Write-Host "✅ Legacy (.venvs/legacy): $version" -ForegroundColor Green
    } else {
        Write-Host "❌ Legacy (.venvs/legacy): NOT FOUND" -ForegroundColor Red
    }
    
    # Bridge status
    try {
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:$BridgePort/health" -TimeoutSec 2 -ErrorAction Stop
        Write-Host "✅ Legacy Bridge: Running (Python $($response.python_version))" -ForegroundColor Green
        Write-Host "   Available SDKs: $($response.available_sdks -join ', ')" -ForegroundColor Gray
    } catch {
        Write-Host "⚪ Legacy Bridge: Not running" -ForegroundColor Yellow
    }
    
    # Environment variable
    $geminiKey = [System.Environment]::GetEnvironmentVariable('GEMINI_API_KEY', 'User')
    if ($geminiKey) {
        Write-Host "✅ GEMINI_API_KEY: Set ($($geminiKey.Substring(0,10))...)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ GEMINI_API_KEY: Not set" -ForegroundColor Yellow
    }
}

function Start-Bridge {
    Write-Host "`nStarting Legacy SDK Bridge..." -ForegroundColor Cyan
    
    $legacyPython = Join-Path $LegacyVenv "Scripts\python.exe"
    if (-not (Test-Path $legacyPython)) {
        Write-Host "❌ Legacy venv not found" -ForegroundColor Red
        return
    }
    
    if (-not (Test-Path $BridgeScript)) {
        Write-Host "❌ Bridge script not found: $BridgeScript" -ForegroundColor Red
        return
    }
    
    # Check if already running
    try {
        Invoke-RestMethod -Uri "http://127.0.0.1:$BridgePort/health" -TimeoutSec 2 -ErrorAction Stop | Out-Null
        Write-Host "⚠️ Bridge already running on port $BridgePort" -ForegroundColor Yellow
        return
    } catch {}
    
    # Load API key
    $env:GEMINI_API_KEY = [System.Environment]::GetEnvironmentVariable('GEMINI_API_KEY', 'User')
    
    # Start bridge
    $process = Start-Process -FilePath $legacyPython -ArgumentList $BridgeScript -PassThru -WindowStyle Hidden
    Write-Host "Started bridge process (PID: $($process.Id))" -ForegroundColor Gray
    
    # Wait for startup
    for ($i = 0; $i -lt 50; $i++) {
        Start-Sleep -Milliseconds 100
        try {
            $response = Invoke-RestMethod -Uri "http://127.0.0.1:$BridgePort/health" -TimeoutSec 2 -ErrorAction Stop
            Write-Host "✅ Bridge started successfully" -ForegroundColor Green
            Write-Host "   URL: http://127.0.0.1:$BridgePort" -ForegroundColor Gray
            Write-Host "   Health: http://127.0.0.1:$BridgePort/health" -ForegroundColor Gray
            Write-Host "   Docs: http://127.0.0.1:$BridgePort/docs" -ForegroundColor Gray
            return
        } catch {}
    }
    
    Write-Host "❌ Bridge failed to start" -ForegroundColor Red
}

function Stop-Bridge {
    Write-Host "`nStopping Legacy SDK Bridge..." -ForegroundColor Cyan
    
    # Find and kill process on port
    $connections = Get-NetTCPConnection -LocalPort $BridgePort -ErrorAction SilentlyContinue
    if ($connections) {
        foreach ($conn in $connections) {
            $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Stopping process: $($process.Name) (PID: $($process.Id))" -ForegroundColor Gray
                Stop-Process -Id $process.Id -Force
            }
        }
        Write-Host "✅ Bridge stopped" -ForegroundColor Green
    } else {
        Write-Host "⚪ Bridge was not running" -ForegroundColor Yellow
    }
}

function Test-Bridge {
    Write-Host "`nTesting Legacy SDK Bridge..." -ForegroundColor Cyan
    
    try {
        # Health check
        $health = Invoke-RestMethod -Uri "http://127.0.0.1:$BridgePort/health" -TimeoutSec 5
        Write-Host "✅ Health check passed" -ForegroundColor Green
        
        # Test Gemini
        $body = @{
            prompt = "Say 'AIOS Multi-Venv Test Success' in exactly 5 words"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:$BridgePort/gemini/generate" `
            -Method Post -Body $body -ContentType "application/json" -TimeoutSec 30
        
        Write-Host "✅ Gemini test passed" -ForegroundColor Green
        Write-Host "   Response: $($response.text)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Test failed: $_" -ForegroundColor Red
        Write-Host "   Make sure bridge is running: .\scripts\venv_manager.ps1 -Action start-bridge" -ForegroundColor Yellow
    }
}

# Execute action
switch ($Action) {
    "status" { Get-Status }
    "activate-primary" { 
        Write-Host "Run: .\.venv\Scripts\Activate.ps1" -ForegroundColor Cyan 
    }
    "activate-legacy" { 
        Write-Host "Run: .\.venvs\legacy\Scripts\Activate.ps1" -ForegroundColor Cyan 
    }
    "start-bridge" { Start-Bridge }
    "stop-bridge" { Stop-Bridge }
    "test" { Test-Bridge }
}
