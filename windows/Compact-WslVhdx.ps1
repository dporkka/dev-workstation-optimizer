#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Compact the WSL2 ext4.vhdx virtual disk to reclaim space on C:\.

.DESCRIPTION
    Shuts down WSL, finds the ext4.vhdx file, attaches it read-only,
    compacts it with diskpart, then restarts WSL.

.EXAMPLE
    .\Compact-WslVhdx.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

Write-Section "Shutting down WSL"
try {
    wsl --shutdown
    Write-Ok "WSL shut down"
}
catch {
    Write-Warn "Could not shut down WSL: $_"
}

Write-Section "Locating WSL ext4.vhdx"
$vhdx = Get-ChildItem -Path "$env:LOCALAPPDATA\wsl" -Filter "ext4.vhdx" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $vhdx) {
    Write-Warn "Could not find ext4.vhdx in $env:LOCALAPPDATA\wsl"
    exit 1
}

$beforeSize = [math]::Round($vhdx.Length / 1GB, 2)
Write-Ok "Found VHDX: $($vhdx.FullName) ($beforeSize GB)"

Write-Section "Compacting VHDX (this may take a few minutes)"
$diskpartScript = @"
select vdisk file="$($vhdx.FullName)"
attach vdisk readonly
compact vdisk
detach vdisk
exit
"@

try {
    $diskpartScript | diskpart | ForEach-Object { Write-Host $_ }
    Write-Ok "Compaction complete"
}
catch {
    Write-Warn "Compaction may have failed: $_"
}

$vhdx.Refresh()
$afterSize = [math]::Round($vhdx.Length / 1GB, 2)
$freed = $beforeSize - $afterSize
Write-Ok "VHDX size: $beforeSize GB -> $afterSize GB (freed ~$freed GB)"

Write-Section "Restarting WSL"
try {
    wsl
    Write-Ok "WSL restarted"
}
catch {
    Write-Warn "Could not restart WSL: $_"
}

Write-Section "Done"
