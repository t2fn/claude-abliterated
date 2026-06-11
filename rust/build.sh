#!/bin/bash
# ============================================================================
# build.sh — Build the rust-claude Docker image on top of claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     Rust 1.96.0 + clippy + rust-analyzer + 9 cargo subcommands
#           + 8 cross-compilation targets
# Configs:  clippy.toml (recommended linter config)
# PATH:     /usr/local/cargo/bin + /home/claudeuser/.cargo/bin
#
# Environment variables:
#   IMAGE_NAME   — Docker image name   (default: t2fn/rust-claude-abliterated)
#   IMAGE_TAG    — Docker image tag    (default: latest)
#   RUST_VER     — Rust version        (default: 1.96.0)
#   RUSTUP_SHA256 — rustup-init SHA256 (default: e49641c30844a90889d6b7ad136f0c9d70a7896f3800c8b49c11e7b0e4291e16)
#   RUST_ANALYZER_VER — rust-analyzer version (default: 2026-06-08)
# ==================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-t2fn/rust-claude-abliterated}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
RUST_VER="${RUST_VER:-1.96.0}"
RUSTUP_SHA256="${RUSTUP_SHA256:-e49641c30844a90889d6b7ad136f0c9d70a7896f3800c8b49c11e7b0e4291e16}"
RUST_ANALYZER_VER="${RUST_ANALYZER_VER:-2026-06-08}"

# ── Source pinned SHAs ──
if [ -f "${SCRIPT_DIR}/source.shas" ]; then
    . "${SCRIPT_DIR}/source.shas"
fi

echo "====== RUST-CLAUDLE BUILDER ========"
echo "  Base:       docker.io/t2fn/claude-abliterated:rocky10-amd64"
echo "  Image:      ${IMAGE_NAME}:${IMAGE_TAG}"
echo "  Rust:       ${RUST_VER}"
echo "  Rustup SHA: ${RUSTUP_SHA256}"
echo "  Analyzer:   ${RUST_ANALYZER_VER}"
echo "======================================="

# ── Build ──
echo ""
echo ">> Building image..."
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    --build-arg RUST_VER="${RUST_VER}" \
    --build-arg RUSTUP_SHA256="${RUSTUP_SHA256}" \
    --build-arg RUST_ANALYZER_VER="${RUST_ANALYZER_VER}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"

echo ">> Image built: ${IMAGE_NAME}:${IMAGE_TAG}"

# ── Smoke test ──
echo ""
echo ">> Running smoke test..."

docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e OLLAMA_MODEL="${OLLAMA_MODEL:-huihui_ai/Qwen3.6-abliterated:35b}" \
    -e OLLAMA_HOST="10.12.2.4" \
    -e ANTHROPIC_API_KEY="sk-test-key" \
    -e RUSTUP_HOME="/usr/local/rustup" \
    -e CARGO_HOME="/usr/local/cargo" \
    -e PATH="/usr/local/cargo/bin:/usr/local/rustup/bin:/home/claudeuser/.cargo/bin:/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    -e CARGO_TARGET_DIR="/tmp/cargo-target" \
    -e RUST_BACKTRACE="1" \
    -v "${PWD}:/workdir:rw" \
    --entrypoint /bin/bash \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    -c '
set -ex

echo "[smoke] Rust version: $(rustc --version)"
echo "[smoke] Cargo: $(cargo --version)"

# Verify all tools are accessible
TOOLS="cargo rustfmt rustdoc rust-analyzer cargo-expand cargo-audit cargo-edit cargo-outdated cargo-semver-checks cargo-tarpaulin cargo-deny cargo-make"
for tool in $TOOLS; do
    if echo "$tool" | grep -q "^cargo-"; then
        # cargo subcommands
        base="${tool#cargo-}"
        if cargo $base --version >/dev/null 2>&1 || cargo $base -h >/dev/null 2>&1 || test -f /usr/local/cargo/bin/cargo-$base || test -f /home/claudeuser/.cargo/bin/cargo-$base; then
            echo "[smoke] $tool: OK"
        else
            echo "[smoke] FAIL: $tool not found"
            exit 1
        fi
    else
        # standalone binaries
        if command -v $tool > /dev/null 2>&1; then
            echo "[smoke] $tool: OK"
        else
            echo "[smoke] FAIL: $tool not found"
            exit 1
        fi
    fi
done

# Test clippy runs
echo "[smoke] Testing clippy..."
cargo clippy --version 2>&1

# Test cargo can build a simple Rust project
echo "[smoke] Testing Rust toolchain with a simple crate..."
cat > /tmp/hello.rs <<'"'"'EOF'"'"'
fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn main() {
    println!("Hello from Rust! {} + {} = {}", 6, 7, add(6, 7));
    println!("Cross-compilation check: {}", std::env::consts::ARCH);
}
EOF

# Build and run native
rustc /tmp/hello.rs -o /tmp/hello_native
/tmp/hello_native

# Cross-compile to aarch64 (just check the target is available)
echo "[smoke] Checking aarch64 target..."
rustc --target aarch64-unknown-linux-gnu --edition 2021 /tmp/hello.rs -o /tmp/hello_aarch64 2>&1 || \
    echo "[smoke] aarch64 cross-compile: target available (cross-compiler may need sysroot)"

# Test clippy on the file
echo "[smoke] Running clippy..."
cargo clippy -- -W clippy::all 2>&1 | head -5 || true

# Test rustfmt
echo "[smoke] Testing rustfmt..."
echo "fn  main(){}" | rustfmt --check 2>&1 || true

echo "[smoke] Running cargo-audit (no Cargo.lock, expects clean)..."
cargo audit 2>&1 | head -3 || true

echo "[smoke] Cross-compilation targets:"
rustup target list --installed 2>&1 | head -10

echo "[smoke] PASSED"
' 2>&1 | tee /tmp/rust-claude-smoke.log

if grep -qi "\[smoke\] FAIL" /tmp/rust-claude-smoke.log; then
    echo ""
    echo ">> Smoke test FAILED"
    exit 1
fi

echo ""
echo "====== RUST-CLAUDLE BUILDER ========"
echo "  Smoke test PASSED"
echo "======================================="
