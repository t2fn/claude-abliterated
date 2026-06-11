# Dockerfile.ghidra — Ghidra + ghidra-mcp on top of claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     Java 21 (full JDK with javac), Ghidra, ghidra-mcp Python package
# Configs:  /home/claudeuser/.ghidra/ and /home/claudeuser/.ghidra-mcp/ (image defaults)
#           pre-start creates /workdir/.ghidra/ and /workdir/.ghidra-mcp/ at runtime
#           These survive volume mounts (created in container fs, not overlayed)
# PID files: /tmp/ghidra-mcp/mcp_pid.txt (cleaned on container exit)
# Hooks:    pre-start.d/ — NN-name.sh scripts sourced in order before Claude starts
#           post-stop.d/ — NN-name.sh scripts sourced in order after Claude exits
#           start_claude.sh orchestrates hooks via source_pre_start_hooks() / source_post_stop_hooks()
#
# Build args:
#   GHIDRA_VER     — Ghidra version  (default: 12.0.4)
#   GHIDRA_DATE    — Ghidra date     (default: 20260303)
#   GHIDRA_MCP_URL — ghidra-mcp repo URL
#

FROM docker.io/t2fn/claude-abliterated:rocky10-amd64

# == Build args ==
ARG GHIDRA_VER=12.1.2 \
    GHIDRA_DATE=20260303 \
    GHIDRA_MCP_URL=https://github.com/t2fn/ghidra-mcp.git \
    AI_GHIDRA_TOOLS_URL=https://github.com/Und3rf10w/ai-ghidra-tools.git

# == Environment (set before switching to root for dnf installs) ==
ENV GHIDRA_VERSION=$GHIDRA_VER \
    GHIDRA_DATE=$GHIDRA_DATE \
    GHIDRA_INSTALL_DIR=/opt/ghidra \
    GHIDRA_MCP_INSTALL_DIR=/opt/ghidra-mcp \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk \
    GHIDRA_ANALYSIS_TIMEOUT_SECONDS=300 \
    GHIDRA_MAX_HEAP=2g \
    PYTHONPATH=/opt/ghidra-mcp/src \
    MCP_TIMEOUT=180000 \
    HOME=/home/claudeuser \
    PATH="/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/ghidra-mcp/bin"

# == Layer 1: root. Install Java 21 (full JDK with javac), Ghidra, ghidra-mcp ==
USER root

# All-in-one RUN: dnf install + ghidra download + ghidra-mcp install
RUN dnf install -y java-21-openjdk-headless java-21-openjdk-devel javapackages-filesystem python3-pip && \
    dnf clean all && \
    GHIDRA_URL="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" && \
    wget -q "$GHIDRA_URL" -O /tmp/ghidra.zip && \
    unzip -q /tmp/ghidra.zip -d /opt && \
    mv /opt/ghidra_${GHIDRA_VERSION}_PUBLIC ${GHIDRA_INSTALL_DIR} && \
    rm /tmp/ghidra.zip && \
    chmod +x ${GHIDRA_INSTALL_DIR}/Ghidra/Features/Decompiler/os/*/decompile* 2>/dev/null && \
    PLATFORM="linux_x86_64" && \
    test -x "${GHIDRA_INSTALL_DIR}/Ghidra/Features/Decompiler/os/${PLATFORM}/decompile" \
    || (echo "FATAL: decompiler not found for ${PLATFORM}" && exit 1) && \
    git clone --depth 1 --single-branch "$GHIDRA_MCP_URL" ${GHIDRA_MCP_INSTALL_DIR} && \
    git clone --depth 1 --single-branch "$AI_GHIDRA_TOOLS_URL" ${GHIDRA_INSTALL_DIR}/ai-ghidra-tools && \
    # bethington/ghidra-mcp uses PEP 723 inline script (no top-level pyproject.toml)
    # Write one so `pip install -e .[sse,dev]` works:
    printf '[build-system]\nrequires = ["setuptools>=68.0", "wheel"]\nbuild-backend = "setuptools.build_meta"\n\n[project]\nname = "ghidra-mcp"\nversion = "5.13.1"\nrequires-python = ">=3.10"\ndependencies = [\n    "mcp>=1.27.2,<2.0.0",\n    "requests>=2.32.0,<3.0.0",\n]\n\n[project.optional-dependencies]\nsse = []\ndev = []\n\n[project.scripts]\nghidra-mcp = "bridge_mcp_ghidra:main"\n\n[tool.setuptools]\npy-modules = ["bridge_mcp_ghidra"]\n' > ${GHIDRA_MCP_INSTALL_DIR}/pyproject.toml && \
    python3 -m pip install --break-system-packages --no-cache-dir \
        -e ${GHIDRA_MCP_INSTALL_DIR}[sse,dev] && \
    rm -rf ${GHIDRA_MCP_INSTALL_DIR}/.git && \
    chown -R claudeuser: /home/claudeuser /opt/ghidra /opt/ghidra-mcp && \
    \
    # == Pre-flight checks (ghidra-mcp README) ==
    echo "== Pre-flight checks ==" && \
    echo "Java: $(java -version 2>&1 | head -1)" && \
    echo "Python: $(python3 --version 2>&1)" && \
    echo "Ghidra: $(ls ${GHIDRA_INSTALL_DIR}/Ghidra/GhidraRun 2>/dev/null && echo 'OK' || echo 'MISSING')" && \
    echo "Decompiler: $(test -x ${GHIDRA_INSTALL_DIR}/Ghidra/Features/Decompiler/os/${PLATFORM}/decompile && echo 'OK' || echo 'MISSING')" && \
    ghidra-mcp --version 2>&1 | head -1 && \
    python3 -m tools.setup preflight 2>&1 | tail -5 && \
    python3 -m tools.setup ensure-prereqs 2>&1 | tail -5 && \
    echo "== Pre-flight complete =="

# == Layer 2: claudeuser. Copy hooks and config defaults ==
USER claudeuser

# == Copy pre-start and post-stop hooks to /home/claudeuser/ ==
COPY hooks/pre-start.d/ /home/claudeuser/pre-start.d/
COPY hooks/post-stop.d/ /home/claudeuser/post-stop.d/

# == Copy ghidra-mcp SKILLS.md into superpowers (standard location for Claude Code to discover) ==
COPY SKILLS.md /home/claudeuser/.superpowers/skills/ghidra-mcp/SKILLS.md

# == Copy ai-ghidra-tools SKILL.md into superpowers ==
COPY ai-ghidra-tools-SKILL.md /home/claudeuser/.superpowers/skills/ai-ghidra-tools/SKILL.md

# == Working directory (user mount point) ==
WORKDIR /workdir

# == Entry point ==
ENTRYPOINT ["start_claude.sh"]
