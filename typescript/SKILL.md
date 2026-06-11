---
name: typescript-claude-abliterated
description: TypeScript dev stack with biome, eslint, prettier, tsx, vitest, turbo, and 9 tools for Claude-driven TypeScript development
---

# TypeScript Dev Stack (claude-abliterated)

A complete TypeScript development environment on top of claude-abliterated:rocky10 with 10 tools and recommended configs.

## Tool Index (installed versions)

| Tool | Package | Version | Role |
|------|---------|---------|------|
| **tsc** | typescript | 6.0.3 | Core compiler (type checking, transpilation) |
| **biome** | biome | 0.3.3 | All-in-one linter + formatter (RECOMMENDED) |
| **eslint** | eslint | 10.x | Comprehensive linter (configurable rules) |
| **prettier** | prettier | 3.x | Code formatter (consistent layout) |
| **tsx** | tsx | 4.x | TypeScript executor (run TS directly) |
| **vitest** | vitest | 4.x | Testing framework (fast, HMR, Vite-based) |
| **turbo** | turbo | 2.x | Monorepo build system (incremental) |
| **ts-patch** | ts-patch | 4.x | TypeScript compiler patcher |
| **tsconfig-paths** | tsconfig-paths | 4.x | Path resolution for tsconfig |
| **@swc/core** | @swc/core | 1.x | Rust-accelerated compiler (fast alternative) |

---

## Pre-Start Hooks (informational only)

The first three pre-start hooks run on container startup and print **version numbers** (not just "OK"):

```bash
# 1. Main environment + version numbers — does NOT lint or touch files
bash /home/claudeuser/pre-start.d/01-configure-typescript.sh
# Output:
#   [typescript] TypeScript environment:
#     Node: v24.16.0
#     npm:  11.16.0
#     tsc:  Version 6.0.3
#     biome: 0.3.3
#     eslint: v10.4.1
#     prettier: 3.8.4
#     tsx:  4.22.4
#     vitest: 4.1.8
#     turbo:  2.9.18

# 2. Biome linter — does NOT lint or touch files
bash /home/claudeuser/pre-start.d/02-configure-biome.sh
# Output:
#   [typescript] Biome linter:
#     version: 0.3.3
#     check:   Check and fix standards violations
#     format:  A JavaScript formatter
#   [typescript] Biome config:
#     Using: biome.json
#     Rules: correctness, suspicious, style, complexity, nursery

# 3. All dev tools + versions — does NOT lint or touch files
bash /home/claudeuser/pre-start.d/03-configure-claude.sh
# Output:
#   [typescript] TypeScript dev tools:
#     tsc: Version 6.0.3
#     biome: 0.3.3
#     eslint: v10.4.1
#     ... (and so on for all tools)
```

**All three hooks above are purely informational.** They verify tools are available and print version numbers — they do NOT lint, format, or touch any files.

## Available (opt-in) hook — does NOT run on startup

```bash
# 4. Auto-lint generated code — AVAILABLE but NOT auto-sourced
bash /home/claudeuser/pre-start.d/04-lint-generated
```

The `04-lint-generated` hook **does modify files** (auto-fixes, organizes imports). It is installed in the container but NOT auto-sourced on startup. Claude should only run it when:
- The user explicitly asks for linting
- The user asks to clean up existing or generated code
- The user asks to lint new code that was just written

**Do NOT assume the user wants linting.** Only suggest and run linting when the user's task relates to code quality, and get permission first if the code area has not been requested.

---

## Linting & Formatting — Configs baked into the container

The container ships with pre-loaded best-practice configs. They are COPYed from the build context and baked into the image — no internet needed.

### biome.json (RECOMMENDED — use for TypeScript code)

Pre-loaded best-practice rules at `/home/claudeuser/biome.json`:

| Group | Rule | Level | Purpose |
|-------|------|-------|-------|
| **correctness** | noUnusedVariables | warn | Code that is plain wrong |
| **correctness** | useArrayLiterals | warn | Use [] or Array<> consistently |
| **suspicious** | noExplicitAny | warn | Prefer explicit types |
| **suspicious** | noConsole | info | Console usage |
| **style** | useConst | error | Always use const when possible |
| **style** | noNonNullAssertion | warn | Prefer optional over ! |
| **complexity** | noForEach | off | Foreach is allowed |
| **nursery** | useSortedClasses | warn | Sort Tailwind classes |

Formatter settings match .prettierrc: `semi: false`, `singleQuote: true`, `tabWidth: 2`, `printWidth: 120`.

