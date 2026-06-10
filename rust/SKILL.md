---
name: rust-claude-abliterated
description: Rust dev stack with clippy, rust-analyzer, 9 cargo subcommands, and 8 cross-compilation targets for Claude-driven Rust development
---

# Rust Dev Stack (claude-abliterated)

A complete Rust development environment on top of claude-abliterated:rocky10 with 15 tools and 8 cross-compilation targets.

## Tool Index

| Tool | Package | Role |
|------|---------|------|
| **rustc** | rustc 1.96.0 | Core compiler (semantic analysis, type checking, borrow checking) |
| **cargo** | cargo 1.96.0 | Package manager & build tool (build, test, run, doc, gen) |
| **clippy** | rustup component | Linter with 800+ lints (correctness, style, complexity, perf) |
| **rustfmt** | rustup component | Auto-formatter (consistent code layout) |
| **rustdoc** | rustup component | Documentation generator (HTML output) |
| **rust-analyzer** | rustup component | Language server (intelli-sense, diagnostics, navigation) |
| **cargo-expand** | crates.io | Macro expansion (inspect macro-generated code) |
| **cargo-audit** | crates.io | Security scanning (RustSec advisory database) |
| **cargo-edit** | crates.io | Cargo.toml management (add, remove, set, upgrade) |
| **cargo-outdated** | crates.io | Dependency version checking |
| **cargo-semver-checks** | crates.io | API semver compliance for libraries |
| **cargo-tarpaulin** | crates.io | Code coverage (HTML, JSON, XML reports) |
| **cargo-deny** | crates.io | License + advisory + dependency checks |
| **Miri** | rustup component | Undefined behavior detection at runtime |
| **rust-src** | rustup component | Standard library source code (for inspection) |

---

## Core Toolchain

### rustc + cargo

```bash
# Build and run
cargo build              # compile debug binary
cargo build --release    # compile release (optimized)
cargo run                # compile and run
cargo run --release      # compile and run release

# Build for specific target (cross-compilation)
cargo build --target x86_64-unknown-linux-gnu
cargo build --target aarch64-unknown-linux-gnu
cargo build --target x86_64-unknown-linux-musl
cargo build --target arm-unknown-linux-gnueabihf

# Testing
cargo test               # run all tests
cargo test --lib         # run lib tests only
cargo test --doc         # run doc tests
cargo test test_name     # run specific test

# Module management
cargo update             # update Cargo.lock
cargo update -p pkg_name # update specific package
cargo check              # fast compilation check (no binary)
cargo verify-project     # validate Cargo.toml
cargo metadata           # show dependency tree

# Code quality
cargo clippy             # run clippy lints
cargo fmt                # format code
cargo doc                # generate documentation
cargo doc --open         # generate and open docs
cargo test --no-run      # compile tests without running
cargo vet                # run vulnerability vetting
```

### Cross-Compilation

```bash
# Add targets
rustup target add x86_64-unknown-linux-gnu
rustup target add x86_64-unknown-linux-musl
rustup target add aarch64-unknown-linux-gnu
rustup target add aarch64-unknown-linux-musl
rustup target add arm-unknown-linux-gnueabihf
rustup target add armv7-unknown-linux-gnueabihf
rustup target add powerpc64-unknown-linux-gnu
rustup target add riscv64gc-unknown-linux-gnu

# Cross-compile to all targets
for target in x86_64-unknown-linux-gnu x86_64-unknown-linux-musl \
              aarch64-unknown-linux-gnu aarch64-unknown-linux-musl \
              arm-unknown-linux-gnueabihf armv7-unknown-linux-gnueabihf \
              powerpc64-unknown-linux-gnu riscv64gc-unknown-linux-gnu; do
    cargo build --target $target --release
    echo "Built for $target"
done
```

---

## Linting & Analysis

### clippy (recommended — use for all Rust code)

```bash
# Run clippy with all lints (deny warnings)
cargo clippy -- -D warnings

# Run clippy with specific lint groups
cargo clippy -- -W clippy::all          # all lints (warn)
cargo clippy -- -D clippy::correctness  # deny correctness
cargo clippy -- -D clippy::suspicious   # deny suspicious patterns
cargo clippy -- -W clippy::style        # warn on style
cargo clippy -- -W clippy::complexity   # warn on complexity
cargo clippy -- -W clippy::perf         # warn on performance
cargo clippy -- -W clippy::pedantic     # warn on pedantic (opinionated)
cargo clippy -- -D clippy::restriction  # deny restriction

# Auto-fix clippy suggestions
cargo clippy -- -D warnings --fix

# Cross-compile + clippy
cargo clippy --target aarch64-unknown-linux-gnu

# With clippy.toml config
cargo clippy -- -D warnings -C clippy.toml
```

#### clippy Lint Groups

| Group | Purpose | Default |
|-------|---------|---------|
| **clippy::correctness** | Code that is plain wrong | deny |
| **clippy::suspicious** | Likely wrong code | warn |
| **clippy::style** | Idiomatic Rust | warn |
| **clippy::complexity** | Overly complex code | warn |
| **clippy::perf** | Performance improvements | warn |
| **clippy::pedantic** | Opinionated but useful | warn |
| **clippy::restriction** | Restrictive patterns | warn |
| **clippy::cargo** | Cargo-specific checks | warn |

### rustfmt

