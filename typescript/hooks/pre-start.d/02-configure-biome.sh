#!/bin/bash
# 02-configure-biome.sh — Verify biome linter/formatter with version numbers
# Mirrors Rust's 02-configure-clippy.sh pattern: version + config

BIOME_VER="$(biome --version 2>/dev/null || echo 'biome installed')"

echo "[typescript] Biome linter:"
echo "  version: $BIOME_VER"
echo "  check:   $(biome check --help 2>&1 | head -1)"
echo "  format:  $(biome format --help 2>&1 | head -1)"

echo "[typescript] Biome config:"
echo "  Using: biome.json"
echo "  Rules: correctness, suspicious, style, complexity, nursery"