```bash
# Lint TypeScript code (fast, Rust-based)
biome check .

# Auto-fix issues in place
biome check --fix .

# Format code
biome format --write .

# Organize imports
biome check --organize-imports .

# Check config
biome check -c biome.json .

# Auto-lint with eslint as secondary check (config files)
eslint biome.json tsconfig.json eslint.config.mjs
```

### eslint.config.mjs

Pre-loaded with TypeScript-specific rules at `/home/claudeuser/eslint.config.mjs`:

- `@typescript-eslint/no-explicit-any: warn` — aligns with biome
- `@typescript-eslint/no-unused-vars: warn` — ignores `_` prefix
- `@typescript-eslint/explicit-function-return-type: off` — let TS infer
- `@typescript-eslint/no-non-null-assertion: warn` — aligns with biome
- `@typescript-eslint/prefer-optional-chain: warn`
- `no-console: warn` — aligns with biome
- `eqeqeq: warn` — always use ===
- `curly: warn` — multi-line curly braces

```bash
# Lint with eslint
eslint . --ext .ts,.tsx

# Auto-fix
eslint --fix .

# Check config files
eslint biome.json tsconfig.json eslint.config.mjs
```

### .prettierrc

Pre-loaded at `/home/claudeuser/.prettierrc`. Aligned with biome:

```json
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "printWidth": 120,
  "trailingComma": "es5",
  "arrowParens": "always",
  "bracketSpacing": true,
  "endOfLine": "lf"
}
```

### tsconfig.json

Pre-loaded at `/home/claudeuser/tsconfig.json`. Best-practice defaults:

- `strict: true` — all strict type checks
- `target: "ES2024"` — modern JS output
- `module: "NodeNext"` — Node.js module resolution
- `declaration: true` — generate .d.ts files
- `sourceMap: true` — source maps
- `outDir: "./dist"` — compiled output
- `rootDir: "./src"` — source root
- `paths: { "@/*": ["./src/*"] }` — path aliases

### .editorconfig

Pre-loaded at `/home/claudeuser/.editorconfig`. Cross-editor consistency:

- UTF-8 encoding
- LF line endings (aligns with prettier)
- 2-space indentation (aligns with biome)
- Trim trailing whitespace (aligns with biome)
- Insert final newline (aligns with biome)
- Tab indentation for Makefiles

---

## Linting Philosophy

### Pre-loaded configs
All linting configs are pre-loaded in the container with best-practice rules.
They guide behavior but do NOT auto-run. Rules are documented in SKILL.md.

### What Claude should do:

**NEW files Claude writes:**
- Auto-lint with the project's primary linter before presenting to the user.
- Auto-fix is always safe here — these are Claude's own files.
- Use the project's config (biome.json) — no need to ask.

**EXISTING code:**
- Do NOT touch unless Claude is explicitly tasked with it.
- If Claude notices linting issues while doing a task, report them and ask:
  "Found some linting issues in file.ts, lint it?"
- Only apply linting/auto-fix when the user confirms (yes/no).
- Run lint read-only (check-only) first if the user is unsure.

### Key rules:
1. **Don't assume the user wants linting** — offer it, let them decide.
2. **Don't auto-lint on startup** — only report tool versions. Real linting
   happens when Claude is tasked with code quality work.
3. **Don't silently modify files** — ask before touching existing code.
   A file you didn't write is not yours to change without permission.
4. **Auto-lint what you write** — new files get auto-linted before presenting.

### Tool status:
```bash
# Linting tools are available and versions are reported on startup.
# They will NOT run automatically — they wait for Claude to be tasked.

[typescript] TypeScript environment:
  tsc:   Version 6.0.3
  biome: 0.3.3
  eslint: v10.4.1
  prettier: 3.8.4

# Hooks 1-3 (01-configure-typescript.sh, 02-configure-biome.sh, 03-configure-claude.sh)
# print versions only. Hook 4 (04-lint-generated) is available but opt-in.
```

---

## Auto-Lint — opt-in, not automatic

The auto-lint workflow is **available** but **not assumed**:

```bash
# Run the auto-lint hook (manual)
bash /home/claudeuser/pre-start.d/04-lint-generated

# What it does:
#   1. Counts .d.ts declaration files
#   2. Runs biome check (lints all files)
#   3. Runs biome check --fix (auto-fixes)
#   4. Runs biome check --organize-imports
#   5. Runs eslint on config files (secondary)
```

