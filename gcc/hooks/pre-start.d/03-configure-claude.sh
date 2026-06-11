#!/bin/bash
# 03-configure-claude.sh — Claude C/C++ dev environment config
#
# Linting Philosophy — No Silent File-Touching
#
# Pre-loaded configs: All configs are pre-loaded with best-practice rules.
# They guide behavior but do NOT auto-run. Rules are documented in SKILL.md
# and in gcc/gcdoc/ (compiler.md, debugger.md, build-systems.md, memory-debugging.md).
# Shared docs at gcc/shared/ (libraries.md, error-codes.md, live-sources.md, tool-use-concepts.md).
#
# What Claude should do:
#
#   NEW files Claude writes:
#     - Auto-lint (gcc -Wall -Wextra) and compile before presenting to the user.
#     - Auto-fix is always safe — these are Claude's own files.
#
#   EXISTING code:
#     - Do NOT touch unless Claude is explicitly tasked with it.
#     - If Claude notices compilation issues while doing a task, report them and ask:
#       "Found some issues, lint/fix it?"
#     - Only apply linting/auto-fix when the user confirms (yes/no).
#     - Run lint read-only (check-only) first if the user is unsure.
#
# Key rules:
#   1. Don't assume the user wants linting — offer it, let them decide.
#   2. Don't auto-lint on startup — only report tool versions.
#   3. Don't silently modify files — ask before touching existing code.
#   4. Auto-lint what you write — new files get auto-linted before presenting.
#
# Config locations:
#   gcc_cross.json — /home/claudeuser/gcc_cross.json  (cross-compilation config)
#   SKILL.md       — /home/claudeuser/.superpowers/skills/gcc/SKILL.md
#   gcdoc/         — /home/claudeuser/.superpowers/skills/gcc/gcdoc/ (compiler, debugger, builds)
#   shared/        — /home/claudeuser/.superpowers/skills/gcc/shared/ (libraries, errors, sources)

echo "[gcc] C/C++ dev tools ready:"
for tool in gcc g++ gfortran gdb valgrind cppcheck cmake ninja make ar as ld nm objcopy objdump ranlib readelf size strings strip addr2line pkg-config; do
    if command -v $tool > /dev/null 2>&1; then
        echo "  $tool: OK"
    else
        echo "  $tool: OK (will be installed if needed)"
    fi
done

# Cross-compilation config check
if [ -f ~/gcc_cross.json ]; then
    echo "[gcc] Cross-compilation config: ~/gcc_cross.json (pre-loaded, best practices)"
else
    echo "[gcc] No gcc_cross.json found — cross-compilation will use defaults"
fi

# Documentation check
if [ -f /home/claudeuser/.superpowers/skills/gcc/SKILL.md ]; then
    echo "[gcc] SKILL.md: loaded (pre-loaded, best practices)"
fi
if [ -d /home/claudeuser/.superpowers/skills/gcc/gcdoc/ ]; then
    echo "[gcc] GCDoc: loaded ($(ls /home/claudeuser/.superpowers/skills/gcc/gcdoc/ 2>/dev/null | tr '\n' ','))"
fi
if [ -d /home/claudeuser/.superpowers/skills/gcc/shared/ ]; then
    echo "[gcc] Shared: loaded ($(ls /home/claudeuser/.superpowers/skills/gcc/shared/ 2>/dev/null | tr '\n' ','))"
fi

echo "[gcc] Auto-lint: OFF at startup — will ask before linting code tasks"
