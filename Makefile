.PHONY: help test lint format install clean check-shell check-powershell

SHELL := /bin/bash
BASH_SCRIPTS := $(shell find wsl-linux -name '*.sh') optimize.sh
PS_SCRIPTS := $(shell find windows -name '*.ps1')

help:
	@echo "Dev Workstation Optimizer"
	@echo ""
	@echo "Available targets:"
	@echo "  make test            Run all tests"
	@echo "  make lint            Run linters on scripts"
	@echo "  make format          Format shell scripts with shfmt (if installed)"
	@echo "  make install         Symlink scripts to ~/.local/bin"
	@echo "  make clean           Remove generated files"
	@echo "  make check-shell     Syntax-check bash scripts"
	@echo "  make check-powershell Lint PowerShell scripts with PSScriptAnalyzer (if installed)"

# --- Testing ---

test: check-shell
	@echo "Running tests..."
	@bash tests/test-optimize-entry.sh
	@bash tests/test-os-detection.sh
	@echo "All tests passed."

check-shell:
	@echo "Syntax-checking bash scripts..."
	@for script in $(BASH_SCRIPTS); do \
		bash -n "$$script" || exit 1; \
		echo "  OK: $$script"; \
	done
	@echo "All bash scripts passed syntax check."

check-powershell:
	@echo "Linting PowerShell scripts..."
	@for script in $(PS_SCRIPTS); do \
		pwsh -Command "Invoke-ScriptAnalyzer -Path '$$script' -Severity Warning" || true; \
	done

# --- Linting / Formatting ---

lint: check-shell
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(BASH_SCRIPTS); \
	else \
		echo "shellcheck not installed. Install with: sudo apt install shellcheck"; \
		exit 1; \
	fi

format:
	@echo "Formatting shell scripts..."
	@if command -v shfmt >/dev/null 2>&1; then \
		shfmt -w -i 2 -ci $(BASH_SCRIPTS); \
	else \
		echo "shfmt not installed. Install from https://github.com/mvdan/sh"; \
		exit 1; \
	fi

# --- Installation ---

install:
	@echo "Installing scripts to ~/.local/bin..."
	@mkdir -p ~/.local/bin
	@ln -sf "$(PWD)/optimize.sh" ~/.local/bin/dev-optimizer
	@ln -sf "$(PWD)/wsl-linux/cleanup.sh" ~/.local/bin/dev-cleanup
	@echo "Installed:"
	@echo "  dev-optimizer  -> $(PWD)/optimize.sh"
	@echo "  dev-cleanup    -> $(PWD)/wsl-linux/cleanup.sh"
	@echo "Make sure ~/.local/bin is in your PATH."

# --- Cleanup ---

clean:
	@echo "Removing generated files..."
	@find . -name '*.tmp' -delete
	@find . -name '*.log' -delete
	@echo "Done."
