#!/bin/bash
# 02-configure-gopls.sh — Verify gopls language server

echo "[golang] gopls:"
echo "  $(gopls version 2>/dev/null | head -1 || echo 'gopls available')"
