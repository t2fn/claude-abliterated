---
name: golang-claude-abliterated
description: Go dev stack with gopls, dlv, golangci-lint, 11 Go tools, and best-practice linting rules for Claude-driven Go development
---

# Go Dev Stack (claude-abliterated)

A complete Go development environment on top of claude-abliterated:rocky10 with 13 tools and best-practice linting.

## Tool Index

| Tool | Package | Role |
|------|---------|------|
| **go** | go 1.26.4 | Core toolchain (build, test, vet, fmt, get, mod, doc) |
| **gopls** | golang.org/x/tools v0.22.0 | Language server (intelli-sense, diagnostics, navigation) |
| **dlv** | delve 1.26.3 | Debugger (debug, trace, attach, core) |
| **gotests** | gotests v1.9.0 | Test generation (table tests, subtests, AI) |
| **goplay** | goplay v1.0.0 | Share code on The Go Playground |
| **gomodifytags** | gomodifytags | Struct tag manipulation |
| **impl** | impl | Interface implementation generation |
| **staticcheck** | staticcheck 2026.1 | Comprehensive static analysis |
| **golangci-lint** | golangci-lint v1.64.8 | Meta-linter (runs all linters at once) |
| **revive** | revive 1.15.0 | Configurable linter (golint successor) |
| **gocritic** | gocritic | Many small lints for code quality |
| **goimports** | goimports | Import organization + formatting |
| **godoc** | godoc | Documentation server and viewer |

---

## Core Toolchain

### go

```bash
# Build and run
go build              # compile
go build -o myapp     # compile to binary
go build ./...         # compile all packages
go build -v ./...     # verbose build
go build -x ./...     # print commands

go run main.go        # compile and run
go run ./...           # run all packages

go test               # run all tests
go test ./...         # run tests in all packages
go test -v ./...      # verbose test output
go test -run TestName # run specific test
go test -count=1      # force re-run (no cache)
go test -bench=.      # run benchmarks
go test -cover        # show coverage

go doc                # show documentation
go doc fmt.Println    # show specific function
go doc -all           # show all documentation

go fmt ./...          # format all files
go fmt file.go        # format single file
go fmt -x ./...       # verbose format

go vet ./...          # static analysis (suspicious constructs)
go vet -printfuncs=info,error ./...  # custom printf functions

# Module management
go mod init           # initialize module
go mod tidy           # add/remove dependencies
go mod verify         # verify dependencies
go mod graph        # show dependency graph
go mod why module   # explain why module is needed
go mod download     # download dependencies

# Cross-compilation
GOOS=windows GOARCH=amd64 go build
GOOS=linux   GOARCH=arm64 go build
GOOS=darwin  GOARCH=amd64 go build

# Install packages
go install package@version   # install specific version
go install ./cmd/...         # install commands
```

### gopls (Language Server)

```bash
# gopls is the Go language server used by Claude Code
# Configuration: /home/claudeuser/.config/gopls/gopls.json
# Settings are pre-loaded with best practices

# Check gopls status
go version -m "$(which gopls)"

# gopls uses golangci-lint config at ~/golangci.yml for linting rules
# Run golangci-lint manually (auto-lint is OFF at startup):
golangci-lint run -c ~/golangci.yml ./...
```

---

## Linting & Analysis

### golangci-lint (pre-loaded config)

The golangci-lint config is pre-loaded at `~/golangci.yml` with best-practice settings:

```bash
# Run with pre-loaded config
golangci-lint run -c ~/golangci.yml ./...

# Check all packages, including tests
golangci-lint run -c ~/golangci.yml --tests ./...

# Show all issues (no cap)
golangci-lint run -c ~/golangci.yml --max-issues-per-linter=0 --max-same-issues=0 ./...

# Fix auto-fixable issues
golangci-lint run -c ~/golangci.yml --fix ./...

# Output as JSON (for CI/automation)
golangci-lint run -c ~/golangci.yml --out-format json ./...

# Check only (don't modify files)
golangci-lint check -c ~/golangci.yml ./...
```

