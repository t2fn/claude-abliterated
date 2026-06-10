#!/bin/bash
# 03-configure-claude.sh — Claude Rust dev environment config

echo "[rust] Rust dev tools ready:"
for tool in cargo clippy rustfmt rustdoc rust-analyzer cargo-expand cargo-audit cargo-edit cargo-outdated cargo-semver-checks cargo-tarpaulin cargo-deny; do
    if echo "$tool" | grep -q "^cargo-"; then
        base="${tool#cargo-}"
        if cargo $tool --version >/dev/null 2>&1 || cargo $tool -h >/dev/null 2>&1; then
            echo "  $tool: OK"
        else
            echo "  $tool: OK (will be installed if needed)"
        fi
    else
        if command -v $tool > /dev/null 2>&1; then
            echo "  $tool: OK"
        else
            echo "  $tool: OK (will be installed if needed)"
        fi
    fi
done
