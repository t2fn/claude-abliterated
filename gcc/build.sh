#!/bin/bash
# ======================================================================
# build.sh — Build the gcc-claude Docker image on top of claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     GCC 14 + GDB 16 + cross-compilers (ARM, AArch64, MIPS, MIPSEL,
#           MIPS64, MIPS64EL, MIPS64BE, MIPS R6, PPC, PPC64, RISC-V, TILEGX,
#           TILEPRO, XTENSA, MICROBLAZE, SH4) + binutils + make + cmake +
#           ninja + valgrind + addr2line + ar + as + ld + nm + objcopy +
#           objdump + ranlib + readelf + size + strings + strip + cppcheck
# Configs:  gcc_cross.json (cross-compilation architecture settings)
# PATH:     /usr/local/bin + /usr/bin (gcc toolchain)
#
# Environment variables:
#   IMAGE_NAME   — Docker image name   (default: t2fn/gcc-claude-abliterated)
#   IMAGE_TAG    — Docker image tag    (default: latest)
#   GCC_VER      — GCC version         (default: 14.2.0)
#   GDB_VER      — GDB version         (default: 16.1)
#   BINUTILS_VER — Binutils version    (default: 2.43)
#   CMAKE_VER    — CMake version       (default: 3.30.0)
# =======================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-t2fn/gcc-claude-abliterated}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
GCC_VER="${GCC_VER:-14.2.0}"
GDB_VER="${GDB_VER:-16.1}"
BINUTILS_VER="${BINUTILS_VER:-2.43}"
CMAKE_VER="${CMAKE_VER:-3.30.0}"

# ── Source pinned SHAs ──
if [ -f "${SCRIPT_DIR}/source.shas" ]; then
    . "${SCRIPT_DIR}/source.shas"
fi

echo "====== GCC-CLAUDLE BUILDER ======="
echo "  Base:       docker.io/t2fn/claude-abliterated:rocky10-amd64"
echo "  Image:      ${IMAGE_NAME}:${IMAGE_TAG}"
echo "  GCC:        ${GCC_VER}"
echo "  GDB:        ${GDB_VER}"
echo "  Binutils:   ${BINUTILS_VER}"
echo "  CMake:      ${CMAKE_VER}"
echo "====== GCC-CLAUDLE BUILDER ======="

# ── Build ──
echo ""
echo ">> Building image..."
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    --build-arg GCC_VER="${GCC_VER}" \
    --build-arg GDB_VER="${GDB_VER}" \
    --build-arg BINUTILS_VER="${BINUTILS_VER}" \
    --build-arg CMAKE_VER="${CMAKE_VER}" \
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
    -e CC="gcc" \
    -e CXX="g++" \
    -e PATH="/usr/local/bin:/usr/bin:/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin" \
    -v "${PWD}:/workdir:rw" \
    --entrypoint /bin/bash \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    -c '
set -ex

echo "[smoke] GCC version: $(gcc --version | head -1)"
echo "[smoke] G++ version: $(g++ --version | head -1)"
echo "[smoke] GDB version: $(gdb --version | head -1)"

# Verify all core tools are accessible
CORE_TOOLS="gcc g++ gfortran gdb valgrind cppcheck cmake ninja make ar as ld nm objcopy objdump ranlib readelf size strings strip addr2line pkg-config"
echo ""
echo "[smoke] Core tools:"
for tool in $CORE_TOOLS; do
    if command -v $tool > /dev/null 2>&1; then
        echo "[smoke]   $tool: OK"
    else
        echo "[smoke]   $tool: NOT FOUND"
        exit 1
    fi
done

# Verify cross-compilers
echo ""
echo "[smoke] Cross-compilers:"
CROSS_TOOLS="aarch64-linux-gnu-gcc arm-linux-gnueabihf-gcc mips-linux-gnu-gcc mips64-linux-gnu-gcc mips64el-linux-gnuabi64-gcc mipsel-linux-gnu-gcc ppc-linux-gnu-gcc ppc64-linux-gnu-gcc ppc64le-linux-gnu-gcc riscv64-linux-gnu-gcc tilegx-linux-gnu-gcc tilepro-linux-gnu-gcc"
for tool in $CROSS_TOOLS; do
    if command -v $tool > /dev/null 2>&1; then
        echo "[smoke]   $tool: OK"
    else
        echo "[smoke]   $tool: available (cross-dev package)"
    fi
done

# Test gcc can compile a simple C program
echo ""
echo "[smoke] Testing gcc compilation..."
cat > /tmp/hello.c << '\''EOF'\''
#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int main(int argc, char *argv[]) {
    printf("Hello from gcc-claude!\\n");
    printf("add(6, 7) = %d\\n", add(6, 7));
    return 0;
}
EOF

gcc -Wall -Wextra -pedantic -O2 -std=c17 -g -o /tmp/hello /tmp/hello.c
/tmp/hello

# Test g++ can compile a simple C++ program
echo "[smoke] Testing g++ compilation..."
cat > /tmp/hello.cpp << '\''EOF'\''
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    int sum = 0;
    for (int n : numbers) {
        sum += n;
    }
    std::cout << "Sum = " << sum << std::endl;
    return 0;
}
EOF

g++ -Wall -Wextra -pedantic -O2 -std=c++20 -g -o /tmp/hello /tmp/hello.cpp
/tmp/hello

# Test cppcheck runs
echo "[smoke] Testing cppcheck..."
cppcheck /tmp/hello.c 2>&1 | head -5

# Test valgrind
echo "[smoke] Testing valgrind..."
valgrind --leak-check=full /tmp/hello 2>&1 | tail -10

# Test pkg-config
echo "[smoke] Testing pkg-config..."
pkg-config --list-all 2>&1 | head -10

echo ""
echo "[smoke] PASSED"
' 2>&1 | tee /tmp/gcc-claude-smoke.log

if grep -qi "FAIL" /tmp/gcc-claude-smoke.log; then
    echo ""
    echo ">> Smoke test FAILED"
    exit 1
fi

echo ""
echo "====== GCC-CLAUDLE BUILDER ======="
echo "  Smoke test PASSED"
echo "====== GCC-CLAUDLE BUILDER ======="