#### Pre-loaded Linting Rules

| Rule | Threshold | Purpose |
|------|-----------|-------|
| **gocognit** | min 15 | Cognitive complexity per function |
| **funlen** | 150 lines, 40 statements | Function length limit |
| **cyclop** | outer-limit 20, deep-nest 4 | Cyclomatic complexity |
| **gocyclo** | min 10 | Cyclomatic complexity per function |
| **goconst** | len >= 3, occ >= 3 | String constants |
| **govet** | enabled | Suspicious constructs |
| **errcheck** | enabled | Unchecked errors |
| **staticcheck** | enabled | Comprehensive static analysis |
| **revive** | enabled | Enhanced golint |
| **unused** | enabled | Unused code |
| **ineffassign** | enabled | Ineffective assignments |
| **gosimple** | enabled | Simplification suggestions |
| **typecheck** | enabled | Type checking |
| **gofmt** | enabled | Standard formatting |
| **goimports** | enabled | Import organization |

#### golangci.yml (pre-loaded config)

```yaml
# Complexity & Length (prevents overly complex/long functions)
linters-settings:
  gocognit:
    min: 15
  funlen:
    lines: 150
    statements: 40
  cyclop:
    test: true
    the-outer-limit: 20
    deep-nesting: 4
  gocyclo:
    min: 10
  goconst:
    min-len: 3
    min-occurrences: 3

# Enabled linters
linters:
  enable:
    - gocognit
    - funlen
    - gocyclo
    - gofmt
    - goimports
    - govet
    - errcheck
    - staticcheck
    - revive
    - unused
    - ineffassign
    - gosimple
    - typecheck

# Run settings
run:
  timeout: 5m
  tests: true
  skip-files:
    - ".*_test\\.go$"

# Issues output
issues:
  max-issues-per-linter: 50
  max-same-issues: 10
  exclude-use-default: false
```

### Individual Linters

```bash
# staticcheck (comprehensive)
staticcheck ./...
staticcheck -version

# revive (configurable)
revive -config golangci.yml ./...
revive -formatter friendly ./...

# gocritic (many small lints)
gocritic check ./...
gocritic check -enable-all ./...

# goimports (import organization)
goimports -w file.go    # fix imports in-place
goimports -d file.go    # show diff

# gofmt (standard formatting)
gofmt -w file.go
gofmt -s -w file.go    # simplify code
```

---

## Debugging & Inspection

### dlv (Delve Debugger)

```bash
# Debug main package
dlv debug
dlv debug -- -flag=value    # with arguments

# Debug specific file/package
dlv debug main.go
dlv debug ./cmd/myapp

# Attach to running process
dlv attach <pid>

# Debug with headless server
dlv debug --headless --listen=:2345 --api-version=3

# Trace function execution
dlv trace main.go

# Core dump
dlv core binary

# Set breakpoints
dlv debug
> break main.go:42
> continue
> print x
> locals
> goroutines
```

### godoc (Documentation)

```bash
# Start documentation server
godoc -http=:6060

# Inspect documentation
godoc fmt.Println
godoc net/http.RoundTripper

# Browse all documentation
godoc -http=:6060 -url=/pkg/
```

---

## Code Generation

### gotests

```bash
# Generate tests for all functions/methods
gotests -all ./...

# Generate tests for exported symbols only
gotests -exported ./...

# Generate table tests
gotests -w output.go ./...

# Generate with specific template
gotests -template testify ./...

# AI-generated tests (requires Ollama)
gotests -ai ./...
gotests -ai-endpoint http://localhost:11434 ./...
```

### impl

```bash
# Generate interface implementation
impl io.Reader
impl -t ./...  # test implementation
impl -w file.go ./...  # write to file
```

### gomodifytags

```bash
# Add tags to struct fields
gomodifytags -w -add json,xomitempty -struct MyStruct file.go

# Remove tags
gomodifytags -w -remove json -struct MyStruct file.go

# Apply to all fields
gomodifytags -w -add json -all file.go
```

