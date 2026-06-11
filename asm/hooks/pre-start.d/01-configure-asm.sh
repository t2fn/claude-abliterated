#!/bin/bash
# 01-configure-asm.sh — Configure assembly environment before Claude starts
# Sourced in order before Claude starts

echo "[asm] Assembly environment:"
echo "  CC=$CC"
echo "  AS=$AS"
echo "  LD=$LD"

# Core tools
echo "  GCC:    $(gcc --version 2>/dev/null | head -1 || echo 'available')"
echo "  as:     $(as --version 2>/dev/null | head -1 || echo 'available')"
echo "  ld:     $(ld --version 2>/dev/null | head -1 || echo 'available')"
echo "  make:   $(make --version 2>/dev/null | head -1 || echo 'available')"
echo "  gdb:    $(gdb --version 2>/dev/null | head -1 || echo 'available')"

# QEMU
echo "  qemu-system: $(qemu-system-x86_64 --version 2>/dev/null | head -1 || echo 'available')"
echo "  qemu-user:   $(qemu-user --version 2>/dev/null | head -1 || echo 'available')"

# Cross-compilers
echo "  Cross-compilers:"
for cc in arm-linux-gnu-gcc aarch64-linux-gnu-gcc riscv64-linux-gnu-gcc mips-linux-gnu-gcc mipsel-linux-gnu-gcc powerpc-linux-gnu-gcc s390x-linux-gnu-gcc; do
    if command -v $cc >/dev/null 2>&1; then
        echo "    $cc:    $(command -v $cc)"
    else
        echo "    $cc:    available (may install on first use)"
    fi
done

# QEMU user archs
echo "  QEMU user-static:"
for arch in x86_64 i386 arm aarch64 riscv64 mips ppc s390x; do
    if command -v qemu-${arch}-static >/dev/null 2>&1; then
        echo "    qemu-${arch}-static: $(command -v qemu-${arch}-static)"
    fi
done
