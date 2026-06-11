#!/bin/bash
# install_gcc.sh — Install docker CLI + dockerd for gcc-claude build, then run build
#
# This script:
# 1. Installs docker CLI and dockerd binaries (from docker-static tarball)
# 2. Installs dependencies: containerd, fuse-overlayfs, iptables
# 3. Starts containerd and dockerd in rootless mode
# 4. Installs buildx as a CLI plugin
# 5. Runs docker build via build.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_STATIC_URL="https://download.docker.com/linux/static/stable/x86_64/docker-27.5.1.tgz"
BUILDX_URL="https://github.com/docker/buildx/releases/download/v0.19.3/buildx-v0.19.3.linux-amd64"
DOCKER_DIR="/home/claudeuser/bin"
INSTALL_DIR="/home/claudeuser/bin"
DOCKERD_XDG_DIR="/tmp/dockerd-xdg"
CONTAINERD_SOCKET="/tmp/containerd.sock"

echo "====== GCC CLAUDE INSTALLER ===="
echo "  Script dir:  ${SCRIPT_DIR}"
echo "  Docker dir:  ${DOCKER_DIR}"
echo "  Dockerd XDG: ${DOCKERD_XDG_DIR}"
echo "  Containerd:  ${CONTAINERD_SOCKET}"
echo "====== GCC CLAUDE INSTALLER ===="

# ── Step 1: Install docker CLI and dockerd if needed ──
echo ""
echo ">> Step 1: Checking docker CLI..."

if command -v docker > /dev/null 2>&1; then
    echo "  docker CLI already installed: $(docker --format '{{.Client.Version}}' version 2>/dev/null || echo 'present')"
else
    echo "  Installing docker CLI..."

    # Create a temp directory for docker files
    mkdir -p "${INSTALL_DIR}/docker-files"

    # Download docker static bundle if not already done
    if [ ! -f "${INSTALL_DIR}/docker-files/docker.tgz" ]; then
        echo "  Downloading ${DOCKER_STATIC_URL}..."
        wget -q "${DOCKER_STATIC_URL}" -O "${INSTALL_DIR}/docker-files/docker.tgz"
    fi

    # Extract docker if needed (handle both nested and flat structures)
    if [ ! -d "${INSTALL_DIR}/docker-files/docker" ]; then
        tar -xzf "${INSTALL_DIR}/docker-files/docker.tgz" -C "${INSTALL_DIR}/docker-files"
    fi

    # Extract all binaries to INSTALL_DIR
    if [ -d "${INSTALL_DIR}/docker-files/docker" ]; then
        cp -f "${INSTALL_DIR}/docker-files/docker/dockerd" "${INSTALL_DIR}/dockerd"
        cp -f "${INSTALL_DIR}/docker-files/docker/docker-init" "${INSTALL_DIR}/docker-init"
        cp -f "${INSTALL_DIR}/docker-files/docker/docker-proxy" "${INSTALL_DIR}/docker-proxy"
        cp -f "${INSTALL_DIR}/docker-files/docker/containerd-shim-runc-v2" "${INSTALL_DIR}/containerd-shim-runc-v2"
        cp -f "${INSTALL_DIR}/docker-files/docker/containerd" "${INSTALL_DIR}/containerd"
        cp -f "${INSTALL_DIR}/docker-files/docker/runc" "${INSTALL_DIR}/runc"
        cp -f "${INSTALL_DIR}/docker-files/docker/ctr" "${INSTALL_DIR}/ctr"
        # Copy docker CLI (it's a file, not a directory)
        cp -f "${INSTALL_DIR}/docker-files/docker/docker" "${INSTALL_DIR}/docker-cli" 2>/dev/null || true
    fi

    chmod +x "${INSTALL_DIR}/dockerd" "${INSTALL_DIR}/docker-init" "${INSTALL_DIR}/docker-proxy" \
             "${INSTALL_DIR}/containerd-shim-runc-v2" "${INSTALL_DIR}/containerd" \
             "${INSTALL_DIR}/runc" "${INSTALL_DIR}/ctr"

    # Create symlink for docker command
    ln -sf "${INSTALL_DIR}/docker-cli" "${INSTALL_DIR}/docker" 2>/dev/null || true
    ln -sf "${INSTALL_DIR}/docker" /home/claudeuser/bin/docker 2>/dev/null || true

    echo "  Docker CLI installed to ${INSTALL_DIR}/docker-cli"
fi

echo "  docker: $(command -v docker 2>/dev/null || echo "$(pwd)/docker")"

# ── Step 2: Install dependencies ──
echo ""
echo ">> Step 2: Installing dependencies..."

