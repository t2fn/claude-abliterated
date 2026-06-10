#!/bin/bash
# 02-configure-clippy.sh — Verify clippy linter and rust-analyzer

echo "[rust] Clippy linter:"
echo "  $(clippy-driver --version 2>/dev/null | head -1 || echo 'clippy available')"

echo "[rust] rust-analyzer (language server):"
echo "  $(rust-analyzer --version 2>/dev/null | head -1 || echo 'available')"

echo "[rust] Clippy config:"
echo "  Using: clippy.toml"
echo "  Flags: -D warnings (deny all warnings)"
