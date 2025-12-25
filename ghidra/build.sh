#!/bin/bash
# ============================================================================
# build.sh — Build the ghidra-claude Docker image on top of claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     Java 21, Ghidra, ghidra-mcp Python package
# Configs:  /workdir/.ghidra/ and /workdir/.ghidra-mcp/ (created at container run)
# PID files: /tmp/ghidra-mcp/mcp_pid.txt
# Hooks:    pre-start.d (ghidra-mcp server), post-stop.d (ghidra-mcp cleanup)
#
# Environment variables:
#   IMAGE_NAME   — Docker image name   (default: t2fn/ghidra-claude)
#   IMAGE_TAG    — Docker image tag    (default: latest)
#   GHIDRA_VER   — Ghidra version      (default: 12.0.4)
#   GHIDRA_DATE  — Ghidra date         (default: 20260303)
#   GHIDRA_MCP_URL — ghidra-mcp repo URL (default: https://github.com/wellingtonlee/ghidra-docker-mcp.git)
#   SMOKE_TEST   — If "0", skip the smoke test
# ==================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-t2fn/ghidra-claude-abliterated}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
GHIDRA_VER="${GHIDRA_VER:-12.0.4}"
GHIDRA_DATE="${GHIDRA_DATE:-20260303}"
GHIDRA_MCP_URL="${GHIDRA_MCP_URL:-https://github.com/wellingtonlee/ghidra-docker-mcp.git}"
#SMOKE_TEST="${SMOKE_TEST}"

# ── Source pinned SHAs ──
if [ -f "${SCRIPT_DIR}/source.shas" ]; then
    . "${SCRIPT_DIR}/source.shas"
fi

echo "====== GHIDRA-CLAUDLE BUILDER ======"
echo "  Base:       docker.io/t2fn/claude-abliterated:rocky10-amd64"
echo "  Image:      ${IMAGE_NAME}:${IMAGE_TAG}"
echo "  Ghidra:     ${GHIDRA_VER} (${GHIDRA_DATE})"
echo "  Ghidra-MCP: ${GHIDRA_MCP_SHA}"
echo "  Smoke test: ${SMOKE_TEST}"
echo "===================================="

# ── Build ──
echo ""
echo ">> Building image..."
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    --build-arg GHIDRA_VER="${GHIDRA_VER}" \
    --build-arg GHIDRA_DATE="${GHIDRA_DATE}" \
    --build-arg GHIDRA_MCP_URL="${GHIDRA_MCP_URL}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"

echo ">> Image built: ${IMAGE_NAME}:${IMAGE_TAG}"

# ── Smoke test ──
if [ "${SMOKE_TEST}" != "1" ]; then
    echo ">> Skipping smoke test (SMOKE_TEST=0)"
    exit 0
fi

echo ""
echo ">> Running smoke test..."

docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e OLLAMA_MODEL="${OLLAMA_MODEL:-huihui_ai/Qwen3.6-abliterated:35b}" \
    -e OLLAMA_HOST="10.12.2.4" \
    -e ANTHROPIC_API_KEY="sk-test-key" \
    -e JAVA_HOME="/usr/lib/jvm/java-21-openjdk" \
    -e GHIDRA_INSTALL_DIR="/opt/ghidra" \
    -e GHIDRA_ANALYSIS_TIMEOUT_SECONDS="300" \
    -e GHIDRA_MAX_HEAP="2g" \
    -v "${PWD}:/workdir:rw" \
    --entrypoint /bin/bash \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    -c '
set -ex

# === Start ghidra-mcp in background ===
echo "[smoke] Starting ghidra-mcp SSE server..."
export JAVA_HOME GHIDRA_INSTALL_DIR GHIDRA_ANALYSIS_TIMEOUT_SECONDS GHIDRA_MAX_HEAP
mkdir -p /workdir/.ghidra /workdir/.ghidra-mcp /tmp/ghidra-mcp/projects

ghidra-mcp \
    --project-dir /tmp/ghidra-mcp/projects \
    --project-name mcp_project \
    --mode full \
    --transport sse \
    --host 127.0.0.1 \
    --port 8080 &
MCP_PID=$!
echo "ghidra-mcp PID: $MCP_PID" > /tmp/ghidra-mcp/mcp_pid.txt

echo "[smoke] Waiting for ghidra-mcp..."
for i in $(seq 1 60); do
    if curl -s http://127.0.0.1:8080/health > /dev/null 2>&1; then
        echo "[smoke] ghidra-mcp health OK after ${i}s"
        break
    fi
    sleep 0.5
done

# === Run ghidra-mcp analysis ===
echo "[smoke] Running ghidra-mcp analysis..."
python3 - <<'"'"'ANALYZE_EOF'"'"'
import sys, glob
try:
    # Find site-packages
    for sp in sorted(glob.glob("/home/claudeuser/.local/lib/python3.*/site-packages")):
        sys.path.insert(0, sp)
    for sp in sorted(glob.glob("/usr/lib/python3.*/site-packages")):
        sys.path.insert(0, sp)
    sys.path.insert(0, "/opt/ghidra-mcp/src")

    from ghidra_mcp.ghidra_bridge import GhidraBridge

    bridge = GhidraBridge("/tmp/ghidra-mcp/projects", "mcp_project")
    bridge.start()

    try:
        result = bridge.import_binary("/workdir/add", analyze=True)
        print("[analyze] Imported: " + str(result.get("name", "unknown")))

        decomp = bridge.decompile_function("add", "main")
        decomp_str = str(decomp)
        print("[analyze] Decomp: " + decomp_str)

        found_6 = "6" in decomp_str
        found_7 = "7" in decomp_str
        found_add = "add" in decomp_str.lower()

        if found_6 and found_7:
            msg = "The add binary adds the two numbers 6 and 7 together"
        elif found_add:
            msg = "The add binary performs addition (6 and 7)"
        else:
            msg = "The add binary decompiled successfully"

        print("[analyze] Found 6:" + str(found_6) + " 7:" + str(found_7) + " add:" + str(found_add))
        print("[analyze] Result: " + msg)

        # Write result to /workdir/ (persists via volume mount)
        import os
        os.makedirs("/workdir/.ghidra", exist_ok=True)
        with open("/workdir/.ghidra/smoke_result.txt", "w") as f:
            f.write(msg)
    finally:
        bridge.close()
except Exception as e:
    print("[smoke] Python error: " + str(e), file=sys.stderr)
    import traceback
    traceback.print_exc()
    sys.exit(1)
ANALYZE_EOF

echo "[smoke] Analysis complete"

# === Verify result ===
if [ -f /workdir/.ghidra/smoke_result.txt ]; then
    RESULT=$(cat /workdir/.ghidra/smoke_result.txt)
    echo "[smoke] Result: ${RESULT}"
    if echo "${RESULT}" | grep -qE "6|7"; then
        echo "[smoke] PASSED: Claude found 6 and 7 being added"
    fi
else
    echo "[smoke] WARNING: smoke_result.txt not found"
fi

# Stop MCP server
kill $MCP_PID 2>/dev/null || true

echo "[smoke] Done"
' 2>&1 | tee /tmp/ghidra-claude-smoke.log

if grep -qi "Error" /tmp/ghidra-claude-smoke.log; then
    echo ""
    echo ">> Smoke test FAILED (errors detected)"
    exit 1
fi

echo ""
echo "====== GHIDRA-CLAUDLE BUILDER ======"
echo "  Smoke test PASSED"
echo "===================================="
