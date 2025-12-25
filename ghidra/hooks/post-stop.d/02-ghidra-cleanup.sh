#!/bin/bash
# 02-ghidra-cleanup — Post-stop hook for Ghidra MCP server.
#
# Stops the ghidra-mcp server after Claude exits.
# PID file read from /tmp/ (cleaned on container exit).

# Read the PID file from /tmp/
MCP_PID_FILE=/tmp/ghidra-mcp/mcp_pid.txt
if [ -f "$MCP_PID_FILE" ]; then
    GHIDRA_MCP_PID=$(cat "$MCP_PID_FILE")
    if [ -n "$GHIDRA_MCP_PID" ] && kill -0 "$GHIDRA_MCP_PID" 2>/dev/null; then
        echo "[post-stop] Stopping ghidra-mcp (PID: $GHIDRA_MCP_PID)..."
        kill "$GHIDRA_MCP_PID" 2>/dev/null || true
        wait "$GHIDRA_MCP_PID" 2>/dev/null || true
    fi
fi

# Kill any lingering ghidra-mcp processes
pkill -f "ghidra-mcp.*--transport sse" 2>/dev/null || true

echo "[post-stop] Ghidra MCP cleanup complete."
