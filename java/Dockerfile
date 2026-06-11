# Dockerfile.java — Java dev stack on claude-abliterated:rocky10
#
# Base:     docker.io/t2fn/claude-abliterated:rocky10
# Adds:     JDK 21.0.5 + Maven 3.9.9 + Gradle 8.12 + Spring Boot CLI
#           + Google Java Format + SpotBugs + PMD + Checkstyle + JDT Language Server
# Configs:  checkstyle.xml (recommended linter config)
# PATH:     /usr/local/java/bin + /usr/lib/jvm/java-21-openjdk/bin
#
# Build args:
#   JAVA_VER       — JDK major version      (default: 21.0.5)
#   MAVEN_VER      — Maven version          (default: 3.9.9)
#   GRADLE_VER     — Gradle version         (default: 8.12)
#   SPRING_BOOT_VER — Spring Boot CLI version (default: 3.3.5)
#   GOOGLE_JAVA_FMT_VER — Google Java Format version (default: 1.22.0)
#   SPOTBUGS_VER   — SpotBugs version       (default: 4.8.6)
#   PMD_VER        — PMD version            (default: 7.5.0)
#   CHECKSTYLE_VER — Checkstyle version     (default: 10.20.1)
#   JDTLS_VER      — JDT Language Server version (default: 1.41.0)
#
# Tools installed (core):
#   java, javac, mvn, gradle (JDK 21, Maven, Gradle)
#
# Tools installed (Spring Boot):
#   spring-boot (Spring Boot CLI — run, init, run tests)
#   springboot-starter-web  (Web/REST applications)
#   springboot-starter-data-jpa  (Database persistence)
#   springboot-starter-security  (Authentication & authorization)
#   springboot-starter-test  (JUnit, Mockito, Testcontainers)
#   springboot-starter-validation  (Bean validation)
#   springboot-starter-actuator  (Production monitoring)
#
# Tools installed (linters):
#   google-java-format, spotbugs, pmd, checkstyle
#
# Tools installed (IDE):
#   jdtls (Eclipse JDT Language Server — intellisense, diagnostics)
#
# Linting philosophy (SKILL.md):
#   NEW files Claude writes  → auto-lint before presenting
#   EXISTING code            → do NOT touch; ask before linting
#   Startup hooks            → report versions only, no file modifications
#

FROM docker.io/t2fn/claude-abliterated:rocky10-amd64

# == Build args ==
ARG JAVA_VER=21.0.5 \
    MAVEN_VER=3.9.9 \
    GRADLE_VER=8.12 \
    SPRING_BOOT_VER=3.3.5 \
    GOOGLE_JAVA_FMT_VER=1.22.0 \
    SPOTBUGS_VER=4.8.6 \
    PMD_VER=7.5.0 \
    CHECKSTYLE_VER=10.20.1 \
    JDTLS_VER=1.41.0 \
    JAVA_DIR=/usr/local/java

# == Environment ==
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk \
    M2=/home/claudeuser/.m2 \
    GRADLE_USER_HOME=/home/claudeuser/.gradle \
    JAVA_DIR=/usr/local/java \
    PATH="/usr/local/java/bin:/usr/lib/jvm/java-21-openjdk/bin:/usr/lib/jvm/java-21-openjdk/lib:/home/claudeuser/.m2/bin:/home/claudeuser/.gradle/wrapper/dists:/home/claudeuser/.local/bin:/home/claudeuser/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    HOME=/home/claudeuser

# == Layer 1: root. Install tools (via script) ==
USER root

COPY install_tools.sh /tmp/install_tools.sh
RUN chmod +x /tmp/install_tools.sh && \
    MAVEN_VER=${MAVEN_VER} \
    GRADLE_VER=${GRADLE_VER} \
    SPRING_BOOT_VER=${SPRING_BOOT_VER} \
    GOOGLE_JAVA_FMT_VER=${GOOGLE_JAVA_FMT_VER} \
    SPOTBUGS_VER=${SPOTBUGS_VER} \
    PMD_VER=${PMD_VER} \
    CHECKSTYLE_VER=${CHECKSTYLE_VER} \
    JDTLS_VER=${JDTLS_VER} \
    bash /tmp/install_tools.sh && \
    echo "= Verify tool directory =" && \
    ls /usr/local/java/ | head -5

# == Ensure /usr/local/java is a real directory (not hidden by overlay) ==
RUN rm -rf /home/claudeuser/java /home/claudeuser/java-tools && \
    mkdir -p /usr/local/java && \
    ls -la /usr/local/java/

# == Layer 2: claudeuser. Hooks + config ==
USER claudeuser

# == Copy pre-start and post-stop hooks ==
COPY hooks/pre-start.d/ /home/claudeuser/pre-start.d/
COPY hooks/post-stop.d/ /home/claudeuser/post-stop.d/

# == Copy recommended configs ==
COPY checkstyle.xml       /home/claudeuser/checkstyle.xml
COPY SKILL.md             /home/claudeuser/.superpowers/skills/java/SKILL.md

# == Working directory ==
WORKDIR /workdir

# == Entry point ==
ENTRYPOINT ["start_claude.sh"]
