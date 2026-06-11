#!/bin/bash
# 03-configure-linting.sh — Report linting tool versions (no auto-lint)
#
# Reports version numbers for all Python linting tools.
# Does NOT touch or modify any files — just reporting status.
# The actual linting is done on demand when Claude is tasked with it.
#
# Sourced in order after 01-configure-python.sh and 02-configure-claude.sh

echo "[python] Python linting versions:"

for tool in ruff pylint flake8 black mypy bandit pycodestyle pyflakes pydocstyle autoflake pyright; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool --version 2>/dev/null)
        if [ -z "$version" ]; then
            version=$($tool -V 2>/dev/null)
        fi
        if [ -z "$version" ]; then
            version=$($tool -h 2>/dev/null | head -1)
        fi
        if [ -n "$version" ]; then
            version=$(echo "$version" | head -1 | sed 's/^ *//;s/ *$//')
            echo "  $tool: $version"
        else
            echo "  $tool: present"
        fi
    else
        echo "  $tool: not found"
    fi
done

echo ""
echo "[python] Linting tools ready — linting will be done on demand when tasks request it."
