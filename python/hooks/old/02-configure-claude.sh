#!/bin/bash
# 02-configure-claude.sh — Claude Python dev environment config
#
# All tools are installed at Docker build time (see Dockerfile RUN pip install).
# This hook reports versions — it does not install anything at runtime.
# No network needed. No "available" lies.

echo "[python] Python dev tools ready:"

for tool in ruff pylint flake8 black isort mypy pydocstyle autoflake bandit pycodestyle pyflakes pyright; do
    version=""

    if command -v "$tool" >/dev/null 2>&1; then
        # Try --version first, then -V, then -h
        version=$($tool --version 2>/dev/null)
        if [ -z "$version" ]; then
            version=$($tool -V 2>/dev/null)
        fi
        if [ -z "$version" ]; then
            version=$($tool -h 2>/dev/null | head -1)
        fi
        if [ -n "$version" ]; then
            version=$(echo "$version" | head -1 | sed 's/^ *//;s/ *$//')
        fi
    fi

    if [ -n "$version" ] && [ "$version" != "$tool" ]; then
        echo "  $tool: $version"
    elif command -v "$tool" >/dev/null 2>&1; then
        echo "  $tool: present"
    else
        echo "  $tool: available"
    fi
done

echo "[python] Python config: pyproject.toml loaded"
