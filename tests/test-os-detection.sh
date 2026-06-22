#!/usr/bin/env bash
# Test OS detection logic inside optimize.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log() { echo "[TEST] $1"; }
fail() { echo "[FAIL] $1"; exit 1; }

# Source the detect_os function from optimize.sh
# Extract function definition and run it
detect_os() {
    local uname_out
    uname_out="$(uname -s)"

    case "$uname_out" in
        Linux*)
            if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        Darwin*)
            echo "macos"
            ;;
        CYGWIN*|MINGW*|MSYS*|Windows_NT)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

log "Detecting current OS"
current=$(detect_os)
if [[ -z "$current" || "$current" == "unknown" ]]; then
    fail "Could not detect current OS"
fi
log "Current OS detected as: $current"

log "Verifying optimize.sh detects the same OS"
output=$(bash "$REPO_DIR/optimize.sh" --dry-run <<< "n")
if ! echo "$output" | grep -qi "Platform detected: $current"; then
    fail "optimize.sh did not detect expected platform: $current"
fi

log "OS detection tests passed"
