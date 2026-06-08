#!/bin/bash
#                                       ▒                           
#                                    ▒▒▒▒▒▒                         
#                                    ▒▒▒▒▒▒▒                        
#                                   ▒▒▒▒▒▒▒                         
#                                   ▒▒▒▒▒▒▒                         
#                                   ▒▒▒▒▒▒▒                         
#                                   ▒▒▒▒▒▒                          
#                                   ▒▒▒▒▒▒                          
#           CLAUDE                  ▒▒▒▒▒▒                          
#            ABLITERATED           ▒▒▒▒▒▒                           
#                                  ▒▒▒▒▒▒                           
#                                  ▒▒▒▒▒                            
#                                  ▒▒▒▒▒                            
#                                  ▒▒▒▒▒                            
#                                 ▒▒▒▒▒                             
#                                 ▒▒▒▒▒                             
# ▒▒                              ▒▒▒▒▒                             
#▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒                             
# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒                         
#               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒          
#                                ▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ 
#                                 ▒▒▒▒           ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
#                                 ▒▒▒▒                  ▒▒▒▒▒▒▒▒▒▒▒▒
#                                 ▒▒▒▒                              
#                                ▒▒▒▒▒                              
#                                ▒▒▒▒▒                              
#                                ▒▒▒▒▒                              
#                               ▒▒▒▒▒                               
#                               ▒▒▒▒▒                               
#                               ▒▒▒▒▒                               
#                              ▒▒▒▒▒▒                               
#                              ▒▒▒▒▒▒                               
#                              ▒▒▒▒▒▒                               
#                             ▒▒▒▒▒▒                                
#                             ▒▒▒▒▒▒                                
#                              ▒▒▒▒▒                                
#
# start_claude.sh — Entrypoint for the Claude Abliterated container.
#
# Usage:
#   start_claude.sh [ARGS]
#   start_claude.sh /bin/bash [-c "cmd"] [ARGS]
#
# Environment variables (all optional):
#   ANTHROPIC_BASE_URL  — API endpoint; derived from OPENAI_BASE_URL if unset.
#   ANTHROPIC_AUTH_TOKEN — API key; derived from OPENAI_API_KEY if unset.
#   OPENAI_BASE_URL     — alternate API endpoint (e.g. reverse proxy).
#   OPENAI_API_KEY      — fallback API key.
#   OLLAMA_MODEL        — if set, starts local Ollama and launches with it.
#   OLLAMA_HOST         — Ollama API host; defaults to autodetect.
#   MODEL               — base model; set from OLLAMA_MODEL if unset.
#   ANTHROPIC_MODEL, ANTHROPIC_SMALL_FAST_MODEL, etc. — model overrides.
#   CLAUDE_CODE_AUTO_COMPACT_WINDOW  — auto-compact token threshold (default: 200000).
#   CLAUDE_AUTOCOMPACT_PCT_OVERRIDE   — auto-compact percentage (default: 95).
#   CLAUDE_CONFIG_DIR — config directory (default: $HOME/.claude).
#
# Behavior:
#   1. Resolves API URLs, keys, and model names from environment.
#   2. If ANTHROPIC_BASE_URL starts with "socket://", starts socat forwarding.
#   3. Copies default .claude config if .claude/ doesn't exist yet.
#   4. If OLLAMA_MODEL is set, starts Ollama and launches claude via ollama.
#   5. Otherwise launches claude directly.
#
# Ollama is killed on script exit only if this script started it.
#

set -e

# ============================================================================
# Ollama tracking — killed on exit if this script started it.
# ============================================================================
OLLAMA_PID=""
OLLAMA_STARTED=0

# ============================================================================
# Plugin directories — pre-start and post-stop hooks.
# Pre-start scripts are sourced (same shell context) near the top.
# Post-stop scripts are invoked during cleanup on EXIT.
# ============================================================================
PRE_START_DIR="/home/claudeuser/pre-start.d"
POST_STOP_DIR="/home/claudeuser/post-stop.d"
POST_STOP_RUN=0  # Guard: only run post-stop scripts once.

