#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

# The upstream build emits a complete local maven repo:
# prebuilt/bundle-android-aar-<api>-maven/com/arthenica/ffmpeg-kit-next/<version>/
MAVEN_DIR=$(find prebuilt -maxdepth 1 -type d -name 'bundle-android-aar-*-maven' | head -1)
AAR=$(find "$MAVEN_DIR" -name '*.aar' | head -1)

if [[ -z "${AAR}" ]]; then
  echo "ERROR: AAR not found under prebuilt" >&2
  exit 1
fi

VERSION=${1:-$(basename "$(dirname "$AAR")")}
ARTIFACT=Chimahon-ffmpeg
GROUP_PATH=com/github/sohilsayed

OUT="maven-repo/${GROUP_PATH}/${ARTIFACT}/${VERSION}"
rm -rf maven-repo
mkdir -p "${OUT}"

cp "$AAR" "${OUT}/${ARTIFACT}-${VERSION}.aar"

cat > "${OUT}/${ARTIFACT}-${VERSION}.pom" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.github.sohilsayed</groupId>
  <artifactId>${ARTIFACT}</artifactId>
  <version>${VERSION}</version>
  <packaging>aar</packaging>
  <dependencies>
    <dependency>
      <groupId>com.arthenica</groupId>
      <artifactId>smart-exception-java</artifactId>
      <version>0.2.1</version>
      <scope>runtime</scope>
    </dependency>
  </dependencies>
</project>
EOF

echo "JitPack maven repo written to ${OUT}"
ls -la "${OUT}"
unzip -l "$AAR" | grep -E '\.so$|\.aar$' | grep -c '\.so$' || true