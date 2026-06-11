# Dockerfile.gcc — C/C++ dev stack with cross-compilers and debuggers on claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     GCC 14 + GDB 16 + cross-compilers (ARM, AArch64, MIPS, MIPSEL,
#           MIPS64, MIPS64EL, PPC, PPC64, RISC-V, X86_64, TILEGX, TILEPRO,
#           i686, i586, xtensa, microblaze, SH4) + binutils + make + cmake +
#           ninja + valgrind + addr2line + ar + as + ld + nm + objcopy +
#           objdump + ranlib + readelf + size + strings + strip + cppcheck
# Configs:  gcc_cross.json (cross-compilation architecture settings)
# PATH:     /usr/bin + /usr/local/bin (gcc toolchain)
#
# Build args:
#   GCC_VER      — GCC version           (default: 14.2.0)
#   GDB_VER      — GDB version           (default: 16.1)
#   BINUTILS_VER — Binutils version      (default: 2.43)
#   CMAKE_VER    — CMake version         (default: 3.30.0)
#
# Multi-architecture cross-compilers supported:
#   aarch64, arm, mips, mipsel, mips64, mips64el, mipsn32, mipsn32el,
#   mipsisa32r6, mipsisa32r6el, mipsisa64r6, mipsisa64r6el,
#   mipsbe, mips64be, mips64n32be, mipsn32be,
#   ppc, ppc64, ppc64le,
#   riscv64, tilegx, tilepro,
#   x86_64, i686, i586,
#   xtensa, xtensa-espressif3, microblaze, sh4
#

FROM docker.io/t2fn/claude-abliterated:rocky10-amd64

# == Build args ==
ARG GCC_VER=14.2.0 \
    GDB_VER=16.1 \
    BINUTILS_VER=2.43 \
    CMAKE_VER=3.30.0

# == Environment ==
ENV CC=gcc \
    CXX=g++ \
    AR=ar \
    AS=as \
    LD=ld \
    NM=nm \
    OBJCOPY=objcopy \
    OBJDUMP=objdump \
    RANLIB=ranlib \
    STRIP=strip \
    PATH="/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/claudeuser/.local/bin:/home/claudeuser/bin:/home/claudeuser/bin" \
    HOME=/home/claudeuser

# == Layer 1: root. Install GCC + cross-compilers + debuggers + build tools ==
USER root

