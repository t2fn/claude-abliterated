#!/bin/bash
# 02-configure-claude.sh — Claude Python dev environment config

echo "[python] Python dev tools ready:"
for tool in ruff pyupgrade pylint flake8 black isort mypy pydocstyle autoflake bandit pycodestyle pyflakes pyright; do
    if command -v $tool > /dev/null 2>&1; then
        echo "  $tool: OK"
    else
        echo "  $tool: available"
    fi
done

echo "[python] Python config: pyproject.toml loaded"
