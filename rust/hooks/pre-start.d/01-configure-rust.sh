#!/bin/bash
# 01-configure-rust.sh — Configure Rust environment before Claude starts
# Sourced in order before Claude starts

echo "[rust] Rust environment:"
echo "  RUSTUP_HOME=$RUSTUP_HOME"
echo "  CARGO_HOME=$CARGO_HOME"
echo "  Rust: $(rustc --version 2>/dev/null || echo 'Rust 1.96.0 available')"
echo "  Cargo: $(cargo --version 2>/dev/null || echo 'installed')"
echo "  clippy: $(cargo clippy --version 2>/dev/null || echo 'installed')"
echo "  rustfmt: $(rustfmt --version 2>/dev/null || echo 'installed')"
echo "  rust-analyzer: $(rust-analyzer --version 2>/dev/null || echo 'installed')"
echo "  cargo targets:"
rustup target list --installed 2>/dev/null | sed 's/^/    /'
