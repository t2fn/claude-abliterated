#!/bin/bash
# 02-configure-ghidra-mcp — Ghidra + MCP config, startup, and health check.
#
# Consolidates: 02-configure-and-start-mcp + 02-ghidra-server + 03-verify-mcp
#
# 1. Creates config dirs (.ghidra, .ghidra-mcp, /tmp/ghidra-mcp)
# 2. Reads port from .mcp.json (via jq), port.txt, or defaults to 48080
# 3. Creates/updates /workdir/.claude/.mcp.json
# 4. Sets GHIDRA_MCP_STARTED=1 so 03-claude knows we're the server
# 5. Launches ghidra-mcp and health-checks it in a loop

# Create config dirs
mkdir -p /workdir/.ghidra-mcp /workdir/.ghidra /tmp/ghidra-mcp/projects

# Copy build-time defaults if needed
cp -n /home/claudeuser/.ghidra-mcp/* /workdir/.ghidra-mcp/ 2>/dev/null || true
cp -n /home/claudeuser/.ghidra/* /workdir/.ghidra/ 2>/dev/null || true

# --- Read config values ---
GHIDRA_MCP_PROJECT_NAME="${GHIDRA_MCP_PROJECT_NAME:=mcp_project}"
GHIDRA_MCP_MODE="${GHIDRA_MCP_MODE:=full}"
GHIDRA_MCP_PORT="${GHIDRA_MCP_PORT:=48080}"

# Allow project_name.txt / mode.txt overrides
for f in project_name mode; do
    if [ -f "/workdir/.ghidra-mcp/${f}.txt" ]; then
        val=$(cat "/workdir/.ghidra-mcp/${f}.txt" 2>/dev/null)
        [ -n "$val" ] && eval "GHIDRA_MCP_${f^^}=$val"
    fi
done

# --- Port resolution (via jq on .mcp.json) ---
MCP_JSON="/workdir/.claude/.mcp.json"
port_resolved=0

if [ -f "$MCP_JSON" ] && command -v jq >/dev/null 2>&1; then
    top_port=$(jq -r '.mcpServers.ghidra.port // empty' "$MCP_JSON" 2>/dev/null)
    if [ -n "$top_port" ] && [ "$top_port" != "null" ]; then
        GHIDRA_MCP_PORT="$top_port"
        port_resolved=1
        echo "[pre-start] Port from .mcp.json top-level port: $GHIDRA_MCP_PORT"
    else
        json_port=$(jq -r '.mcpServers.ghidra.args // empty | tostring | split("--port ") | last | split(" ") | first' "$MCP_JSON" 2>/dev/null)
        if [ -n "$json_port" ] && [ "$json_port" != "null" ]; then
            GHIDRA_MCP_PORT="$json_port"
            port_resolved=1
            echo "[pre-start] Port from .mcp.json args: $GHIDRA_MCP_PORT"
        fi
    fi
fi

if [ "$port_resolved" -eq 0 ] && [ -f /workdir/.ghidra-mcp/port.txt ]; then
    file_val=$(cat /workdir/.ghidra-mcp/port.txt 2>/dev/null)
    if [ -n "$file_val" ]; then
        GHIDRA_MCP_PORT="$file_val"
        port_resolved=1
        echo "[pre-start] Port from port.txt: $GHIDRA_MCP_PORT"
    fi
fi

GHIDRA_MCP_PORT="${GHIDRA_MCP_PORT:-48080}"

# --- Write .mcp.json ---
if [ -f "$MCP_JSON" ]; then
    jq --arg port "$GHIDRA_MCP_PORT" \
       --arg name "$GHIDRA_MCP_PROJECT_NAME" \
       --arg mode "$GHIDRA_MCP_MODE" \
       '(.mcpServers.ghidra.args) = "--project-dir /tmp/ghidra-mcp/projects --project-name \($name) --mode \($mode) --transport streamable-http --host 127.0.0.1 --port \($port)"' \
       "$MCP_JSON" > /tmp/mcp_tmp.json && mv /tmp/mcp_tmp.json "$MCP_JSON"
else
    mkdir -p /workdir/.claude
    cat > "$MCP_JSON" <<MCPEOF
{
  "mcpServers": {
    "ghidra": {
      "command": "ghidra-mcp",
      "args": "--project-dir /tmp/ghidra-mcp/projects --project-name ${GHIDRA_MCP_PROJECT_NAME} --mode ${GHIDRA_MCP_MODE} --transport streamable-http --host 127.0.0.1 --port ${GHIDRA_MCP_PORT}",
      "env": {
        "GHIDRA_INSTALL_DIR": "${GHIDRA_INSTALL_DIR:-/opt/ghidra}",
        "GHIDRA_ANALYSIS_TIMEOUT_SECONDS": "${GHIDRA_ANALYSIS_TIMEOUT_SECONDS:-300}",
        "GHIDRA_MAX_HEAP": "${GHIDRA_MAX_HEAP:-2g}",
        "JAVA_HOME": "${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}"
      }
    }
  }
}
MCPEOF
    echo "[pre-start] Created .mcp.json at $MCP_JSON with port $GHIDRA_MCP_PORT"
fi

# --- Export all env ---
export GHIDRA_INSTALL_DIR
export GHIDRA_ANALYSIS_TIMEOUT_SECONDS
export GHIDRA_MAX_HEAP
export JAVA_HOME
export GHIDRA_MCP_PROJECT_NAME
export GHIDRA_MCP_MODE
export GHIDRA_MCP_PORT

# --- Launch ghidra-mcp (set GHIDRA_MCP_STARTED before launch) ---
export GHIDRA_MCP_STARTED=1

ghidra-mcp \
    --project-dir /tmp/ghidra-mcp/projects \
    --project-name "$GHIDRA_MCP_PROJECT_NAME" \
    --mode "$GHIDRA_MCP_MODE" \
    --transport streamable-http \
    --host 127.0.0.1 \
    --port "$GHIDRA_MCP_PORT" \
    >> /tmp/ghidra-mcp.log 2>&1 &

GHIDRA_MCP_PID=$!
CLAUDE_GHIDRA_PID=$GHIDRA_MCP_PID
echo "$GHIDRA_MCP_PID" > /tmp/ghidra-mcp/mcp_pid.txt

echo "[pre-start] Ghidra MCP server started (PID: $GHIDRA_MCP_PID, port: $GHIDRA_MCP_PORT) GHIDRA_MCP_STARTED=$GHIDRA_MCP_STARTED"

# --- Health check (both /health and /mcp) ---
echo "[pre-start] Verifying MCP server health on port ${GHIDRA_MCP_PORT}..."
for i in $(seq 1 15); do
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${GHIDRA_MCP_PORT}/health" 2>/dev/null || echo "000")
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        # /health responds — also check /mcp endpoint
        mcp_code=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${GHIDRA_MCP_PORT}/mcp" 2>/dev/null || echo "000")
        if [ "$mcp_code" -ge 200 ] && [ "$mcp_code" -lt 300 ]; then
            echo "[pre-start] MCP server ready (health OK, /mcp $mcp_code) after ${i}s"
            break
        fi
        # /health up but /mcp not ready yet
        [ "$i" -eq 15 ] && echo "[pre-start] WARNING: /mcp endpoint still settling (HTTP $mcp_code)"
    fi
    sleep 2
done
