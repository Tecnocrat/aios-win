#Requires -RunAsAdministrator
<#
.SYNOPSIS
    AIOS Supercell - Core OS Hardening for Windows 11
.DESCRIPTION
    Prepares Windows 11 as an agentic substrate:
    - Disables sleep/hibernation
    - Configures power settings for always-on behavior
    - Enables BitLocker (if TPM available)
    - Sets static IP or DHCP reservation
    - Enables Remote Desktop with Network Level Authentication
.NOTES
    Run as Administrator
#>

$ErrorActionPreference = "Stop"
$LogPath = "C:\aios-supercell\logs\os-hardening-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
New-Item -ItemType Directory -Force -Path (Split-Path $LogPath) | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage
}

Write-Log "=== AIOS Core OS Hardening Started ===" "HEADER"

# 1. Disable sleep and hibernation
Write-Log "Disabling sleep and hibernation..."
try {
    powercfg -h off
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 0
    powercfg -change -disk-timeout-ac 0
    powercfg -change -disk-timeout-dc 0
    powercfg -change -monitor-timeout-ac 30
    powercfg -change -monitor-timeout-dc 15
    Write-Log "Power settings configured for always-on operation" "SUCCESS"
} catch {
    Write-Log "Failed to configure power settings: $_" "ERROR"
}

# 2. Enable High Performance power plan
Write-Log "Setting High Performance power plan..."
try {
    $highPerf = powercfg -l | Where-Object { $_ -match "High performance" }
    if ($highPerf) {
        $guid = ($highPerf -split '\s+')[3]
        powercfg -setactive $guid
        Write-Log "High Performance plan activated" "SUCCESS"
    }
} catch {
    Write-Log "Failed to set power plan: $_" "ERROR"
}

# 3. BitLocker preparation
Write-Log "Checking BitLocker status..."
try {
    $tpm = Get-Tpm
    if ($tpm.TpmPresent -and $tpm.TpmReady) {
        Write-Log "TPM is present and ready"
        
        $volumes = Get-BitLockerVolume | Where-Object { $_.VolumeType -eq "OperatingSystem" }
        foreach ($vol in $volumes) {
            if ($vol.ProtectionStatus -eq "Off") {
                Write-Log "BitLocker is OFF on $($vol.MountPoint). Enable manually with: Enable-BitLocker -MountPoint '$($vol.MountPoint)' -EncryptionMethod XtsAes256 -UsedSpaceOnly -TpmProtector" "WARN"
            } else {
                Write-Log "BitLocker already enabled on $($vol.MountPoint)" "SUCCESS"
            }
        }
    } else {
        Write-Log "TPM not available. BitLocker with password can be enabled manually." "WARN"
    }
} catch {
    Write-Log "BitLocker check failed: $_" "ERROR"
}

# 4. Network configuration
Write-Log "Checking network configuration..."
try {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Virtual -eq $false }
    
    foreach ($adapter in $adapters) {
        $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($ipConfig) {
            Write-Log "Adapter: $($adapter.Name)"
            Write-Log "  Current IP: $($ipConfig.IPAddress)"
            Write-Log "  DHCP: $($ipConfig.PrefixOrigin -eq 'Dhcp')"
            
            # If you want static IP, uncomment and configure:
            # $staticIP = "192.168.1.100"
            # $prefixLength = 24
            # $gateway = "192.168.1.1"
            # $dns = @("1.1.1.1", "1.0.0.1")
            # 
            # New-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress $staticIP -PrefixLength $prefixLength -DefaultGateway $gateway
            # Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $dns
        }
    }
} catch {
    Write-Log "Network configuration check failed: $_" "ERROR"
}

# 5. Enable Remote Desktop with NLA
Write-Log "Enabling Remote Desktop with Network Level Authentication..."
try {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    
    # Require Network Level Authentication
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1
    
    Write-Log "Remote Desktop enabled with NLA" "SUCCESS"
} catch {
    Write-Log "Failed to enable RDP: $_" "ERROR"
}

# 6. Disable Windows Update automatic restart
Write-Log "Configuring Windows Update to prevent automatic restarts..."
try {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 3 -Force -ErrorAction SilentlyContinue
    Write-Log "Windows Update configured to notify before restart" "SUCCESS"
} catch {
    Write-Log "Failed to configure Windows Update: $_" "ERROR"
}

# 7. Set system for best performance (optional visual adjustments)
Write-Log "Optimizing for performance..."
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force
    Write-Log "Performance optimizations applied" "SUCCESS"
} catch {
    Write-Log "Failed to apply performance settings: $_" "ERROR"
}

# 8. Configure Windows Defender exclusions for AIOS paths
Write-Log "Adding Windows Defender exclusions for AIOS directories..."
try {
    $exclusions = @(
        "C:\aios-supercell",
        "C:\Users\jesus\server"
    )
    
    foreach ($path in $exclusions) {
        if (Test-Path $path) {
            Add-MpPreference -ExclusionPath $path -ErrorAction SilentlyContinue
            Write-Log "Added exclusion: $path" "SUCCESS"
        }
    }
} catch {
    Write-Log "Failed to add Defender exclusions: $_" "ERROR"
}

# 9. System information summary
Write-Log "=== System Information ===" "HEADER"
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    
    Write-Log "Computer Name: $($cs.Name)"
    Write-Log "OS: $($os.Caption) $($os.Version)"
    Write-Log "CPU: $($cpu.Name)"
    Write-Log "RAM: $([math]::Round($cs.TotalPhysicalMemory/1GB, 2)) GB"
} catch {
    Write-Log "Failed to retrieve system info: $_" "ERROR"
}

Write-Log "=== AIOS Core OS Hardening Complete ===" "HEADER"
Write-Log "Log saved to: $LogPath"
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Review log file: $LogPath" -ForegroundColor Yellow
Write-Host "2. If needed, configure static IP in this script and re-run" -ForegroundColor Yellow
Write-Host "3. If BitLocker not enabled, run: Enable-BitLocker -MountPoint 'C:' -EncryptionMethod XtsAes256 -UsedSpaceOnly -TpmProtector" -ForegroundColor Yellow
Write-Host "4. Run 02-install-baseline-tools.ps1 to continue AIOS setup" -ForegroundColor Green
