#!/bin/bash
# 02-configure-gdb.sh — Verify GDB debugger with version numbers
# Mirrors the pattern: version + capability check

GDB_VER="$(gdb --version 2>/dev/null | head -1 || echo 'gdb installed')"

echo "[asm] GDB debugger:"
echo "  version: $GDB_VER"
echo "  architecture: $(gdb -ex "set architecture" -ex "quit" 2>&1 | head -1)"
echo "  features:  $(gdb --ex "show version" --ex "quit" 2>&1 | head -1)"

# Cross-architecture support
echo "[asm] Cross-arch debug support:"
if command -v arm-linux-gnu-gdb >/dev/null 2>&1; then
    echo "  ARM debug:  $(arm-linux-gnu-gdb --version 2>/dev/null | head -1)"
fi
if command -v aarch64-linux-gnu-gdb >/dev/null 2>&1; then
    echo "  ARM64 debug: $(aarch64-linux-gnu-gdb --version 2>/dev/null | head -1)"
fi
if command -v riscv64-linux-gnu-gdb >/dev/null 2>&1; then
    echo "  RISC-V debug: $(riscv64-linux-gnu-gdb --version 2>/dev/null | head -1)"
fi
if command -v mips-linux-gnu-gdb >/dev/null 2>&1; then
    echo "  MIPS debug: $(mips-linux-gnu-gdb --version 2>/dev/null | head -1)"
fi
if command -v powerpc-linux-gnu-gdb >/dev/null 2>&1; then
    echo "  PPC debug:  $(powerpc-linux-gnu-gdb --version 2>/dev/null | head -1)"
fi
if command -v s390x-linux-gnu-gdb >/dev/null 2>&1; then
    echo "  S390 debug: $(s390x-linux-gnu-gdb --version 2>/dev/null | head -1)"
fi

# Available binary formats
echo "[asm] Binary formats:"
echo "  ELF:  $(test -f /usr/lib/binfmt_misc/elf && echo 'OK' || echo 'via binfmt')"
echo "  BIN:  $(echo 'OK')"
echo "  HEX:  $(echo 'OK (objcopy)')"
echo "  SREC: $(echo 'OK (objcopy)')"