# ============================================================================
# Pre-start plugins — source all *.sh in pre-start.d (alphabetical order).
# Scripts are sourced (not exec'd), so they share the same shell context
# and can set/override environment variables for the rest of the script.
# ============================================================================
for hook in "${PRE_START_DIR}"/*.sh; do
    [ -f "$hook" ] || continue
    [ -r "$hook" ] || continue
    echo "[pre-start] sourcing ${hook}"
    source "$hook"
done
unset hook

# ============================================================================
# API URL and key resolution.
# Derive ANTHROPIC_BASE_URL from OPENAI_BASE_URL (strip trailing /v1).
# Derive ANTHROPIC_AUTH_TOKEN from OPENAI_API_KEY.
# ============================================================================
if [ -z "$ANTHROPIC_BASE_URL" ] && [ -n "$OPENAI_BASE_URL" ]; then
    ANTHROPIC_BASE_URL=${OPENAI_BASE_URL%/}
    export ANTHROPIC_BASE_URL=${ANTHROPIC_BASE_URL%/v1}
fi

if [ -z "$ANTHROPIC_AUTH_TOKEN" ] && [ -n "$OPENAI_API_KEY" ]; then
    export ANTHROPIC_AUTH_TOKEN="${OPENAI_API_KEY}"
fi

# ============================================================================
# Model propagation.
# If MODEL is unset but OLLAMA_MODEL is set, use OLLAMA_MODEL as the base.
# If MODEL is set, propagate it to all downstream model variables.
# ============================================================================
if [ -z "$MODEL" ] && [ -n "$OLLAMA_MODEL" ]; then
    MODEL="$OLLAMA_MODEL"
fi

if [ -n "$MODEL" ]; then
    [ -z "$ANTHROPIC_MODEL" ] && export ANTHROPIC_MODEL="$MODEL"
    [ -z "$ANTHROPIC_SMALL_FAST_MODEL" ] && export ANTHROPIC_SMALL_FAST_MODEL="$MODEL"
    [ -z "$CLAUDE_CODE_SUBAGENT_MODEL" ] && export CLAUDE_CODE_SUBAGENT_MODEL="$MODEL"
    [ -z "$ANTHROPIC_DEFAULT_SONNET_MODEL" ] && export ANTHROPIC_DEFAULT_SONNET_MODEL="$MODEL"
    [ -z "$ANTHROPIC_DEFAULT_HAIKU_MODEL" ] && export ANTHROPIC_DEFAULT_HAIKU_MODEL="$MODEL"
    [ -z "$ANTHROPIC_DEFAULT_OPUS_MODEL" ] && export ANTHROPIC_DEFAULT_OPUS_MODEL="$ANTHROPIC_MODEL"
fi

# ============================================================================
# Auto-compact settings (defaults).
# ============================================================================
[ -z "$CLAUDE_CODE_AUTO_COMPACT_WINDOW" ] && export CLAUDE_CODE_AUTO_COMPACT_WINDOW="200000"
[ -z "$CLAUDE_AUTOCOMPACT_PCT_OVERRIDE" ] && export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE="95"

# ============================================================================
# Local port detection.
# If OPENAI_BASE_URL starts with http://localhost:, extract the port.
# ============================================================================
if [[ "$OPENAI_BASE_URL" == http://localhost:* ]]; then
    LOCAL_PORT=${OPENAI_BASE_URL#http://localhost:}
    export LOCAL_PORT=${LOCAL_PORT%%[^0-9]*}
fi

# ============================================================================
# Socket forwarding.
# If ANTHROPIC_BASE_URL starts with socket://, start socat to forward a local
# TCP port to the Unix socket, then replace ANTHROPIC_BASE_URL with
# http://127.0.0.1:<port>.
# ============================================================================
SOCKET_PID=""
SOCKET_PORT=""
SOCKET_PORT_FILE=""
if [[ "$ANTHROPIC_BASE_URL" == socket://* ]]; then
    SOCKET_PATH=${ANTHROPIC_BASE_URL#socket://}
    SOCKET_PORT_FILE=$(mktemp /tmp/.socat-port.XXXXXX)
    socat TCP-LISTEN:0,fork,reuseaddr,local-portfile:${SOCKET_PORT_FILE} UNIX:${SOCKET_PATH} &
    SOCKET_PID=$!

    for _i in $(seq 1 30); do
        if [ -s "$SOCKET_PORT_FILE" ]; then
            SOCKET_PORT=$(cat "$SOCKET_PORT_FILE")
            break
        fi
        sleep 0.1
    done
    [ -z "$SOCKET_PORT" ] && SOCKET_PORT=18080
    export ANTHROPIC_BASE_URL="http://127.0.0.1:${SOCKET_PORT}"
    echo "Socket forwarding: socket://${SOCKET_PATH} -> http://127.0.0.1:${SOCKET_PORT} (socat PID: $SOCKET_PID)"
fi

# ============================================================================
# cleanup — kill ollama and socat on exit; invoke post-stop.d plugins.
# ============================================================================
cleanup() {
    # Stop ollama if this script started it.
    if [ "$OLLAMA_STARTED" -eq 1 ] && [ -n "$OLLAMA_PID" ]; then
        echo "Stopping ollama (PID: $OLLAMA_PID)..."
        kill $OLLAMA_PID 2>/dev/null || true
        wait $OLLAMA_PID 2>/dev/null || true
    fi
    # Stop socat socket forwarder if one was started.
    if [ -n "$SOCKET_PID" ]; then
        echo "Stopping socat (PID: $SOCKET_PID)..."
        kill $SOCKET_PID 2>/dev/null || true
        wait $SOCKET_PID 2>/dev/null || true
    fi
    # Clean up the temp port file.
    if [ -n "$SOCKET_PORT_FILE" ] && [ -e "$SOCKET_PORT_FILE" ]; then
        rm -f "$SOCKET_PORT_FILE"
    fi
    # Invoke post-stop.d plugins (only once).
    if [ "$POST_STOP_RUN" -eq 0 ]; then
        POST_STOP_RUN=1
        for hook in "${POST_STOP_DIR}"/*.sh; do
            [ -f "$hook" ] || continue
            [ -r "$hook" ] || continue
            echo "[post-stop] sourcing ${hook}"
            source "$hook"
        done
        unset hook
    fi
}
trap cleanup EXIT

# ============================================================================
# Config initialization.
# Copy default .claude config from the Docker image build-time location
# into the working config directory if it doesn't exist yet.
# ============================================================================
if [ ! -e "./.claude" ]; then
    rsync -a $HOME/.claude/ $CLAUDE_CONFIG_DIR/
fi

# ============================================================================
# Main entry — either ollama or direct claude.
# If $1 == "/bin/bash", run a shell with remaining args;
# otherwise launch claude with the appropriate model.
# ============================================================================
if [ -n "$OLLAMA_MODEL" ]; then
    if [ "$OLLAMA_HOST" == "" ]; then
        echo "OLLAMA_MODEL=$OLLAMA_MODEL — starting ollama.."

        if pgrep -x ollama > /dev/null; then
            echo "Ollama is already running (PID: $(pgrep -x ollama))"
        else
            echo "Starting Ollama server in background..."
            ollama serve &
            OLLAMA_PID=$!
            OLLAMA_STARTED=1
            echo "Ollama started (PID: $OLLAMA_PID)"

            # Wait up to 30s for ollama to become ready.
            for i in $(seq 1 30); do
                if ollama list > /dev/null 2>&1; then
                    echo "Ollama server is ready after ${i}s"
                    break
                fi
                sleep 1
            done
        fi
    fi

    # Pull the model if it is not already present.
    if ollama list | grep -q "^$OLLAMA_MODEL "; then
        echo "Model $OLLAMA_MODEL already present"
    else
        echo "Pulling model $OLLAMA_MODEL..."
        ollama pull "$OLLAMA_MODEL"
        echo "Model pulled successfully"
    fi

    if [ "$1" == "/bin/bash" ]; then
        shift 1
        /bin/bash "$@"
    else
        ollama launch claude --model "$OLLAMA_MODEL" -- "$@"
    fi
else
    if [ "$1" == "/bin/bash" ]; then
        shift 1
        /bin/bash "$@"
    elif [ -n "$MODEL" ]; then
        claude --model "$MODEL" "$@"
    else
        claude "$@"
    fi
fi
