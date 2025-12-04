<#
.SYNOPSIS
    AIOS Local AI Agent Launcher - Ollama RC1 with aios-mistral
    
.DESCRIPTION
    Starts the Ollama 0.13.1-rc1 server with AIOS-integrated Mistral 7B model.
    This is a last-gen edge AI agent optimized for 4GB VRAM deployment.
    
.NOTES
    Host: HP_LAB (192.168.1.129)
    Model: aios-mistral (Mistral 7B Instruct v0.3)
    VRAM: 4GB optimized
    Context: 4096 tokens
#>

param(
    [switch]$Serve,
    [switch]$Stop,
    [switch]$Status,
    [string]$Prompt
)

$OllamaRC1 = "C:\dev\aios-win\ai\tools\ollama-rc1\ollama-0.13.1-rc1\ollama-rc1.exe"
$Model = "aios-mistral"

function Write-AIOS {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host "[AIOS-MISTRAL] " -ForegroundColor DarkCyan -NoNewline
    Write-Host $Message -ForegroundColor $Color
}

if (-not (Test-Path $OllamaRC1)) {
    Write-AIOS "Ollama RC1 not found. Build required." "Red"
    Write-AIOS "Run: cd ai\tools\ollama-rc1\ollama-0.13.1-rc1; go build -o ollama-rc1.exe ." "Yellow"
    exit 1
}

if ($Serve) {
    Write-AIOS "Starting Ollama 0.13.1-rc1 server..." "Green"
    
    # Stop existing ollama processes
    Stop-Process -Name "ollama*" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Start RC1 server
    Start-Process -FilePath $OllamaRC1 -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 3
    
    Write-AIOS "Server started. Model: $Model" "Green"
    Write-AIOS "Test: .\aios-mistral.ps1 -Prompt 'Hello'" "Yellow"
}
elseif ($Stop) {
    Write-AIOS "Stopping Ollama server..." "Yellow"
    Stop-Process -Name "ollama*" -Force -ErrorAction SilentlyContinue
    Write-AIOS "Server stopped." "Green"
}
elseif ($Status) {
    $proc = Get-Process -Name "ollama*" -ErrorAction SilentlyContinue
    if ($proc) {
        Write-AIOS "Server running (PID: $($proc.Id))" "Green"
        & $OllamaRC1 list
    } else {
        Write-AIOS "Server not running" "Yellow"
    }
}
elseif ($Prompt) {
    & $OllamaRC1 run $Model $Prompt
}
else {
    Write-Host @"
AIOS Local AI Agent - Mistral 7B (RC1)
======================================
Usage:
  .\aios-mistral.ps1 -Serve              # Start Ollama RC1 server
  .\aios-mistral.ps1 -Stop               # Stop server
  .\aios-mistral.ps1 -Status             # Check status and list models
  .\aios-mistral.ps1 -Prompt "question"  # Query the agent

Model: aios-mistral (Mistral 7B Instruct)
VRAM:  4GB optimized
Host:  HP_LAB (192.168.1.129)
"@
}
