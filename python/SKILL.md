---
name: python-claude-abliterated
description: Python linting & code quality stack with ruff, pylint, mypy, bandit, and 12 supporting tools for Claude-driven Python development
---

# Python Dev Stack (claude-abliterated)

A complete Python development and linting environment on top of claude-abliterated:rocky10 with 13 tools.

## Tool Index

| Tool | Package | Role |
|------|---------|------|
| **ruff** | ruff>=0.11.0 | Fastest linter + formatter (RECOMMENDED — replaces flake8, isort, black, pydocstyle) |
| **pylint** | pylint>=3.3.0 | Comprehensive linter (style, complexity, conventions) |
| **flake8** | flake8>=7.1.0 | Style guide enforcement (PEP 8) |
| **black** | black>=24.10.0 | Opinionated code formatter |
| **isort** | isort>=5.13.0 | Import sorting |
| **mypy** | mypy>=1.14.0 | Static type checking |
| **pyright** | pyright>=1.1.390 | Microsoft's static type checker |
| **pyupgrade** | pyupgrade>=3.17.0 | Upgrade syntax to newer Python versions |
| **pydocstyle** | pydocstyle>=6.3.0 | Docstring style checking |
| **autoflake** | autoflake>=2.3.0 | Remove unused imports and variables |
| **bandit** | bandit>=1.8.0 | Security linter for Python code |
| **pycodestyle** | pycodestyle>=2.12.0 | PEP 8 style checks |
| **pyflakes** | pyflakes>=3.2.0 | Find programming errors (no style) |

---

## Linting Policy

**New files Claude writes** are auto-linted with `ruff check --fix` before being presented to the user. This is always done — no need to ask.

**Existing code** is NOT touched unless Claude is explicitly tasked with linting it. When Claude notices linting issues in existing code, Claude should **ask the user** before running any linting or auto-fix.

```
When writing NEW files:   auto-lint with ruff check --fix
When touching EXISTING:   ask first: "Lint the existing code? (yes/no)"
```

## Recommended Workflow for Claude-Driven Python Development

```bash
# 1. Lint new files (auto — Claude does this automatically)
ruff check .              # lint all files
ruff check --fix .        # auto-fix fixable issues
ruff format .             # format code (or use black)

# 2. Full lint stack (ask before running on existing code)
ruff check . && pylint . && mypy . && bandit -r .

# 3. Upgrade syntax (ask before modifying existing code)
pyupgrade --py310 *.py

# 4. Clean unused imports (ask before modifying existing code)
autoflake --remove-all-unused-imports --recursive .

# 5. Sort imports (ask before modifying existing code)
isort .                   # or: ruff check --select I . --fix
```

---

## Core Linting

### ruff (RECOMMENDED — use for all Python code)

The fastest all-in-one linter. Replaces flake8, isort, black, pydocstyle, and more.

```bash
# Lint all files (fast — written in Rust)
ruff check .

# Auto-fix fixable issues
ruff check --fix .

# Format code (replaces black)
ruff format .

# Check without modifying (dry-run)
ruff format --check .

# With pyproject.toml config
ruff check -c pyproject.toml .

# Check specific files
ruff check src/module.py tests/test_module.py

# List available rules
ruff rule E501           # show rule documentation

# Show current config
ruff check --show-config

# Performance — ~10-100x faster than pylint
time ruff check .        # typically <1s for entire project
```

#### ruff Linters (from pyproject.toml)

| Rule Prefix | Source | Purpose |
|-------------|--------|---------|
| **E/W** | pycodestyle | PEP 8 errors and warnings |
| **F** | pyflakes | Programming errors (unused imports, undefined names) |
| **I** | isort | Import sorting |
| **N** | pep8-naming | Naming conventions |
| **UP** | pyupgrade | Syntax upgrades to newer Python |
| **B** | flake8-bugbear | Common bugs and design issues |
| **SIM** | flake8-simplify | Simplify expressions |
| **TCH** | flake8-type-checking | Type hint imports |
| **DTZ** | flake8-datetimez | Datetime timezone issues |
| **RUF** | ruff-specific | Ruff-specific rules |
| **PLE/PLR/PLW** | pylint | Errors, refactor, warnings |
| **G** | flake8-logging-format | Logging format strings |
| **RET** | flake8-return | Return statement simplification |
| **C4** | flake8-comprehensions | Comprehension style |
| **PIE** | flake8-pie | Unnecessary statements |
| **PYI** | flake8-pyi | Typing stub file style |

