#!/bin/bash
set -euo pipefail

# Download and unpack all prebuilt frameworks required by Code.xcodeproj.
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESOURCES_DIR="$ROOT_DIR/Resources"
rm -rf "$RESOURCES_DIR"
mkdir -p "$RESOURCES_DIR"
cd "$RESOURCES_DIR"

fetch_zip() {
  local url="$1"
  local destination="$2"
  local archive
  archive="$(mktemp "${TMPDIR:-/tmp}/codeapp-framework.XXXXXX.zip")"
  echo "Downloading $url"
  curl --fail --location --retry 3 --retry-all-errors --silent --show-error "$url" --output "$archive"
  mkdir -p "$destination"
  unzip -q "$archive" -d "$destination"
  rm -f "$archive"
}

# Python
fetch_zip "https://github.com/bummoblizard/cpython/releases/download/1.0.1/cpython.zip" "."

# LLVM. Each archive contains one XCFramework. Unpack into Resources/llvm.
mkdir -p llvm
for lib in ar link libLLVM lld clang nm dis llc lli opt; do
  fetch_zip "https://github.com/thebaselab/llvm-project/releases/download/iOS-14/${lib}.xcframework.zip" llvm
  test -d "llvm/${lib}.xcframework" || { echo "Missing llvm/${lib}.xcframework after extraction" >&2; exit 1; }
done

# ios_system
mkdir -p Term
for lib in files curl_ios awk text shell tar ios_system; do
  fetch_zip "https://github.com/holzschu/ios_system/releases/download/v3.0.0/${lib}.xcframework.zip" Term
done
fetch_zip "https://github.com/holzschu/network_ios/releases/download/v0.2/network_ios.xcframework.zip" Term
fetch_zip "https://github.com/holzschu/ios_system/releases/download/v2.7.0/ssh_cmd.xcframework.zip" Term
fetch_zip "https://github.com/holzschu/libssh2-for-iOS/releases/download/v1.2/openssl.xcframework.zip" Term
fetch_zip "https://github.com/holzschu/libssh2-for-iOS/releases/download/v1.2/libssh2.xcframework.zip" Term
fetch_zip "https://github.com/holzschu/libgit2/releases/download/ios_1.0/lg2.xcframework.zip" Term

# Python auxiliary frameworks
mkdir -p PythonAux
for lib in harfbuzz freetype libpng; do
  fetch_zip "https://github.com/holzschu/Python-aux/releases/download/1.0/${lib}.xcframework.zip" PythonAux
done

# Node.js
mkdir -p NodeJS
fetch_zip "https://github.com/1Conan/nodejs-mobile/releases/download/v18.19.0-ios/NodeMobile.xcframework.zip" NodeJS

# PHP
mkdir -p PHP
fetch_zip "https://github.com/bummoblizard/php-src/releases/download/v0.3/php.xcframework.zip" PHP

# NMSSH
fetch_zip "https://github.com/thebaselab/NMSSH/releases/download/2.3.1-p5/NMSSH.xcframework.zip" .

# Java runtime/toolchain bundle
mkdir -p Java
fetch_zip "https://github.com/thebaselab/android-openjdk-build-multiarch/releases/download/v0.2/java-8-zero-frameworks-tools-with-src.zip" Java

# Language servers and Monaco resources
fetch_zip "https://github.com/thebaselab/codeapp-python/releases/download/2024.8.15/python-lsp.zip" .
fetch_zip "https://github.com/thebaselab/codeapp-monaco/releases/download/2025.9.20/monaco-textmate.bundle.zip" .
fetch_zip "https://github.com/thebaselab/codeapp-java/releases/download/2024.8.16/java-lsp.zip" .

echo "Framework downloads and extraction complete."
