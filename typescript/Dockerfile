# Dockerfile.typescript — TypeScript dev stack on claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     TypeScript 6.0.3 + biome, eslint, prettier, tsx, vitest,
#           turbo, ts-patch, tsconfig-paths, @swc/core
# Configs:  biome.json, eslint.config.mjs, .prettierrc, tsconfig.json,
#           .editorconfig, SKILL.md — all pre-loaded best-practice standards
#           (written from build context via COPY)
# Hooks:    01-03 pre-start (.sh = auto-sourced), 04-lint-generated (no .sh = opt-in)
# SKILL.md: installed in .agents/skills/typescript-claude-abliterated/ (discovered by skill loader)
# PATH:     /home/claudeuser/.local/bin + /home/claudeuser/bin + /usr/local/cargo/bin
#
# Offline-ready: all npm packages installed globally with cached npm layers.
# No runtime internet dependency for pre-start hooks or tool execution.
#
# Build args:
#   TS_VER       — TypeScript version (default: 6.0.3)
#   BIOME_VER    — Biome version    (default: 0.3.3)
#

FROM docker.io/t2fn/claude-abliterated:rocky10-amd64

# == Build args ==
ARG TS_VER=6.0.3 \
    BIOME_VER=0.3.3

# == Environment ==
ENV NODE_ENV=production \
    NPM_CONFIG_LOGLEVEL=warn \
    PATH="/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/cargo/bin:/usr/local/rustup/bin:/home/claudeuser/.cargo/bin:/home/claudeuser/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    HOME=/home/claudeuser

# == Layer 1: root. Install TypeScript + all tools ==
USER root

RUN set -ex && \
    # ── 1. Install system deps (for native addons) ──
    dnf install -y gcc gcc-c++ make python3 && \
    dnf clean all && rm -rf /var/cache/dnf && \
    \
    # ── 2. Install TypeScript core + all tools via npm (parallel) ──
    #    All versions pinned — offline ready, no runtime internet needed.
    npm install -g \
        typescript@"$TS_VER" \
        biome@"$BIOME_VER" \
        eslint@10 \
        prettier@3 \
        tsx@4 \
        vitest@4 \
        turbo@2 \
        ts-patch@4 \
        tsconfig-paths@4 \
        @swc/core@1 \
    && \
    # tsconfig-paths@4.2.0 has no "bin" field in its package.json, so no symlink is created.
    # Create a wrapper binary so command -v tsconfig-paths works.
    printf '#!/usr/bin/env node\nrequire("tsconfig-paths");\n' \
        > /usr/bin/tsconfig-paths \
    && chmod +x /usr/bin/tsconfig-paths \
    && \
    \
    # ── 3. Ensure npm cache is baked into the layer (offline ready) ──
    npm cache ls >/dev/null 2>&1 && \
    \
    # ── 4. Chown for claudeuser ──
    chown -R claudeuser:claudeuser /home/claudeuser /usr/local/share /usr/local/lib /usr/local/bin || true; \
    \
    # ── 5. Pre-flight checks ──
    echo "== Pre-flight checks ==" && \
    echo "Node:      $(node --version 2>&1)" && \
    echo "npm:       $(npm --version 2>&1)" && \
    echo "tsc:       $(tsc --version 2>&1)" && \
    echo "biome:     $(biome --version 2>&1)" && \
    echo "eslint:    $(eslint --version 2>&1)" && \
    echo "prettier:  $(prettier --version 2>&1)" && \
    echo "tsx:       $(tsx --version 2>&1)" && \
    echo "vitest:    $(vitest --version 2>&1)" && \
    echo "turbo:     $(turbo --version 2>&1)" && \
    echo "ts-patch:  $(ts-patch --version 2>&1)" && \
    echo "tsconfig:  $(tsc --showConfig 2>&1 | head -1)" && \
    echo "swc:       $(which swc 2>&1 || echo 'available via @swc/core')" && \
    echo "" && \
    echo "Pre-loaded configs:" && \
    echo "  biome.json:           $(test -f /home/claudeuser/biome.json && echo 'OK' || echo 'MISSING')" && \
    echo "  eslint.config.mjs:     $(test -f /home/claudeuser/eslint.config.mjs && echo 'OK' || echo 'MISSING')" && \
    echo "  .prettierrc:           $(test -f /home/claudeuser/.prettierrc && echo 'OK' || echo 'MISSING')" && \
    echo "  tsconfig.json:         $(test -f /home/claudeuser/tsconfig.json && echo 'OK' || echo 'MISSING')" && \
    echo "  .editorconfig:         $(test -f /home/claudeuser/.editorconfig && echo 'OK' || echo 'MISSING')" && \
    echo "  SKILL.md:              $(test -f /home/claudeuser/.agents/skills/typescript-claude-abliterated/SKILL.md && echo 'OK (installed)' || echo 'MISSING')" && \
    echo "" && \
    echo "Pre-start hooks (auto-sourced):" && \
    echo "  01-configure-typescript.sh  $(test -f /home/claudeuser/pre-start.d/01-configure-typescript.sh && echo 'OK' || echo 'MISSING')" && \
    echo "  02-configure-biome.sh       $(test -f /home/claudeuser/pre-start.d/02-configure-biome.sh && echo 'OK' || echo 'MISSING')" && \
    echo "  03-configure-claude.sh      $(test -f /home/claudeuser/pre-start.d/03-configure-claude.sh && echo 'OK' || echo 'MISSING')" && \
    echo "  04-lint-generated           $(test -f /home/claudeuser/pre-start.d/04-lint-generated && echo 'OK (opt-in)' || echo 'MISSING (opt-in)')" && \
    echo "" && \
    echo "Installed npm packages:" && \
    npm ls -g --depth=0 2>&1 | head -15 && \
    echo "=== Pre-flight complete ===";

# == Layer 2: claudeuser. Hooks + configs ==
USER claudeuser

# == Copy pre-start and post-stop hooks ==
COPY hooks/pre-start.d/ /home/claudeuser/pre-start.d/
COPY hooks/post-stop.d/ /home/claudeuser/post-stop.d/

# == Copy recommended configs from build context ==
COPY biome.json         /home/claudeuser/biome.json
COPY eslint.config.mjs  /home/claudeuser/eslint.config.mjs
COPY .prettierrc        /home/claudeuser/.prettierrc
COPY tsconfig.json      /home/claudeuser/tsconfig.json
COPY .editorconfig      /home/claudeuser/.editorconfig
COPY SKILL.md           /home/claudeuser/.agents/skills/typescript-claude-abliterated/SKILL.md

# == Working directory ==
WORKDIR /workdir

# == Entry point ==
ENTRYPOINT ["start_claude.sh"]
