# Dockerfile.asm — Cross-architecture assembly dev stack on claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     GCC 14.x + binutils 2.43 + GDB 16.x + QEMU 9.x + Make 4.4.1
#           + cross-compilers (ARM, ARM64, RISC-V, MIPS, MIPS BE, PPC, Tile, S390, M68K, SH; SH/Tile binutils-only)
# Configs:  SKILL.md (best-practice rules)
# PATH:     /usr/bin + /usr/local/bin + /home/claudeuser/.local/bin
#
# Build args:
#   GCC_VER      — GCC major version     (default: 14)
#   BINUTILS_VER — binutils version      (default: 2.43)
#   GDB_VER      — GDB version           (default: 16.3)
#   QEMU_VER     — QEMU version          (default: 9.2)
#
# Tools installed (core — 14 tools):
#   gcc, as, ld, objdump, nm, readelf, objcopy, strip, strings (GCC + binutils)
#   make (build automation)
#   ndisasm (universal disassembler)
#
# Tools installed (debugger):
#   gdb (GNU Debugger — breakpoints, step, inspect, core dumps)
#
# Tools installed (emulation):
#   qemu-system (full system emulation for all architectures)
#   qemu-user (user-mode cross-architecture binary execution)
#   qemu-*-static wrappers (14 architecture binaries)
#
# Supported architectures:
#   x86_64, x86, ARM, ARM64, RISC-V, MIPS, MIPS BE, MicroMIPS,
#   PowerPC, PowerPC 64LE, Tile, M68K, S390, SH
#
# Linting philosophy (SKILL.md):
#   NEW files Claude writes  → auto-lint before presenting
#   EXISTING code            → do NOT touch; ask before linting
#   Startup hooks            → report versions only, no file modifications
#

FROM docker.io/t2fn/claude-abliterated:rocky10-amd64

# == Build args ==
ARG GCC_VER=14 \
    BINUTILS_VER=2.43 \
    GDB_VER=16.3 \
    QEMU_VER=9.2

# == Environment ==
ENV CC=gcc \
    AS=as \
    LD=ld \
    PATH="/usr/bin:/usr/local/bin:/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    HOME=/home/claudeuser

# == Layer 1: root. Install assembly toolchain via install_asm.sh ==
USER root

# install_asm.sh handles all installation:
#   1. dnf install core tools + cross-compilers + QEMU
#   2. Creates qemu-user-static wrapper scripts for all architectures
#   3. Verifies cross-compilers, QEMU, and core tools
# By moving the install logic out of the Dockerfile, we get:
#   - Clean Dockerfile that's easy to read and modify
#   - install_asm.sh can be run standalone for debugging
#   - No fragile && chains or nested for/if/heredoc in the Dockerfile itself
COPY install_asm.sh /tmp/install_asm.sh
RUN bash /tmp/install_asm.sh && rm /tmp/install_asm.sh

# == Layer 2: claudeuser. Hooks + config ==
USER claudeuser

# == Copy pre-start and post-stop hooks ==
COPY hooks/pre-start.d/ /home/claudeuser/pre-start.d/
COPY hooks/post-stop.d/ /home/claudeuser/post-stop.d/

# == Copy ASM.md into superpowers (deep reference) ==
COPY ASM.md /home/claudeuser/.superpowers/skills/asm/ASM.md

# == Copy SKILL.md into superpowers (standard location for Claude Code to discover) ==
COPY SKILL.md /home/claudeuser/.superpowers/skills/asm/SKILL.md

# == Working directory ==
WORKDIR /workdir

# == Entry point ==
ENTRYPOINT ["start_claude.sh"]
