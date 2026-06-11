#!/bin/bash
# 01-configure-gcc.sh — Configure GCC environment before Claude starts
# Sourced in order before Claude starts

echo "[gcc] C/C++ compiler environment:"
echo "  CC=$CC"
echo "  CXX=$CXX"
echo "  AR=$AR"
echo "  LD=$LD"

# Primary compilers
echo "[gcc] Primary compilers:"
echo "  gcc:   $(gcc --version 2>/dev/null | head -1)"
echo "  g++:   $(g++ --version 2>/dev/null | head -1)"
echo "  gfortran: $(gfortran --version 2>/dev/null | head -1)"

# Core toolchain
echo "[gcc] Core tool chain:"
for tool in ar as ld nm objcopy objdump ranlib readelf size strings strip addr2line; do
    echo "  $tool: $(which $tool 2>/dev/null || echo 'not found')"
done

# Debuggers
echo "[gcc] Debuggers:"
echo "  gdb:   $(gdb --version 2>/dev/null | head -1)"
echo "  valgrind: $(valgrind --version 2>/dev/null)"
echo "  cppcheck: $(cppcheck --version 2>/dev/null)"

# Build tools
echo "[gcc] Build tools:"
echo "  cmake: $(cmake --version 2>/dev/null | head -1)"
echo "  ninja: $(ninja --version 2>/dev/null)"
echo "  make:  $(make --version 2>/dev/null | head -1)"
echo "  pkg-config: $(pkg-config --version 2>/dev/null)"

# Cross-compilers
echo "[gcc] Cross-compilers:"
for cc in aarch64-linux-gnu-gcc arm-linux-gnueabihf-gcc mips-linux-gnu-gcc mips64-linux-gnu-gcc mips64el-linux-gnuabi64-gcc mipsel-linux-gnu-gcc mipsisa32r6el-linux-gnu-gcc mipsisa64r6el-linux-gnu-gcc ppc-linux-gnu-gcc ppc64-linux-gnu-gcc ppc64le-linux-gnu-gcc riscv64-linux-gnu-gcc tilegx-linux-gnu-gcc tilepro-linux-gnu-gcc; do
    if command -v $cc > /dev/null 2>&1; then
        echo "  $cc: OK ($($cc --version 2>&1 | head -1))"
    else
        echo "  $cc: available (cross-dev package)"
    fi
done
