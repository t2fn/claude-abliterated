#!/bin/bash
set -e

# ── Lock file to prevent concurrent runs ──
LOCK_FILE="/tmp/build_all.sh.lock"
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    echo "build_all.sh is already running (lock file: $LOCK_FILE)"
    exit 1
fi

rsync --delete -av $HOME/git/claude/ gx10:git/claude/ --exclude=.claude || true

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
REPO="${T2FN_REPO:-t2fn}"
BASE="${REPO}/claude-abliterated"

# Last-built version stored by this script
VERSION_FILE="$SCRIPT_DIR/.claude-latest-version"

# ── Fetch git SHAs at the top (before building anything) ──
# These SHAs are fetched once and passed to all Docker builds for reproducibility.
fetch_git_sha() {
    git ls-remote "https://github.com/${1}/${2}.git" HEAD | awk '{print $1}'
}

TWEAKCC_SHA=$(fetch_git_sha skrabe tweakcc-fixed)
LOBOTOMIZED_SHA=$(fetch_git_sha skrabe lobotomized-claude-code)
CLAUDE_TOOLS_SHA=$(fetch_git_sha mijuny claude-tools)
AWESOME_TOOLKIT_SHA=$(fetch_git_sha rohitg00 awesome-claude-code-toolkit)
SUPERPOWERS_SHA=$(fetch_git_sha pcvelz superpowers)
SHANNON_SHA=$(fetch_git_sha unicodeveloper shannon)

export TWEAKCC_SHA LOBOTOMIZED_SHA CLAUDE_TOOLS_SHA AWESOME_TOOLKIT_SHA SUPERPOWERS_SHA SHANNON_SHA

