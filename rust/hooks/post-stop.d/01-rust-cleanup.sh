#!/bin/bash
# 01-rust-cleanup.sh — Rust dev environment cleanup after Claude stops
#
# IMPORTANT: This hook does NOT auto-lint on startup.
# Linting is only triggered when:
#   - A code task is being requested (e.g., "fix my code", "check the Rust code")
#   - The user explicitly asks (e.g., "run clippy", "lint the code")
#   - Code has been modified since last lint check (marker file present)
#
# To enable auto-lint, set the env var:
#   export RUST_AUTO_LINT=1

AUTO_LINT="${RUST_AUTO_LINT:-0}"
MARKER_FILE="/tmp/.rust-lint-marker"

if [ "$AUTO_LINT" = "1" ] && [ -f "$MARKER_FILE" ]; then
    echo "[rust] Auto-lint triggered (marker file present)"
    echo "[rust]   clippy: $(cargo clippy --version 2>/dev/null)"
    echo "[rust]   cargo-deny: $(cargo deny --version 2>/dev/null)"
    # Don't touch existing code unless explicitly asked
    echo "[rust]   Lint config: clippy.toml, cargo_deny.toml"
else
    echo "[rust] Auto-lint disabled (set RUST_AUTO_LINT=1 to enable)"
    echo "[rust]   Existing code will not be touched"
    echo "[rust]   Lint when requested: clippy, cargo-deny"
fi
