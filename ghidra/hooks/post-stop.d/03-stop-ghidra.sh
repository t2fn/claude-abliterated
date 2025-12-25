#!/bin/bash
# 03-stop-ghidra — Post-stop hook for socat socket forwarding.
#
# Stops the socat process if socket forwarding was active.

if [ -n "$SOCKET_PID" ] && kill -0 "$SOCKET_PID" 2>/dev/null; then
    echo "[post-stop] Stopping socat (PID: $SOCKET_PID)..."
    kill "$SOCKET_PID" 2>/dev/null || true
    wait "$SOCKET_PID" 2>/dev/null || true
fi

# Clean up port file
if [ -n "$SOCKET_PORT_FILE" ] && [ -e "$SOCKET_PORT_FILE" ]; then
    rm -f "$SOCKET_PORT_FILE"
fi

echo "[post-stop] Ghidra socket cleanup complete."