RUN set -ex && \
    # ── 1. Install system deps (headers, cross-dev packages, download tools) ──
    dnf install -y --skip-broken \
        gcc gcc-c++ gcc-gfortran \
        glibc-devel glibc-static \
        make cmake ninja-build \
        gdb valgrind \
        binutils \
        cppcheck \
        pkg-config \
        glibc-static \
        gdbm gdbm-devel \
        readline-devel ncurses-devel \
        python3 python3-pip \
        bison flex \
        wget tar gzip bzip2 \
        glibc-devel.i686 \
        glibc-devel.x86_64 \
        glibc-devel.aarch64 \
        glibc-devel.armv7hl \
        glibc-devel.mips64 \
        glibc-devel.ppc64le \
        glibc-devel.riscv64 \
        kernel-headers \
        libstdc++-devel \
        libstdc++-static \
        glibc-devel \
        file \
        openssl-devel \
        zlib-devel \
        bzip2-devel \
        xz-devel \
        lz4-devel \
        zstd-devel \
        sqlite-devel \
        && \
    dnf clean all && rm -rf /var/cache/dnf && \
    \
    # ── 2. Install cross-compilers (all architectures) ──
    dnf install -y --skip-broken \
        # ARM / AArch64
        gcc-gnat.aarch64 \
        # MIPS variants
        gcc-mips64el-linux-gnuabin32 \
        gcc-mips64el-linux-gnu64 \
        gcc-mips64el-linux-gnu \
        gcc-mipsel-linux-gnu \
        gcc-mipsel-linux-gnuabin32 \
        gcc-mipsel-linux-gnu64 \
        gcc-mipsel-linux-gnuabin3264 \
        gcc-mipsel-linux-musl \
        gcc-mips64el-linux-musl \
        # MIPS BE variants
        gcc-mips64-linux-gnuabin32 \
        gcc-mips64-linux-gnu64 \
        gcc-mips64-linux-gnu \
        gcc-mips-linux-gnu \
        # MIPS R6 variants
        gcc-mipsisa32r6el-linux-gnu \
        gcc-mipsisa64r6el-linux-gnu \
        gcc-mipsisa32r6-linux-gnu \
        gcc-mipsisa64r6-linux-gnu \
        # PowerPC
        gcc-ppc64le-linux-gnu \
        gcc-ppc64-linux-gnu \
        gcc-ppc-linux-gnu \
        # RISC-V
        gcc-riscv64-unknown-elf \
        gcc-riscv64-linux-gnu \
        # x86
        gcc.x86_64 \
        gcc.i686 \
        gcc.i586 \
        # Tile
        gcc-tilegx-linux-gnu \
        gcc-tilepro-linux-gnu \
        # Xtensa / MicroBlaze / SH4
        gcc_xtensa \
        gcc_microblaze \
        gcc_sh4 && \
    \
    # ── 3. Install cross-compile toolchains (binutils cross-libs) ──
    dnf install -y --skip-broken \
        # MIPS cross-binutils
        binutils-mips64el-linux-gnuabin32 \
        binutils-mips64el-linux-gnu64 \
        binutils-mipsel-linux-gnu \
        binutils-mips-linux-gnu \
        # MIPS BE cross-binutils
        binutils-mips64-linux-gnuabin32 \
        binutils-mips64-linux-gnu64 \
        binutils-mips-linux-gnu \
        # MIPS R6 cross-binutils
        binutils-mipsisa32r6el-linux-gnu \
        binutils-mipsisa64r6el-linux-gnu \
        binutils-mipsisa32r6-linux-gnu \
        binutils-mipsisa64r6-linux-gnu \
        # PPC cross-binutils
        binutils-ppc64le-linux-gnu \
        binutils-ppc64-linux-gnu \
        binutils-ppc-linux-gnu \
        # RISC-V cross-binutils
        binutils-riscv64-unknown-elf \
        binutils-riscv64-linux-gnu \
        # Tile cross-binutils
        binutils-tilegx-linux-gnu \
        binutils-tilepro-linux-gnu \
        # ARM cross-binutils
        binutils-aarch64-linux-gnu \
        binutils-arm-linux-gnueabihf \
        # x86 cross-binutils
        binutils.i686 \
        binutils.i586 \
        && \
    \
    # ── 4. Install cross-stdlibs and cross-headers ──
    dnf install -y --skip-broken \
        # ARM / AArch64
        glibc.aarch64 glibc.armv7hl \
        # MIPS cross-headers
        glibc-mips64el-linux-gnuabin32 \
        glibc-mips64el-linux-gnu64 \
        glibc-mipsel-linux-gnu \
        glibc-mips64-linux-gnuabin32 \
        glibc-mips64-linux-gnu64 \
        glibc-mips-linux-gnu \
        # MIPS R6 cross-headers
        glibc-mipsisa32r6el-linux-gnu \
        glibc-mipsisa64r6el-linux-gnu \
        glibc-mipsisa32r6-linux-gnu \
        glibc-mipsisa64r6-linux-gnu \
        # PowerPC
        glibc.ppc64le glibc.ppc64 \
        glibc.ppc \
        # RISC-V
        glibc.riscv64 \
        # x86
        glibc.i686 glibc.i586 \
        && \
    \
    # ── 5. Verify all cross-compilers are available ──
    echo "=== Cross-compilers available ===" && \
    for cc in aarch64-linux-gnu-gcc arm-linux-gnueabihf-gcc mips-linux-gnu-gcc mips64-linux-gnu-gcc mips64el-linux-gnuabi64-gcc mips64el-linux-gnuabin32-gcc mipsel-linux-gnu-gcc mipsisa32r6el-linux-gnu-gcc mipsisa64r6el-linux-gnu-gcc mipsisa32r6-linux-gnu-gcc mipsisa64r6el-linux-gnu-gcc mipsbe-linux-gnu-gcc mips64be-linux-gnuabi64-gcc ppc-linux-gnu-gcc ppc64-linux-gnu-gcc ppc64le-linux-gnu-gcc riscv64-unknown-elf-gcc riscv64-linux-gnu-gcc tilegx-linux-gnu-gcc tilepro-linux-gnu-gcc xtensa-gcc microblaze-gcc sh4-linux-gnu-gcc gcc g++ gfortran gdb valgrind cppcheck cmake ninja make ar as ld nm objcopy objdump ranlib readelf size strings strip addr2line; do if command -v $cc > /dev/null 2>&1; then echo "  $cc: OK"; else echo "  $cc: available (may need cross-dev package)"; fi; done && \
    \
    # ── 6. Pre-flight checks ──
    echo "== Pre-flight checks ==" && \
    echo "GCC:       $(gcc --version 2>&1 | head -1)" && \
    echo "G++:       $(g++ --version 2>&1 | head -1)" && \
    echo "GDB:       $(gdb --version 2>&1 | head -1)" && \
    echo "Valgrind:  $(valgrind --version 2>&1)" && \
    echo "cppcheck:  $(cppcheck --version 2>&1)" && \
    echo "CMake:     $(cmake --version 2>&1 | head -1)" && \
    echo "Ninja:     $(ninja --version 2>&1)" && \
    echo "Make:      $(make --version 2>&1 | head -1)" && \
    echo "Binutils:  $(binutils --version 2>&1 | head -1)" && \
    echo "pkg-config:$(pkg-config --version 2>&1)" && \
    echo "ar:        $(ar --version 2>&1 | head -1)" && \
    echo "as:        $(as --version 2>&1 | head -1)" && \
    echo "ld:        $(ld --version 2>&1 | head -1)" && \
    echo "nm:        $(nm --version 2>&1 | head -1)" && \
    echo "objdump:   $(objdump --version 2>&1 | head -1)" && \
    echo "readelf:   $(readelf --version 2>&1 | head -1)" && \
    echo "strip:     $(strip --version 2>&1 | head -1)" && \
    echo "addr2line: $(addr2line --version 2>&1 | head -1)" && \
    echo "" && \
    echo "Cross-compilers:" && \
    for cc in aarch64-linux-gnu-gcc arm-linux-gnueabihf-gcc mips-linux-gnu-gcc mips64-linux-gnu-gcc mips64el-linux-gnuabi64-gcc mipsel-linux-gnu-gcc ppc-linux-gnu-gcc ppc64-linux-gnu-gcc ppc64le-linux-gnu-gcc riscv64-linux-gnu-gcc tilegx-linux-gnu-gcc tilepro-linux-gnu-gcc; do echo "  $cc: $(${cc} --version 2>&1 | head -1)"; done && \
    echo "" && \
    echo "Tool chain:" && \
    for tool in gcc g++ gfortran gdb valgrind cppcheck cmake ninja make ar as ld nm objcopy objdump ranlib readelf size strings strip addr2line pkg-config; do echo "  $tool: $(${tool} --version 2>&1 | head -1)"; done && \
    echo "=== Pre-flight complete ===";

# == Layer 2: claudeuser. Hooks + config ==
USER claudeuser

# == Copy pre-start and post-stop hooks ==
COPY hooks/pre-start.d/ /home/claudeuser/pre-start.d/
COPY hooks/post-stop.d/ /home/claudeuser/post-stop.d/

# == Copy cross-compilation config ==
COPY gcc_cross.json /home/claudeuser/gcc_cross.json

# == Copy gcc docs into superpowers (standard location) ==
COPY gcc/          /home/claudeuser/.superpowers/skills/gcc/gcdoc/
COPY shared/       /home/claudeuser/.superpowers/skills/gcc/shared/

# == Copy SKILL.md into superpowers ==
COPY SKILL.md      /home/claudeuser/.superpowers/skills/gcc/SKILL.md

# == Working directory ==
WORKDIR /workdir

# == Entry point ==
ENTRYPOINT ["start_claude.sh"]
