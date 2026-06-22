# Agent Instructions for dev-workstation-optimizer

## Project Purpose

This repository provides cross-platform scripts to optimize Windows, WSL2, and native Ubuntu/Debian workstations for heavy software development.

## Repository Layout

```
dev-workstation-optimizer/
├── optimize.sh                  # Cross-platform entry point (auto-detects OS)
├── windows/
│   ├── Optimize-WindowsForDev.ps1
│   ├── Compact-WslVhdx.ps1
│   └── README.md
├── wsl-linux/
│   ├── optimize-linux.sh        # Supports WSL2 and native Ubuntu/Debian
│   ├── optimize-wsl.sh          # Symlink to optimize-linux.sh (backward compat)
│   ├── cleanup.sh
│   ├── apply-system-optimizations.sh
│   └── README.md
└── shared/
    ├── .wslconfig
    ├── vscode-settings.json
    └── ssh-config
```

## Design Principles

1. **Safety first.** Always back up existing configs before modifying them. The Windows script creates a System Restore point.
2. **Idempotent.** Scripts should be safe to run multiple times.
3. **Cross-platform.** Use `optimize.sh` for OS detection; avoid hard-coding Windows or Linux assumptions in the entry script.
4. **No hidden changes.** Show users what will change; require confirmation unless `--yes` is passed.
5. **No hard dependencies.** Aider integration is optional. Don't require users to install Aider.

## Adding a New Optimization

1. Determine the target platform: Windows, WSL/Linux, or both.
2. Place the change in the appropriate script:
   - Windows-only → `windows/Optimize-WindowsForDev.ps1`
   - Linux/WSL → `wsl-linux/optimize-linux.sh`
   - Shared config → `shared/`
3. Back up any file you modify.
4. Update `README.md` with the new feature and usage.
5. Update this file if the change affects agent behavior.

## Testing Checklist

- [ ] Script runs without errors on the target platform.
- [ ] `--dry-run` correctly previews changes without applying them.
- [ ] Backups are created before modifications.
- [ ] README is updated.
- [ ] No secrets or personal data are hard-coded.

## Common Commands

```bash
# Run the optimizer with OS auto-detection
bash optimize.sh

# Dry run
bash optimize.sh --dry-run

# Skip confirmations
bash optimize.sh --yes

# Get an Aider-ready context prompt
bash optimize.sh --with-aider
```
