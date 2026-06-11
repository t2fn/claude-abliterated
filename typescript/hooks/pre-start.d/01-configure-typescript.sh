#!/bin/bash
# 01-configure-typescript.sh — Configure TypeScript environment before Claude starts
# Sourced in order before Claude starts
# Mirrors the Rust/golang pattern: print env vars + actual version numbers

echo "[typescript] TypeScript environment:"
echo "  Node: $(node --version 2>/dev/null)"
echo "  npm:  $(npm --version 2>/dev/null)"
echo "  tsc:  $(tsc --version 2>/dev/null)"
echo "  biome: $(biome --version 2>/dev/null)"
echo "  eslint: $(eslint --version 2>/dev/null)"
echo "  prettier: $(prettier --version 2>/dev/null)"
echo "  tsx:  $(tsx --version 2>/dev/null)"
echo "  vitest: $(vitest --version 2>/dev/null)"
echo "  turbo:  $(turbo --version 2>/dev/null)"
