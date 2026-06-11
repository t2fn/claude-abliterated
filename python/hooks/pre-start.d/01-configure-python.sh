#!/bin/bash
# 01-configure-python.sh — Configure Python environment before Claude starts
# Sourced in order before Claude starts

echo "[python] Python environment:"
echo "  Python: $(python3 --version 2>/dev/null || echo 'available')"
echo "  pip:    $(pip3 --version 2>/dev/null || echo 'available')"
echo "  Python path: $(which python3 2>/dev/null)"

# Tool availability and version check (all tools are installed at Docker build time)
for tool in ruff pylint flake8 black mypy bandit; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool --version 2>/dev/null || $tool -V 2>/dev/null || $tool -h 2>/dev/null | head -1)
        if [ -n "$version" ] && [ "$version" != "$tool" ]; then
            version=$(echo "$version" | head -1 | sed 's/^ *//;s/ *$//')
            echo "  $tool: $version"
        else
            echo "  $tool: present"
        fi
    else
        echo "  $tool: available"
    fi
done
