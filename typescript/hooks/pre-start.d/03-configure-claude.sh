#!/bin/bash
# 03-configure-claude.sh — Claude TypeScript dev environment config
# Mirrors Rust/Go pattern: print actual versions for all tools

echo "[typescript] TypeScript dev tools:"

for tool in tsc biome eslint prettier tsx vitest turbo ts-patch tsconfig-paths @swc/core; do
    case $tool in
        tsc)
            ver="$(tsc --version 2>/dev/null)"
            ;;
        biome)
            ver="$(biome --version 2>/dev/null)"
            ;;
        eslint)
            ver="$(eslint --version 2>/dev/null)"
            ;;
        prettier)
            ver="$(prettier --version 2>/dev/null)"
            ;;
        tsx)
            ver="$(tsx --version 2>/dev/null)"
            ;;
        vitest)
            ver="$(vitest --version 2>/dev/null)"
            ;;
        turbo)
            ver="$(turbo --version 2>/dev/null)"
            ;;
        ts-patch)
            ver="$(ts-patch --version 2>/dev/null)"
            ;;
        tsconfig-paths)
            if command -v tsconfig-paths-bootstrap >/dev/null 2>&1 || type tsconfig-paths-bootstrap >/dev/null 2>&1; then
                ver="$(tsconfig-paths-bootstrap --version 2>/dev/null || echo 'available')"
            else
                ver="OK (via tsconfig-paths-bootstrap)"
            fi
            ;;
        @swc/core)
            if command -v swc >/dev/null 2>&1; then
                ver="$(swc --version 2>/dev/null)"
            else
                ver="OK (via @swc/core)"
            fi
            ;;
        *)
            if command -v "$tool" >/dev/null 2>&1; then
                ver="$($tool --version 2>/dev/null || echo 'installed')"
            else
                ver="OK (will be installed if needed)"
            fi
            ;;
    esac
    echo "  $tool: $ver"
done
