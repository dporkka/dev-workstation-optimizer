# Windows Optimizations

## Prerequisites

- Windows 10/11
- PowerShell 5.1 or later
- Administrator rights

## Quick Start

1. Open PowerShell **as Administrator**.
2. Set execution policy if needed:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Run the optimizer:
   ```powershell
   .\Optimize-WindowsForDev.ps1
   ```
4. To also free disk space by disabling Hibernate:
   ```powershell
   .\Optimize-WindowsForDev.ps1 -DisableHibernate
   ```
5. Compact the WSL virtual disk:
   ```powershell
   .\Compact-WslVhdx.ps1
   ```

## What It Does

| Setting | Purpose |
|---|---|
| High Performance power plan | Prevents CPU downclocking during long builds |
| Remove startup apps | Frees RAM at boot |
| Defender exclusions for WSL | Major compile-speed improvement |
| Disable Delivery Optimization | Reduces background network I/O |
| Game Mode | Prioritizes foreground apps |
| Best-performance visual effects | Slightly reduces GPU/CPU overhead |
| Storage Sense | Auto-cleans temp files |

## Safety

- Creates a System Restore point before changes (unless `-SkipRestorePoint` is used).
- Use `-WhatIf` to preview changes:
  ```powershell
  .\Optimize-WindowsForDev.ps1 -WhatIf
  ```