#### ruff Recommended Flags

```bash
# CRITICAL: Use ruff check as the default linter for Python code

# ruff check — comprehensive linting (replaces flake8 + pyflakes + pycodestyle)
# Covers: imports, unused code, naming, complexity, PEP 8, bugbear

# ruff format — code formatting (replaces black)
# Consistent style, zero-config opinionated formatting
```

**Recommendation**: Auto-fix issues in code Claude is actively writing. For existing code not being touched by the current task, report linting issues to the user and offer to run `ruff check --fix` if asked.

---

### pylint

Comprehensive linter with deep code analysis. Slower than ruff but more detailed.

```bash
# Full linting with default settings
pylint .

# With pyproject.toml config
pylint -c pyproject.toml .

# Check specific file
pylint src/module.py

# Specific checks only
pylint --disable=C,R,W .     # only errors (E)

# Output as JSON
pylint --output-format=json . | jq '.[] | .message'

# Check function complexity
pylint --enable=C901,R0904 .

# Detailed output
pylint --reports=y .
```

#### pylint Common Check Codes

| Code | Category | Description |
|------|----------|-------------|
| C0114/C0115/C0116 | convention | Missing module/class/function docstring |
| C0301 | convention | Line too long |
| C0330 | formatting | Wrong horizontal space before colon |
| R0902 | refactor | Too many instance attributes |
| R0903 | refactor | Too few public methods |
| R0904 | refactor | Too many public methods |
| R0912 | refactor | Too many branches |
| R0913 | refactor | Too many arguments |
| R0914 | refactor | Too many local variables |
| W0120 | warning | Useless else |
| W0612 | warning | Unused variable |
| W0613 | warning | Unused argument |
| E0102 | error | Function has a local shadowing a name |
| E1101 | error | Module has no member |
| E0602 | error | Undefined variable |

---

## Formatting

### black — The Code Formatter

```bash
# Format all Python files
black .

# Check without modifying (dry-run)
black --check .

# Diff what would change
black --diff .

# Format specific files
black src/module.py tests/test_module.py

# Custom line length
black --line-length 120 .

# Exclude patterns
black --exclude="(\.git|\.venv|__pycache__|\.mypy_cache)" .
```

### isort — Import Sorting

```bash
# Sort imports in all files
isort .

# Check without modifying
isort --check-only .

# Sort specific file
isort src/module.py

# Diff changes
isort --diff .

# With pyproject.toml config
isort --settings-path pyproject.toml .
```

### pycodestyle — PEP 8 Style

```bash
# Check PEP 8 compliance
pycodestyle .

# Specific errors only
pycodestyle --select=E,W .

# Custom max line length
pycodestyle --max-line-length=100 .
```

### pyflakes — Find Programming Errors

```bash
# Find undefined names, unused imports, reimports
pyflakes .

# Specific file
pyflakes src/module.py
```

---

## Type Checking

### mypy — Static Type Checker

```bash
# Type check all files
mypy .

# Check specific file
mypy src/module.py

# With pyproject.toml config
mypy -c pyproject.toml .

# Incremental (faster on re-run)
mypy --cache-dir=.mypy_cache .

# Strict mode
mypy --strict .

# Show error codes
mypy --show-error-codes .

# Output as JSON
mypy --json-output . | jq '.'
```

### pyright — Microsoft's Type Checker

```bash
# Type check all files
pyright .

# Check specific file
pyright src/module.py

# Watch mode (re-check on file change)
pyright --watch .

# With pyproject.toml config
pyright --project --config pyrightconfig.json .

# Output details
pyright --outputdetails .
```

---

## Code Quality & Upgrades

### pyupgrade — Upgrade Syntax

```bash
# Upgrade syntax to Python 3.10+
pyupgrade --py310 *.py

# Upgrade to specific version
pyupgrade --py39 --py311 *.py

# Preview what would change
pyupgrade --py310 --diff *.py

# Recursively upgrade
pyupgrade --py310 **/*.py
```

### autoflake — Remove Unused Code

```bash
# Remove unused imports
autoflake --remove-all-unused-imports -r .

# Remove unused variables
autoflake --remove-unused-variables -r .

# Both
autoflake --remove-all-unused-imports --remove-unused-variables -r .

# In-place modification
autoflake --in-place --remove-all-unused-imports *.py

# Ignore specific patterns
autoflake --ignore-init-module-imports -r .
```

