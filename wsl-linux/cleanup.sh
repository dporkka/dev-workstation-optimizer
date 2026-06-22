#!/usr/bin/env bash
# Weekly dev cleanup script
set -euo pipefail

echo "== Dev cleanup starting =="

# Package manager caches
echo "Pruning pnpm store..."
pnpm store prune 2>/dev/null || true

echo "Cleaning npm cache..."
npm cache clean --force 2>/dev/null || true

# Docker
echo "Pruning Docker build cache..."
docker builder prune -f 2>/dev/null || true
docker system prune -f 2>/dev/null || true

# Journal
echo "Vacuuming journal..."
journalctl --vacuum-time=7d 2>/dev/null || true

# Old temp files
echo "Cleaning old /tmp files..."
find /tmp -type f -atime +3 -delete 2>/dev/null || true
find /tmp -type d -empty -delete 2>/dev/null || true

# Old log files in home
find "$HOME" -maxdepth 2 -name "*.log" -type f -atime +7 -delete 2>/dev/null || true

echo "== Dev cleanup complete =="
