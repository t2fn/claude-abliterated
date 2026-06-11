#!/bin/bash
# 02-rust-stop-servers.sh — Stop any lingering rust-analyzer/clippy servers
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

if [ "$AUTO_LINT" = "1" ]; then
    echo "[rust] Stopping rust-analyzer and clippy servers"
    # Stop rust-analyzer server (if running)
    pkill -f "rust-analyzer" 2>/dev/null || true
    # Stop clippy drivers (if any)
    pkill -f "clippy" 2>/dev/null || true
    echo "[rust] Servers stopped."
else
    echo "[rust] Lint servers left running (RUST_AUTO_LINT=0)"
    echo "[rust]   rust-analyzer: running (or stopped manually)"
    echo "[rust]   clippy: running (or stopped manually)"
    echo "[rust]   Code will not be modified unless requested"
fi
