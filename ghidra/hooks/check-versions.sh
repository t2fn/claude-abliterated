#!/bin/bash
# check-versions.sh — Check if pinned Dockerfile versions have updates.
#
# Queries GitHub APIs for the latest GHIDRA release and ghidra-docker-mcp repo,
# compares against the ARG values pinned in the Dockerfile, and reports what's out of date.
#
# Usage:
#   ./check-versions.sh          # report only (exit 0 = up-to-date, 1 = update available)
#   UPDATE=1 ./check-versions.sh # apply found updates to the Dockerfile in-place
#   ./check-versions.sh /path/to/Dockerfile  # explicit path
#   GHIDRA_COLOR=1 ./check-versions.sh  # force color output
#
# Exit codes:
#   0 — all versions up to date (or updates applied)
#   1 — update available (or error fetching)

set -euo pipefail

DOCKERFILE="${1:-./Dockerfile}"
APPLY="${UPDATE:-0}"
COLOR="${GHIDRA_COLOR:-0}"

# Color helpers (no-op if COLOR=0)
if [ "$COLOR" -eq 0 ]; then
    RED="" GREEN="" YELLOW="" RESET=""
    USE_ECHO=true
else
    RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' RESET=$'\033[0m'
    USE_ECHO=false
fi

echo_line() {
    # Print a line; interprets escape codes when COLOR=1
    if [ "$USE_ECHO" = true ]; then
        echo "$1"
    else
        echo -e "$1"
    fi
}

# --- Parse pinned versions from Dockerfile ---
# The ARGs are on a single Dockerfile line with backslash continuations:
#   ARG GHIDRA_VER=12.0.4 \
#       GHIDRA_DATE=20260303 \
#       GHIDRA_MCP_URL=https://github.com/...
# We match each key wherever it appears (first line or continuation lines).

ghidra_ver=$(grep -E '(^ARG GHIDRA_VER=|^ *GHIDRA_VER=)' "$DOCKERFILE" | head -1 | sed 's/^ARG GHIDRA_VER=//;s/^ *GHIDRA_VER=//;s/[[:space:]]\\*$//;s/[[:space:]]*$//')
ghidra_date=$(grep 'GHIDRA_DATE=' "$DOCKERFILE" | head -1 | sed 's/.*GHIDRA_DATE=//;s/[[:space:]]\\*$//;s/[[:space:]]*$//')
ghidra_mcp_url=$(grep 'GHIDRA_MCP_URL=' "$DOCKERFILE" | head -1 | sed 's/.*GHIDRA_MCP_URL=//;s/[[:space:]]\\*$//;s/[[:space:]]*$//')

# --- Check GHIDRA ---
ghidra_repo="NationalSecurityAgency/ghidra"
ghidra_tag=$(curl -sL "https://api.github.com/repos/${ghidra_repo}/releases/latest" | jq -r '.tag_name' 2>/dev/null || echo "unknown")
ghidra_pub=$(curl -sL "https://api.github.com/repos/${ghidra_repo}/releases/latest" | jq -r '.published_at' 2>/dev/null | cut -c1-10 || echo "unknown")

# Extract the version number from the tag (e.g. Ghidra_12.1.2_build -> 12.1.2)
ghidra_latest_ver=$(echo "$ghidra_tag" | sed 's/^Ghidra_//;s/_build$//')

# Convert published date 2026-06-05 -> 20260605 for GHIDRA_DATE
ghidra_latest_date=$(echo "$ghidra_pub" | tr -d '-')

if [ "$ghidra_ver" = "$ghidra_latest_ver" ]; then
    ghidra_status="${GREEN}up-to-date${RESET}"
    ghidra_needs_update=false
else
    ghidra_status="${YELLOW}UPDATE AVAILABLE${RESET}"
    ghidra_needs_update=true
fi

# --- Check ghidra-mcp ---
mcp_repo="wellingtonlee/ghidra-docker-mcp"
# Check if it's a git clone (no tags) or pip install
mcp_has_tags=$(curl -sL "https://api.github.com/repos/${mcp_repo}/tags?per_page=1" | jq 'length > 0' 2>/dev/null || echo false)

if [ "$mcp_has_tags" = "true" ]; then
    mcp_latest=$(curl -sL "https://api.github.com/repos/${mcp_repo}/tags?per_page=1" | jq -r '.[0].name' 2>/dev/null || echo "unknown")
    mcp_latest_display="$mcp_latest"
else
    mcp_date=$(curl -sL "https://api.github.com/repos/${mcp_repo}/commits?per_page=1" | jq -r '.[0].commit.committer.date' 2>/dev/null | cut -c1-10 || echo "unknown")
    mcp_latest=$(echo "$mcp_date" | tr -d '-')
    mcp_latest_display="${mcp_date//-/}"
fi

# --- Apply update if requested ---
if [ "$APPLY" = "1" ] && [ "$ghidra_needs_update" = true ]; then
    echo_line ""
    echo_line "${YELLOW}Applying update...${RESET}"

    # Replace GHIDRA_VER and GHIDRA_DATE in the Dockerfile in-place using awk.
    # awk's line-based matching is more precise than sed:
    #   - GHIDRA_VER: only the ARG line
    #   - GHIDRA_DATE: only in the ARG block (before first ENV line)
    #   - ENV GHIDRA_DATE=$GHIDRA_DATE is left untouched
    #   - GHIDRA_MCP_URL: only in the ARG block
    awk -v new_ver="${ghidra_latest_ver}" \
        -v new_date="${ghidra_latest_date}" \
        -v new_mcp_url="${ghidra_mcp_url}" \
    'BEGIN { env_seen=0 }
    /^ENV / { env_seen=1 }
    !env_seen {
        if ($0 ~ /^ARG GHIDRA_VER=/) {
            sub(/GHIDRA_VER=[^ ]*/, "GHIDRA_VER=" new_ver)
        }
        if ($0 ~ /^    GHIDRA_DATE=/) {
            sub(/GHIDRA_DATE=[0-9]+/, "GHIDRA_DATE=" new_date)
        }
        if ($0 ~ /^    GHIDRA_MCP_URL=/) {
            sub(/GHIDRA_MCP_URL=[^ ]*/, "GHIDRA_MCP_URL=" new_mcp_url)
        }
    }
    { print }' "$DOCKERFILE" > "$DOCKERFILE.tmp" && mv "$DOCKERFILE.tmp" "$DOCKERFILE"

    ghidra_ver="$ghidra_latest_ver"
    ghidra_date="${ghidra_latest_date}"
    ghidra_status="${GREEN}updated to ${ghidra_ver} / ${ghidra_latest_date}${RESET}"

    echo_line "${GREEN}Applied: GHIDRA_VER=${ghidra_ver}, GHIDRA_DATE=${ghidra_date}${RESET}"
    ghidra_needs_update=false
fi

# --- Summary ---
echo_line "=== Version Check ($(date -u +%Y-%m-%d)) ==="
echo_line ""
echo_line "GHIDRA"
echo_line "  Pinned:  ${ghidra_ver} (date ${ghidra_date})"
echo_line "  Latest:  ${ghidra_latest_ver} (tagged ${ghidra_tag})"
echo_line "  Status:  ${ghidra_status}"
echo_line ""
echo_line "ghidra-mcp"
echo_line "  URL:     ${ghidra_mcp_url}"
echo_line "  Latest:  ${mcp_latest_display}"
if [ "$mcp_has_tags" = "true" ]; then
    echo_line "  Status:  git clone (latest tag: ${mcp_latest_display})"
else
    echo_line "  Status:  git clone (latest commit: ${mcp_latest_display})"
fi
echo_line ""

# GHIDRA URL format for reference (only shown when update available and not yet applied)
if [ "$ghidra_status" = "${YELLOW}UPDATE AVAILABLE${RESET}" ] || [ "$ghidra_status" = "UPDATE AVAILABLE" ]; then
    echo_line "Suggested: ARG GHIDRA_VER=${ghidra_latest_ver}"
    echo_line "  New URL: https://github.com/${ghidra_repo}/releases/download/${ghidra_tag}/ghidra_${ghidra_latest_ver}_PUBLIC_${ghidra_latest_date//_/-}.zip"
fi

if [ "$ghidra_needs_update" = true ]; then
    exit 1
fi
exit 0
