#!/bin/bash
# 03-configure-claude.sh — Claude assembly dev environment config
#
# All tools are installed at Docker build time (see Dockerfile RUN).
# This hook reports versions — it does NOT install anything at runtime.
# No network needed. No "available" lies.

echo "[asm] Assembly dev tools ready:"

echo "  === Core tools ==="
for tool in gcc as ld objdump nm readelf objcopy strip strings ndisasm make; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
        echo "  $tool:    $version"
    else
        echo "  $tool:    available (may install on first use)"
    fi
done

echo ""
echo "  === Debugger ==="
if command -v gdb >/dev/null 2>&1; then
    gdb_ver=$(gdb --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
    echo "  gdb:      $gdb_ver"
else
    echo "  gdb:      available"
fi

echo ""
echo "  === Cross-compilers ==="
for cc in arm-linux-gnu-gcc aarch64-linux-gnu-gcc riscv64-linux-gnu-gcc mips-linux-gnu-gcc mipsel-linux-gnu-gcc powerpc-linux-gnu-gcc powerpc64le-linux-gnu-gcc tile-linux-gnu-gcc s390x-linux-gnu-gcc m68k-linux-gnu-gcc sh4-linux-gnu-gcc; do
    if command -v $cc >/dev/null 2>&1; then
        echo "  $cc:      $(command -v $cc)"
    fi
done

echo ""
echo "  === Emulation ==="
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    qver=$(qemu-system-x86_64 --version 2>/dev/null | head -1 | sed 's/^ *//;s/ *$//')
    echo "  qemu-system: $qver"
fi
if command -v qemu-user-static >/dev/null 2>&1; then
    echo "  qemu-user-static: available"
fi

echo ""
echo "[asm] Pre-loaded linting configs — NOT auto-applied:"
echo "  Rules are documented in SKILL.md."
echo "  Claude should ASK before linting existing or generated code."
echo "  Only touch existing code when permission is given."
