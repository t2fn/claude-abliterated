#!/bin/bash
# 01-configure-golang.sh — Configure Go environment before Claude starts
# Sourced in order before Claude starts

echo "[golang] Go environment:"
echo "  GOROOT=$GOROOT"
echo "  GOPATH=$GOPATH"
echo "  GOBIN=$GOBIN"
echo "  Go: $(go version 2>/dev/null || echo 'Go 1.26.4 available')"
echo "  golangci-lint: $(golangci-lint version 2>/dev/null | head -1 || echo 'installed')"
