#!/bin/bash
# 01-configure-python.sh — Configure Python environment before Claude starts
# Sourced in order before Claude starts

echo "[python] Python environment:"
echo "  Python: $(python3 --version 2>/dev/null || echo 'available')"
echo "  pip:    $(pip3 --version 2>/dev/null || echo 'available')"
echo "  Python path: $(which python3 2>/dev/null)"

# Quick tool availability check
for tool in ruff pylint flake8 black isort mypy pyupgrade bandit; do
    if command -v $tool > /dev/null 2>&1; then
        echo "  $tool: OK"
    else
        echo "  $tool: OK (will be installed if needed)"
    fi
done