**When to lint:**
- ✅ When the user asks for linting or code quality
- ✅ When writing new files — suggest running `biome check --fix` afterward
- ✅ When the user asks to clean up existing or generated code
- ✅ When the user mentions "fix all issues" or "check my code"
- ❌ Do NOT auto-run lint on startup (it is available, not automatic)
- ❌ Do NOT lint files the user has not asked about, unless they just wrote them

**When asking the user:**
> "Would you like me to run biome auto-lint on the code before we proceed?"
> "Shall I also clean up existing / generated code with biome check --fix?"

---

## Core Toolchain

### tsc (TypeScript compiler)

```bash
# Build and run
tsc                          # compile with tsconfig.json
tsc --project tsconfig.json  # compile with specific config
tsc --noEmit                 # type-check only (fast)
tsc --watch                  # incremental compilation
tsc --build                  # incremental build for projects

# Code generation
tsc --declaration            # generate .d.ts files
tsc --declarationMap         # generate declaration maps
tsc --sourceMap              # generate source maps
tsc --init                   # generate tsconfig.json

# Module management
tsc --showConfig             # display resolved config
tsc --listFiles              # list compiled files
tsc --traceResolution        # trace module resolution
```

### biome (RECOMMENDED — use for all TypeScript code)

The all-in-one linter and formatter from Biome. Fast (Rust), zero-config, replaces both ESLint + Prettier.

```bash
# Run biome check (lint) with all rules
biome check .

# Auto-fix biome check issues
biome check --fix .

# Format code (equivalent to prettier)
biome format .

# Format and write in place
biome format --write .

# Format specific file
biome format file.ts

# Organize imports (like import sorting)
biome check --organize-imports .

# Check with custom config
biome check -c biome.json .
```

#### biome Lint Rules

| Group | Default | Purpose |
|-------|---------|---------|
| **correctness** | warn | Code that is plain wrong |
| **suspicious** | warn | Likely wrong code |
| **style** | warn | Idiomatic TypeScript |
| **complexity** | warn | Overly complex code |
| **nursery** | warn | Opinionated rules |
| **pedantic** | off | Strict style |

---

## Linting & Formatting

### biome vs eslint + prettier

```bash
# Quick check — biome (fastest — Rust-based)
biome check . && biome format .

# Full lint stack — eslint with TypeScript rules
eslint . --ext .ts,.tsx

# Format with prettier (or biome format)
prettier --check .
prettier --write .

# Auto-fix eslint
eslint --fix .

# Compare outputs
biome check . | eslint --stdin --stdin-filename=file.ts
```

### prettier

```bash
# Check all files
prettier --check .

# Format specific extensions
prettier --write "**/*.{ts,tsx,js,jsx,mjs,json}"

# Format with config
prettier --config .prettierrc --write .

# Preview diff
prettier --check --verbose .
```

### eslint

```bash
# Lint all TypeScript files
eslint . --ext .ts,.tsx

# Auto-fix fixable issues
eslint --fix .

# Check with config
eslint --config eslint.config.mjs .

# Output as JSON (CI-friendly)
eslint --format json .

# Show all rules
eslint --print-config eslint.config.mjs
```

---

## Testing

### vitest (RECOMMENDED — use for all tests)

Fast, Vite-based testing framework. Supports unit, integration, and E2E tests.

```bash
# Run all tests
vitest

# Run with watch mode
vitest watch

# Run specific file
vitest src/foo.test.ts

# Run with coverage
vitest --coverage

# Generate coverage report
vitest run --coverage --coverage.reporter=html

# Run in CI mode
vitest run

# Run with specific test name pattern
vitest run --testNamePattern "should do.*"

# Run specific suite
vitest run src/math.test.ts --reporter verbose
```

### Writing TypeScript tests

```typescript
// src/math.test.ts
import { describe, it, expect } from "vitest";
import { add } from "./math";

describe("math", () => {
  it("adds two numbers", () => {
    expect(add(2, 3)).toBe(5);
  });

  it("handles edge cases", () => {
    expect(add(0, 0)).toBe(0);
    expect(add(-1, 1)).toBe(0);
  });
});
```

---

## Monorepo & Build

### turbo

```bash
# Full monorepo build
turbo build

# Run with cache
turbo build --cache

# Run specific package
turbo build --filter my-package

# Run dev server
turbo dev

# Full CI-like check
turbo run build test lint type-check
```

### ts-patch

```bash
# Patch TypeScript to add plugin support
ts-patch install

# Unpatch
ts-patch uninstall

# Check patch status
ts-patch status
```

### tsconfig-paths

```bash
# Resolve paths in tsconfig
tsconfig-paths-bootstrap

# Use in ts-node / tsx
tsx --paths -P tsconfig.json app.ts
```

---

