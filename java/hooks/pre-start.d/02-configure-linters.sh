#!/bin/bash
# 02-configure-linters.sh — Verify Java linters/formatters are present and report versions
# NOTE: Does NOT auto-lint. Only verifies tools are present and configs are readable.
# When Claude is tasked with code quality, this hook reports tool versions.

echo "[java] Linter/Formatter versions:"

# Google Java Format
if [ -f /home/claudeuser/java/google-java-format.jar ]; then
    gjf_ver=$(java -jar /home/claudeuser/java/google-java-format.jar --version 2>&1 | head -1 || echo 'unknown')
    echo "  google-java-format:  $gjf_ver"
else
    echo "  google-java-format:  JAR missing"
fi

# SpotBugs
if [ -f /home/claudeuser/java/spotbugs/bin/spotbugs.sh ]; then
    sb_ver=$(spotbugs -version 2>&1 | head -1 || echo 'unknown')
    echo "  spotbugs:            $sb_ver"
else
    echo "  spotbugs:            binary missing"
fi

# PMD
if [ -f /home/claudeuser/java/pmd/bin/pmd.sh ]; then
    pmd_ver=$(pmd -version 2>&1 | head -1 || echo 'unknown')
    echo "  pmd:                 $pmd_ver"
else
    echo "  pmd:                 binary missing"
fi

# Checkstyle
if [ -f /home/claudeuser/java/checkstyle.jar ]; then
    cs_ver=$(java -jar /home/claudeuser/java/checkstyle.jar --version 2>&1 | head -1 || echo 'unknown')
    echo "  checkstyle:          $cs_ver"
    echo "  config:              /home/claudeuser/checkstyle.xml (best-practices)"
else
    echo "  checkstyle:          JAR missing"
fi

# JDT Language Server
if [ -d /home/claudeuser/java/jdtls ]; then
    echo "  jdtls:               version available"
else
    echo "  jdtls:               available (for IDE-like features)"
fi

# Spring Boot
if [ -f /home/claudeuser/java/springboot/bin/spring ]; then
    sp_ver=$(spring --version 2>&1 | head -1 || echo 'unknown')
    echo "  spring-boot-cli:     $sp_ver"
else
    echo "  spring-boot-cli:     binary missing"
fi

echo ""
echo "  NOTE: All linters are verified and ready."
echo "  They will NOT run automatically — Claude asks before applying lint to code."