---

## Development Workflow

### Recommended Workflow for Claude-Driven Go Development

```bash
# 1. Code: gopls provides real-time diagnostics

# 2. Before committing: run full lint stack
golangci-lint run -c ~/golangci.yml ./...
go fmt ./...
go vet ./...

# 3. Generate tests
gotests -all ./...

# 4. Verify builds
go build ./...
go test ./...

# 5. Check static analysis
staticcheck ./...
revive ./...

# 6. Full CI-like check
go build ./... && golangci-lint run -c ~/golangci.yml ./... && go test ./...
```

### Auto-Lint Behavior

**Auto-lint is OFF at startup.** When Claude is tasked with code development:

#### NEW files Claude writes:
- Auto-lint with the project's primary linter before presenting to the user.
- Auto-fix is always safe here — these are Claude's own files.
- Use the project's pre-loaded config (`~/golangci.yml`) — no need to ask.

#### EXISTING code:
- Do NOT touch unless Claude is explicitly tasked with it.
- If Claude notices linting issues while doing a task, report them and ask:
  > "Found some linting issues, lint it?"
- Only apply linting/auto-fix when the user confirms (yes/no).
- Run lint read-only (check-only) first if the user is unsure.

#### Key rules:
1. **Don't assume the user wants linting** — offer it, let them decide.
2. **Don't auto-lint on startup** — only report tool versions. Real linting
   happens when Claude is tasked with code quality work.
3. **Don't silently modify files** — ask before touching existing code.
   A file you didn't write is not yours to change without permission.
4. **Auto-lint what you write** — new files get auto-linted before presenting.

```bash
# Linting tools are available and versions are reported on startup.
# They will NOT run automatically — they wait for Claude to be tasked.
```

### Container cache (777)

The `~/.cache` directory is set to `777` so users running the container
with an alternate UID can write to the cache without permission errors.
The gopls persistent index (`~/.cache/gopls`) and go build cache are
also 777 and owned by `claudeuser`.

### Config locations

```bash
# All config files live in HOME (not /etc)
~/golangci.yml          # golangci-lint rules (best-practice defaults)
~/.config/gopls/gopls.json  # gopls language server settings
```

---

## Code Quality Checklist

Before committing Go code:

- [ ] `go fmt ./...` — formatted
- [ ] `go vet ./...` — no vet errors
- [ ] `golangci-lint run -c ~/golangci.yml ./...` — passes lint rules
- [ ] `go test ./...` — tests pass
- [ ] `staticcheck ./...` — no staticcheck warnings
- [ ] No unused imports (goimports will clean)
- [ ] Error handling: no unchecked errors (errcheck)
- [ ] Functions under complexity threshold (gocognit <= 15)
- [ ] Functions under length threshold (funlen <= 150 lines)
- [ ] Deep nesting <= 4 levels (cyclop)

---

## Anti-Patterns

- **Cognitive complexity > 15** — function should be split
- **Function length > 150 lines** — consider companion functions
- **Deep nesting > 4 levels** — use early returns
- **Cyclomatic complexity > 10** — break into smaller functions
- **Unchecked errors** — always check error returns
- **Unused imports** — goimports will clean
- **Missing error handling** — errcheck catches unchecked errors
- **Poor struct tags** — use gomodifytags for consistency
- **Overly broad imports** — group imports, use relative paths
- **Missing test cases** — use gotests for coverage

---

## Linting Commands Quick Reference

```bash
# Full lint (with pre-loaded config)
golangci-lint run -c ~/golangci.yml ./...

# Per-linter commands
staticcheck ./...          # comprehensive static analysis
revive ./...               # enhanced golint
gocritic check ./...      # many small lints
go vet ./...               # suspicious constructs
go fmt ./...               # formatting
goimports -w ./...         # import organization

# Auto-fix linting
golangci-lint run -c ~/golangci.yml --fix ./...

# Check without modifying
golangci-lint check -c ~/golangci.yml ./...
```
