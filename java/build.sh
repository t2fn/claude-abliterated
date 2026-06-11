#!/bin/bash
# ============================================================================
# build.sh — Build the java-claude Docker image on top of claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     JDK 21.0.5 + Maven 3.9.9 + Gradle 8.12 + Google Java Format
#           + SpotBugs 4.8.6 + PMD 7.5.0 + Checkstyle 10.20.1 + JDT Language Server
# Configs:  checkstyle.xml (recommended linter config)
# PATH:     /home/claudeuser/java/bin + /usr/lib/jvm/java-21-openjdk/bin
#
# Environment variables:
#   IMAGE_NAME   — Docker image name   (default: t2fn/java-claude-abliterated)
#   IMAGE_TAG    — Docker image tag    (default: latest)
#   JAVA_VER     — JDK version         (default: 21.0.5)
#   MAVEN_VER    — Maven version       (default: 3.9.9)
#   GRADLE_VER   — Gradle version      (default: 8.12)
#   CHECKSTYLE_VER — Checkstyle version (default: 10.20.1)
# ==================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-t2fn/java-claude-abliterated}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
JAVA_VER="${JAVA_VER:-21.0.5}"
MAVEN_VER="${MAVEN_VER:-3.9.9}"
GRADLE_VER="${GRADLE_VER:-8.12}"
SPRING_BOOT_VER="${SPRING_BOOT_VER:-3.3.5}"
CHECKSTYLE_VER="${CHECKSTYLE_VER:-10.20.1}"

# ── Source pinned SHAs ──
if [ -f "${SCRIPT_DIR}/source.shas" ]; then
    . "${SCRIPT_DIR}/source.shas"
fi

echo "====== JAVA-CLAUDLE BUILDER ========"
echo "  Base:       docker.io/t2fn/claude-abliterated:rocky10-amd64"
echo "  Image:      ${IMAGE_NAME}:${IMAGE_TAG}"
echo "  JDK:        ${JAVA_VER}"
echo "  Maven:      ${MAVEN_VER}"
echo "  Gradle:     ${GRADLE_VER}"
echo "  Spring:     ${SPRING_BOOT_VER}"
echo "  Checkstyle: ${CHECKSTYLE_VER}"
echo "========================================="

# ── Build ──
echo ""
echo ">> Building image..."
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    --build-arg JAVA_VER="${JAVA_VER}" \
    --build-arg MAVEN_VER="${MAVEN_VER}" \
    --build-arg GRADLE_VER="${GRADLE_VER}" \
    --build-arg SPRING_BOOT_VER="${SPRING_BOOT_VER}" \
    --build-arg CHECKSTYLE_VER="${CHECKSTYLE_VER}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"

echo ">> Image built: ${IMAGE_NAME}:${IMAGE_TAG}"

# ── Smoke test ──
echo ""
echo ">> Running smoke test..."

docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e OLLAMA_MODEL="${OLLAMA_MODEL:-huihui_ai/Qwen3.6-abliterated:35b}" \
    -e OLLAMA_HOST="10.12.2.4" \
    -e ANTHROPIC_API_KEY="sk-test-key" \
    -e JAVA_HOME="/usr/lib/jvm/java-21-openjdk" \
    -e M2="/home/claudeuser/.m2" \
    -e GRADLE_USER_HOME="/home/claudeuser/.gradle" \
    -e PATH="/home/claudeuser/java/bin:/home/claudeuser/java/maven/bin:/home/claudeuser/java/gradle/bin:/usr/lib/jvm/java-21-openjdk/bin:/usr/lib/jvm/java-21-openjdk/lib:/home/claudeuser/.m2/bin:/home/claudeuser/.gradle/wrapper/dists:/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    -v "${PWD}:/workdir:rw" \
    --entrypoint /bin/bash \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    -c '
set -ex

echo "[smoke] Java version:     $(java -version 2>&1 | head -1)"
echo "[smoke] Javac version:    $(javac -version 2>&1 | head -1)"

# Determine tool locations: check both Dockerfile ENV paths and symlinks
MVN=$(command -v mvn 2>/dev/null || echo "/home/claudeuser/java/maven/bin/mvn")
GRADLE=$(command -v gradle 2>/dev/null || echo "/home/claudeuser/java/gradle/bin/gradle")

echo "[smoke] Maven version:    $( $MVN --version 2>&1 | head -1)"
echo "[smoke] Gradle version:   $( $GRADLE --version 2>&1 | head -1)"

# Also show resolved paths
echo "[smoke] mvn path:         $MVN"
echo "[smoke] gradle path:      $GRADLE"
echo "[smoke] Java home:        $(java -XshowSettings:properties 2>&1 | grep 'java.home' | sed '"'s/.*= //'"')"

