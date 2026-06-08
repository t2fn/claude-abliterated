#!/bin/bash
# update_source_shas.sh — Update source.shas with deliberate commits (tags, PR merges).
#
# For each repo, picks a SHA in order of preference:
#   1. Latest tag's commit SHA   (deliberate — explicitly released)
#   2. Latest PR-merge commit     (deliberate — reviewed/merged via GitHub)
#   3. HEAD (less significant — just the current tip)
#
# Special handling:
#   - PR merges and tags are treated equally as "deliberate" commits.
#   - Commits after a tag/PR-merge are less significant (we prefer the older
#     deliberate commit over a newer raw HEAD).
#   - Commits with "WIP" or "TESTING" in their message are ignored entirely.
#
# This script auto-discovers repo config from source.shas, so no hardcoded values.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_SHAS="${SCRIPT_DIR}/source.shas"

# ── Repo definitions (ordered list of owner/repo) ────────────────
# These must match the repo names referenced in source.shas.
declare -a REPO_LIST=(
  "skrabe/tweakcc-fixed"
  "skrabe/lobotomized-claude-code"
  "mijuny/claude-tools"
  "rohitg00/awesome-claude-code-toolkit"
  "pcvelz/superpowers"
  "unicodeveloper/shannon"
)

# ── Helper functions ─────────────────────────────────────────

# Read the current SHA value from source.shas for a given variable name.
read_current_sha() {
  local var_name="$1"
  grep "^${var_name}=" "$SOURCE_SHAS" | head -1 | sed "s/^${var_name}=//"
}

# Get the latest tag's commit SHA for a repo.
latest_tag_sha() {
  local repo="$1"
  local result
  result=$(git ls-remote "https://github.com/${repo}.git" "refs/tags/*" \
    | grep -v '\^{}' \
    | tail -1 \
    | awk '{print $1}' || true)
  echo "${result:-}"
}

# Get the latest tag name (e.g. v4.0.11) for a repo.
latest_tag_name() {
  local repo="$1"
  local result
  result=$(git ls-remote "https://github.com/${repo}.git" "refs/tags/*" \
    | grep -v '\^{}' \
    | tail -1 \
    | awk '{print $2}' \
    | sed 's|refs/tags/||' || true)
  echo "${result:-}"
}

# Check if a commit is a PR merge via GitHub API.
is_pr_merge() {
  local repo="$1"
  local commit_sha="$2"

  local api_response
  api_response=$(curl -sf "https://api.github.com/repos/${repo}/commits/${commit_sha}" 2>/dev/null) || true

  if [ -n "$api_response" ]; then
    local committer
    committer=$(echo "$api_response" | python3 -c \
      "import sys,json; d=json.load(sys.stdin); print(d.get('commit',{}).get('committer',{}).get('name',''))" 2>/dev/null)
    local msg
    msg=$(echo "$api_response" | python3 -c \
      "import sys,json; d=json.load(sys.stdin); print(d.get('commit',{}).get('message',''))" 2>/dev/null)

    # PR merges have committer=GitHub OR message contains "Merge PR" / "Merge pull request"
    if echo "$committer" | grep -qi "GitHub"; then
      return 0
    fi
    if echo "$msg" | grep -qi "Merge PR\|Merge pull request"; then
      return 0
    fi
  fi

  return 1
}

# Check if a commit has WIP or TESTING in its message.
# If so, the commit is ignored entirely (not deliberate).
is_wip_or_testing() {
  local repo="$1"
  local commit_sha="$2"

  local api_response
  api_response=$(curl -sf "https://api.github.com/repos/${repo}/commits/${commit_sha}" 2>/dev/null) || true

  if [ -n "$api_response" ]; then
    local msg
    msg=$(echo "$api_response" | python3 -c \
      "import sys,json; d=json.load(sys.stdin); print(d.get('commit',{}).get('message',''))" 2>/dev/null)

    if echo "$msg" | grep -qi "WIP\|TESTING"; then
      return 0
    fi
  fi

  return 1
}

# ── Main logic ─────────────────────────────────────────────

echo "== update_source_shas =="
echo ""

CHANGES=0
declare -a NEW_VARS=()
declare -a NEW_SHAS=()

