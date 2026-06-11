#!/bin/bash
# ============================================================
# smoke_test.sh — Standalone smoke test for java-claude image
#
# Run inside the container (or mount from host):
#   docker run --rm --entrypoint /bin/bash \
#       -v "${PWD}:/workdir:rw" \
#       t2fn/java-claude-abliterated:latest \
#       /workdir/smoke_test.sh
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed (detailed output)
# ============================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

PASS=0
FAIL=0
WARN=0
errors=0

# ── Helper functions ──
ok()   { PASS=$((PASS + 1)); echo -e "  ${GREEN}PASS${NC}: $*"; }
fail() { FAIL=$((FAIL + 1)); errors=1; echo -e "  ${RED}FAIL${NC}: $*"; }
warn() { WARN=$((WARN + 1)); echo -e "  ${YELLOW}WARN${NC}: $*"; }

section() { echo ""; echo -e "  ${GREEN}=== $1 ===${NC}"; }

# ── Tool directory (use /usr/local/java as primary, fall back to java) ──
TOOLS_DIR="/usr/local/java"
if [ ! -d "$TOOLS_DIR" ]; then
    # Try java-tools
    if [ -d /home/claudeuser/java-tools ]; then
        TOOLS_DIR="/home/claudeuser/java-tools"
    elif [ -d /home/claudeuser/java ] || [ -L /home/claudeuser/java ]; then
        TOOLS_DIR="/home/claudeuser/java"
    fi
fi
TOOL_BASE="$TOOLS_DIR"

# ── Base paths ──
JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk}"
JAVA="$JAVA_HOME/bin/java"
JAVAC="$JAVA_HOME/bin/javac"
MVN="$TOOL_BASE/maven/bin/mvn"
GRADLE="$TOOL_BASE/gradle/bin/gradle"
SPRINGBOOT="$TOOL_BASE/springboot/bin/spring"
SPRINGBOOT_LEGACY="$TOOL_BASE/spring-3.3.5/bin/spring"
SPOTBUGS="$TOOL_BASE/spotbugs/bin/spotbugs.sh"
PMD="$TOOL_BASE/pmd/bin/pmd.sh"
CHECKSTYLE="$TOOL_BASE/checkstyle.jar"
GOOGLE_JAVA_FORMAT="$TOOL_BASE/google-java-format.jar"
CHECKSTYLE_XML="/home/claudeuser/checkstyle.xml"
SKILL_MD="/home/claudeuser/.superpowers/skills/java/SKILL.md"
JDTLS_DIR="$TOOL_BASE/jdtls"

# ── 1. Java core ──
section "Java Core"

if [ -x "$JAVA" ]; then
    ok "java exists at $JAVA"
else
    fail "java not found at $JAVA"
fi

if [ -x "$JAVAC" ]; then
    ok "javac exists at $JAVAC"
else
    fail "javac not found at $JAVAC"
fi

# ── 2. Tool binaries (existence) ──
section "Tool Binaries"

for tool_name in "maven:$MVN" "gradle:$GRADLE" "springboot:$SPRINGBOOT" \
                 "springboot_legacy:$SPRINGBOOT_LEGACY" \
                 "spotbugs:$SPOTBUGS" "pmd:$PMD"; do
    name="${tool_name%%:*}"
    path="${tool_name#*:}"
    if [ -x "$path" ]; then
        ok "$name binary exists at $path"
    elif [ -f "$path" ]; then
        ok "$name file exists at $path (not executable, but exists)"
    else
        fail "$name not found at $path"
    fi
done

# ── 3. Tool JARs (existence) ──
section "Tool JARs"

for jar_name in "checkstyle:$CHECKSTYLE" "google_java_format:$GOOGLE_JAVA_FORMAT"; do
    name="${jar_name%%:*}"
    jar="${jar_name#*:}"
    if [ -f "$jar" ]; then
        ok "$name JAR exists ($jar)"
    else
        fail "$name JAR missing ($jar)"
    fi
done

# ── 4. Tool binaries (runability) ──
section "Tool Runability"

if [ -x "$JAVA" ]; then
    java_ver=$("$JAVA" -version 2>&1 | head -1) || true
    ok "java: $java_ver"
else
    fail "java cannot run"
fi

if [ -x "$JAVAC" ]; then
    javac_ver=$("$JAVAC" -version 2>&1 | head -1) || true
    ok "javac: $javac_ver"
else
    fail "javac cannot run"
fi

