#!/usr/bin/env bash
# Apply low-level system optimizations (zram + sysctl + services)
# Intended to be called by optimize-wsl.sh, but can be run standalone.
set -euo pipefail

echo "=== Applying WSL system optimizations ==="

# Install zram-tools if not present
if ! command -v zramswap &>/dev/null; then
    echo "Installing zram-tools..."
    sudo apt-get update
    sudo apt-get install -y zram-tools
fi

# Configure zram
if [ -f /etc/default/zramswap ]; then
    echo "Configuring zram..."
    sudo sed -i 's/^#*ALGO=.*/ALGO=lzo-rle/' /etc/default/zramswap
    sudo sed -i 's/^#*PERCENT=.*/PERCENT=25/' /etc/default/zramswap
    sudo sed -i 's/^#*PRIORITY=.*/PRIORITY=100/' /etc/default/zramswap

    grep -q '^ALGO=' /etc/default/zramswap || echo 'ALGO=lzo-rle' | sudo tee -a /etc/default/zramswap
    grep -q '^PERCENT=' /etc/default/zramswap || echo 'PERCENT=25' | sudo tee -a /etc/default/zramswap
    grep -q '^PRIORITY=' /etc/default/zramswap || echo 'PRIORITY=100' | sudo tee -a /etc/default/zramswap
fi

# Kernel memory tuning
echo "Creating sysctl config..."
cat <<'SYSCONF' | sudo tee /etc/sysctl.d/99-wsl-dev.conf
# WSL development optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.oom_kill_allocating_task=1
vm.dirty_ratio=15
vm.dirty_background_ratio=5
SYSCONF

echo "Applying sysctl..."
sudo sysctl --system

# Start/enable zram
echo "Starting zramswap..."
sudo systemctl enable zramswap
sudo systemctl restart zramswap

# Disable unnecessary WSL services
echo "Disabling unnecessary services..."
for svc in apparmor snapd landscape-client apport; do
    if systemctl is-enabled "$svc" &>/dev/null || systemctl is-active "$svc" &>/dev/null; then
        echo "Disabling $svc..."
        sudo systemctl disable --now "$svc" || true
    fi
done

echo "=== Done ==="
echo "Verify with: zramctl, free -h, swapon -s, sysctl vm.vfs_cache_pressure"
