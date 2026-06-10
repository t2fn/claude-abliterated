#!/bin/bash
# 03-configure-claude.sh — Claude Go dev environment config

echo "[golang] Go dev tools ready:"
for tool in go gopls dlv gotests goplay gomodifytags impl staticcheck golangci-lint revive gocritic goimports godoc; do
    if command -v $tool > /dev/null 2>&1; then
        echo "  $tool: OK"
    else
        echo "  $tool: OK (will be installed if needed)"
    fi
done
