> ⚠️ **Use at your own risk.** These scripts modify system settings. Read the scripts before running, back up important data, and create a restore point (Windows script does this automatically).

# Dev Workstation Optimizer

A collection of scripts and configs to optimize Windows + WSL2 (and generic Linux) for heavy software development: faster builds, better RAM usage, less background noise, and more free disk space.

## What It Optimizes

| Area | Optimization |
|---|---|
| **Windows** | High Performance power plan, remove startup apps, Defender exclusions for WSL, disable Delivery Optimization, Game Mode, visual effects, Storage Sense |
| **WSL memory** | Correctly size `.wslconfig` based on installed RAM |
| **Swap** | Fast zram + small disk swap fallback |
| **Kernel** | `vm.swappiness`, `vm.vfs_cache_pressure`, OOM behavior, dirty ratios |
| **Services** | Disable unnecessary Ubuntu cloud/snap services inside WSL |
| **VS Code** | Exclude build dirs from file watcher, limit tsserver memory, disable telemetry |
| **Git** | `fsmonitor`, `untrackedCache`, `manyFiles`, pack threads |
| **SSH** | Connection multiplexing for faster git fetch/push |
| **Docker** | BuildKit enabled, log rotation, build cache GC |
| **Package managers** | npm/pnpm concurrency and retry tuning |
| **Build tools** | `MAKEFLAGS`, `CMAKE_BUILD_PARALLEL_LEVEL`, `GOMAXPROCS` |
| **Disk** | WSL vhdx compaction helper, weekly cleanup script |

## Quick Start

### 1. Windows

Open PowerShell **as Administrator**:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\windows\Optimize-WindowsForDev.ps1
```

Then compact the WSL virtual disk:

```powershell
.\windows\Compact-WslVhdx.ps1
```

### 2. WSL / Linux

Inside WSL:

```bash
cd wsl-linux
bash optimize-wsl.sh
```

Restart WSL:

```powershell
wsl --shutdown
wsl
```

Verify:

```bash
free -h
swapon --show
zramctl
```

### 3. Weekly Maintenance

```bash
~/.local/bin/dev-cleanup
```

## Folder Layout

```
dev-workstation-optimizer/
├── windows/
│   ├── Optimize-WindowsForDev.ps1
│   ├── Compact-WslVhdx.ps1
│   └── README.md
├── wsl-linux/
│   ├── optimize-wsl.sh
│   ├── cleanup.sh
│   ├── apply-system-optimizations.sh
│   └── README.md
└── shared/
    ├── .wslconfig
    ├── vscode-settings.json
    └── ssh-config
```

## Expected Performance Impact

- **Builds**: 20–50% faster for I/O-heavy projects once Defender exclusions are active.
- **git status**: 2–5x faster in large repos.
- **git fetch/push**: ~0.2s after first connection with SSH multiplexing.
- **Memory pressure**: zram is 10–50x faster than disk swap.
- **Boot/login**: fewer startup apps and WSL services means less RAM/CPU contention.

Results depend on your workload and hardware. These scripts remove bottlenecks, not add cores.

## Safety & Reverting

- The Windows script creates a System Restore point by default.
- The WSL/Linux script backs up existing configs to `~/.dev-optimizer-backups/<timestamp>/`.
- Re-enable disabled services with `sudo systemctl enable --now <service>`.
- Restore backed-up files manually from `~/.dev-optimizer-backups/`.

## Compatibility

- **Windows**: 10/11
- **WSL**: WSL2 with Ubuntu/Debian-based distro
- **Linux**: Debian/Ubuntu derivatives (zram setup uses apt)

## License

MIT
