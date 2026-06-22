#!/usr/bin/env bash
# Cross-platform dev workstation optimizer entry point.
# Usage: bash optimize.sh [options]
#
# Options:
#   -n, --dry-run     Show what would be done without making changes
#   -y, --yes         Skip confirmation prompts
#   --with-aider      Print an Aider prompt for AI-assisted customization
#   -h, --help        Show this help message

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
SKIP_CONFIRM=false
WITH_AIDER=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${BLUE}[dev-optimizer]${NC} $1"; }
ok() { echo -e "${GREEN}[dev-optimizer]${NC} $1"; }
warn() { echo -e "${YELLOW}[dev-optimizer]${NC} $1"; }
error() { echo -e "${RED}[dev-optimizer]${NC} $1"; }

usage() {
    sed -n '/^# Usage:/,/^#.*-h/p' "$0" | sed 's/^# //' | sed 's/^#//'
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -y|--yes)
                SKIP_CONFIRM=true
                shift
                ;;
            --with-aider)
                WITH_AIDER=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

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

confirm() {
    if [[ "$SKIP_CONFIRM" == true ]]; then
        return 0
    fi
    echo -n -e "${CYAN}Proceed? [Y/n]:${NC} "
    read -r response
    case "$response" in
        [nN][oO]|[nN])
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

print_aider_prompt() {
    local platform="$1"
    cat <<EOF

${CYAN}=== Aider / AI Assistant Context ===${NC}
Copy and paste the following into Aider (or any coding agent) to get help customizing these optimizations:

---
You are helping improve the dev-workstation-optimizer project.
Current platform detected: ${platform}
Repository: https://github.com/dporkka/dev-workstation-optimizer

Please review the optimize.sh entry point and the platform-specific scripts in:
- windows/Optimize-WindowsForDev.ps1
- wsl-linux/optimize-linux.sh

Suggest improvements or add a new optimization for ${platform}. Keep changes safe,
back up existing configs, and update README.md with usage instructions.
---

EOF
}

main() {
    parse_args "$@"

    log "Detecting operating system..."
    PLATFORM="$(detect_os)"

    case "$PLATFORM" in
        wsl)
            ok "Platform detected: WSL2"
            log "This will run the WSL/Linux optimizer and can also run the Windows optimizer."
            ;;
        linux)
            ok "Platform detected: Linux (native Ubuntu/Debian)"
            log "This will run the native Linux optimizer."
            ;;
        windows)
            ok "Platform detected: Windows"
            log "This will run the Windows PowerShell optimizer."
            ;;
        macos)
            warn "Platform detected: macOS"
            log "macOS is not fully supported yet. Contributions welcome!"
            ;;
        *)
            error "Could not detect a supported operating system."
            exit 1
            ;;
    esac

    if [[ "$WITH_AIDER" == true ]]; then
        print_aider_prompt "$PLATFORM"
        exit 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log "DRY RUN mode. No changes will be made."
    fi

    echo ""
    case "$PLATFORM" in
        wsl)
            echo "Planned actions:"
            echo "  1. Run WSL/Linux optimizations (zram, sysctl, services, Git, VS Code, npm/pnpm, Docker)"
            echo "  2. Optionally run Windows optimizations (power plan, Defender exclusions, Game Mode)"
            ;;
        linux)
            echo "Planned actions:"
            echo "  1. Run native Linux optimizations (zram, sysctl, services, Git, VS Code, npm/pnpm, Docker)"
            ;;
        windows)
            echo "Planned actions:"
            echo "  1. Run Windows optimizations (power plan, startup apps, Defender exclusions, Game Mode)"
            echo "  2. Optionally compact the WSL virtual disk"
            ;;
    esac
    echo ""

    if ! confirm; then
        log "Aborted by user."
        exit 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log "Would execute the following:"
    fi

    case "$PLATFORM" in
        wsl|linux)
            if [[ "$DRY_RUN" == true ]]; then
                echo "  bash \"$SCRIPT_DIR/wsl-linux/optimize-linux.sh\""
            else
                bash "$SCRIPT_DIR/wsl-linux/optimize-linux.sh"
            fi
            ;;
        windows)
            if [[ "$DRY_RUN" == true ]]; then
                echo "  powershell -ExecutionPolicy Bypass -File \"$SCRIPT_DIR\\windows\\Optimize-WindowsForDev.ps1\""
            else
                powershell -ExecutionPolicy Bypass -File "$SCRIPT_DIR\\windows\\Optimize-WindowsForDev.ps1"
            fi
            ;;
    esac

    if [[ "$PLATFORM" == "wsl" && "$DRY_RUN" != true ]]; then
        echo ""
        log "WSL optimizations complete."
        warn "To also optimize Windows, run this from an Administrator PowerShell:"
        warn "  powershell -ExecutionPolicy Bypass -File \"$SCRIPT_DIR\\windows\\Optimize-WindowsForDev.ps1\""
    fi

    ok "Done."
}

main "$@"
