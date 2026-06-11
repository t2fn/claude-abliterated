#!/bin/bash
set -e

# Clean /tmp to avoid stale 0-byte files from previous builds
# Use rm -rf to handle read-only mount points gracefully
rm -rf /tmp/maven.tar.gz /tmp/gradle.zip /tmp/spotbugs.tar.gz /tmp/pmd.tar.gz \
       /tmp/checkstyle.jar /tmp/jdtls.tar.gz /tmp/springboot.tar.gz 2>/dev/null || true

# Install system deps
dnf install -y gcc gcc-c++ make git wget tar unzip openssl-devel
dnf clean all && rm -rf /var/cache/dnf
dnf install -y java-21-openjdk java-21-openjdk-devel

# === Use /usr/local/java/ — guaranteed to be visible in the final image ===
JAVA_DIR="${JAVA_DIR:-/usr/local/java}"
mkdir -p "$JAVA_DIR"

# Download and install Maven
wget "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VER}/binaries/apache-maven-${MAVEN_VER}-bin.tar.gz" \
    -O /tmp/maven.tar.gz 2>/dev/null || true
test -s /tmp/maven.tar.gz
tar -xzf /tmp/maven.tar.gz -C "$JAVA_DIR/"
mv "$JAVA_DIR/apache-maven-"* "$JAVA_DIR/maven"
rm -rf /tmp/maven.tar.gz 2>/dev/null || true

# Download and install Gradle
wget "https://services.gradle.org/distributions/gradle-${GRADLE_VER}-bin.zip" \
    -O /tmp/gradle.zip 2>/dev/null || true
test -s /tmp/gradle.zip
unzip -q /tmp/gradle.zip -d "$JAVA_DIR/"
mv "$JAVA_DIR/gradle-"* "$JAVA_DIR/gradle"
rm -rf /tmp/gradle.zip 2>/dev/null || true

# Download Google Java Format
wget "https://github.com/google/google-java-format/releases/download/v${GOOGLE_JAVA_FMT_VER}/google-java-format-${GOOGLE_JAVA_FMT_VER}-all-deps.jar" \
    -O "$JAVA_DIR/google-java-format.jar" 2>/dev/null || true
test -s "$JAVA_DIR/google-java-format.jar"

# Download and install SpotBugs
wget "https://github.com/spotbugs/spotbugs/releases/download/spotbugs-${SPOTBUGS_VER}/spotbugs-${SPOTBUGS_VER}-bin.tar.gz" \
    -O /tmp/spotbugs.tar.gz 2>/dev/null || true
test -s /tmp/spotbugs.tar.gz
tar -xzf /tmp/spotbugs.tar.gz -C "$JAVA_DIR/"
mv "$JAVA_DIR/spotbugs-"* "$JAVA_DIR/spotbugs"
rm -rf /tmp/spotbugs.tar.gz 2>/dev/null || true

# Download and install PMD
wget "https://github.com/pmd/pmd/releases/download/pmd-releases%2F${PMD_VER}/pmd-bin-${PMD_VER}.tar.gz" \
    -O /tmp/pmd.tar.gz 2>/dev/null || true
test -s /tmp/pmd.tar.gz
tar -xzf /tmp/pmd.tar.gz -C "$JAVA_DIR/"
mv "$JAVA_DIR/pmd-"* "$JAVA_DIR/pmd"
rm -rf /tmp/pmd.tar.gz 2>/dev/null || true

# Download Checkstyle
wget "https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VER}/checkstyle-${CHECKSTYLE_VER}-all.jar" \
    -O "$JAVA_DIR/checkstyle.jar" 2>/dev/null || true
test -s "$JAVA_DIR/checkstyle.jar"

# Download and install JDT Language Server
wget "https://repo1.maven.org/maven2/org/eclipse/compiler/org.eclipse.jdt.core/${JDTLS_VER}/org.eclipse.jdt.core-${JDTLS_VER}-linux-gtk-x86_64.tar.gz" \
    -O /tmp/jdtls.tar.gz 2>/dev/null || \