### pydocstyle — Docstring Style

```bash
# Check docstrings (D codes)
pydocstyle .

# Only missing docstrings
pydocstyle --add-select=D1,D2,D3 .

# Ignore specific rules
pydocstyle --ignore=D203,D212,D407 .

# One per line
pydocstyle --add-select=D208 .
```

---

## Security

### bandit — Security Linter

```bash
# Audit all Python files for security issues
bandit -r .

# Specific severity levels
bandit -r -ll .     # medium and high
bandit -r -hhh .    # all levels

# Output as JSON
bandit -r -f json . | jq '.'

# Exclude directories
bandit -r --exclude=tests,.git .

# Show inline comments for issues
bandit -r -v .

# Check specific file
bandit src/module.py
```

#### bandit Common Issues

| Code | Severity | Description |
|------|----------|-------------|
| B101 | low | assert used (not security issue but noisy) |
| B301 | medium | Pickle/Unpickle used |
| B303 | high | Used with weak crypto |
| B310 | medium | URL open using HTTP |
| B404 | medium | Import subprocess |
| B603 | high | subprocess call without shell=True check |
| B606 | high | subprocess call without explicit shell |
| B105 | medium | Hardcoded password |
| B106 | medium | Hardcoded username |

---

## Comprehensive Linting

### Full Python Lint Stack

```bash
# Run ALL tools in one command (recommended CI command)
ruff check . && \
pylint --disable=C0114,C0115,C0116,R0903 . && \
mypy --ignore-missing-imports . && \
bandit -r -ll . && \
pyupgrade --py310 *.py --diff && \
isort --check-only . && \
black --check . && \
pydocstyle --ignore=D203,D212 . && \
autoflake --check --remove-all-unused-imports -r .
```

### Minimal Lint Stack (Recommended for most projects)

```bash
# Use ruff as the primary tool (fastest, most comprehensive)
ruff check .            # lint (replaces flake8, pyflakes, pycodestyle)
ruff check --fix .      # auto-fix
ruff format .           # format (replaces black)
mypy .                  # type check
bandit -r .             # security
```

---

## Anti-Patterns

- **Cognitive complexity > 15** — function should be split (mypy/ruff catch this)
- **Function length > 150 lines** — consider extracting helpers (pylint R0915)
- **Unpacking too many values** — use *rest pattern (mypy)
- **Mixing positional and keyword args** — prefer explicit keyword args
- **Unnecessary complex code** — simplify with ruff SIM rules
- **Mutable default arguments** — use None sentinel (pylint W0102)
- **Unused imports** — autoflake or ruff check (F401)
- **Mixed type hints** — be consistent with Union vs | (pyupgrade UP007)

---

## Recommended Workflow for Claude-Driven Python Development

```bash
# 1. During coding: ruff provides real-time diagnostics
ruff check --watch .
# New files are auto-linted with ruff check --fix before presenting to user.

# 2. Before committing: run full lint stack (ask first for existing code)
ruff check . && pylint . && mypy . && bandit -r .

# 3. Quick fix all issues (ask before modifying existing code)
ruff check --fix . && autoflake --in-place --remove-all-unused-imports -r .

# 4. Check formatting (dry-run first for existing code)
ruff format --check . && isort --check-only .

# 5. Upgrade syntax (ask before modifying existing code)
pyupgrade --py310 **/*.py

# 6. Security audit (read-only — safe)
bandit -r -f json . | jq '.results[] | select(.severity == "HIGH")'
```

---

## pyproject.toml Reference

See `./pyproject.toml` in this directory for the full recommended configuration:

```yaml
# Key settings from pyproject.toml

# ruff
[tool.ruff]
target-version = "py310"
line-length = 100

[tool.ruff.lint]
select = ["E", "W", "F", "I", "N", "UP", "B", "SIM", "TCH", "DTZ", "RUF",
          "PLE", "PLR", "PLW", "G", "RET", "C4", "PIE", "PYI"]
ignore = ["E501", "RET504", "SIM108"]

# black
[tool.black]
line-length = 100
target-version = ["py310"]

# isort
[tool.isort]
line_length = 100
profile = "black"

# mypy
[tool.mypy]
strict = true
python_version = "3.10"

# bandit
[tool.bandit]
skips = ["B101"]
```
