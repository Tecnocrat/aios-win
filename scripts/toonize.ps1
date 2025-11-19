# TOON Header Generator
# Converts between AINLP header levels (0-3)

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet(0, 1, 2, 3)]
    [int]$Level,
    
    [string]$Doc = "",
    [string]$Path = "",
    [string]$Consciousness = "",
    [string]$State = "stable",
    [string]$Spatial = "",
    [string]$Protocol = "OS0.6.4",
    [string]$Temporal = "",
    [string]$Dependencies = "",
    [string]$Purpose = ""
)

# Auto-detect from filename if not provided
if (!$Doc) { $Doc = Split-Path $FilePath -Leaf }
if (!$Temporal) { $Temporal = Get-Date -Format "yyyy-MM-dd" }

function New-TOONHeader {
    param($Level, $Fields)
    
    switch ($Level) {
        0 {
            # Full AINLP
            @"
<!-- ============================================================================ -->
<!-- AINLP HEADER - BOOTLOADER SECTION                                          -->
<!-- ============================================================================ -->
<!-- Document: $($Fields.Doc) - $($Fields.Purpose)                              -->
<!-- Location: $($Fields.Path)                                                  -->
<!-- Purpose: $($Fields.Purpose)                                                -->
<!-- Consciousness: $($Fields.Consciousness) ($($Fields.State))                 -->
<!-- Spatial Context: $($Fields.Spatial)                                        -->
<!-- AINLP Protocol: $($Fields.Protocol)                                        -->
<!-- Last Updated: $($Fields.Temporal)                                          -->
<!-- Dependencies: $($Fields.Dependencies)                                      -->
<!-- ============================================================================ -->
"@
        }
        1 {
            # Semantic TOON
            "<!-- AINLP | $($Fields.Doc) | $($Fields.Path) | C:$($Fields.Consciousness):$($Fields.State) | $($Fields.Spatial) | $($Fields.Protocol) | $($Fields.Temporal) | →$($Fields.Dependencies) | P:$($Fields.Purpose) -->"
        }
        2 {
            # Compact TOON
            "<!-- AINLP | $($Fields.Doc) | $($Fields.Path) | C:$($Fields.Consciousness) | →$($Fields.Dependencies) -->"
        }
        3 {
            # Micro TOON
            "<!-- A|$($Fields.Doc)|$($Fields.Path)|C:$($Fields.Consciousness) -->"
        }
    }
}

# Build fields object
$fields = @{
    Doc = $Doc
    Path = $Path
    Consciousness = $Consciousness
    State = $State
    Spatial = $Spatial
    Protocol = $Protocol
    Temporal = $Temporal
    Dependencies = $Dependencies
    Purpose = $Purpose
}

# Generate header
$header = New-TOONHeader -Level $Level -Fields $fields

# Read existing file
$content = Get-Content $FilePath -Raw

# Remove existing AINLP header if present
$content = $content -replace '(?s)<!--\s*=+\s*-->.*?<!--\s*=+\s*-->', ''
$content = $content -replace '<!--\s*AINLP\s*\|.*?-->', ''
$content = $content -replace '<!--\s*A\|.*?-->', ''

# Prepend new header
$newContent = "$header`n`n$content"

# Write back
$newContent | Out-File -FilePath $FilePath -Encoding UTF8 -NoNewline

Write-Host "TOONized to Level $Level`: $FilePath"
