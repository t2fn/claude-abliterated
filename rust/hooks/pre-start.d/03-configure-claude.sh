#!/bin/bash
# 03-configure-claude.sh — Verify Rust dev tools are present and report versions
#
# All tools are installed at Docker build time (see Dockerfile RUN cargo install).
# This hook only reports — it does not install anything at runtime.
# No network needed. No "will be installed" lies.

echo "[rust] Rust dev tools ready:"

# Per-tool version check: each tool gets the right method for its binary
check_version() {
    local tool="$1"
    local version=""
    local status=""

    case "$tool" in
        cargo)
            # Standard cargo binary
            version=$(cargo --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            status="${version:-MISSING}"
            ;;
        clippy)
            # clippy is installed as rustup component (clippy-x86_64-unknown-linux-gnu)
            # The actual binary is clippy-driver (symlink to rustup)
            if command -v clippy-driver >/dev/null 2>&1; then
                version=$(clippy-driver --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            elif command -v clippy >/dev/null 2>&1; then
                version=$(clippy --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            else
                version="MISSING"
            fi
            ;;
        rustfmt)
            version=$(rustfmt --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        rustdoc)
            version=$(rustdoc --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        rust-analyzer)
            version=$(rust-analyzer --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        cargo-expand)
            version=$(cargo-expand --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        cargo-audit)
            version=$(cargo-audit --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        cargo-edit)
            # cargo-edit is the CRATE that provides 4 subcommand binaries:
            #   cargo-add, cargo-rm, cargo-set-version, cargo-upgrade
            # It does NOT produce a standalone cargo-edit binary.
            # Check: if ANY of its 4 subcommand binaries are present, it's installed.
            if command -v cargo-add >/dev/null 2>&1 || \
               command -v cargo-rm >/dev/null 2>&1 || \
               command -v cargo-set-version >/dev/null 2>&1 || \
               command -v cargo-upgrade >/dev/null 2>&1; then
                version="installed (cargo-add, cargo-rm, cargo-set-version, cargo-upgrade)"
            else
                version="MISSING"
            fi
            ;;
        cargo-outdated)
            # cargo-outdated binary exists but --version returns empty (it's a cargo subcommand delegate)
            # Fix: use `cargo outdated --version` which returns proper version
            if command -v cargo-outdated >/dev/null 2>&1; then
                version=$(cargo-outdated --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
                if [ -n "$version" ] && [ "$version" != "cargo-outdated" ]; then
                    : # version is valid
                else
                    # Fallback: use cargo subcommand form
                    version=$(cargo outdated --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
                fi
            fi
            [ -z "$version" ] && version="MISSING"
            ;;
        cargo-semver-checks)
            # Reports as "cargo 0.48.0" — report as-is
            version=$(cargo-semver-checks --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        cargo-tarpaulin)
            # Reports as "tarpaulin X.Y.Z" — report as-is
            version=$(cargo-tarpaulin --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        cargo-deny)
            version=$(cargo-deny --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        *)
            # Generic: try --version, then -V, then -h
            if command -v "$tool" >/dev/null 2>&1; then
                version=$($tool --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
                if [ -z "$version" ]; then
                    version=$($tool -V 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
                fi
                if [ -z "$version" ]; then
                    version=$($tool -h 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
                fi
            fi
            [ -z "$version" ] && version="MISSING"
            ;;
    esac

    echo "  $tool: $version"
}

for tool in cargo clippy rustfmt rustdoc rust-analyzer cargo-expand cargo-audit cargo-edit cargo-outdated cargo-semver-checks cargo-tarpaulin cargo-deny; do
    check_version "$tool"
done
