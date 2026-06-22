#!/usr/bin/env bash
# Test that optimize.sh accepts expected flags and shows help.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log() { echo "[TEST] $1"; }
fail() { echo "[FAIL] $1"; exit 1; }

log "Checking optimize.sh --help"
output=$(bash "$REPO_DIR/optimize.sh" --help)
if ! echo "$output" | grep -q "Usage:"; then
    fail "--help did not show usage"
fi

log "Checking optimize.sh --dry-run"
output=$(bash "$REPO_DIR/optimize.sh" --dry-run <<< "n")
if ! echo "$output" | grep -q "DRY RUN"; then
    fail "--dry-run did not indicate dry run mode"
fi

log "Checking optimize.sh --with-aider"
output=$(bash "$REPO_DIR/optimize.sh" --with-aider)
if ! echo "$output" | grep -q "Aider"; then
    fail "--with-aider did not print Aider context"
fi

log "optimize.sh entry tests passed"
