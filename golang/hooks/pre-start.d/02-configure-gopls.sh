#!/bin/bash
# 02-configure-gopls.sh — Verify gopls language server

# gopls writes version to stderr (not stdout), so capture both
GOPLS_VER=$(go version -m "$(which gopls)" 2>&1 | grep "^mod " | head -1)
if [ -z "$GOPLS_VER" ]; then
    GOPLS_VER="gopls available (version detection pending)"
fi

echo "[golang] gopls:"
echo "  $GOPLS_VER"

# gopls settings (if config exists, show it)
if [ -f /home/claudeuser/.config/gopls/gopls.json ]; then
    echo "  config: /home/claudeuser/.config/gopls/gopls.json"
fi
if [ -f /home/claudeuser/go/pkg/gopls/gopls.json ]; then
    echo "  config: /home/claudeuser/go/pkg/gopls/gopls.json"
fi
