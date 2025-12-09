#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    AIOS - Minimal Multipotential Initialization
.DESCRIPTION
    [LANGUAGE:PYTHON] discovery → external window → structured output
.NOTES
    Pattern: [VOID] → Python check → discover → display
#>

[CmdletBinding()]
param(
    [switch]$External,  # Launch in external PowerShell window
    [switch]$Json
)

$script:AIOS_ROOT = $PSScriptRoot
$script:AIOS_CORE = Join-Path $AIOS_ROOT "aios-core"

# ═══════════════════════════════════════════════════════════════════════════════
# [VOID] → Python Environment Check → Tool Discovery
# ═══════════════════════════════════════════════════════════════════════════════

$discoveryScript = @'
import sys
import json
from pathlib import Path

def discover():
    """[LANGUAGE:PYTHON] - Discover all .py tools"""
    tools_root = Path(r'{0}') / 'ai' / 'tools'
    
    if not tools_root.exists():
        return {{"status": "ERROR", "error": "tools_root not found"}}
    
    # Find ALL .py files (not just categorized)
    all_tools = []
    nested = {{}}
    
    for py_file in tools_root.rglob('*.py'):
        if py_file.name.startswith('__'):
            continue
        rel = py_file.relative_to(tools_root)
        parts = rel.parts
        
        if len(parts) == 1:
            # Root level
            nested.setdefault('root', []).append(py_file.stem)
        else:
            # Nested in category
            category = parts[0]
            nested.setdefault(category, []).append(py_file.stem)
        
        all_tools.append(str(rel))
    
    return {{
        "status": "INITIALIZED",
        "language": "PYTHON",
        "tool_count": len(all_tools),
        "nested": nested,
        "commands": ["python -m ai.tools.<category>.<tool>"]
    }}

result = discover()
print(json.dumps(result, indent=2))
'@ -f $AIOS_CORE

# ═══════════════════════════════════════════════════════════════════════════════
# Entry Point
# ═══════════════════════════════════════════════════════════════════════════════

# Check Python available
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[LANGUAGE:PYTHON] NOT AVAILABLE" -ForegroundColor Red
    exit 1
}

if ($External) {
    # Launch in external PowerShell window
    $escapedScript = $discoveryScript -replace '"', '\"'
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", "python -c `"$escapedScript`""
    Write-Host "[LANGUAGE:PYTHON] External window launched" -ForegroundColor Cyan
    exit 0
}

# Execute inline
$result = python -c $discoveryScript 2>&1

if ($Json) {
    $result
} else {
    Write-Host ""
    Write-Host "[LANGUAGE:PYTHON] $pythonVersion" -ForegroundColor Cyan
    Write-Host ""
    $parsed = $result | ConvertFrom-Json
    Write-Host "Status: $($parsed.status)" -ForegroundColor Green
    Write-Host "Tools:  $($parsed.tool_count)" -ForegroundColor White
    Write-Host ""
    foreach ($cat in $parsed.nested.PSObject.Properties) {
        Write-Host "  $($cat.Name): $($cat.Value.Count)" -ForegroundColor DarkGray
    }
    Write-Host ""
}
