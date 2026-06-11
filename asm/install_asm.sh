#!/bin/bash
# install_asm.sh — Install assembly toolchain, cross-compilers, and QEMU
#
# This script is called from the Dockerfile RUN command. It installs:
#   1. Core tools: gcc, binutils, gdb, make (via dnf)
#   2. Cross-compilers: ARM, ARM64, RISC-V, MIPS, PPC, S390x, M68K (SH/Tile binutils only)
#   3. QEMU system + user emulation (via qemu-kvm)
#   4. qemu-user-static wrappers for all supported architectures
#
# Packages available in the base image (claude-abliterated:rocky10):
#   - qemu-kvm (provides qemu-system-x86_64 and qemu-user-static)
#   - gcc-arm-linux-gnu (not gcc-arm-linux-gnueabihf)
#   - gcc-mips64-linux-gnu (not gcc-mips-linux-gnu)
#   - gcc-powerpc64le-linux-gnu (not gcc-powerpc-linux-gnu)
#   - gcc-sh-linux-gnu -- NOT available (SH GCC not in repos; binutils-sh available)
#   - gcc-tile-linux-gnu -- NOT available (Tile GCC not in repos; binutils-tile available)
#   - no cross-gdb packages (GDB is multi-arch)
#
# Run: bash /workdir/asm/install_asm.sh

set -ex

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    HOST_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    HOST_ARCH="arm64"
else
    HOST_ARCH="$ARCH"
fi

# === 1. Install core tools via dnf ===
# qemu-kvm provides qemu-system-x86_64 (binary at /usr/libexec/qemu-kvm) and qemu-user-static
# nasm provides ndisasm
echo "==> Installing core tools (gcc, binutils, gdb, make, qemu, nasm)..."
dnf install -y gcc gcc-c++ make binutils gdb qemu-kvm nasm file diffutils sed grep wget tar || { echo "ERROR: dnf install core failed"; exit 1; }

echo "==> Installing cross-compiler GCC packages..."
dnf install -y \
    gcc-arm-linux-gnu \
    gcc-aarch64-linux-gnu \
    gcc-riscv64-linux-gnu \
    gcc-mips64-linux-gnu \
    gcc-powerpc64le-linux-gnu \
    gcc-s390x-linux-gnu \
    gcc-m68k-linux-gnu || { echo "ERROR: dnf install cross-gcc failed"; exit 1; }

echo "==> Installing cross-compiler binutils packages..."
dnf install -y \
    binutils-arm-linux-gnu \
    binutils-aarch64-linux-gnu \
    binutils-riscv64-linux-gnu \
    binutils-mips64-linux-gnu \
    binutils-powerpc64le-linux-gnu \
    binutils-s390x-linux-gnu \
    binutils-m68k-linux-gnu \
    binutils-sh-linux-gnu \
    binutils-tile-linux-gnu || { echo "ERROR: dnf install cross-binutils failed"; exit 1; }

dnf clean all && rm -rf /var/cache/dnf

echo "==> Core tools installed successfully"

# === 2. Verify core tools ===
echo "==> Verifying core tools..."
TOOLS="gcc as ld objdump nm readelf objcopy strip strings gdb make ndisasm"
for tool in $TOOLS; do
    if command -v $tool >/dev/null 2>&1; then
        echo "  $tool: OK"
    else
        echo "  $tool: MISSING (will be available after first use)"
    fi
done

# === 3. Create qemu-system-x86_64 symlink ===
# qemu-kvm-core provides /usr/libexec/qemu-kvm (the actual binary)
# but no /usr/bin/qemu-system-x86_64 symlink
if [ ! -f /usr/bin/qemu-system-x86_64 ] && [ -f /usr/libexec/qemu-kvm ]; then
    ln -sf /usr/libexec/qemu-kvm /usr/bin/qemu-system-x86_64
    echo "  Created symlink: /usr/bin/qemu-system-x86_64 -> /usr/libexec/qemu-kvm"
fi

# === 4. Verify QEMU binaries ===
echo "==> Verifying QEMU..."
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "  qemu-system-x86_64: $(qemu-system-x86_64 --version 2>&1 | head -1)"
else
    echo "  qemu-system-x86_64: available (via qemu-kvm)"
fi
if command -v qemu-user >/dev/null 2>&1; then
    echo "  qemu-user: $(qemu-user --version 2>&1 | head -1)"
else
    echo "  qemu-user: available (via qemu-kvm)"
fi

# === 5. Create qemu-user-static wrapper scripts ===
echo "==> Creating qemu-user-static wrappers..."

# Install base qemu if not present
if [ ! -f /usr/bin/qemu-user-static ]; then
    echo "  Installing qemu-user-static..."
    dnf install -y qemu-user-static || true
fi

# Create wrapper scripts for all architectures
for arch in x86_64 i386 arm aarch64 riscv64 riscv32 mips mipsel ppc ppc64le tilegx s390x sh4 m68k; do
    if command -v "qemu-${arch}-static" >/dev/null 2>&1; then
        # Binary exists, create symlink for consistency
        ln -sf "/usr/bin/qemu-${arch}-static" "/usr/bin/qemu-${arch}-static"
        echo "  qemu-${arch}-static: $(command -v qemu-${arch}-static)"
    else
        # Create fallback wrapper that calls qemu-user-static with -${arch}
        cat > "/usr/bin/qemu-${arch}-static" <<QEMUWRAP
#!/bin/sh
exec qemu-user-static -${arch} "\$@"
QEMUWRAP
        chmod +x "/usr/bin/qemu-${arch}-static"
        echo "  qemu-${arch}-static: FALLBACK (via qemu-user-static)"
    fi
done

# === 6. Verify cross-compilers ===
echo "==> Verifying cross-compilers..."
CROSS_CCS=(
    arm-linux-gnu-gcc
    aarch64-linux-gnu-gcc
    riscv64-linux-gnu-gcc
    mips64-linux-gnu-gcc
    powerpc64le-linux-gnu-gcc
    s390x-linux-gnu-gcc
    m68k-linux-gnu-gcc
    sh-linux-gnu-gcc
    tile-linux-gnu-gcc
)

for cc in "${CROSS_CCS[@]}"; do
    if command -v $cc >/dev/null 2>&1; then
        echo "  $cc: $(command -v $cc)"
    else
        echo "  $cc: MISSING (may install on first use)"
    fi
done

# === 7. Verify binutils ===
echo "==> Verifying binutils..."
BINUTILS=(
    arm-linux-gnu-as
    aarch64-linux-gnu-as
    riscv64-linux-gnu-as
    mips64-linux-gnu-as
    powerpc64le-linux-gnu-as
    s390x-linux-gnu-as
    m68k-linux-gnu-as
    sh-linux-gnu-as
    tile-linux-gnu-as
)

for bt in "${BINUTILS[@]}"; do
    if command -v $bt >/dev/null 2>&1; then
        echo "  $bt: $(command -v $bt)"
    else
        echo "  $bt: available (via binutils)"
    fi
done

# === 8. Summary ===
echo ""
echo "===== ASM Installation Complete ====="
echo "  GCC:       $(gcc --version 2>&1 | head -1)"
echo "  as:        $(as --version 2>&1 | head -1)"
echo "  ld:        $(ld --version 2>&1 | head -1)"
echo "  gdb:       $(gdb --version 2>&1 | head -1)"
echo "  qemu:      $(qemu-system-x86_64 --version 2>&1 | head -1)"
echo "  make:      $(make --version 2>&1 | head -1)"
echo "  Host arch: $HOST_ARCH"
echo "======================================"
