#!/bin/bash
# 04-configure-claude — Pre-start hook for Claude configuration.
#
# Sets up auto-compact, config directory, writes .mcp.json,
# and registers the server with `claude mcp add`.
# Reads GHIDRA_MCP_PORT and other values from 02-configure-ghidra-mcp.sh.

# Auto-compact settings
: "${CLAUDE_CODE_AUTO_COMPACT_WINDOW:=200000}"
: "${CLAUDE_AUTOCOMPACT_PCT_OVERRIDE:=95}"
export CLAUDE_CODE_AUTO_COMPACT_WINDOW CLAUDE_AUTOCOMPACT_PCT_OVERRIDE

# Claude config directory
: "${CLAUDE_CONFIG_DIR:=$HOME/.claude}"
export CLAUDE_CONFIG_DIR

CLAUDE_MODE="${CLAUDE_MODE:-full}"

#if [ ! -e "./.claude" ]; then
#    rsync -a $HOME/.claude/ $CLAUDE_CONFIG_DIR/ 2>/dev/null || true
#fi

#MCP_FILE="/workdir/.claude/.mcp.json"
#mkdir -p /workdir/.claude
#
#cat > "$MCP_FILE" <<MCPEOF
#{
#  "mcpServers": {
#    "ghidra": {
#      "command": "ghidra-mcp",
#      "args": "--project-dir /tmp/ghidra-mcp/projects --project-name ${GHIDRA_MCP_PROJECT_NAME} --mode ${GHIDRA_MCP_MODE} --transport sse --host 127.0.0.1 --port ${GHIDRA_MCP_PORT}",
#      "env": {
#        "GHIDRA_INSTALL_DIR": "${GHIDRA_INSTALL_DIR}",
#        "GHIDRA_ANALYSIS_TIMEOUT_SECONDS": "${GHIDRA_ANALYSIS_TIMEOUT_SECONDS}",
#        "GHIDRA_MAX_HEAP": "${GHIDRA_MAX_HEAP}",
#        "JAVA_HOME": "${JAVA_HOME}"
#      }
#    }
#  }
#}
#MCPEOF

# Wait for /mcp endpoint to be ready (server binds 127.0.0.1, not ::1)
#sleep 3
claude mcp add --transport http ghidra http://127.0.0.1:$GHIDRA_MCP_PORT/mcp || true
echo "[pre-start] Claude configured: MCP_FILE=$MCP_FILE CLAUDE_MODE=$CLAUDE_MODE GHIDRA_MCP_PORT=$GHIDRA_MCP_PORT"
