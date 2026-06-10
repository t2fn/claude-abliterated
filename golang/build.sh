#!/bin/bash
# ============================================================================
# build.sh — Build the golang-claude Docker image on top of claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     Go 1.26.4 + gopls, dlv, gotests, goplay, gomodifytags,
#           impl, staticcheck, golangci-lint, revive, go-critic, goimports, godoc
# Configs:  golangci.yml (recommended linter config)
# PATH:     /home/claudeuser/go/bin + /usr/local/go/bin
#
# Environment variables:
#   IMAGE_NAME   — Docker image name   (default: t2fn/golang-claude-abliterated)
#   IMAGE_TAG    — Docker image tag    (default: latest)
#   GO_VER       — Go version          (default: 1.26.4)
#   GO_SHA256    — Go binary SHA256    (default: 1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f)
# ==================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-t2fn/golang-claude-abliterated}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
GO_VER="${GO_VER:-1.26.4}"
GO_SHA256="${GO_SHA256:-1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f}"

# ── Source pinned SHAs ──
if [ -f "${SCRIPT_DIR}/source.shas" ]; then
    . "${SCRIPT_DIR}/source.shas"
fi

echo "====== GOLANG-CLAUDLE BUILDER ========="
echo "  Base:       docker.io/t2fn/claude-abliterated:rocky10-amd64"
echo "  Image:      ${IMAGE_NAME}:${IMAGE_TAG}"
echo "  Go:         ${GO_VER}"
echo "  Go SHA256:  ${GO_SHA256}"
echo "========================================="

# ── Build ──
echo ""
echo ">> Building image..."
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    --build-arg GO_VER="${GO_VER}" \
    --build-arg GO_SHA256="${GO_SHA256}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"

echo ">> Image built: ${IMAGE_NAME}:${IMAGE_TAG}"

# ── Smoke test ──
echo ""
echo ">> Running smoke test..."

docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e OLLAMA_MODEL="${OLLAMA_MODEL:-huihui_ai/Qwen3.6-abliterated:35b}" \
    -e OLLAMA_HOST="10.12.2.4" \
    -e ANTHROPIC_API_KEY="sk-test-key" \
    -e GOROOT="/usr/local/go" \
    -e GOPATH="/home/claudeuser/go" \
    -e GOBIN="/home/claudeuser/go/bin" \
    -e PATH="/home/claudeuser/go/bin:/usr/local/go/bin:/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    -v "${PWD}:/workdir:rw" \
    --entrypoint /bin/bash \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    -c '
set -ex

echo "[smoke] Go version: $(go version)"

# Verify all tools are accessible
TOOLS="gopls dlv gotests goplay gomodifytags impl staticcheck golangci-lint revive gocritic goimports godoc go"
for tool in $TOOLS; do
    if command -v $tool > /dev/null 2>&1; then
        echo "[smoke] $tool: OK"
    else
        echo "[smoke] FAIL: $tool not found"
        exit 1
    fi
done

# Test golangci-lint runs with our config
echo "[smoke] Testing golangci-lint config..."
golangci-lint linters 2>&1 | head -5

# Test go can compile and lint a simple file
echo "[smoke] Testing go toolchain..."
cat > /tmp/hello.go <<'"'"'EOF'"'"'
package main

import "fmt"

func add(a, b int) int {
    return a + b
}

func main() {
    fmt.Println(add(6, 7))
}
EOF

go build -o /tmp/hello /tmp/hello.go
/tmp/hello

echo "[smoke] Running golangci-lint on hello.go..."
golangci-lint run /tmp/hello.go 2>&1 || true

echo "[smoke] PASSED"
' 2>&1 | tee /tmp/golang-claude-smoke.log

if grep -qi "FAIL" /tmp/golang-claude-smoke.log; then
    echo ""
    echo ">> Smoke test FAILED"
    exit 1
fi

echo ""
echo "====== GOLANG-CLAUDLE BUILDER ========="
echo "  Smoke test PASSED"
echo "========================================="
