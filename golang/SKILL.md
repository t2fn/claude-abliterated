---
name: golang-claude-abliterated
description: Go dev stack with gopls, dlv, golangci-lint, and 11 supporting tools for Claude-driven Go development
---

# Go Dev Stack (claude-abliterated)

A complete Go development environment on top of claude-abliterated:rocky10 with 14 tools.

## Tool Index

| Tool | Package | Role |
|------|---------|------|
| **go** | go 1.26.4 | Core toolchain (build, test, fmt, doc, get, mod, run, vet) |
| **gopls** | golang.org/x/tools/gopls | Official Go Language Server (intelli-sense, diagnostics, navigation) |
| **dlv** | github.com/go-delve/delve | Delve debugger (breakpoints, step, inspect variables) |
| **gotests** | github.com/cweill/gotests | Generate unit tests from Go code |
| **goplay** | github.com/haya14busa/goplay | Run code on Go Playground from editor |
| **gomodifytags** | github.com/fatih/gomodifytags | Add/remove struct tags |
| **impl** | github.com/josharian/impl | Generate interface implementation stubs |
| **staticcheck** | honnef.co/go/tools/cmd/staticcheck | Default lint tool (comprehensive checks) |
| **golangci-lint** | github.com/golangci/golangci-lint | Meta-linter aggregating all checks |
| **revive** | github.com/mgechev/revive | Enhanced golint (fast, configurable) |
| **go-critic** | github.com/go-critic/go-critic | Deep code analysis (200+ checks) |
| **goimports** | golang.org/x/tools/cmd/goimports | Organize imports automatically |
| **godoc** | golang.org/x/tools/cmd/godoc | Local documentation server |

---

## Core Toolchain

### go (1.26.4)

```bash
# Build and run
go build ./...          # build all packages
go run main.go          # compile and run
go test ./...           # run all tests
go test -v -run TestFoo ./...  # run specific test

# Module management
go mod tidy             # remove unused, add missing deps
go mod verify           # verify checksums
go mod graph            # show module graph
go list -m -u all       # check for updates

# Code quality
go vet ./...            # inspect suspicious constructs
go fmt ./...            # format code (standard)
go doc ./...            # show documentation
go tool compile -e ./... # compile with error details
```

---

## Language Server

### gopls

The official Go language server. Runs as a per-project server providing:

- **IntelliSense**: code completion, signature help
- **Diagnostics**: real-time error/warning overlay
- **Navigation**: go-to-definition, find-references, peek-definition
- **Refactoring**: rename, extract variable/const/function, organize imports

```bash
# Check gopls version
gopls version

# Run standalone (useful for debugging)
gopls -rpc.trace -v serve

# In CI or for diagnostics-only:
gopls check ./...
```

---

## Debugging

### dlv (Delve)

```bash
# Interactive debugging
dlv debug main.go                    # debug main package
dlv debug --headless --listen=127.0.0.1:2345  # headless mode (IDE)
dlv test ./...                       # debug tests
dlv exec ./myapp                     # debug compiled binary

# Debug commands
dlv> continue                       # continue to next breakpoint
dlv> step                           # step into
dlv> next                           # step over
dlv> print var                      # print variable
dlv> goroutines                     # list goroutines
dlv> threads                        # list threads
dlv> stack                          # show stack trace
```

---

## Code Generation

### gotests — Generate Unit Tests

```bash
# Generate all tests for a file
gotests -all -w .

# Generate tests for specific methods
gotests -name "Test" -w .

# Templates
gotests -templates default -w .    # default template
gotests -templates table -w .      # table-driven test template
```

### impl — Generate Interface Stubs

```bash
# Generate implementation for interface
impl MyInterface > impl.go

# Specify interface and target file
impl -o impl.go MyInterface MyStruct
```

### gomodifytags — Manage Struct Tags

```bash
# Add tags to fields
gomodifytags -w -add-tags json xml .

# Remove tags
gomodifytags -w -clear-tags json .

# Format tags
gomodifytags -w -format json .
```

---

## Linting & Analysis

### golangci-lint (recommended — use for all Go code)

```bash
# Run with recommended config
golangci-lint run -c golangci.yml ./...

# With recommended flags (complexity + length + file splitting checks)
golangci-lint run \
    -c golangci.yml \
    --max-same-issues=10 \
    --max-issues-per-linter=50 \
    --timeout=5m \
    ./...

# Check function complexity (prevents overly complex/long functions)
golangci-lint run \
    -c golangci.yml \
    --enable=gocognit,funlen,gocyclo \
    ./...
```

#### golangci-lint Linters (from golangci.yml)

