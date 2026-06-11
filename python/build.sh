#!/bin/bash
# ============================================================================
# build.sh — Build the python-claude Docker image on top of claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10-amd64
# Adds:     Python 3.13 + ruff, pyupgrade, pylint, flake8, black, isort,
#           mypy, pydocstyle, autoflake, bandit, pycodestyle, pyflakes, pyright
# Configs:  pyproject.toml (ruff, black, isort, mypy, bandit defaults)
# PATH:     /home/claudeuser/.local/bin
#
# Environment variables:
#   IMAGE_NAME   — Docker image name   (default: t2fn/python-claude-abliterated)
#   IMAGE_TAG    — Docker image tag    (default: latest)
#   PYTHON_TOOLS_VER — Extra pip install args (e.g. "numpy>=2.0 pandas>=2.0")
# ==================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-t2fn/python-claude-abliterated}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
PYTHON_TOOLS_VER="${PYTHON_TOOLS_VER:-}"

# ── Source pinned SHAs ──
if [ -f "${SCRIPT_DIR}/source.shas" ]; then
    . "${SCRIPT_DIR}/source.shas"
fi

echo "====== PYTHON-CLAUDLE BUILDER ======="
echo "  Base:         docker.io/t2fn/claude-abliterated:rocky10-amd64"
echo "  Image:        ${IMAGE_NAME}:${IMAGE_TAG}"
echo "  Extra tools:  ${PYTHON_TOOLS_VER}"
echo "====================================="

# ── Build ──
echo ""
echo ">> Building image..."
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    --build-arg PYTHON_TOOLS_VER="${PYTHON_TOOLS_VER}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"

echo ">> Image built: ${IMAGE_NAME}:${IMAGE_TAG}"

# ── Smoke test ──
echo ""
echo ">> Running smoke test.."

docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e OLLAMA_MODEL="${OLLAMA_MODEL:-huihui_ai/Qwen3.6-abliterated:35b}" \
    -e OLLAMA_HOST="10.12.2.4" \
    -e ANTHROPIC_API_KEY="sk-test-key" \
    -e PYTHONUNBUFFERED="1" \
    -e PYTHONPATH="/home/claudeuser/.local/lib/python3.13/site-packages" \
    -e PATH="/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    -v "${PWD}:/workdir:rw" \
    --entrypoint /bin/bash \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    -c '
set -ex

echo "[smoke] Python version: $(python3 --version)"

# Verify all tools are accessible
TOOLS="ruff pyupgrade pylint flake8 black isort mypy pydocstyle autoflake bandit pycodestyle pyflakes pyright"
for tool in $TOOLS; do
    if command -v $tool > /dev/null 2>&1; then
        echo "[smoke] $tool: OK"
    else
        echo "[smoke] FAIL: $tool not found"
        exit 1
    fi
done

# Test ruff linting on a simple file
echo "[smoke] Testing ruff linting..."
cat > /tmp/test_smoke.py <<'"'"'EOF'"'"'
"""A simple test module."""

def add(a: int, b: int) -> int:
    """Add two numbers."""
    return a + b

def main() -> None:
    """Run the main function."""
    result: int = add(6, 7)
    print(f"Result: {result}")

if __name__ == "__main__":
    main()
EOF

ruff check /tmp/test_smoke.py
ruff format --check /tmp/test_smoke.py

# Test mypy type checking
echo "[smoke] Testing mypy type checking..."
mypy /tmp/test_smoke.py

# Test pylint
echo "[smoke] Testing pylint..."
pylint /tmp/test_smoke.py --disable=C0114,C0115,C0116,R0903 2>&1 | tail -5

# Test bandit security
echo "[smoke] Testing bandit security..."
bandit -r /tmp/test_smoke.py 2>&1 | tail -3

# Test pyupgrade
echo "[smoke] Testing pyupgrade..."
pyupgrade --py310 /tmp/test_smoke.py --diff

echo "[smoke] PASSED"
' 2>&1 | tee /tmp/python-claude-smoke.log

if grep -qi "FAIL" /tmp/python-claude-smoke.log; then
    echo ""
    echo ">> Smoke test FAILED"
    exit 1
fi

echo ""
echo "====== PYTHON-CLAUDLE BUILDER ======="
echo "  Smoke test PASSED"
echo "====================================="
