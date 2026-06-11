#!/bin/bash
# 02-configure-cross.sh — Verify cross-compilation targets
# Lists all cross-compilers and their architectures

echo "[gcc] Cross-compilation targets:"
echo "  Config: /home/claudeuser/gcc_cross.json"
echo ""

# List all available cross-compilers by architecture family
echo "  [ARM]"
for cc in aarch64-linux-gnu-gcc arm-linux-gnueabihf-gcc; do
    echo "    $cc: $(${cc} --version 2>&1 | head -1 2>/dev/null || echo 'not installed')"
done

echo "  [MIPS]"
for cc in mips-linux-gnu-gcc mips64-linux-gnu-gcc mips64el-linux-gnuabi64-gcc mipsel-linux-gnu-gcc mipsisa32r6el-linux-gnu-gcc mipsisa64r6el-linux-gnu-gcc; do
    echo "    $cc: $(${cc} --version 2>&1 | head -1 2>/dev/null || echo 'not installed')"
done

echo "  [MIPS BE]"
for cc in mipsbe-linux-gnu-gcc mips64be-linux-gnuabi64-gcc; do
    echo "    $cc: $(${cc} --version 2>&1 | head -1 2>/dev/null || echo 'not installed')"
done

echo "  [PPC]"
for cc in ppc-linux-gnu-gcc ppc64-linux-gnu-gcc ppc64le-linux-gnu-gcc; do
    echo "    $cc: $(${cc} --version 2>&1 | head -1 2>/dev/null || echo 'not installed')"
done

echo "  [RISC-V]"
for cc in riscv64-linux-gnu-gcc riscv64-unknown-elf-gcc; do
    echo "    $cc: $(${cc} --version 2>&1 | head -1 2>/dev/null || echo 'not installed')"
done

echo "  [x86]"
for cc in gcc; do
    echo "    $cc: $(gcc --version 2>&1 | head -1)"
done

echo "  [Tile]"
for cc in tilegx-linux-gnu-gcc tilepro-linux-gnu-gcc; do
    echo "    $cc: $(${cc} --version 2>&1 | head -1 2>/dev/null || echo 'not installed')"
done

echo "  [Other]"
for cc in xtensa-gcc microblaze-gcc sh4-linux-gnu-gcc; do
    echo "    $cc: $(${cc} --version 2>&1 | head -1 2>/dev/null || echo 'not installed')"
done

# Cross-compilation example
echo ""
echo "  [Cross-compilation example]"
echo '  export CROSS_COMPILE=aarch64-linux-gnu-'
echo '  export ARCH=arm64'
echo '  aarch64-linux-gnu-gcc -o app-arm main.c -static'
