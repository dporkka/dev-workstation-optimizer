#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Optimize Windows for heavy software development workflows.

.DESCRIPTION
    Applies performance-focused settings for Windows + WSL2 development:
    - High Performance power plan
    - Remove unnecessary startup apps
    - Windows Defender exclusions for WSL
    - Disable Delivery Optimization
    - Enable Game Mode
    - Best-performance visual effects
    - Enable Storage Sense
    - Optionally disable Hibernate

.PARAMETER DisableHibernate
    Disable Hibernate to free disk space equal to installed RAM.

.PARAMETER SkipRestorePoint
    Skip creating a System Restore point.

.EXAMPLE
    .\Optimize-WindowsForDev.ps1

.EXAMPLE
    .\Optimize-WindowsForDev.ps1 -DisableHibernate
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$DisableHibernate,
    [switch]$SkipRestorePoint
)

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

# --- System Restore Point ---
if (-not $SkipRestorePoint) {
    Write-Section "Creating System Restore Point"
    try {
        Checkpoint-Computer -Description "DevWorkstationOptimizer" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Ok "System restore point created"
    }
    catch {
        Write-Warn "Could not create restore point: $_"
    }
}

# --- Power Plan ---
Write-Section "Setting High Performance Power Plan"
try {
    $highPerf = powercfg /list | Select-String "High performance" | ForEach-Object { $_.Line.Split()[3] }
    if ($highPerf) {
        powercfg /setactive $highPerf
        Write-Ok "Power plan set to High Performance"
    }
    else {
        Write-Warn "High Performance power plan not found"
    }
}
catch {
    Write-Warn "Could not set power plan: $_"
}

# --- Startup Apps ---
Write-Section "Removing Unnecessary Startup Apps"
$startupApps = @(
    "OneDrive",
    "BraveSoftware Update",
    "GoogleDriveFS",
    "MicrosoftEdgeAutoLaunch*",
    "fifine Control Deck"
)
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$props = Get-ItemProperty -Path $runKey -ErrorAction SilentlyContinue
foreach ($pattern in $startupApps) {
    $matches = $props.PSObject.Properties | Where-Object { $_.Name -like $pattern }
    foreach ($match in $matches) {
        if ($PSCmdlet.ShouldProcess($match.Name, "Remove startup app")) {
            Remove-ItemProperty -Path $runKey -Name $match.Name -ErrorAction SilentlyContinue
            Write-Ok "Removed startup app: $($match.Name)"
        }
    }
}

# --- Windows Defender Exclusions for WSL ---
Write-Section "Adding Windows Defender Exclusions for WSL"
$exclusions = @(
    "$env:LOCALAPPDATA\wsl",
    "\\wsl$",
    "C:\wsl-swap"
)
foreach ($path in $exclusions) {
    try {
        Add-MpPreference -ExclusionPath $path -ErrorAction Stop
        Write-Ok "Added Defender exclusion: $path"
    }
    catch {
        Write-Warn "Could not add Defender exclusion for $path`: $_"
    }
}

# --- Delivery Optimization ---
Write-Section "Disabling Windows Delivery Optimization"
try {
    $doPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
    if (-not (Test-Path $doPath)) {
        New-Item -Path $doPath -Force | Out-Null
    }
    New-ItemProperty -Path $doPath -Name "DODownloadMode" -Value 0 -PropertyType DWord -Force | Out-Null
    Write-Ok "Delivery Optimization disabled"
}
catch {
    Write-Warn "Could not disable Delivery Optimization: $_"
}

# --- Game Mode ---
Write-Section "Enabling Game Mode"
try {
    $gameBarPath = "HKCU:\Software\Microsoft\GameBar"
    if (-not (Test-Path $gameBarPath)) {
        New-Item -Path $gameBarPath -Force | Out-Null
    }
    New-ItemProperty -Path $gameBarPath -Name "AllowAutoGameMode" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $gameBarPath -Name "AutoGameModeEnabled" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Ok "Game Mode enabled"
}
catch {
    Write-Warn "Could not enable Game Mode: $_"
}

# --- Visual Effects ---
Write-Section "Setting Visual Effects to Best Performance"
try {
    $visualEffectsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $visualEffectsPath)) {
        New-Item -Path $visualEffectsPath -Force | Out-Null
    }
    New-ItemProperty -Path $visualEffectsPath -Name "VisualFXSetting" -Value 2 -PropertyType DWord -Force | Out-Null
    Write-Ok "Visual effects set to best performance"
}
catch {
    Write-Warn "Could not set visual effects: $_"
}

# --- Storage Sense ---
Write-Section "Enabling Storage Sense"
try {
    $storageSensePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
    if (-not (Test-Path $storageSensePath)) {
        New-Item -Path $storageSensePath -Force | Out-Null
    }
    New-ItemProperty -Path $storageSensePath -Name "01" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $storageSensePath -Name "04" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $storageSensePath -Name "08" -Value 7 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $storageSensePath -Name "32" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $storageSensePath -Name "256" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $storageSensePath -Name "512" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Ok "Storage Sense enabled"
}
catch {
    Write-Warn "Could not enable Storage Sense: $_"
}

# --- Hibernate ---
if ($DisableHibernate) {
    Write-Section "Disabling Hibernate"
    try {
        powercfg /hibernate off
        Write-Ok "Hibernate disabled"
    }
    catch {
        Write-Warn "Could not disable Hibernate: $_"
    }
}

Write-Section "Optimization Complete"
Write-Host "Restart Windows Terminal/VS Code for full effect." -ForegroundColor Green
Write-Host "Run Compact-WslVhdx.ps1 next to reclaim WSL disk space." -ForegroundColor Green
