# WSL2 / Linux Optimizations

## Prerequisites

- WSL2 with Ubuntu/Debian-based distro, or a Debian/Ubuntu system
- `sudo` access
- Internet connection (to install `zram-tools` if missing)

## Quick Start

1. Clone or download this repo into WSL.
2. Run the optimizer:
   ```bash
   cd wsl-linux
   bash optimize-wsl.sh
   ```
3. Restart WSL:
   ```powershell
   wsl --shutdown
   wsl
   ```
4. Verify:
   ```bash
   free -h
   swapon --show
   zramctl
   ```

## What It Does

| Setting | Purpose |
|---|---|
| zram | Compressed in-memory swap, faster than disk swap |
| `vm.swappiness=10` | Reduce swap tendency |
| `vm.vfs_cache_pressure=50` | Keep directory/inode caches longer |
| `vm.oom_kill_allocating_task=1` | Prevent system lockups from runaway builds |
| `.wslconfig` tuning | Correct RAM/processor allocation, no disk swap bloat |
| VS Code Server settings | Exclude build dirs from file watcher, limit tsserver memory |
| Git fsmonitor/untrackedCache | Faster `git status` in large repos |
| SSH multiplexing | Reuse SSH connections for git fetch/push |
| npm/pnpm concurrency | Faster package installs |
| Docker BuildKit | Faster Docker builds with cache mounts |
| Parallel build env vars | Use all CPU cores for make/cmake/go |
| Disable unused services | Faster WSL boot, less background CPU/RAM |

## Weekly Maintenance

```bash
~/.local/bin/dev-cleanup
```

## Reverting

Backups are saved to `~/.dev-optimizer-backups/<timestamp>/`. To restore a file:

```bash
cp ~/.dev-optimizer-backups/<timestamp>/.wslconfig /mnt/c/Users/$USER/.wslconfig
```

To re-enable a disabled service:

```bash
sudo systemctl enable --now <service-name>
```
