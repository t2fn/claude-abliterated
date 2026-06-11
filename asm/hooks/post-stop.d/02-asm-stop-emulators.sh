#!/bin/bash
# 02-asm-stop-emulators.sh — Stop any lingering QEMU/ emulator processes

echo "[asm] Cleaning up assembly background processes."

# Kill any lingering qemu-system or qemu-user processes
pkill -f "qemu-system" 2>/dev/null || true
pkill -f "qemu-user" 2>/dev/null || true
pkill -f "gdb" 2>/dev/null || true

echo "[asm] Assembly emulator processes cleaned up."
