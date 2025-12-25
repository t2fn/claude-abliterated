#!/bin/bash
# 01-configure-ghidra — Ghidra environment and config dirs.
#
# Detects JAVA_HOME if unset. Sets all GHIDRA_ and CLAUDE_GHIDRA_*
# environment variables with safe defaults.

# Java home detection
if [ ! -d "${JAVA_HOME:-}" ]; then
    detected=$(find /usr/lib/jvm -maxdepth 1 -name 'java-21-openjdk-*' -type d 2>/dev/null | head -1)
    if [ -n "$detected" ]; then
        export JAVA_HOME="$detected"
        echo "[pre-start] Detected JAVA_HOME=$JAVA_HOME"
    fi
fi

# Ghidra environment — only set if truly unset/empty
export GHIDRA_INSTALL_DIR="${GHIDRA_INSTALL_DIR:-/opt/ghidra}"
export GHIDRA_ANALYSIS_TIMEOUT_SECONDS="${GHIDRA_ANALYSIS_TIMEOUT_SECONDS:-300}"
export GHIDRA_MAX_HEAP="${GHIDRA_MAX_HEAP:-2g}"
export CLAUDE_GHIDRA_AUTO_START="${CLAUDE_GHIDRA_AUTO_START:-true}"
export CLAUDE_GHIDRA_PORT="${CLAUDE_GHIDRA_PORT:-48080}"
export CLAUDE_GHIDRA_MODE="${CLAUDE_GHIDRA_MODE:-full}"
export CLAUDE_GHIDRA_PROJECT_DIR="${CLAUDE_GHIDRA_PROJECT_DIR:-/workdir/projects}"
export CLAUDE_GHIDRA_PROJECT_NAME="${CLAUDE_GHIDRA_PROJECT_NAME:-mcp_project}"

echo "[pre-start] Ghidra environment configured: GHIDRA_INSTALL_DIR=$GHIDRA_INSTALL_DIR JAVA_HOME=$JAVA_HOME"
