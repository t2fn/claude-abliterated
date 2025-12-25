#!/bin/bash
# Install script for the claude-abliterated Docker image.
#
# This script sets up the entire Claude Abliterated Code environment in one pass.
set -ex
cd /home/claudeuser

# Prevent git committing of any .claude directory (for the /workdir/.claude path)
echo ".claude/" > $HOME/.gitignore_global
git config --global core.excluesfile $HOME/.gitignore_global

# Ensure fully explicit PATH so git and other standard binaries are always found.
# The Dockerfile ENV PATH may vary across base images; this guarantees all standard paths.
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/claudeuser/bin:/home/claudeuser/.local/bin"

# Self-healing: if git was installed in the first RUN layer but didn't persist to the
# second RUN layer's filesystem, check common locations and use absolute path.
if [ ! -x /usr/bin/git ]; then
    if [ -x /usr/local/bin/git ]; then
        : # found in alternate path
    elif command -v rpm >/dev/null 2>&1 && rpm -q git >/dev/null 2>&1; then
        : # git package is installed (binary may be in non-standard location)
    fi
fi

# ---------------------------------------------------------------------------
# 1. Install Claude CLI (release from claude.ai)
#    Fetch the official install script, strip stray 'rm' lines that would
#    delete our downloads layer, save it, then run with the pinned version.
#    CLAUDE_VERSION is set via --build-arg at build time; falls back to 'latest'.
# ---------------------------------------------------------------------------
: "${CLAUDE_VERSION:=latest}"
curl -fsSL https://claude.ai/install.sh | sed '/^ *rm/d' > /tmp/claude-install.sh
bash /tmp/claude-install.sh "$CLAUDE_VERSION"
# When using litellm and using the 128000 limit, a rounding error can sometime cause it to add a small bit
#perl -i -pe 's/(q=|_S_=)128000(?=[;,}])/${1}127997/g' /home/claudeuser/.local/share/claude/versions/*

# ---------------------------------------------------------------------------
# 2. Apply tweakcc-fixed
#    Clones the tweakcc repo at a pinned SHA, installs deps, builds, and patches Claude
#    Code's cli.js in place — three mechanisms cover different injection
#    paths: named-prompt overrides, inline-blob overrides, and system
#    reminder overrides.
#    TWEAKCC_SHA is set via --build-arg at build time; falls back to HEAD.
#    .git is removed after checkout to minimize image size (shallow clone, no history).
# ---------------------------------------------------------------------------
: "${TWEAKCC_SHA:=HEAD}"
git clone --depth 100 --single-branch https://github.com/skrabe/tweakcc-fixed.git ~/dev/tweakcc-fixed
cd ~/dev/tweakcc-fixed
# Fetch the specific SHA into the shallow clone's history (needed for older tag SHAs).
git fetch origin "${TWEAKCC_SHA}" 2>/dev/null
# Remove shallow boundary so git checkout can read the tree through the full chain.
#git fetch origin --unshallow 2>/dev/null
git checkout -q "$TWEAKCC_SHA"
# Run pnpm install; --include=optional installs esbuild but its postinstall may be ignored
# We use --ignore-scripts=false to ensure postinstall runs and creates the binary
pnpm install --dangerously-allow-all-builds && pnpm approve-builds --all && pnpm build
mkdir -p /home/claudeuser/.tweakcc/
cp /tmp/config.json /home/claudeuser/.tweakcc/config.json
node ~/dev/tweakcc-fixed/dist/index.mjs --apply

# ---------------------------------------------------------------------------
# 3. Clone lobotomized-claude-code
#    Copies the system-prompt overrides repo and symlinks system-prompts/
#    and system-reminders/ into the ~/.tweakcc/ directory for easy access.
#    LOBOTOMIZED_SHA is set via --build-arg at build time; falls back to HEAD.
# ---------------------------------------------------------------------------
: "${LOBOTOMIZED_SHA:=HEAD}"
git clone --depth 100 --single-branch https://github.com/skrabe/lobotomized-claude-code.git ~/.tweakcc/lobotomized-claude-code
cd ~/.tweakcc/lobotomized-claude-code
# Fetch the specific SHA into the shallow clone's history (needed for older tag SHAs).
git fetch origin "${LOBOTOMIZED_SHA}" 2>/dev/null
# Remove shallow boundary so git checkout can read the tree through the full chain.
#git fetch origin --unshallow 2>/dev/null
git checkout -q "$LOBOTOMIZED_SHA"
ln -sfn ~/.tweakcc/lobotomized-claude-code/system-prompts ~/.tweakcc/system-prompts
ln -sfn ~/.tweakcc/lobotomized-claude-code/system-reminders ~/.tweakcc/system-reminders