# Install fuse-overlayfs and iptables if not already installed
if ! command -v fuse-overlayfs > /dev/null 2>&1; then
    echo "  Installing fuse-overlayfs..."
    apt-get install -y -qq fuse-overlayfs 2>&1 | tail -3
fi

if ! command -v iptables > /dev/null 2>&1; then
    echo "  Installing iptables..."
    apt-get install -y -qq iptables 2>&1 | tail -3
fi

# Install buildx if not already installed
if [ ! -f "${INSTALL_DIR}/docker-buildx" ] || ! file "${INSTALL_DIR}/docker-buildx" | grep -q "ELF"; then
    echo "  Downloading buildx..."
    wget -q "${BUILDX_URL}" -O "${INSTALL_DIR}/docker-buildx"
    chmod +x "${INSTALL_DIR}/docker-buildx"
fi

# Install buildx as a CLI plugin
mkdir -p "${INSTALL_DIR}/cli-plugins"
mkdir -p "${HOME}/.docker/cli-plugins"
ln -sf "${INSTALL_DIR}/docker-buildx" "${INSTALL_DIR}/cli-plugins/docker-buildx"
ln -sf "${INSTALL_DIR}/docker-buildx" "${HOME}/.docker/cli-plugins/docker-buildx"

echo "  Dependencies installed."

# ── Step 3: Start containerd and dockerd ──
echo ""
echo ">> Step 3: Starting containerd and dockerd..."

# Kill any existing processes
pkill -9 dockerd 2>/dev/null || true
pkill -9 containerd 2>/dev/null || true
sleep 2

# Create XDG runtime directory
mkdir -p "${DOCKERD_XDG_DIR}"

# Set up environment for rootless mode
export XDG_RUNTIME_DIR="${DOCKERD_XDG_DIR}"
export DOCKER_HOST="unix://${DOCKERD_XDG_DIR}/docker.sock"

# Create symlinks for sockets
ln -sf "${DOCKERD_XDG_DIR}/docker.sock" /tmp/docker.sock 2>/dev/null || true

# Start containerd with explicit socket address
echo "  Starting containerd..."
nohup "${INSTALL_DIR}/containerd" --address "${CONTAINERD_SOCKET}" \
    > /tmp/containerd-install.log 2>&1 &
CTR_PID=$!
echo "  containerd PID: ${CTR_PID}"
sleep 2

# Verify containerd is running
if [ -S "${CONTAINERD_SOCKET}" ]; then
    echo "  containerd socket ready."
else
    echo "  Waiting for containerd socket..."
    sleep 3
fi

# Start dockerd in rootless mode with containerd
echo "  Starting dockerd (rootless, with containerd)..."
nohup "${INSTALL_DIR}/dockerd" \
    --rootless \
    --host="unix://${DOCKERD_XDG_DIR}/docker.sock" \
    --containerd="${CONTAINERD_SOCKET}" \
    --storage-driver=vfs \
    --iptables=false \
    --ip6tables=false \
    --bridge=none \
    > /tmp/dockerd-install.log 2>&1 &
DOCKERD_PID=$!
echo "  dockerd PID: ${DOCKERD_PID}"

# Wait for dockerd to start (up to 15 seconds)
echo "  Waiting for dockerd to become ready..."
for i in $(seq 1 15); do
    if [ -S "${DOCKERD_XDG_DIR}/docker.sock" ] || [ -S /tmp/docker.sock ]; then
        echo "  dockerd socket ready after ${i}s"
        break
    fi
    sleep 1
done

# Verify docker can connect
sleep 2
if docker version > /dev/null 2>&1; then
    echo "  dockerd is ready and responding!"
else
    echo "  dockerd started, waiting a bit more..."
    sleep 3
    docker version
fi

# ── Step 4: Run build.sh ──
echo ""
echo ">> Step 4: Running build.sh..."
cd "${SCRIPT_DIR}"

# Set environment for build
export DOCKER_HOST="unix://${DOCKERD_XDG_DIR}/docker.sock"

# Run the build
echo ""
bash ./build.sh 2>&1

BUILD_EXIT=$?
echo ""
if [ ${BUILD_EXIT} -eq 0 ]; then
    echo ""
    echo "====== INSTALL + BUILD COMPLETE ======"
    echo "  Docker CLI:    installed"
    echo "  containerd:    running (rootless)"
    echo "  dockerd:       running (rootless, XDG=${DOCKERD_XDG_DIR})"
    echo "  buildx:        installed as CLI plugin"
    echo "  Image:         $(docker images --format '{{.Repository}}:{{.Tag}}' --filter 'reference=*gcc*' 2>/dev/null | head -1)"
    echo "====== INSTALL + BUILD COMPLETE ======"
else
    echo ""
    echo "====== BUILD FAILED (exit ${BUILD_EXIT}) ======"
fi

exit ${BUILD_EXIT}
