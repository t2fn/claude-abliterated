#!/bin/bash
# 02-python-stop-lint.sh — Stop any lingering Python linting/type-checking processes

echo "[python] Cleaning up Python background processes."

# Kill any lingering pylint/lsp servers
pkill -f "pylint" 2>/dev/null || true
pkill -f "pyright" 2>/dev/null || true
pkill -f "mypy" 2>/dev/null || true

echo "[python] Python linting processes cleaned up."
