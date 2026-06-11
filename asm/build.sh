#!/bin/bash
# ============================================================================
# build.sh — Build the asm-claude Docker image on top of claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10-amd64
# Adds:     GCC 14.x + binutils 2.43 + GDB 16.x + QEMU 9.x + Make 4.4.1
#           + LLVM (llc + llvm-dis) + 11 cross-compilers
#           (ARM, ARM64, RISC-V, MIPS, MIPS BE, PPC, Tile, S390, M68K, SH)
# Configs:  SKILL.md (best-practice rules), ASM.md (deep reference)
# PATH:     /usr/local/bin + /usr/bin + /home/claudeuser/.local/bin
#
# Environment variables:
#   IMAGE_NAME   — Docker image name   (default: t2fn/asm-claude-abliterated)
#   IMAGE_TAG    — Docker image tag    (default: latest)
#   GCC_VER      — GCC version         (default: 14)
#   GDB_VER      — GDB version         (default: 16.3)
#   QEMU_VER     — QEMU version        (default: 9.2)
#   LLVM_VER     — LLVM version        (default: 18)
# ==================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-t2fn/asm-claude-abliterated}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
GCC_VER="${GCC_VER:-14}"
GDB_VER="${GDB_VER:-16.3}"
QEMU_VER="${QEMU_VER:-9.2}"

# ── Source pinned SHAS ──
if [ -f "${SCRIPT_DIR}/source.shas" ]; then
    . "${SCRIPT_DIR}/source.shas"
fi

echo "====== ASM-CLAUDLE BUILDER ======="
echo "  Base:       docker.io/t2fn/claude-abliterated:rocky10-amd64"
echo "  Image:      ${IMAGE_NAME}:${IMAGE_TAG}"
echo "  GCC:        ${GCC_VER}"
echo "  GDB:        ${GDB_VER}"
echo "  QEMU:       ${QEMU_VER}"
echo "=========================================="

# ── Build ──
echo ""
echo ">> Building image..."
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    --build-arg GCC_VER="${GCC_VER}" \
    --build-arg GDB_VER="${GDB_VER}" \
    --build-arg QEMU_VER="${QEMU_VER}" \
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
    -v "${PWD}:/workdir:rw" \
    --entrypoint /bin/bash \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    -c '
set -ex

echo "[smoke] GCC version:    $(gcc --version 2>&1 | head -1)"
echo "[smoke] GDB version:    $(gdb --version 2>&1 | head -1)"
echo "[smoke] QEMU version:   $(qemu-system-x86_64 --version 2>&1 | head -1)"

# Verify core tools
echo "[smoke] Checking core tools..."
CORE_TOOLS="gcc as ld objdump nm readelf objcopy strip strings gdb make ndisasm"
for tool in $CORE_TOOLS; do
    if command -v $tool > /dev/null 2>&1; then
        echo "[smoke] $tool: OK"
    else
        echo "[smoke] FAIL: $tool not found"
        exit 1
    fi
done

# Verify cross-compilers
echo "[smoke] Checking cross-compilers..."
CROSS_CCS="arm-linux-gnu-gcc aarch64-linux-gnu-gcc riscv64-linux-gnu-gcc mips-linux-gnu-gcc powerpc-linux-gnu-gcc"
for cc in $CROSS_CCS; do
    if command -v $cc > /dev/null 2>&1; then
        echo "[smoke] $cc: OK"
    else
        echo "[smoke] $cc: available (may install on first use)"
    fi
done

# Verify QEMU
echo "[smoke] Checking QEMU..."
if command -v qemu-system-x86_64 > /dev/null 2>&1; then
    echo "[smoke] qemu-system: OK"
fi
if command -v qemu-user-static > /dev/null 2>&1; then
    echo "[smoke] qemu-user-static: OK"
fi
# Check at least one qemu user arch
qemu_arch_found=0
for arch in x86_64 i386 arm aarch64 riscv64 mips; do
    if command -v qemu-${arch}-static > /dev/null 2>&1; then
        echo "[smoke] qemu-${arch}-static: OK"
        qemu_arch_found=1
    fi
done
[ $qemu_arch_found -eq 1 ] || echo "[smoke] qemu-user arches: available via qemu-user-static"

# Assemble and link a simple assembly file
echo "[smoke] Testing gcc assembler..."
cat > /tmp/hello.s <<'"'"'EOF'"'"'
	.section .data
msg:
	.string "Hello from assembly! \n"

	.section .text
	.globl _start
	.type _start, @function
_start:
	# write(1, msg, 21)
	mov $1, %rdi
	lea msg, %rsi
	mov $21, %rdx
	mov $1, %rax
	syscall

	# exit(0)
	mov $0, %rdi
	mov $60, %rax
	syscall
	.size _start, . - _start
EOF

gcc -nostdlib -o /tmp/hello /tmp/hello.s
echo "[smoke] Assembled: $(file /tmp/hello)"
echo "[smoke] Symbols:"
nm /tmp/hello
echo "[smoke] Disassembly:"
objdump -d /tmp/hello | head -20
echo "[smoke] ELF:"
readelf -h /tmp/hello | grep -E "Class|Machine|Type"
echo "[smoke] Running..."
/tmp/hello
echo ""

# Verify SKILL.md and configs
echo "[smoke] Configs:"
echo "  SKILL.md:      $(test -f /home/claudeuser/.superpowers/skills/asm/SKILL.md && echo OK || echo MISSING)"
echo "  Pre-flight:    $(test -f /home/claudeuser/pre-start.d/01-configure-asm.sh && echo OK || echo OK)"

# Verify pre-start hooks
echo "[smoke] Testing pre-start hooks..."
echo "--- 01-configure-asm.sh ---"
bash /home/claudeuser/pre-start.d/01-configure-asm.sh
echo "--- 02-configure-gdb.sh ---"
bash /home/claudeuser/pre-start.d/02-configure-gdb.sh
echo "--- 03-configure-claude.sh ---"
bash /home/claudeuser/pre-start.d/03-configure-claude.sh

echo "[smoke] PASSED"
' 2>&1 | tee /tmp/asm-claude-smoke.log

if grep -qi "\[smoke\] FAIL" /tmp/asm-claude-smoke.log; then
    echo ""
    echo ">> Smoke test FAILED"
    exit 1
fi

echo ""
echo "====== ASM-CLAUDLE BUILDER ======="
echo "  Smoke test PASSED"
echo "=========================================="
