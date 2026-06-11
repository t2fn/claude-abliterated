# Rust Linting Rules for Claude

## Purpose

This file contains the linting rules that Claude should follow when working with Rust code in this project.
All rules are pre-loaded in the container — no network needed.

## Clippy Rules

### Always run before committing:

```bash
cargo clippy -- -D warnings
```

### Rules that MUST be enforced (deny on warnings):

| Rule | Severity | Reason |
|------|----------|--------|
| `clippy::correctness` | DENY | Code that is plain wrong |
| `clippy::suspicious` | DENY | Likely wrong code patterns |
| `clippy::style` | WARN | Idiomatic Rust |
| `clippy::complexity` | WARN | Overly complex code |
| `clippy::perf` | WARN | Performance improvements |
| `clippy::pedantic` | WARN | Opinionated but useful |
| `clippy::restriction` | WARN | Restrictive patterns |
| `clippy::cargo` | WARN | Cargo-specific checks |

### Auto-fix on write:

When Claude writes or modifies Rust code, it should:

1. **Check for clippy warnings** — run `cargo clippy -- -W clippy::all`
2. **Fix what it can** — run `cargo clippy -- -D warnings --fix`
3. **Not break what works** — only modify code that was changed or flagged by clippy

### Rules that should NOT be auto-fixed:

| Rule | Reason |
|------|--------|
| `clippy::needless_pass_by_value` | May change API surface |
| `clippy::new_without_default` | May change API surface |
| `clippy::missing_safety_doc` | Documentation only, not correctness |
| `clippy::doc_markdown` | Documentation only |
| `clippy::type_complexity` | Opinionated, not correctness |

## Cargo-Deny Rules

### Always run before committing:

```bash
cargo deny check
```

### License rules:

| License | Status |
|---------|--------|
| MIT | ALLOW |
| Apache-2.0 | ALLOW |
| BSD-2-Clause | ALLOW |
| BSD-3-Clause | ALLOW |
| ISC | ALLOW |
| Unlicense | ALLOW |
| GPL-2.0 | DENY |
| GPL-3.0 | DENY |
| AGPL-3.0 | DENY |

### Advisory rules:

| Rule | Action |
|------|--------|
| Yanked crates | ERROR |
| Security advisories | WARN |
| Version conflicts | WARN |

## Auto-Lint Behavior

### When linting IS triggered (user asks or code changed):

1. **Check for lints** — `cargo clippy` and `cargo deny check`
2. **Report findings** — list any warnings or errors
3. **Ask before fixing** — "Should I fix the clippy warnings?"
4. **Fix only if asked** — `cargo clippy -- -D warnings --fix`

### When linting is NOT triggered (auto mode):

1. **Do NOT modify existing code** — leave it untouched
2. **Do NOT run clippy** — only run when explicitly requested
3. **Do NOT run cargo-deny** — only run when explicitly requested

### How to trigger linting:

- **"Fix my code"** — run clippy and fix
- **"Check the code"** — run clippy, report findings
- **"Lint the code"** — run clippy and cargo-deny
- **"Commit"** — ask user if they want linting before commit

## SKILL.md Integration

When Claude writes new Rust code, it should:

1. **Follow the clippy rules** above
2. **Use the pre-loaded configs** — `clippy.toml` and `cargo_deny.toml` are in `/home/claudeuser/`
3. **Ask before modifying** — "Should I run clippy on the new code?"
4. **Not break existing code** — only modify code that was changed or flagged
