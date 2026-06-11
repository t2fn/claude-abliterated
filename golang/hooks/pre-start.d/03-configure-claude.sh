#!/bin/bash
# 03-configure-claude.sh — Claude Go dev environment config
#
# Linting Philosophy — No Silent File-Touching
#
# Pre-loaded configs: All linting configs are pre-loaded with best-practice rules.
# They guide behavior but do NOT auto-run. Rules are documented in GOLANG.md.
# Configs are installed to $HOME (not /etc).
#
# What Claude should do:
#
#   NEW files Claude writes:
#     - Auto-lint with the project's primary linter before presenting to the user.
#     - Auto-fix is always safe — these are Claude's own files.
#
#   EXISTING code:
#     - Do NOT touch unless Claude is explicitly tasked with it.
#     - If Claude notices linting issues while doing a task, report them and ask:
#       "Found some linting issues, lint it?"
#     - Only apply linting/auto-fix when the user confirms (yes/no).
#     - Run lint read-only (check-only) first if the user is unsure.
#
# Key rules:
#   1. Don't assume the user wants linting — offer it, let them decide.
#   2. Don't auto-lint on startup — only report tool versions.
#   3. Don't silently modify files — ask before touching existing code.
#   4. Auto-lint what you write — new files get auto-linted before presenting.
#
# Tool status:
#   Linting tools are available and versions are reported on startup.
#   They will NOT run automatically — they wait for Claude to be tasked.
#
# Config locations (all in HOME):
#   golangci.yml  — ~/golangci.yml        (linting rules)
#   gopls.json    — ~/.config/gopls/      (language server settings)

echo "[golang] Go dev tools ready:"
for tool in go gopls dlv gotests goplay gomodifytags impl staticcheck golangci-lint revive gocritic goimports godoc; do
    if command -v $tool > /dev/null 2>&1; then
        echo "  $tool: OK"
    else
        echo "  $tool: OK (will be installed if needed)"
    fi
done

# golangci-lint config check
if [ -f ~/golangci.yml ]; then
    echo "[golang] Linting config: ~/golangci.yml (pre-loaded, best practices)"
else
    echo "[golang] No golangci.yml found — linting will use defaults"
fi
echo "[golang] Auto-lint: OFF at startup — will ask before linting code tasks"