| Linter | Purpose | Threshold |
|--------|---------|-----------|
| **gocognit** | Cognitive complexity | min 15 (functions above flagged) |
| **funlen** | Function length | 150 lines, 40 statements |
| **gocyclo** | Cyclomatic complexity | min 10 |
| **gofmt** | Standard formatting | gofmt compliance |
| **goimports** | Import organization | no unused, sorted |
| **govet** | Suspicious constructs | - |
| **errcheck** | Unchecked errors | - |
| **staticcheck** | Comprehensive linting | - |
| **revive** | Enhanced golint | - |
| **unused** | Dead/unused code | - |
| **ineffassign** | Wasted assignments | - |
| **gosimple** | Code simplification | - |
| **gocognit** | Cognitive complexity | min 15 per function |
| **typecheck** | Type checking | - |

#### golangci-lint Recommended Flags (for go functions)

```bash
# CRITICAL: Keep functions not too complex, not too long, split between files

# gocognit min=15 — prevents cognitive complexity explosion
#   Functions with cognitive complexity > 15 should be split or refactored

# funlen lines=150 statements=40 — prevents long functions
#   Functions longer than 150 lines or 40 statements should be split

# cyclop deep-nesting=4 — prevents deep nesting
#   Functions with nesting depth > 4 should extract inner logic

# gocyclo min=10 — prevents cyclomatic complexity
#   Functions with cyclomatic complexity > 10 have too many branches
```

**Recommendation**: Run `golangci-lint run -c golangci.yml ./...` on all Go code in CI. Any function flagged for complexity or length should be:
- **Split** into smaller helper functions (if the function does multiple things)
- **Refactored** with extracted loops/goroutines (if the function is too long)
- **Split between files** (if the function spans multiple responsibilities — move related types/helpers to companion files)

### staticcheck

```bash
# Comprehensive linting (default linter)
staticcheck ./...

# With checks for complexity
staticcheck -checks=all ./...
```

### revive

```bash
# Fast linting (faster than golangci-lint for quick checks)
revive -config revive.toml ./...

# Human-readable output
revive -formatter friendly ./...
```

### go-critic

```bash
# Deep code analysis with 200+ checks
gocritic check ./...

# Check specific categories
gocritic check -enable=camelCase,nestedRule,wayReturn ./...
```

---

## Documentation & Playground

### godoc

```bash
# Start local documentation server
godoc -http=:6060

# Show docs for specific package
godoc fmt Printf
godoc -url fmt.Printf
```

### goplay

```bash
# Paste code to Go Playground
echo 'package main; func main() { println("hello") }' | goplay

# Open Playground in browser
goplay -open
```

### goimports

```bash
# Organize imports and format
goimports -w .

# Check what would change (dry-run)
goimports -d .
```

---

## Recommended Workflow for Claude-Driven Go Development

```bash
# 1. Code: gopls provides real-time diagnostics

# 2. Before committing: run full lint stack
golangci-lint run -c golangci.yml ./...

# 3. Check for complexity issues
golangci-lint run -c golangci.yml --enable=gocognit,funlen,gocyclo ./...

# 4. Generate tests where needed
gotests -all -w .

# 5. Debug with dlv when tests fail
dlv test ./...

# 6. Check documentation
godoc -http=:6060
```

---

## golangci.yml Reference

See `./golangci.yml` in this directory for the full recommended configuration:

```yaml
# Key settings from golangci.yml

linters-settings:
  gocognit:    min: 15       # cognitive complexity threshold
  funlen:      lines: 150, statements: 40  # function length
  cyclop:      deep-nesting: 4, test: true   # nesting depth
  gocyclo:     min: 10       # cyclomatic complexity
  goconst:     min-len: 3, min-occurrences: 3

linters:
  enable:
    - gocognit    # cognitive complexity
    - funlen      # function length
    - gocyclo     # cyclomatic complexity
    - gofmt       # standard formatting
    - goimports   # import organization
    - govet       # suspicious constructs
    - errcheck    # unchecked errors
    - staticcheck # comprehensive linting
    - revive      # enhanced golint
    - unused      # dead code
    - ineffassign # wasted assignments
    - gosimple    # simplification
    - typecheck   # type checking

run:
  timeout: 5m
  tests: true
```

---

## Anti-Patterns

- **Cognitive complexity > 55** — function should be split into smaller helpers
- **Function length > 150 lines** — consider extracting to companion file
- **Cyclomatic complexity > 20** — too many branches; extract conditions
- **Deep nesting > 4** — extract inner logic to helper function
- **Multiple responsibilities in one function** — split between files by responsibility
- **Unchecked errors** — always check return errors with `errcheck`
- **Unused imports/code** — run `golangci-lint` before committing