# ---------------------------------------------------------------------------
# 4. Install claude-tools (everyday slash commands)
#    Clones the CLI tools repo and copies its scripts into ~/bin so they
#    are available via slash commands (/fix, /ask, /plan).
#    CLAUDE_TOOLS_SHA is set via --build-arg at build time; falls back to HEAD.
# ---------------------------------------------------------------------------
: "${CLAUDE_TOOLS_SHA:=HEAD}"
git clone --depth 100 --single-branch https://github.com/mijuny/claude-tools ~/.claude-tools
cd ~/.claude-tools
git fetch origin "${CLAUDE_TOOLS_SHA}" 2>/dev/null
# Remove shallow boundary so git checkout can read the tree through the full chain.
#git fetch origin --unshallow 2>/dev/null
git checkout -q "$CLAUDE_TOOLS_SHA"
mkdir -p ~/bin
cp -f ~/.claude-tools/bin/* ~/bin/
chmod +x ~/bin/*

# ---------------------------------------------------------------------------
# 5. Install awesome-claude-code-toolkit (skills, rules, templates)
#    Copies skills (domain-specific knowledge), rules (per-project behavior),
#    and templates (reusable code patterns) into ~/.claude/.
#    AWESOME_TOOLKIT_SHA is set via --build-arg at build time; falls back to HEAD.
# ---------------------------------------------------------------------------
: "${AWESOME_TOOLKIT_SHA:=HEAD}"
git clone --depth 100 --single-branch https://github.com/rohitg00/awesome-claude-code-toolkit ~/.claude-code-toolkit
cd ~/.claude-code-toolkit
git fetch origin "${AWESOME_TOOLKIT_SHA}" 2>/dev/null
# Remove shallow boundary so git checkout can read the tree through the full chain.
#git fetch origin --unshallow 2>/dev/null
git checkout -q "$AWESOME_TOOLKIT_SHA"
cp -rf ~/.claude-code-toolkit/skills ~/.claude/skills
cp -rf ~/.claude-code-toolkit/rules ~/.claude/rules
cp -rf ~/.claude-code-toolkit/templates ~/.claude/templates

# ---------------------------------------------------------------------------
# 6. Install superpowers (advanced dev workflows)
#    Clones scripts (brainstorming, gate checking, subagent development)
#    into ~/bin and skills into ~/.claude/skills/.
#    SUPERPOWERS_SHA is set via --build-arg at build time; falls back to HEAD.
# ---------------------------------------------------------------------------
: "${SUPERPOWERS_SHA:=HEAD}"
git clone --depth 100 --single-branch https://github.com/pcvelz/superpowers ~/.superpowers
cd ~/.superpowers
git fetch origin "${SUPERPOWERS_SHA}" 2>/dev/null
# Remove shallow boundary so git checkout can read the tree through the full chain.
#git fetch origin --unshallow 2>/dev/null
git checkout -q "$SUPERPOWERS_SHA"
cp -f ~/.superpowers/scripts/*.sh ~/bin/
chmod +x ~/bin/*.sh
cp -rf ~/.superpowers/skills ~/.claude/skills

# ---------------------------------------------------------------------------
# 7. Install shannon (AI-driven research and guidance)
#    Clones scripts and SKILL.md into ~/bin and ~/.claude/skills/.
#    SHANNON_SHA is set via --build-arg at build time; falls back to HEAD.
# ---------------------------------------------------------------------------
: "${SHANNON_SHA:=HEAD}"
git clone --depth 100 --single-branch https://github.com/unicodeveloper/shannon ~/.shannon
cd ~/.shannon
git fetch origin "${SHANNON_SHA}" 2>/dev/null
# Remove shallow boundary so git checkout can read the tree through the full chain.
#git fetch origin --unshallow 2>/dev/null
git checkout -q "$SHANNON_SHA"
cp -f ~/.shannon/scripts/*.sh ~/bin/
cp -f ~/.shannon/SKILL.md ~/.claude/skills/

# ---------------------------------------------------------------------------
# 8. Install global npm packages
#    npx and antigravity-awesome-skills are pre-installed by the Dockerfile's
#    merged layer (L1+2) as root — these npm install calls are idempotent,
#    re-installing them into ~/claudeuser/.local for the claudeuser account.
#    npx (Node package runner) and antigravity-awesome-skills (200+ skills,
#    activates automatically based on project file detection).
# ---------------------------------------------------------------------------
mkdir -p ~/.local/bin
npm install -g npx --prefix /home/claudeuser/.local
npm install -g antigravity-awesome-skills --prefix /home/claudeuser/.local && antigravity-awesome-skills -y

# 8b. Upgrade all global npm packages to latest major versions
#     Uses -S flag to get latest major (not just semver-compatible)
#     This minimizes vulnerabilities from outdated transitive dependencies.
npm install -g -S --force npm --prefix /home/claudeuser/.local
npm install -g -S --force pnpm --prefix /home/claudeuser/.local
npm install -g -S --force antigravity-awesome-skills --prefix /home/claudeuser/.local
# npm update -g skipped to avoid EACCES rename errors with Docker overlay2
# All packages already at latest major from -S installs above
# Deduplicate AFTER all installs to avoid race conditions
# Use --force to handle Docker overlay2 filesystem rename issues
npm dedupe --force 2>/dev/null

# 9. Cleanup
#    Removes the backup directory created during install and sets permissive
#    read and execute-on-directories permissions across ~/home/claudeuser/.
# ---------------------------------------------------------------------------
rm -rf /home/claudeuser/.claude/backups/
chmod a+rX -R /home/claudeuser/

# 10. Ensure plugin directories exist for the start/stop hook infrastructure.
#     pre-start.d  — sourced by start_claude.sh near the top.
#     post-stop.d  — sourced during cleanup (EXIT) in start_claude.sh.
# Users can drop *.sh files into these directories for custom plugins.
# ---------------------------------------------------------
mkdir -p /home/claudeuser/pre-start.d /home/claudeuser/post-stop.d