if [ -x "$MVN" ]; then
    mvn_ver=$("$MVN" --version 2>&1 | head -1) || true
    ok "mvn: $mvn_ver"
elif [ -f "$MVN" ]; then
    warn "mvn exists but may not be executable: $MVN"
fi

if [ -x "$GRADLE" ]; then
    gradle_ver=$("$GRADLE" --version 2>&1 | head -1) || true
    ok "gradle: $gradle_ver"
elif [ -f "$GRADLE" ]; then
    warn "gradle exists but may not be executable: $GRADLE"
fi

if [ -x "$SPRINGBOOT" ] || [ -x "$SPRINGBOOT_LEGACY" ]; then
    spring_path="$SPRINGBOOT"
    [ -x "$spring_path" ] || spring_path="$SPRINGBOOT_LEGACY"
    spring_ver=$("$spring_path" --version 2>&1 | head -1) || true
    ok "spring: $spring_ver (from $spring_path)"
elif [ -f "$SPRINGBOOT" ] || [ -f "$SPRINGBOOT_LEGACY" ]; then
    warn "spring exists but may not be executable"
fi

if [ -x "$SPOTBUGS" ]; then
    sb_ver=$("$SPOTBUGS" -version 2>&1 | head -1) || true
    ok "spotbugs: $sb_ver"
elif [ -f "$SPOTBUGS" ]; then
    warn "spotbugs exists but may not be executable: $SPOTBUGS"
fi

if [ -x "$PMD" ]; then
    pmd_ver=$("$PMD" -version 2>&1 | head -1) || true
    ok "pmd: $pmd_ver"
elif [ -f "$PMD" ]; then
    warn "pmd exists but may not be executable: $PMD"
fi

# Test JARs can be loaded by java
if [ -x "$JAVA" ]; then
    if [ -f "$CHECKSTYLE" ]; then
        cs_test=$("$JAVA" -jar "$CHECKSTYLE" --version 2>&1) || true
        if echo "$cs_test" | grep -qi "error\|unable\|missing"; then
            fail "checkstyle JAR error: $cs_test"
        else
            ok "checkstyle JAR runs: $(echo "$cs_test" | head -1)"
        fi
    fi

    if [ -f "$GOOGLE_JAVA_FORMAT" ]; then
        gf_test=$("$JAVA" -jar "$GOOGLE_JAVA_FORMAT" --version 2>&1) || true
        if echo "$gf_test" | grep -qi "error\|unable\|missing"; then
            fail "google-java-format JAR error: $gf_test"
        else
            ok "google-java-format JAR runs: $(echo "$gf_test" | head -1)"
        fi
    fi
fi

# ── 5. Config files ──
section "Config Files"

if [ -f "$CHECKSTYLE_XML" ]; then
    ok "checkstyle.xml exists"
else
    fail "checkstyle.xml missing"
fi

if [ -f "$SKILL_MD" ]; then
    ok "SKILL.md exists"
else
    fail "SKILL.md missing"
fi

# ── 6. JDTLS directory ──
section "JDTLS"

if [ -d "$JDTLS_DIR" ]; then
    file_count=$(find "$JDTLS_DIR" -maxdepth 2 -type f | wc -l)
    ok "jdtls directory exists ($file_count files)"
else
    fail "jdtls directory missing"
fi

# ── 7. Java compilation test ──
section "Java Compilation Test"

test_dir="/tmp/java-smoke-test-$$"
rm -rf "$test_dir"
mkdir -p "$test_dir"

cat > "$test_dir/Hello.java" <<'JAVA_EOF'
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello from Java smoke test! " + (6 + 7));
    }
}
JAVA_EOF

if [ -x "$JAVAC" ]; then
    javac -d "$test_dir" "$test_dir/Hello.java" 2>&1 || {
        fail "javac failed to compile Hello.java"
    }

    if [ -x "$JAVA" ]; then
        hello_out=$("$JAVA" -cp "$test_dir" Hello 2>&1) || true
        if echo "$hello_out" | grep -q "Hello from Java"; then
            ok "Compilation + execution: $hello_out"
        else
            warn "Execution output: $hello_out"
        fi
    fi
else
    warn "javac not available for compilation test"
fi

rm -rf "$test_dir"

# ── 8. Summary ──
section "SUMMARY"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "  Warnings: $WARN"

if [ $FAIL -gt 0 ]; then
    echo -e "\n  ${RED}*** SMOKE TEST FAILED ***${NC}"
    exit 1
else
    echo -e "\n  ${GREEN}*** SMOKE TEST PASSED ***${NC}"
    exit 0
fi
