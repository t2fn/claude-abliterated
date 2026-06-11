#!/bin/bash
# 03-configure-claude.sh — Claude Java dev environment config
#
# All tools are installed at Docker build time (see Dockerfile RUN).
# This hook reports versions — it does NOT install anything at runtime, and does NOT auto-lint.
# No network needed. No "will be installed" lies.
# No auto-touching of existing code — rules documented in SKILL.md:
#   NEW files Claude writes  → auto-lint before presenting
#   EXISTING code            → do NOT touch; ask before linting
#
# Linting tools are available and versions are reported on startup.
# They will NOT run automatically — they wait for Claude to be tasked.

echo "[java] Java dev tools ready:"

# Per-tool version check: each tool gets the right method for its binary
check_version() {
    local tool="$1"
    local version=""

    case "$tool" in
        java)
            version=$(java -version 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        javac)
            version=$(javac -version 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        mvn)
            version=$(mvn --version 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        gradle)
            version=$(gradle --version 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
            [ -z "$version" ] && version="MISSING"
            ;;
        spring)
            if command -v spring >/dev/null 2>&1; then
                version=$(spring --version 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
                if [ -z "$version" ]; then
                    version=$(spring help 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
                fi
            fi
            [ -z "$version" ] && version="available"
            ;;
        spotbugs)
            if command -v spotbugs >/dev/null 2>&1; then
                version=$(spotbugs -version 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
            elif [ -f /home/claudeuser/java/spotbugs/bin/spotbugs.sh ]; then
                version="present (at /home/claudeuser/java/spotbugs/)"
            else
                version="MISSING"
            fi
            ;;
        pmd)
            if command -v pmd >/dev/null 2>&1; then
                version=$(pmd -version 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
            elif [ -f /home/claudeuser/java/pmd/bin/pmd.sh ]; then
                version="present (at /home/claudeuser/java/pmd/)"
            else
                version="MISSING"
            fi
            ;;
        checkstyle)
            if [ -f /home/claudeuser/java/checkstyle.jar ]; then
                version=$(java -jar /home/claudeuser/java/checkstyle.jar --version 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
                version="${version} (config: /home/claudeuser/checkstyle.xml)"
            else
                version="JAR missing"
            fi
            ;;
        google-java-format)
            if [ -f /home/claudeuser/java/google-java-format.jar ]; then
                version=$(java -jar /home/claudeuser/java/google-java-format.jar --version 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
            else
                version="JAR missing"
            fi
            ;;
        jdtls)
            if [ -d /home/claudeuser/java/jdtls ]; then
                version="ready (IDE language server)"
            else
                version="available"
            fi
            ;;
        jdb)
            if command -v jdb >/dev/null 2>&1; then
                version=$(jdb -help 2>&1 | head -1 | sed 's/^ *//;s/ *$//')
            else
                version="MISSING"
            fi
            ;;
        *)
            version="MISSING"
            ;;
    esac

    echo "  $tool: $version"
}

for tool in java javac mvn gradle spring spotbugs pmd checkstyle google-java-format jdtls jdb; do
    check_version "$tool"
done

echo ""
echo "[java] Pre-loaded linting configs — NOT auto-applied:"
echo "  Rules are documented in SKILL.md."
echo "  Claude should ASK before linting existing or generated code."
echo "  Only touch existing code when permission is given."
