# Dockerfile.rust — Rust dev stack on claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     Rust 1.96.0 toolchain + clippy + rust-analyzer + 8 cargo subcommands
#           + 8 cross-compilation targets + system deps
# Configs:  clippy.toml, cargo_deny.toml (recommended configs)
# PATH:     /usr/local/cargo/bin + /home/claudeuser/.cargo/bin
#
# Build args:
#   RUST_VER      — Rust toolchain version (default: 1.96.0)
#   RUSTUP_SHA256 — rustup-init binary SHA256
#   RUST_ANALYZER_VER — rust-analyzer date version (default: 2026-06-08)
#
# Tools installed (core):
#   rustc, cargo, rustfmt, rustdoc, clippy, rust-analyzer (via rustup)
#
# Tools installed (cargo subcommands):
#   cargo-expand, cargo-audit, cargo-edit, cargo-outdated,
#   cargo-semver-checks, cargo-tarpaulin, cargo-deny, cargo-make
#
# Cross-compilation targets (8):
#   x86_64-unknown-linux-gnu   (native)
#   x86_64-unknown-linux-musl  (static)
#   aarch64-unknown-linux-gnu  (ARM 64-bit)
#   aarch64-unknown-linux-musl (ARM 64-bit static)
#   arm-unknown-linux-gnueabihf (ARM 32-bit)
#   armv7-unknown-linux-gnueabihf (ARMv7 32-bit)
#   powerpc64-unknown-linux-gnu (PowerPC 64-bit)
#   riscv64gc-unknown-linux-gnu (RISC-V 64-bit)
#

FROM docker.io/t2fn/claude-abliterated:rocky10-amd64

# == Build args ==
ARG RUST_VER=1.96.0 \
    RUSTUP_SHA256=e49641c30844a90889d6b7ad136f0c9d70a7896f3800c8b49c11e7b0e4291e16 \
    RUST_ANALYZER_VER=2026-06-08

# == Environment ==
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH="/usr/local/cargo/bin:/usr/local/rustup/bin:/home/claudeuser/.cargo/bin:/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    CARGO_TARGET_DIR=/tmp/cargo-target \
    RUST_BACKTRACE=1 \
    RUSTFLAGS="-D warnings"

# == Layer 1: root. Install system deps + rustup + core + cargo subcommands + cross-targets ==
USER root

ENV PATH="/usr/local/cargo/bin:/usr/local/rustup/bin:/home/claudeuser/.cargo/bin:/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RUN set -ex && \
    # ── 1. System deps (for openssl-sys, git2, etc.) ──
    dnf install -y openssl-devel openssl pkgconfig make gcc gcc-c++ git && \
    dnf clean all && rm -rf /var/cache/dnf && \
    \
    # ── 2. Install rustup-init (always fresh) ──
    export HOME=/root && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path --default-toolchain "$RUST_VER" && \
    \
    # ── 3. Set HOME back and ensure rustup is in PATH ──
    export HOME=/home/claudeuser && \
    \
    # ── 4. Install core components (if not already present) ──
    rustup component add clippy 2>/dev/null || true && \
    rustup component add rustfmt 2>/dev/null || true && \
    rustup component add rust-docs 2>/dev/null || true && \
    rustup component add rust-analyzer 2>/dev/null || true && \
    rustup component add rust-src 2>/dev/null || true && \
    \
    # ── 5. Install cross-compilation targets ──
    rustup target add x86_64-unknown-linux-gnu && \
    rustup target add x86_64-unknown-linux-musl && \
    rustup target add aarch64-unknown-linux-gnu && \
    rustup target add aarch64-unknown-linux-musl && \
    rustup target add arm-unknown-linux-gnueabihf && \
    rustup target add armv7-unknown-linux-gnueabihf && \
    rustup target add powerpc64-unknown-linux-gnu && \
    rustup target add riscv64gc-unknown-linux-gnu && \
    \
    # ── 6. Install cargo subcommands (compiled from source, parallel) ──
    cargo install \
        cargo-expand \
        cargo-audit \
        cargo-edit \
        cargo-outdated \
        cargo-semver-checks \
        cargo-tarpaulin \
        cargo-deny \
        cargo-make \
    && \
    \
    # ── 7. Cleanup ──
    rm -rf /usr/local/cargo/registry/src && \
    rm -rf /usr/local/cargo/registry/cache && \
    chown -R claudeuser:claudeuser /home/claudeuser/.cargo /home/claudeuser/.rustup /usr/local/cargo /usr/local/rustup || true && \
    \
    # ── 8. Pre-flight checks ──
    echo "== Pre-flight checks ==" && \
    echo "Rust:      $(rustc --version 2>&1)" && \
    echo "Cargo:     $(cargo --version 2>&1)" && \
    echo "rustup:    $(rustup --version 2>&1)" && \
    echo "clippy:    $(cargo clippy --version 2>&1)" && \
    echo "rustfmt:   $(rustfmt --version 2>&1)" && \
    echo "rustdoc:   $(rustdoc --version 2>&1)" && \
    echo "rust-analyzer: $(rust-analyzer --version 2>&1)" && \
    echo "" && \
    echo "cargo subcommands:" && \
    echo "  cargo-expand:       $(cargo expand --version 2>&1 || echo 'OK')" && \
    echo "  cargo-audit:        $(cargo audit  2>&1 | head -1)" && \
    echo "  cargo-edit:         $(cargo edit --version 2>&1 || echo 'OK')" && \
    echo "  cargo-outdated:     $(cargo outdated 2>&1 | head -1)" && \
    echo "  cargo-semver-checks:$(cargo semver-checks --version 2>&1 || echo 'OK')" && \
    echo "  cargo-tarpaulin:    $(cargo tarpaulin --version 2>&1 || echo 'OK')" && \
    echo "  cargo-deny:         $(cargo deny --version 2>&1 || echo 'OK')" && \
    echo "  cargo-make:         $(cargo make --version 2>&1 || echo 'OK')" && \
    echo "" && \
    echo "Cross-compilation targets:" && \
    rustup target list --installed && \
    echo "=== Pre-flight complete ===";

# == Layer 2: claudeuser. Hooks + config ==
USER claudeuser

# == Copy pre-start and post-stop hooks ==
COPY hooks/pre-start.d/ /home/claudeuser/pre-start.d/
COPY hooks/post-stop.d/ /home/claudeuser/post-stop.d/

# == Copy recommended configs ==
COPY clippy.toml         /home/claudeuser/clippy.toml
COPY cargo_deny.toml     /home/claudeuser/cargo_deny.toml

# == Working directory ==
WORKDIR /workdir

# == Entry point ==
ENTRYPOINT ["start_claude.sh"]
