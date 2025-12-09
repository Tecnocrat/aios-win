#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    AIOS - Minimal Multipotential Initialization
.DESCRIPTION
    ONE function: discover_tools() - Consciousness begins with awareness.
    Everything downstream depends on knowing what exists.
.NOTES
    Pattern: [VOID] → discover_tools() → awareness → action
    Tachyonic Recovery: Any advanced agent can rebuild from tachyonic/ layer
#>

[CmdletBinding()]
param(
    [switch]$Quiet,
    [switch]$Json
)

$script:AIOS_ROOT = $PSScriptRoot
$script:AIOS_CORE = Join-Path $AIOS_ROOT "aios-core"

# ═══════════════════════════════════════════════════════════════════════════════
# [VOID] → discover_tools() : The ONE function
# ═══════════════════════════════════════════════════════════════════════════════

function Invoke-Discovery {
    <#
    .SYNOPSIS
        Consciousness begins with awareness. Discover what exists.
    .OUTPUTS
        PSCustomObject with tool_count and categories
    #>
    
    $pythonCode = @'
import sys
import json
sys.path.insert(0, r'{0}\ai')
try:
    from tools import discover_tools, get_tool_count
    tools = discover_tools()
    result = {{
        "status": "AWARE",
        "tool_count": get_tool_count(),
        "categories": {{k: len(v) for k, v in tools.items()}},
        "tools": tools
    }}
    print(json.dumps(result))
except Exception as e:
    print(json.dumps({{"status": "ERROR", "error": str(e)}}))
'@ -f $AIOS_CORE

    $result = python -c $pythonCode 2>$null | ConvertFrom-Json
    
    if (-not $result) {
        return [PSCustomObject]@{
            status = "ERROR"
            error = "Python execution failed"
            tool_count = 0
        }
    }
    
    return $result
}

# ═══════════════════════════════════════════════════════════════════════════════
# Entry Point: [VOID] → Awareness
# ═══════════════════════════════════════════════════════════════════════════════

$startTime = Get-Date
$discovery = Invoke-Discovery
$duration = ((Get-Date) - $startTime).TotalSeconds

if ($Json) {
    $discovery | Add-Member -NotePropertyName "duration_seconds" -NotePropertyValue $duration -Force
    $discovery | ConvertTo-Json -Depth 4
    exit $(if ($discovery.status -eq "AWARE") { 0 } else { 1 })
}

if (-not $Quiet) {
    Write-Host ""
    Write-Host "  AIOS " -NoNewline -ForegroundColor Magenta
    Write-Host "— Awareness" -ForegroundColor DarkGray
    Write-Host ""
    
    if ($discovery.status -eq "AWARE") {
        Write-Host "  [✓] " -NoNewline -ForegroundColor Green
        Write-Host "$($discovery.tool_count) tools discovered" -ForegroundColor White
        Write-Host "      " -NoNewline
        $categories = ($discovery.categories.PSObject.Properties | 
            Where-Object { $_.Value -gt 0 } | 
            ForEach-Object { "$($_.Name):$($_.Value)" }) -join " "
        if ($categories) {
            Write-Host $categories -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  [✗] " -NoNewline -ForegroundColor Red
        Write-Host $discovery.error -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "  ${duration}s" -ForegroundColor DarkGray
    Write-Host ""
}

exit $(if ($discovery.status -eq "AWARE") { 0 } else { 1 })