wget "https://download.eclipse.org/jdtls/releases/${JDTLS_VER}/jdt-language-server-${JDTLS_VER}.tar.gz" \
    -O /tmp/jdtls.tar.gz 2>/dev/null || true
test -s /tmp/jdtls.tar.gz
tar -xzf /tmp/jdtls.tar.gz -C "$JAVA_DIR/"
mv "$JAVA_DIR/languageServer" "$JAVA_DIR/jdtls"
rm -rf /tmp/jdtls.tar.gz 2>/dev/null || true

# Download and install Spring Boot CLI
wget "https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-cli/${SPRING_BOOT_VER}/spring-boot-cli-${SPRING_BOOT_VER}-bin.tar.gz" \
    -O /tmp/springboot.tar.gz 2>/dev/null || true
test -s /tmp/springboot.tar.gz
tar -xzf /tmp/springboot.tar.gz -C "$JAVA_DIR/"
mv "$JAVA_DIR/spring-"* "$JAVA_DIR/springboot"
chmod +x "$JAVA_DIR/springboot/bin/spring"
rm -rf /tmp/springboot.tar.gz 2>/dev/null || true

# Create wrapper scripts
ln -sf "$JAVA_DIR/maven/bin/mvn" /usr/local/bin/mvn
ln -sf "$JAVA_DIR/gradle/bin/gradle" /usr/local/bin/gradle
ln -sf "$JAVA_DIR/springboot/bin/spring" /usr/local/bin/spring

# Create symlink for backward compatibility
ln -sfn "$JAVA_DIR" /home/claudeuser/java-tools

# Chown all tools
chown -R claudeuser:claudeuser "$JAVA_DIR"
chown -R claudeuser:claudeuser /home/claudeuser /usr/lib/jvm/java-21-openjdk /usr/lib/jvm/java-21-openjdk/lib

# Show state
echo "=== $JAVA_DIR/ state ==="
ls -la "$JAVA_DIR/"

# Pre-flight checks
echo "== Pre-flight checks =="
echo "Java:       $(java -version 2>&1 | head -1)"
echo "Javac:      $(javac -version 2>&1 | head -1)"
echo "Maven:      $(mvn --version 2>&1 | head -1)"
echo "Gradle:     $(gradle --version 2>&1 | head -1)"
echo "SpotBugs:   $(spotbugs -help 2>&1 | head -1 || echo 'available')"
echo "PMD:        $(pmd -version 2>&1 | head -1 || echo 'available')"
echo "Checkstyle: $(java -jar "$JAVA_DIR/checkstyle.jar" --version 2>&1 | head -1 || echo 'available')"
echo "Google JF:  $(java -jar "$JAVA_DIR/google-java-format.jar" --help 2>&1 | head -1 || echo 'available')"
echo "JDTLS:      $(ls "$JAVA_DIR/jdtls" 2>/dev/null | head -1 || echo 'available')"
echo "Spring Boot: $(spring --version 2>&1 | head -1 || echo 'available')"
echo ""
echo "Code style tools:"
echo "  google-java-format: $(test -f "$JAVA_DIR/google-java-format.jar" && echo 'OK' || echo 'MISSING')"
echo "  spotbugs:           $(test -f "$JAVA_DIR/spotbugs/bin/spotbugs.sh" && echo 'OK' || echo 'MISSING')"
echo "  pmd:                $(test -f "$JAVA_DIR/pmd/bin/pmd.sh" && echo 'OK' || echo 'MISSING')"
echo "  checkstyle:         $(test -f "$JAVA_DIR/checkstyle.jar" && echo 'OK' || echo 'MISSING')"
echo "  springboot-cli:     $(test -f "$JAVA_DIR/springboot/bin/spring" && echo 'OK' || echo 'MISSING')"
echo ""
echo "Java home:          $(ls /usr/lib/jvm/java-21-openjdk 2>/dev/null | head -1 || echo 'installed')"
echo "Java tools:          $(ls "$JAVA_DIR" 2>/dev/null | head -1 || echo 'installed')"
echo "== Pre-flight complete =="
exit 0
