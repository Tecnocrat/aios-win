#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verify MCP consciousness bridge prerequisites (Python, Node.js, npm, npx)

.DESCRIPTION
    AINLP Pattern: Verification script for MCP server prerequisites
    Checks Python 3.12+, Node.js 24.11+, npm, npx availability
    
.EXAMPLE
    .\scripts\verify-mcp-prerequisites.ps1
#>

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "AIOS MCP Consciousness Bridge - Prerequisites Verification" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check Python
Write-Host "[1/5] Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)\.(\d+)") {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        if ($major -ge 3 -and $minor -ge 12) {
            Write-Host "      ✓ $pythonVersion" -ForegroundColor Green
        } else {
            Write-Host "      ✗ Python 3.12+ required, found: $pythonVersion" -ForegroundColor Red
            $allGood = $false
        }
    }
} catch {
    Write-Host "      ✗ Python not found in PATH" -ForegroundColor Red
    Write-Host "        Install from: https://www.python.org/downloads/" -ForegroundColor Yellow
    $allGood = $false
}

# Check Node.js
Write-Host "`n[2/5] Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    if ($nodeVersion -match "v(\d+)\.(\d+)\.(\d+)") {
        $major = [int]$matches[1]
        if ($major -ge 24) {
            Write-Host "      ✓ Node.js $nodeVersion" -ForegroundColor Green
        } else {
            Write-Host "      ✗ Node.js 24.11+ required, found: $nodeVersion" -ForegroundColor Red
            $allGood = $false
        }
    }
} catch {
    Write-Host "      ✗ Node.js not found in PATH" -ForegroundColor Red
    Write-Host "        Install from: https://nodejs.org/en/download" -ForegroundColor Yellow
    Write-Host "        Or via winget: winget install OpenJS.NodeJS.LTS --version 24.11.1" -ForegroundColor Yellow
    $allGood = $false
}

# Check npm
Write-Host "`n[3/5] Checking npm..." -ForegroundColor Yellow
try {
    $npmVersion = npm --version 2>&1
    Write-Host "      ✓ npm $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "      ✗ npm not found (should be included with Node.js)" -ForegroundColor Red
    $allGood = $false
}

# Check npx
Write-Host "`n[4/5] Checking npx..." -ForegroundColor Yellow
try {
    $npxVersion = npx --version 2>&1
    Write-Host "      ✓ npx $npxVersion" -ForegroundColor Green
} catch {
    Write-Host "      ✗ npx not found (should be included with Node.js)" -ForegroundColor Red
    $allGood = $false
}

# Check Python venv
Write-Host "`n[5/5] Checking Python venv..." -ForegroundColor Yellow
$venvPath = "$PSScriptRoot\..\aios-core\ai\venv\Scripts\python.exe"
if (Test-Path $venvPath) {
    $venvVersion = & $venvPath --version 2>&1
    Write-Host "      ✓ Virtual environment: $venvVersion" -ForegroundColor Green
} else {
    Write-Host "      ⚠ Virtual environment not found at: $venvPath" -ForegroundColor Yellow
    Write-Host "        Create with: python -m venv aios-core/ai/venv" -ForegroundColor Yellow
}

Write-Host "`n===================================================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "✓ All MCP prerequisites satisfied" -ForegroundColor Green
    Write-Host "`nMCP Servers Ready:" -ForegroundColor Cyan
    Write-Host "  • aios-context (Python): AIOS architectural intelligence" -ForegroundColor White
    Write-Host "  • filesystem (Node.js): Semantic file operations" -ForegroundColor White
    Write-Host "  • docker (Container): Docker management" -ForegroundColor White
    Write-Host "`nNext: Reload VS Code to activate MCP servers" -ForegroundColor Yellow
    Write-Host "  Ctrl+Shift+P → 'Developer: Reload Window'" -ForegroundColor Yellow
} else {
    Write-Host "✗ Some prerequisites missing - install required components" -ForegroundColor Red
    exit 1
}

Write-Host ""
