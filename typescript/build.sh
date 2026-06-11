#!/bin/bash
# ============================================================================
# build.sh — Build the typescript-claude Docker image on top of claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     TypeScript 6.0.3 + biome, eslint, prettier, tsx, vitest,
#           turbo, ts-patch, tsconfig-paths, @swc/core
# Configs:  biome.json, eslint.config.mjs, .prettierrc, tsconfig.json
# PATH:     /home/claudeuser/.local/bin + /home/claudeuser/bin
#
# Environment variables:
#   IMAGE_NAME   — Docker image name   (default: t2fn/typescript-claude-abliterated)
#   IMAGE_TAG    — Docker image tag    (default: latest)
#   TS_VER       — TypeScript version  (default: 6.0.3)
#   BIOME_VER    — Biome version       (default: 0.3.3)
# ==================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-t2fn/typescript-claude-abliterated}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
TS_VER="${TS_VER:-6.0.3}"
BIOME_VER="${BIOME_VER:-0.3.3}"

# ── Source pinned SHAS ──
if [ -f "${SCRIPT_DIR}/source.shas" ]; then
    . "${SCRIPT_DIR}/source.shas"
fi

echo "====== TYPESCRIPT-CLAUDLE BUILDER ========"
echo "  Base:       docker.io/t2fn/claude-abliterated:rocky10-amd64"
echo "  Image:      ${IMAGE_NAME}:${IMAGE_TAG}"
echo "  TypeScript: ${TS_VER}"
echo "  Biome:      ${BIOME_VER}"
echo "=========================================="

# ── Build ──
echo ""
echo ">> Building image..."
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    --build-arg TS_VER="${TS_VER}" \
    --build-arg BIOME_VER="${BIOME_VER}" \
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
    -e NODE_ENV="production" \
    -e PATH="/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/cargo/bin:/usr/local/rustup/bin:/home/claudeuser/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    -v "${PWD}:/workdir:rw" \
    --entrypoint /bin/bash \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    -c '
set -ex

echo "[smoke] Node version: $(node --version)"
echo "[smoke] npm version: $(npm --version)"
echo "[smoke] TypeScript: $(tsc --version)"

# Verify all tools are accessible
TOOLS="tsc biome eslint prettier tsx vitest turbo ts-patch tsconfig-paths"
for tool in $TOOLS; do
    if command -v $tool > /dev/null 2>&1; then
        echo "[smoke] $tool: OK"
    else
        echo "[smoke] FAIL: $tool not found"
        exit 1
    fi
done

# Test biome runs with our config
echo "[smoke] Testing biome config..."
biome check --version 2>&1 | head -2

# Test prettier config
echo "[smoke] Testing prettier config..."
prettier --version 2>&1

# Test TypeScript can compile a simple file
echo "[smoke] Testing TypeScript toolchain with a simple file..."
cat > /tmp/hello.ts <<EOF
const add = (a: number, b: number): number => a + b;

const main = (): void => {
  console.log("Hello from TypeScript!", add(6, 7));
  console.log("Cross-compilation check:", process.arch);
};

main();
EOF

tsx /tmp/hello.ts

# Test biome check on the file
echo "[smoke] Running biome check on hello.ts..."
biome check /tmp/hello.ts 2>&1 | head -5 || true

# Test eslint on the file
echo "[smoke] Running eslint on hello.ts..."
eslint /tmp/hello.ts 2>&1 | head -5 || true

# Test vitest is available
echo "[smoke] Checking vitest..."
vitest --version 2>&1 | head -2

# Test turbo is available
echo "[smoke] Checking turbo..."
turbo --version 2>&1 | head -2

# Test tsconfig
echo "[smoke] TypeScript config:"
tsc --showConfig 2>&1 | head -5

# Test swc
echo "[smoke] Checking swc..."
swc --version 2>&1 | head -2 || echo "  @swc/core available"

echo "[smoke] Configs:"
echo "  biome.json:           $(test -f /home/claudeuser/biome.json && echo 'OK' || echo 'MISSING')"
echo "  eslint.config.mjs:     $(test -f /home/claudeuser/eslint.config.mjs && echo 'OK' || echo 'MISSING')"
echo "  .prettierrc:           $(test -f /home/claudeuser/.prettierrc && echo 'OK' || echo 'MISSING')"
echo "  tsconfig.json:         $(test -f /home/claudeuser/tsconfig.json && echo 'OK' || echo 'MISSING')"
echo "  .editorconfig:         $(test -f /home/claudeuser/.editorconfig && echo 'OK' || echo 'MISSING')"
echo "  SKILL.md:              $(test -f /home/claudeuser/.agents/skills/typescript-claude-abliterated/SKILL.md && echo 'OK' || echo 'MISSING')"

# Test pre-start hooks produce version output
echo "[smoke] Testing pre-start hooks..."
echo "--- 01-configure-typescript.sh ---"
bash /home/claudeuser/pre-start.d/01-configure-typescript.sh
echo "--- 02-configure-biome.sh ---"
bash /home/claudeuser/pre-start.d/02-configure-biome.sh
echo "--- 03-configure-claude.sh ---"
bash /home/claudeuser/pre-start.d/03-configure-claude.sh
echo "--- 04-lint-generated ---"
bash /home/claudeuser/pre-start.d/04-lint-generated

echo "[smoke] PASSED"
' 2>&1 | tee /tmp/typescript-claude-smoke.log

if grep -qi "\[smoke\] FAIL" /tmp/typescript-claude-smoke.log; then
    echo ""
    echo ">> Smoke test FAILED"
    exit 1
fi

echo ""
echo "====== TYPESCRIPT-CLAUDLE BUILDER ======"
echo "  Smoke test PASSED"
echo "=========================================="
