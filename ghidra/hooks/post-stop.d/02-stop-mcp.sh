#!/bin/bash
# 02-stop-mcp — Post-stop hook for Ghidra MCP server cleanup.
#
# Stops the ghidra-mcp server using both the PID file and process
# matching. Cleans up the marker file.

# Stop via PID file
MCP_PID_FILE=/tmp/ghidra-mcp/mcp_pid.txt
if [ -f "$MCP_PID_FILE" ]; then
    GHIDRA_MCP_PID=$(cat "$MCP_PID_FILE")
    if [ -n "$GHIDRA_MCP_PID" ] && kill -0 "$GHIDRA_MCP_PID" 2>/dev/null; then
        echo "[post-stop] Stopping ghidra-mcp (PID: $GHIDRA_MCP_PID)..."
        kill "$GHIDRA_MCP_PID" 2>/dev/null || true
        wait "$GHIDRA_MCP_PID" 2>/dev/null || true
    fi
fi

# Stop via CLAUDE_GHIDRA_PID (set by start_claude.sh)
if [ -n "$CLAUDE_GHIDRA_PID" ] && [ "$CLAUDE_GHIDRA_PID" -gt 0 ] 2>/dev/null; then
    if kill -0 "$CLAUDE_GHIDRA_PID" 2>/dev/null; then
        echo "[post-stop] Stopping ghidra-mcp (PID: $CLAUDE_GHIDRA_PID)..."
        kill "$CLAUDE_GHIDRA_PID" 2>/dev/null || true
        wait "$CLAUDE_GHIDRA_PID" 2>/dev/null || true
    fi
fi

# Catch any remaining ghidra-mcp processes
pkill -f "ghidra-mcp.*--transport sse" 2>/dev/null || true

# Remove marker file
rm -f /tmp/.ghidra_mcp_started

echo "[post-stop] MCP cleanup complete."
