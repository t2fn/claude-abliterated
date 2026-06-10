# Dockerfile.python — Python linting & code quality stack on claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     Python 3.13 + ruff, pyupgrade, pylint, flake8, black, isort,
#           mypy, pydocstyle, autoflake, bandit, pycodestyle, pyflakes, pyright
# Configs:  pyproject.toml (ruff, black, isort, mypy, bandit defaults)
# PATH:     /home/claudeuser/.local/bin includes all tool binaries
#
# Build args:
#   PYTHON_TOOLS_VER — pinned versions string for pip install
#
FROM docker.io/t2fn/claude-abliterated:rocky10-amd64

# == Build args ==
ARG PYTHON_TOOLS_VER=

# == Environment ==
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/home/claudeuser/.local/lib/python3.13/site-packages \
    PATH="/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    HOME=/home/claudeuser

# == Layer 1: root. Install Python dev tools + all Python linting tools ==
USER root

# Install Python dev headers + pip + build deps
RUN dnf install -y python3-devel python3-pip gcc make && \
    dnf clean all && \
    \
    # Install all Python linting & code quality tools
    python3 -m pip install --break-system-packages --no-cache-dir \
        # === Meta-linter / unified tool ===
        ruff>=0.11.0 \
        # === Syntax upgrade ===
        pyupgrade>=3.17.0 \
        # === Comprehensive linters ===
        pylint>=3.3.0 \
        flake8>=7.1.0 \
        # === Formatters ===
        black>=24.10.0 \
        isort>=5.13.0 \
        # === Type checkers ===
        mypy>=1.14.0 \
        pyright>=1.1.390 \
        # === Docstrings & style ===
        pydocstyle>=6.3.0 \
        pycodestyle>=2.12.0 \
        pyflakes>=3.2.0 \
        autoflake>=2.3.0 \
        # === Security ===
        bandit>=1.8.0 \
        ${PYTHON_TOOLS_VER} && \
    \
    # === Pre-flight checks ===
    echo "== Pre-flight checks ==" && \
    echo "Python:  $(python3 --version 2>&1)" && \
    echo "pip:     $(pip3 --version 2>&1)" && \
    for tool in ruff pyupgrade pylint flake8 black isort mypy pydocstyle autoflake bandit pycodestyle pyflakes pyright; do echo "  $tool: $($tool --version 2>&1 | head -1)"; done && \
    echo "== Pre-flight complete ==" && \
    \
    chown -R claudeuser: /home/claudeuser

# == Layer 2: claudeuser. Hooks + config ==
USER claudeuser

# == Copy pre-start and post-stop hooks ==
COPY hooks/pre-start.d/ /home/claudeuser/pre-start.d/
COPY hooks/post-stop.d/ /home/claudeuser/post-stop.d/
COPY pyproject.toml /home/claudeuser/pyproject.toml

# == Working directory ==
WORKDIR /workdir

# == Entry point ==
ENTRYPOINT ["start_claude.sh"]
