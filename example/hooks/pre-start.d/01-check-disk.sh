#!/bin/bash
# 01-check-disk — Example pre-start plugin.
# Checks available disk space and warns if low.

AVAILABLE_KB=$(df "$HOME" | tail -1 | awk '{print $4}')
# Warn if less than 1 GB (1048576 KB) available.
if [ "${AVAILABLE_KB:-0}" -lt 1048576 ]; then
    echo "[pre-start] WARNING: disk space low (${AVAILABLE_KB} KB available)"
fi
unset AVAILABLE_KB
