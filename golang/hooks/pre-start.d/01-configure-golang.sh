#!/bin/bash
# 01-configure-golang.sh — Configure Go environment before Claude starts
# Sourced in order before Claude starts

echo "[golang] Go environment:"
echo "  GOROOT=$GOROOT"
echo "  GOPATH=$GOPATH"
echo "  GOBIN=$GOBIN"

# go: direct binary output
echo "  Go: $(go version 2>/dev/null)"

# golangci-lint: version line
echo "  golangci-lint: $(golangci-lint version 2>/dev/null | head -1)"

# Fix gopls cache ownership (root-owned from Docker build)
# Also ensure ~/.cache is 777 for alternate UID users
if [ -d /home/claudeuser/.cache/gopls ]; then
    chown -R claudeuser: /home/claudeuser/.cache/gopls
fi
if [ -d /home/claudeuser/.cache ]; then
    chmod 777 /home/claudeuser/.cache
fi

# List all core tools with accurate versions
echo "[golang] Tool versions:"

# go: native version command
echo "  go: $(go version 2>/dev/null)"

# gopls: go version -m (writes to stderr, captures exact module version)
echo "  gopls: $(go version -m "$(which gopls)" 2>&1 | grep "^mod " | head -1)"

# dlv: dlv version (first 2 lines)
echo "  dlv: $(dlv version 2>&1 | head -2)"

# gotests: --version
echo "  gotests: $(gotests --version 2>&1 | head -1)"

# gomodifytags: -version
echo "  gomodifytags: $(gomodifytags -version 2>&1)"

# impl: -v
echo "  impl: $(impl -v 2>&1)"

# staticcheck: -version
echo "  staticcheck: $(staticcheck -version 2>&1)"

# goplay: go version -m (goplay reads stdin, skip it)
echo "  goplay: $(go version -m "$(which goplay)" 2>&1 | grep "^mod " | head -1)"

# gocritic: version
echo "  gocritic: $(gocritic version 2>&1)"

# goimports: go version -m (goimports reads stdin, skip it)
echo "  goimports: $(go version -m "$(which goimports)" 2>&1 | grep "^mod " | head -1)"

# godoc: -v (shows "Go Documentation Server")
echo "  godoc: $(godoc -v 2>&1 | grep "Go Documentation")"

# revive: -version
echo "  revive: $(revive -version 2>&1)"