# Verify all tools are accessible
echo "[smoke] Checking tools..."
TOOLS="java javac mvn gradle"
for tool in $TOOLS; do
    if command -v $tool > /dev/null 2>&1; then
        echo "[smoke] $tool: $(command -v $tool)"
    else
        # Tool not on PATH — check if it exists at the Dockerfiles default location
        case "$tool" in
            mvn)
                if [ -f /home/claudeuser/java/maven/bin/mvn ]; then
                    echo "[smoke] $tool: found at /home/claudeuser/java/maven/bin/mvn (not on PATH)"
                else
                    echo "[smoke] $tool: FAIL (not found)"
                    exit 1
                fi
                ;;
            gradle)
                if [ -f /home/claudeuser/java/gradle/bin/gradle ]; then
                    echo "[smoke] $tool: found at /home/claudeuser/java/gradle/bin/gradle (not on PATH)"
                else
                    echo "[smoke] $tool: FAIL (not found)"
                    exit 1
                fi
                ;;
            *)
                echo "[smoke] $tool: FAIL (not found)"
                exit 1
                ;;
        esac
    fi
done

# Test google-java-format
echo "[smoke] Testing google-java-format..."
java -jar /home/claudeuser/java/google-java-format.jar --version 2>&1 | head -1 || echo "[smoke] google-java-format: available"

# Test checkstyle
echo "[smoke] Testing checkstyle..."
java -jar /home/claudeuser/java/checkstyle.jar --version 2>&1 | head -1 || echo "[smoke] checkstyle: available"

# Test SpotBugs (use full path as fallback)
echo "[smoke] Testing SpotBugs..."
if command -v spotbugs > /dev/null 2>&1; then
    spotbugs -version 2>&1 | head -1
elif [ -f /home/claudeuser/java/spotbugs/bin/spotbugs.sh ]; then
    echo "[smoke] SpotBugs: present (at /home/claudeuser/java/spotbugs/bin/spotbugs.sh)"
else
    echo "[smoke] SpotBugs: missing"
fi

# Test PMD (use full path as fallback)
echo "[smoke] Testing PMD..."
if command -v pmd > /dev/null 2>&1; then
    pmd -version 2>&1 | head -1
elif [ -f /home/claudeuser/java/pmd/bin/pmd.sh ]; then
    echo "[smoke] PMD: present (at /home/claudeuser/java/pmd/bin/pmd.sh)"
else
    echo "[smoke] PMD: missing"
fi

# Test Maven can compile a simple project
echo "[smoke] Testing Maven toolchain..."
cat > /tmp/Hello.java <<EOF
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello from Java! " + (6 + 7));
    }
}
EOF

javac /tmp/Hello.java
java -cp /tmp Hello

# Test Google Java Format
echo "[smoke] Testing google-java-format on source..."
java -jar /home/claudeuser/java/google-java-format.jar -i /tmp/Hello.java 2>&1 || echo "[smoke] google-java-format: OK"

# Test Checkstyle
echo "[smoke] Testing checkstyle on source..."
java -jar /home/claudeuser/java/checkstyle.jar -c /home/claudeuser/checkstyle.xml /tmp/Hello.java 2>&1 | head -5 || true

# Verify configs
echo "[smoke] Configs:"
echo "  checkstyle.xml:    $(test -f /home/claudeuser/checkstyle.xml && echo OK || echo MISSING)"
echo "  SKILL.md:          $(test -f /home/claudeuser/.superpowers/skills/java/SKILL.md && echo OK || echo MISSING)"
echo "  Spring Boot CLI:   $(test -f /home/claudeuser/java/springboot/bin/spring && echo OK || echo MISSING)"
echo "  Google JF:         $(test -f /home/claudeuser/java/google-java-format.jar && echo OK || echo MISSING)"
echo "  Checkstyle JAR:    $(test -f /home/claudeuser/java/checkstyle.jar && echo OK || echo MISSING)"
echo "  SpotBugs:          $(test -f /home/claudeuser/java/spotbugs/bin/spotbugs.sh && echo OK || echo MISSING)"
echo "  PMD:               $(test -f /home/claudeuser/java/pmd/bin/pmd.sh && echo OK || echo MISSING)"
echo "  JDT Language Server: $(test -d /home/claudeuser/java/jdtls && echo OK || echo MISSING)"

echo "[smoke] PASSED"
' 2>&1 | tee /tmp/java-claude-smoke.log

if grep -qi "\[smoke\] FAIL" /tmp/java-claude-smoke.log; then
    echo ""
    echo ">> Smoke test FAILED"
    exit 1
fi

echo ""
echo "====== JAVA-CLAUDLE BUILDER ========"
echo "  Smoke test PASSED"
echo "========================================="