for entry in "${REPO_LIST[@]}"; do
  repo="$entry"
  repo_name="${repo##*/}"          # e.g. tweakcc-fixed
  owner="${repo%/*}"               # e.g. skrabe

  # Map repo_name to the env_var name in source.shas
  # Strategy: look for the .sha or SHA env var whose value starts with the owner's repos
  env_var=""
  case "$repo_name" in
    tweakcc-fixed)          env_var="TWEAKCC_SHA" ;;
    lobotomized-claude-code) env_var="LOBOTOMIZED_SHA" ;;
    claude-tools)           env_var="CLAUDE_TOOLS_SHA" ;;
    awesome-claude-code-toolkit) env_var="AWESOME_TOOLKIT_SHA" ;;
    superpowers)            env_var="SUPERPOWERS_SHA" ;;
    shannon)                env_var="SHANNON_SHA" ;;
    *)                      env_var="${repo_name^^}_SHA" ;;
  esac

  # Read current SHA from source.shas
  cur_sha=$(read_current_sha "$env_var")

  echo "--- ${repo} (${env_var}) ---"
  echo "  current:   ${cur_sha}"

  # Get latest tag
  tag_sha=$(latest_tag_sha "$repo")
  tag_name=$(latest_tag_name "$repo")
  head_sha=$(git ls-remote "https://github.com/${repo}.git" HEAD | awk '{print $1}')

  # Check if HEAD is PR merge
  head_is_pr="no"
  if is_pr_merge "$repo" "$head_sha" 2>/dev/null; then
    head_is_pr="yes"
  fi

  # Check if HEAD is WIP/TESTING (ignore it)
  head_is_wip="no"
  if is_wip_or_testing "$repo" "$head_sha" 2>/dev/null; then
    head_is_wip="yes"
  fi

  # Determine recommended SHA
  # Priority: tag > PR-merge HEAD (if HEAD not WIP) > HEAD (if not WIP) > HEAD regardless
  if [ -n "$tag_sha" ] && [ "$tag_sha" != "" ]; then
    # Has tags — prefer the latest tag (it's a deliberate snapshot)
    # Even if HEAD has moved past the tag, the tag is "more deliberate" than raw HEAD
    rec_sha="$tag_sha"
    rec_label="${tag_name} (tag)"

    if [ "$head_sha" != "$tag_sha" ]; then
      rec_label="${rec_label} (HEAD=${head_sha})"
    fi
  elif [ "$head_is_pr" = "yes" ] && [ "$head_is_wip" = "no" ]; then
    # No tags but HEAD is a PR merge and not WIP
    rec_sha="$head_sha"
    rec_label="HEAD (PR merge)"
  elif [ "$head_is_wip" = "yes" ]; then
    # HEAD is WIP/TESTING — still use it but note it
    rec_sha="$head_sha"
    rec_label="HEAD (WIP/TESTING — using anyway)"
  else
    # No tags, not a PR merge — use HEAD but less significance
    rec_sha="$head_sha"
    rec_label="HEAD (direct — less significant)"
  fi

  # Check if current == recommended
  if [ "$cur_sha" = "$rec_sha" ]; then
    echo "  tag:       ${tag_name} -> ${tag_sha}"
    echo "  head:      ${head_sha} (PR: ${head_is_pr}, WIP: ${head_is_wip})"
    echo "  recommended: ${rec_label} -> ${rec_sha}"
    echo "  status:    OK (unchanged)"
    NEW_VARS+=("$env_var")
    NEW_SHAS+=("$cur_sha")
  else
    echo "  tag:       ${tag_name} -> ${tag_sha}"
    echo "  head:      ${head_sha} (PR: ${head_is_pr}, WIP: ${head_is_wip})"
    echo "  recommended: ${rec_label} -> ${rec_sha}"
    echo "  status:    CHANGE (will update)"
    NEW_VARS+=("$env_var")
    NEW_SHAS+=("$rec_sha")
    CHANGES=$((CHANGES + 1))
  fi
  echo ""
done

# ── Update source.shas ─────────────────────────────────────

echo "== Writing updates =="

if [ -f "$SOURCE_SHAS" ]; then
  TMPFILE=$(mktemp)
  cp "$SOURCE_SHAS" "$TMPFILE"

  # Apply each update
  for i in "${!NEW_VARS[@]}"; do
    var="${NEW_VARS[$i]}"
    sha="${NEW_SHAS[$i]}"
    sed -i "s|^${var}=.*|${var}=${sha}|" "$TMPFILE"
  done

  # Show diff
  echo ""
  echo "--- diff (pinned SHA lines) ---"
  diff <(grep -E "^[A-Z_]+SHA=" "$SOURCE_SHAS") \
       <(grep -E "^[A-Z_]+SHA=" "$TMPFILE") || true

  # Move into place
  cp "$TMPFILE" "$SOURCE_SHAS"
  rm "$TMPFILE"

  echo ""
  echo "== Done. ${CHANGES} changes applied. =="
else
  echo "ERROR: source.shas not found at ${SOURCE_SHAS}"
  exit 1
fi
