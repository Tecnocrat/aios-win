#Requires -RunAsAdministrator
<#
.SYNOPSIS
    AIOS Supercell - TLS Certificate Generator
.DESCRIPTION
    Generates self-signed certificates for .lan domains
.NOTES
    Run as Administrator
#>

$ErrorActionPreference = "Stop"

# Configuration
$CertDir = "C:\Users\jesus\server\stacks\ingress\certs"
$Domain = "*.lan"
$ValidityDays = 3650  # 10 years

Write-Host "=== AIOS TLS Certificate Generator ===" -ForegroundColor Cyan
Write-Host "Generating self-signed certificate for: $Domain`n" -ForegroundColor White

# Create certs directory
New-Item -ItemType Directory -Force -Path $CertDir | Out-Null

# Certificate paths
$certPath = "$CertDir\lan.crt"
$keyPath = "$CertDir\lan.key"
$pfxPath = "$CertDir\lan.pfx"

# Check if OpenSSL is available
$openssl = Get-Command openssl -ErrorAction SilentlyContinue

if (-not $openssl) {
    Write-Host "OpenSSL not found. Using PowerShell certificate generation..." -ForegroundColor Yellow
    
    # Generate certificate using PowerShell
    $cert = New-SelfSignedCertificate `
        -Subject "CN=$Domain" `
        -DnsName $Domain, "localhost", "*.lan" `
        -KeyAlgorithm RSA `
        -KeyLength 4096 `
        -NotAfter (Get-Date).AddDays($ValidityDays) `
        -CertStoreLocation "Cert:\LocalMachine\My" `
        -KeyExportPolicy Exportable `
        -KeyUsage KeyEncipherment, DigitalSignature `
        -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1")
    
    # Export to PFX
    $password = ConvertTo-SecureString -String "aios-supercell" -Force -AsPlainText
    Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $password | Out-Null
    
    # Export to PEM format
    $certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
    Set-Content -Path $certPath -Value "-----BEGIN CERTIFICATE-----" -Encoding ASCII
    Add-Content -Path $certPath -Value ([Convert]::ToBase64String($certBytes, [System.Base64FormattingOptions]::InsertLineBreaks)) -Encoding ASCII
    Add-Content -Path $certPath -Value "-----END CERTIFICATE-----" -Encoding ASCII
    
    Write-Host "✓ Certificate generated using PowerShell" -ForegroundColor Green
    Write-Host "  Note: Private key export requires OpenSSL for full PEM format" -ForegroundColor Yellow
    
} else {
    Write-Host "Using OpenSSL for certificate generation..." -ForegroundColor Green
    
    # Create OpenSSL config
    $configPath = "$CertDir\openssl.cnf"
    $configContent = @"
[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_ca

[dn]
C = US
ST = Core
L = AIOS
O = AIOS Supercell
CN = $Domain

[v3_ca]
subjectAltName = @alt_names
basicConstraints = CA:TRUE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = localhost
DNS.2 = *.lan
DNS.3 = grafana.lan
DNS.4 = prometheus.lan
DNS.5 = vault.lan
DNS.6 = traefik.lan
DNS.7 = loki.lan
DNS.8 = whoami.lan
"@
    
    Set-Content -Path $configPath -Value $configContent
    
    # Generate key and certificate
    & openssl req -x509 -nodes -days $ValidityDays -newkey rsa:4096 `
        -keyout $keyPath -out $certPath -config $configPath
    
    Remove-Item $configPath
    
    Write-Host "✓ Certificate generated with OpenSSL" -ForegroundColor Green
}

Write-Host "`nCertificate Details:" -ForegroundColor Cyan
Write-Host "  Certificate: $certPath" -ForegroundColor White
Write-Host "  Private Key: $keyPath" -ForegroundColor White
Write-Host "  Domain:      $Domain" -ForegroundColor White
Write-Host "  Validity:    $ValidityDays days" -ForegroundColor White

Write-Host "`nTo trust this certificate:" -ForegroundColor Yellow
Write-Host "  1. Import $certPath into 'Trusted Root Certification Authorities'" -ForegroundColor Gray
Write-Host "  2. Run: Import-Certificate -FilePath '$certPath' -CertStoreLocation Cert:\LocalMachine\Root" -ForegroundColor Gray

Write-Host "`nFor acme.json (Let's Encrypt):" -ForegroundColor Yellow
Write-Host "  Create empty file with restricted permissions" -ForegroundColor Gray
$acmePath = "C:\Users\jesus\server\stacks\ingress\acme.json"
New-Item -ItemType File -Path $acmePath -Force | Out-Null
$acl = Get-Acl $acmePath
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
$acl.SetAccessRule($rule)
Set-Acl -Path $acmePath -AclObject $acl
Write-Host "  Created: $acmePath" -ForegroundColor Green