```bash
# Format all files
cargo fmt

# Check (dry-run)
cargo fmt -- --check

# Custom config
cargo fmt -- --config-path rustfmt.toml
```

### rust-analyzer (Language Server)

```bash
# Check version
rust-analyzer --version

# Run standalone LSP
rust-analyzer

# Generate documentation
rust-analyzer doc --index 0

# Inspect macro expansion
rust-analyzer diagnostics
```

---

## Debugging & Inspection

### cargo-expand

```bash
# Expand all macros in a crate
cargo expand

# Expand and pipe to pager
cargo expand | less

# Expand specific crate in workspace
cargo expand --package my_crate

# Expand and save to file
cargo expand > expanded.rs

# Inspect generated code for #[derive], proc_macros, impl blocks
cargo expand | grep -A 10 "impl"
```

### Miri (undefined behavior detection)

```bash
# Run tests under Miri (catches UB at runtime)
cargo miri setup

# Run a single test
cargo miri run

# Run all tests
cargo miri test

# Inspect specific function
cargo miri run --bin my_app
```

### rustdoc

```bash
# Generate documentation
cargo doc --open

# Generate docs without running tests
cargo doc --no-deps

# Cross-package documentation
cargo doc --document-private-items
```

---

## Code Generation

### cargo-edit

```bash
# Add dependencies
cargo add serde
cargo add serde --dev          # dev dependency
cargo add serde --features derive  # with features

# Remove dependencies
cargo remove serde

# Set specific versions
cargo set serde --ver 1.0

# Upgrade dependencies
cargo upgrade

# List dependencies
cargo list
```

### cargo-semver-checks

```bash
# Check if current changes break semver
cargo semver-checks

# Check a specific package
cargo semver-checks --package my_crate

# Output as JSON
cargo semver-checks --format json

# Check against baseline
cargo semver-checks --baseline-repo https://github.com/org/my_crate.git
```

---

## Security & Compliance

### cargo-audit

```bash
# Scan Cargo.lock for vulnerabilities
cargo audit

# Scan with specific advisory database
cargo audit -d https://advisory.db

# Output as JSON
cargo audit --json

# Ignore specific advisories
cargo audit --ignore RUSTSEC-2024-0000

# Fail on errors
cargo audit --deny warnings
```

### cargo-deny

```bash
# Full check (licenses + advisories + features)
cargo deny check

# Check workspace
cargo deny check --workspace

# Show dependency graph
cargo deny graph

# List dependencies with licenses
cargo deny list

# Machine-readable output
cargo deny check --format json

# With cargo_deny.toml config
cargo deny check -c cargo_deny.toml
```

---

## Code Coverage

### cargo-tarpaulin

```bash
# Run tests and generate coverage report
cargo tarpaulin

# Generate HTML report
cargo tarpaulin --out html --out-file coverage.html

# Generate JSON report
cargo tarpaulin --out json --out-file coverage.json

# Generate XML report (CI-friendly)
cargo tarpaulin --out xml --out-file coverage.xml

# Minimum coverage threshold
cargo tarpaulin --fail-under 80  # fail if below 80%

# Exclude test code
cargo tarpaulin --exclude-files "tests/*"

# Generate coverage for specific package
cargo tarpaulin --package my_crate
```

---

## Development Workflow

### Recommended Workflow for Claude-Driven Rust Development

```bash
# 1. Code: rust-analyzer provides real-time diagnostics

# 2. Before committing: run full lint stack
cargo clippy -- -D warnings
cargo fmt -- --check

# 3. Security check
cargo audit
cargo deny check

# 4. Check dependency versions
cargo outdated
cargo semver-checks

# 5. Cross-compile
for target in x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu; do
    cargo build --target $target --release
done

# 6. Generate tests
cargo expand

# 7. Coverage
cargo tarpaulin --fail-under 80

# 8. Full CI-like check
cargo check && cargo clippy -- -D warnings && cargo fmt -- --check && cargo test && cargo build
```

### Quick Reference

```bash
# === Development ===
cargo check        # fast check
cargo build        # compile
cargo run          # compile + run
cargo test         # test

# === Code Quality ===
cargo clippy       # lint
cargo fmt          # format
cargo doc          # docs

# === Dependencies ===
cargo add pkg      # add dependency
cargo remove pkg   # remove dependency
cargo update       # update Cargo.lock
cargo outdated     # show outdated
cargo audit        # security scan

# === Cross-compilation ===
cargo build --target aarch64-unknown-linux-gnu
cargo clippy --target aarch64-unknown-linux-gnu
cargo build --target x86_64-unknown-linux-musl --release

# === Inspection ===
cargo expand       # macro expansion
cargo miri test    # UB detection
cargo deny check   # licenses + advisories
cargo semver-checks  # API compliance
```

---

## Anti-Patterns

- **Cognitive complexity > 20** — function should be split into smaller helpers
- **Function length > 50 lines** — consider extracting to companion function
- **Too many unwrap()** — use expect() with messages, or ? operator
- **Generic monomorphization bloat** — use specific types in hot paths
- **Overuse of Box** — prefer stack when possible
- **Unchecked Result** — always handle errors with ? or Result propagation
- **Unused dependencies** — run `cargo outdated` and `cargo deny check` before committing
- **Missing clippy lints** — run `cargo clippy -- -D warnings` before committing
- **Inconsistent formatting** — run `cargo fmt` before committing
