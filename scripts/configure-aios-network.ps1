param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("laptop", "desktop")]
    [string]$MachineType,

    [Parameter(Mandatory=$false)]
    [switch]$SkipRestart
)

Write-Host "🔧 Configuring AIOS Network ($MachineType)" -ForegroundColor Green

# Determine configuration based on machine type
$hostname = if ($MachineType -eq "laptop") { "AIOS-LAPTOP" } else { "AIOS" }
$ipAddress = if ($MachineType -eq "laptop") { "192.168.1.129" } else { "192.168.1.128" }

Write-Host "📍 Target Configuration:" -ForegroundColor Yellow
Write-Host "  • Hostname: $hostname" -ForegroundColor White
Write-Host "  • IP Address: $ipAddress" -ForegroundColor White

# Set hostname
Write-Host "`n🏷️ Setting hostname..." -ForegroundColor Yellow
$currentHostname = $env:COMPUTERNAME
if ($currentHostname -ne $hostname) {
    Write-Host "  • Changing from '$currentHostname' to '$hostname'" -ForegroundColor White
    Rename-Computer -NewName $hostname -Force
    $restartRequired = $true
} else {
    Write-Host "  • Hostname already correct" -ForegroundColor Green
}

# Configure Windows Firewall for AIOS services
Write-Host "`n🔥 Configuring Windows Firewall..." -ForegroundColor Yellow
$aiosPorts = @(8000, 8001, 3001, 8080, 9090, 3000, 3100, 8200, 9091)
$rulesCreated = 0

foreach ($port in $aiosPorts) {
    $ruleName = "AIOS Port $port"
    $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

    if (-not $existingRule) {
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -ErrorAction SilentlyContinue
        if ($?) {
            Write-Host "  • Created rule for port $port" -ForegroundColor White
            $rulesCreated++
        }
    } else {
        Write-Host "  • Rule for port $port already exists" -ForegroundColor Green
    }
}

# Create inter-AIOS communication rule
$interAiosRule = "AIOS Inter-Cell Communication"
$existingInterRule = Get-NetFirewallRule -DisplayName $interAiosRule -ErrorAction SilentlyContinue

if (-not $existingInterRule) {
    New-NetFirewallRule -DisplayName $interAiosRule -Direction Inbound -RemoteAddress "192.168.1.128/32","192.168.1.129/32" -Action Allow -ErrorAction SilentlyContinue
    if ($?) {
        Write-Host "  • Created inter-cell communication rule" -ForegroundColor White
    }
}

Write-Host "  • Created $rulesCreated new firewall rules" -ForegroundColor Green

# Update hosts file for DNS resolution
Write-Host "`n📇 Updating hosts file..." -ForegroundColor Yellow
$hostsPath = "$env:windir\System32\drivers\etc\hosts"
$hostsContent = Get-Content $hostsPath -ErrorAction SilentlyContinue
$hostsEntries = @(
    "192.168.1.129 aios-laptop.local aios-laptop",
    "192.168.1.128 aios.local aios"
)

$entriesAdded = 0
foreach ($entry in $hostsEntries) {
    if ($hostsContent -notcontains $entry) {
        Add-Content $hostsPath "`n$entry" -ErrorAction SilentlyContinue
        if ($?) {
            Write-Host "  • Added: $entry" -ForegroundColor White
            $entriesAdded++
        }
    } else {
        Write-Host "  • Already exists: $entry" -ForegroundColor Green
    }
}

Write-Host "  • Added $entriesAdded new hosts entries" -ForegroundColor Green

# Test network connectivity
Write-Host "`n🧪 Testing network connectivity..." -ForegroundColor Yellow

# Test local connectivity
$localTest = Test-NetConnection -ComputerName "localhost" -Port 80 -InformationLevel Quiet
Write-Host "  • Local connectivity: $(if ($localTest) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($localTest) { 'Green' } else { 'Red' })

# Test inter-machine connectivity
$peerIP = if ($MachineType -eq "laptop") { "192.168.1.128" } else { "192.168.1.129" }
$peerTest = Test-NetConnection -ComputerName $peerIP -InformationLevel Quiet
Write-Host "  • Peer connectivity ($peerIP): $(if ($peerTest) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($peerTest) { 'Green' } else { 'Red' })

# Test DNS resolution
$dnsTest = $null
try {
    $dnsTest = Resolve-DnsName -Name "aios.local" -ErrorAction Stop
} catch {
    # Ignore DNS resolution errors for now
}
Write-Host "  • DNS resolution (aios.local): $(if ($dnsTest) { '✅ PASS' } else { '❌ FAIL' })" -ForegroundColor $(if ($dnsTest) { 'Green' } else { 'Red' })

# Summary
Write-Host "`n📋 Configuration Summary:" -ForegroundColor Cyan
Write-Host "  • Hostname: $hostname" -ForegroundColor White
Write-Host "  • Firewall Rules: Configured for AIOS ports" -ForegroundColor White
Write-Host "  • Hosts File: Updated with AIOS entries" -ForegroundColor White
Write-Host "  • Network Tests: $(if ($localTest -and $peerTest) { '✅ PASS' } else { '⚠️ PARTIAL' })" -ForegroundColor $(if ($localTest -and $peerTest) { 'Green' } else { 'Yellow' })

if ($restartRequired -and -not $SkipRestart) {
    Write-Host "`n🔄 System restart required to apply hostname change." -ForegroundColor Yellow
    Write-Host "  • Run this command after restart: $($MyInvocation.Line)" -ForegroundColor White

    $restart = Read-Host "Restart now? (y/n)"
    if ($restart -eq 'y') {
        Restart-Computer -Force
    }
} else {
    Write-Host "`n✅ AIOS network configuration complete!" -ForegroundColor Green
    Write-Host "🌐 Next steps:" -ForegroundColor Cyan
    Write-Host "  • Deploy cell stack: .\deploy.ps1 -DeploymentType local-desktop" -ForegroundColor White
    Write-Host "  • Test connectivity: Visit http://localhost:8000/health" -ForegroundColor White
}