# ── Fetch current Claude Code version from the API ──
LATEST_VER=$(curl -s https://downloads.claude.ai/claude-code-releases/latest | tr -d '[:space:]')
LAST_BUILT_VER=$(cat "$VERSION_FILE" 2>/dev/null | tr -d '[:space:]')

export BUILDX_NO_DEFAULT_ATTESTATIONS=true

if [ -n "$LAST_BUILT_VER" ] && [ "$LATEST_VER" = "$LAST_BUILT_VER" ] && [ "${FORCE_BUILD:-}" != "1" ]; then
    echo "No new version: latest=$LATEST_VER == last-built=$LAST_BUILT_VER. Skipping build."
    exit 0
fi

echo "Latest Claude Code version: $LATEST_VER (last built: ${LAST_BUILT_VER:-none})"
echo "Git SHAs pinned for this build:"
echo "  TWEAKCC_SHA=$TWEAKCC_SHA"
echo "  LOBOTOMIZED_SHA=$LOBOTOMIZED_SHA"
echo "  CLAUDE_TOOLS_SHA=$CLAUDE_TOOLS_SHA"
echo "  AWESOME_TOOLKIT_SHA=$AWESOME_TOOLKIT_SHA"
echo "  SUPERPOWERS_SHA=$SUPERPOWERS_SHA"
echo "  SHANNON_SHA=$SHANNON_SHA"

declare -A BUILDS=(
    ["${BASE}:rocky10"]="Dockerfile.rocky10 rockylinux/rockylinux:10 rocky10"
    ["${BASE}:rocky9"]="Dockerfile.rocky9 rockylinux:9 rocky9"
    ["${BASE}:ubuntu"]="Dockerfile.ubuntu24 ubuntu ubuntu"
    ["${BASE}:debian"]="Dockerfile.debian debian debian"
    ["${BASE}:alpine"]="Dockerfile.alpine alpine alpine"
)

GX10="${GX10_HOST:-gx10}"

HUB_TOKEN=$( jq -r '.auths."https://index.docker.io/v1/".auth' ~/.docker/config.json 2>/dev/null ) || true
FAILED=0
PASSED=0
BUILD_START_TOTAL=$(date +%s)
declare -A BUILD_TIME

# Build-arg prefix shared across all platforms
BARGS=(
    "--build-arg" "CLAUDE_VERSION=${LATEST_VER}"
    "--build-arg" "TWEAKCC_SHA=${TWEAKCC_SHA}"
    "--build-arg" "LOBOTOMIZED_SHA=${LOBOTOMIZED_SHA}"
    "--build-arg" "CLAUDE_TOOLS_SHA=${CLAUDE_TOOLS_SHA}"
    "--build-arg" "AWESOME_TOOLKIT_SHA=${AWESOME_TOOLKIT_SHA}"
    "--build-arg" "SUPERPOWERS_SHA=${SUPERPOWERS_SHA}"
    "--build-arg" "SHANNON_SHA=${SHANNON_SHA}"
)

for image_key in "${!BUILDS[@]}"; do
    read -r df base short_tag <<< "${BUILDS[$image_key]}"

    # Record start time for this build
    build_start=$(date +%s)

    # Extract just the repository name (without tag suffix) from the key
    repo_name="docker.io/${image_key%%:*}"
    remote_repo_name="docker.io/${image_key%%:*}"

    echo "====== Building ${repo_name}:${short_tag} (from $df) ======"

    docker pull "$base"

    # Build amd64 image locally with build-args
    docker build --platform linux/amd64 "${BARGS[@]}" "$SCRIPT_DIR" -f "$SCRIPT_DIR/$df" -t "${repo_name}:${short_tag}-amd64"

    if [ "$short_tag" = "rocky10" ]; then
        echo Smoke test
        echo "docker run --entrypoint timeout --rm -it -v .:/workdir -e OLLAMA_HOST=10.12.2.4 -e OLLAMA_MODEL=huihui_ai/Qwen3.6-abliterated:35b --rm \"${repo_name}:${short_tag}-amd64\" 120 start_claude.sh -p \"what is the speed of light\""
        if docker run --entrypoint timeout --rm -it -v .:/workdir -e OLLAMA_HOST=10.12.2.4 -e OLLAMA_MODEL=huihui_ai/Qwen3.6-abliterated:35b --rm "${repo_name}:${short_tag}-amd64" 120 start_claude.sh -p "what is the speed of light" | grep 299; then
            echo pass
        else
            echo failed
            docker run --name build_investigator --rm -it -e IS_SANDBOX=1 -u root -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/workdir -e OLLAMA_HOST=10.12.2.4 -e OLLAMA_MODEL=huihui_ai/Qwen3.6-abliterated:35b --rm t2fn/claude-abliterated:debian --system-prompt "You are a program troubleshooter" -p "investigate the issue with install.sh as it seems to be blocking the build_rocky10.sh to pass the smoke test in build_all.sh.  You may need to look at the repos, such as tweakcc-fixed or lobotomized-claude-code to see what changes may have caused the issue.  Investigate, test, and fix install.sh to allow build_rocky10.sh to build a container and the claude instance to function properly.  Please try building the docker container and test that it can run a prompt properly or fix what needs to be done by modifying install.sh to make the claude code run properly on both redhat and debian varients."
            exit 1
        fi
        echo Passed
    fi

    ver=$( docker run --rm --entrypoint claude "${repo_name}:${short_tag}-amd64" --version | sed '/Claude/!d;s/ .*//' )

    # Tag amd64 versions
    docker rmi "${repo_name}:${short_tag}" || true
    docker tag "${repo_name}:${short_tag}-amd64" "${repo_name}:${short_tag}-${ver}-amd64"
    docker push "${repo_name}:${short_tag}-${ver}-amd64"

    echo "Building ${short_tag} arm64 on $GX10 ..."
    # SSH to gx10 to build arm64 image with same build-args
    ssh "$GX10" "cd ~/git/claude && \
        docker pull '$base' && \
        docker build . --platform linux/arm64 \
            --build-arg CLAUDE_VERSION=${LATEST_VER} \
            --build-arg TWEAKCC_SHA=${TWEAKCC_SHA} \
            --build-arg LOBOTOMIZED_SHA=${LOBOTOMIZED_SHA} \
            --build-arg CLAUDE_TOOLS_SHA=${CLAUDE_TOOLS_SHA} \
            --build-arg AWESOME_TOOLKIT_SHA=${AWESOME_TOOLKIT_SHA} \
            --build-arg SUPERPOWERS_SHA=${SUPERPOWERS_SHA} \
            --build-arg SHANNON_SHA=${SHANNON_SHA} \
            -f $df -t '${repo_name}:${short_tag}-arm64' && \
        docker save '${repo_name}:${short_tag}-arm64' -o '/tmp/${short_tag}-gx10.tar'"
    scp "$GX10:/tmp/${short_tag}-gx10.tar" "/tmp/${short_tag}-gx10.tar"

    echo Load arm64 image locally
    docker load -i "/tmp/${short_tag}-gx10.tar"
    echo Tagging with version number
    docker tag "${repo_name}:${short_tag}-arm64" "${repo_name}:${short_tag}-${ver}-arm64"
    echo pushing locally
    docker push "${repo_name}:${short_tag}-${ver}-arm64"

    echo Create combined manifest for short_tag
    docker buildx imagetools create -t "${remote_repo_name}:${short_tag}" \
        "${repo_name}:${short_tag}-${ver}-amd64" \
        "${repo_name}:${short_tag}-${ver}-arm64"

    echo Create combined manifest for short_tag-version
    docker buildx imagetools create -t "${remote_repo_name}:${short_tag}-${ver}" \
        "${repo_name}:${short_tag}-${ver}-amd64" \
        "${repo_name}:${short_tag}-${ver}-arm64"

    # Tag rocky10 as latest (AFTER manifest creation)
    if [ "$short_tag" = "rocky10" ]; then
        echo Tagging with latest-amd
        docker tag "${repo_name}:${short_tag}-amd64" "${repo_name}:latest-amd64"
        echo pushing locally
        docker push "${repo_name}:latest-amd64"
        echo tagging rocky10 as latest
        docker buildx imagetools create -t "${remote_repo_name}:latest" \
            "${repo_name}:${short_tag}-${ver}-amd64" \
            "${repo_name}:${short_tag}-${ver}-arm64"
        docker rmi "${repo_name}:latest-amd64"
    fi

    # Cleanup local images (the -amd64 image is saved in the tar)
    docker rmi "${repo_name}:${short_tag}-amd64" 2>/dev/null || true
    docker rmi "${repo_name}:${short_tag}-arm64" 2>/dev/null || true
    docker rmi "${repo_name}:${short_tag}-${ver}-amd64" 2>/dev/null || true
    docker rmi "${repo_name}:${short_tag}-${ver}-arm64" 2>/dev/null || true
    docker rmi "${repo_name}:${short_tag}" 2>/dev/null || true

    echo " OK: ${repo_name}:${short_tag}-${ver} (amd64 + arm64)"
    echo ""
    ((PASSED++)) || true

    # Track timing for this build
    build_elapsed=$(( $(date +%s) - build_start ))
    BUILD_TIME[$short_tag]=$build_elapsed

    # Cleanup local tars
    rm -f "/tmp/${short_tag}-gx10.tar"

    # Cleanup gx10 images and temp tar
    ssh "$GX10" "cd ~/git/claude && \
        docker rmi '${repo_name}:${short_tag}' '${repo_name}:${short_tag}-arm64' '${repo_name}:${short_tag}-${ver}-arm64' 2>/dev/null || true && \
        rm -f '/tmp/${short_tag}-gx10.tar'"
done

echo ""
echo "====== Build timings ======"
for st in rocky10 rocky9 debian ubuntu; do
    if [ -n "${BUILD_TIME[$st]:-}" ]; then
        printf "  %-10s %6.1fs\n" "$st" "$(echo "${BUILD_TIME[$st]}" | awk '{printf "%.1f", $1}')"
    fi
done
TOTAL_ELAPSED=$(( $(date +%s) - BUILD_START_TOTAL ))
printf "  %-10s %6.1fs\n" "total" "$(echo "$TOTAL_ELAPSED" | awk '{printf "%.1f", $1}')"
echo ""

echo "====== Results: $PASSED passed, $FAILED failed ======"

# Save the CLAUDE_VERSION (fetched at the top) to the version file only on success
# This ensures the version saved matches what was used throughout the build.
if [ "$FAILED" -eq 0 ]; then
    echo "$LATEST_VER" > "$VERSION_FILE"
    echo "Saved version $LATEST_VER to $VERSION_FILE"
else
    echo "Build failed — version file not updated (was $LAST_BUILT_VER)."
    exit 1
fi

# Clean up temporary build cache space
echo "Cleaning up Docker build cache ..."
docker system prune -f --filter "until=24h"
echo "Done."

# Release lock
flock -u 200
