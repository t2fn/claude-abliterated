#!/bin/bash
# 01-configure-java.sh — Configure Java environment before Claude starts
# Sourced in order before Claude starts
#
# LINTING PHILOSOPHY (from SKILL.md):
#   NEW files Claude writes  → auto-lint before presenting
#   EXISTING code            → do NOT touch; ask before linting
#   Startup hook runs        → report versions only, no file modifications

echo "[java] Java environment:"
echo "  JAVA_HOME=$JAVA_HOME"
echo "  M2=$M2"
echo "  GRADLE_USER_HOME=$GRADLE_USER_HOME"

# Core Java tools (use -version 2>&1 to capture stderr output)
echo "  Java:     $(java -version 2>&1 | head -1)"
echo "  Javac:    $(javac -version 2>&1 | head -1)"

# Build tools
echo "  Maven:    $(mvn --version 2>&1 | head -1)"
echo "  Gradle:   $(gradle --version 2>&1 | head -1)"

# Spring Boot
echo "  Spring:   $(spring --version 2>&1 | head -1 || echo 'Spring Boot CLI available')"

# Linters
echo "  SpotBugs: $(spotbugs -version 2>&1 | head -1 || spotbugs -help 2>&1 | head -1)"
echo "  PMD:      $(pmd -version 2>&1 | head -1)"
echo "  Checkstyle: $(java -jar /home/claudeuser/java/checkstyle.jar --version 2>&1 | head -1)"
echo "  Google JF: $(java -jar /home/claudeuser/java/google-java-format.jar --version 2>&1 | head -1)"

# IDE tools
echo "  JDTLS:    $(ls /home/claudeuser/java/jdtls 2>/dev/null | head -1 || echo 'JDTLS available')"
echo "  JDB:      $(jdb -help 2>&1 | head -1 || echo 'JDB debugger available')"

# Pre-loaded linting configs (best-practices-ready)
echo ""
echo "[java] Pre-loaded linting configs:"
echo "  checkstyle.xml:  $(test -f /home/claudeuser/checkstyle.xml && echo 'OK — best-practices rules loaded' || echo 'MISSING')"
echo "  SKILL.md:        $(test -f /home/claudeuser/.superpowers/skills/java/SKILL.md && echo 'OK — rules guide for Claude' || echo 'MISSING')"
echo ""
echo "  NOTE: Linting configs are pre-loaded but NOT auto-run."
echo "  Claude will ask before linting existing or generated code."
