#!/bin/bash
# 00-tmp-cleanup — Example post-stop plugin.
# Cleans up temporary files on exit.

# Clean up any leftover temp files from pre-start hooks.
if [ -d "${PRE_START_DIR:-}" ]; then
    find "${PRE_START_DIR}" -name "*.tmp" -delete 2>/dev/null || true
fi

# Clean up any leftover temp files from post-stop hooks.
if [ -d "${POST_STOP_DIR:-}" ]; then
    find "${POST_STOP_DIR}" -name "*.tmp" -delete 2>/dev/null || true
fi
