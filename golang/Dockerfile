# Dockerfile.golang — Go dev stack on claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     Go 1.26.4 + gopls, dlv, gotests, goplay, gomodifytags,
#           impl, staticcheck, golangci-lint, revive, go-critic, goimports, godoc
# Configs:  /usr/local/go (Go toolchain), /home/claudeuser/go (GOPATH, tools)
# PATH:     /home/claudeuser/go/bin includes all tool binaries
#
# Build args:
#   GO_VER       — Go version (default: 1.26.4)
#   GO_SHA256    — Go binary checksum
#

FROM docker.io/t2fn/claude-abliterated:rocky10-amd64

# == Build args ==
ARG GO_VER=1.26.4 \
    GO_SHA256=1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f

# == Environment ==
ENV GOROOT=/usr/local/go \
    GOPATH=/home/claudeuser/go \
    GOBIN=/home/claudeuser/go/bin \
    PATH="/home/claudeuser/go/bin:/usr/local/go/bin:/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    HOME=/home/claudeuser

# == Layer 1: root. Install Go + all Go tools ==
USER root

# All-in-one RUN: download Go + install all tools + pre-flight checks
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi && \
    GO_URL="https://go.dev/dl/go${GO_VER}.linux-${ARCH}.tar.gz" && \
    wget -q "$GO_URL" -O /tmp/go.tar.gz && \
    echo "$GO_SHA256  /tmp/go.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz && \
    chown -R claudeuser: /usr/local/go /home/claudeuser && \
    su -l -s /bin/bash -c "export PATH=\"/usr/local/go/bin:/home/claudeuser/go/bin:\$PATH\" && go install golang.org/x/tools/gopls@latest && go install github.com/go-delve/delve/cmd/dlv@latest && go install github.com/cweill/gotests/...@latest && go install github.com/haya14busa/goplay/cmd/goplay@latest && go install github.com/fatih/gomodifytags@latest && go install github.com/josharian/impl@latest && go install honnef.co/go/tools/cmd/staticcheck@latest && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && go install github.com/mgechev/revive@latest && go install github.com/go-critic/go-critic/cmd/gocritic@latest && go install golang.org/x/tools/cmd/goimports@latest && go install golang.org/x/tools/cmd/godoc@latest" claudeuser && \
    echo "== Pre-flight checks ==" && \
    echo "Go: $(go version)" && \
    echo "gopls:  $(gopls version 2>&1 | head -1)" && \
    echo "dlv:    $(dlv version 2>&1 | head -1)" && \
    echo "golangci-lint: $(golangci-lint version 2>&1 | head -1)" && \
    echo "staticcheck: $(staticcheck -version 2>&1 | head -1)" && \
    echo "revive:  $(revive -version 2>&1 | head -1)" && \
    echo "gocritic:$(gocritic version 2>&1 | head -1)" && \
    echo "gotests: $(gotests --version 2>&1 | head -1)" && \
    echo "gomodifytags: $(gomodifytags -version 2>&1 | head -1)" && \
    echo "impl:  $(impl -v 2>&1 | head -1)" && \
    echo "goimports: $(goimports -v 2>&1 | head -1)" && \
    echo "goplay:  $(goplay -v 2>&1 | head -1)" && \
    echo "godoc:   $(godoc -version 2>&1 | head -1)" && \
    echo "=== Pre-flight complete ===";

# == Layer 2: claudeuser. Hooks + config ==
USER claudeuser

# == Copy pre-start and post-stop hooks ==
COPY hooks/pre-start.d/ /home/claudeuser/pre-start.d/
COPY hooks/post-stop.d/ /home/claudeuser/post-stop.d/

# == Copy golangci-lint config ==
COPY golangci.yml /etc/golangci.yml

# == Working directory ==
WORKDIR /workdir

# == Entry point ==
ENTRYPOINT ["start_claude.sh"]