## Fast Compilation

### @swc/core

Rust-accelerated alternative to tsc for very fast compilation.

```bash
# Check if swc is available
which swc

# Compile with swc (faster than tsc)
swc src/ -d dist/

# Compile with config
swc src/ -d dist/ -s swcrc

# Compare speeds
time tsc --noEmit
time swc src/ -d dist/
```

---

## Execution

### tsx

Run TypeScript files directly without compilation.

```bash
# Run TypeScript file directly
tsx app.ts

# Run with args
tsx app.ts --port 3000

# Run in watch mode
tsx --watch app.ts

# Pipe TypeScript code
echo 'console.log("hello");' | tsx

# Run with tsconfig
tsx -P tsconfig.json app.ts
```

---

## Development Workflow

### Claude's Linting Behavior

When working with TypeScript code, follow these linting rules:

**DO:**
- Suggest `biome check --fix` when writing new files (mention it, but don't assume)
- Ask before linting existing / untouched code
- Run `biome check .` on new files before proceeding
- Mention the config files being used (`biome.json`, `eslint.config.mjs`, `.prettierrc`)
- Note the version numbers when reporting lint results

**DON'T:**
- Auto-lint on container startup (the first 3 hooks are informational only)
- Touch existing code without the user's permission
- Assume "fix all issues" means run on every file — scope to the relevant area
- Lint in a way that breaks user code (prefer `biome check --fix --no-errors-on-unmatched`)

### Recommended Workflow for Claude-Driven TypeScript Development

```bash
# 1. Code: tsx provides fast iteration
tsx app.ts                          # run directly

# 2. Before committing: run full lint stack (opt-in)
biome check . --fix                 # lint + auto-fix
biome format --write .              # format code
tsc --noEmit                        # type-check

# 3. If asked to clean up existing/generated code:
bash /home/claudeuser/pre-start.d/04-lint-generated

# 4. Run tests
vitest run                          # all tests

# 5. Cross-validate with eslint + prettier
eslint --fix .                      # eslint auto-fix
prettier --write .                  # prettier format

# 6. Full CI-like check
biome check . && biome format --check . && tsc --noEmit && vitest run
```

### Quick Reference

```bash
# === Compilation ===
tsc              # compile
tsc --watch      # watch mode
tsc --noEmit     # type-check only
tsx app.ts       # run TypeScript
swc src/ -d dist/  # fast compile with swc

# === Linting (opt-in) ===
biome check .            # lint (RECOMMENDED)
biome check --fix .      # auto-fix
biome check --organize-imports .  # import sorting
eslint . --fix .         # eslint with auto-fix

# === Formatting ===
biome format .           # biome format
biome format --write .   # biome format in-place
prettier --write .       # prettier format

# === Testing ===
vitest             # run tests
vitest run         # CI mode
vitest --coverage  # with coverage

# === Dependencies ===
npm install pkg    # add dependency
npm rm pkg         # remove dependency
npm outdated       # check updates
turbo build        # monorepo build

# === Config files (baked into container) ===
biome.json             # biome rules + formatter
eslint.config.mjs      # eslint TypeScript rules
.prettierrc            # prettier formatting
tsconfig.json          # TypeScript compiler
.editorconfig          # cross-editor consistency

# === Auto-Lint (opt-in) ===
bash /home/claudeuser/pre-start.d/04-lint-generated   # full auto-lint
biome check .              # lint all
biome check --fix .        # auto-fix
biome check --organize-imports .  # organize imports
eslint biome.json tsconfig.json eslint.config.mjs  # config check

# === Inspection ===
tsc --showConfig   # show config
tsc --traceResolution  # trace modules
biome lint         # show all lints
eslint --print-config .  # show rules

# === Code Quality ===
tsc --noEmit       # type-check fast
biome check .      # lint
biome format --check .  # format check
prettier --check .      # prettier check
vitest run             # tests
```

---

## Anti-Patterns

- **Cognitive complexity > 20** — function should be split into smaller helpers
- **Function length > 50 lines** — consider extracting to companion function
- **Too many `any`** — use `unknown` or explicit types
- **Missing return types** — let TypeScript infer, but add for public APIs
- **Nested `any`** — prefer `Record<string, unknown>` over `{ [key: string]: any }`
- **Unchecked `Result`** — always handle errors with `?` or `Result` propagation
- **Missing biome lints** — run `biome check --fix` before committing
- **Inconsistent formatting** — run `biome format --write .` before committing
- **Unused imports** — biome handles this automatically; eslint also checks
- **Linting without permission** — ask before touching existing code, only lint what was requested
