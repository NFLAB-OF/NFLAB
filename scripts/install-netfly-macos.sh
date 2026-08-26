#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# NETFLY v3.0.3 + BLUESTACKS AIR
# macOS Apple Silicon Installation Helper
# ============================================================

NETFLY_VERSION="3.0.3"
NETFLY_URL="https://github.com/NFLAB-OF/NFLAB/releases/download/v3.0.3/netfly_tablet.v3.0.3.apk"
NETFLY_SHA256="759b865c46ebe9e4c93461f7702c553c3fc4e3a91aaa2bb5247a20042bb16106"

ROOT="$HOME/Library/Application Support/NETFLY BlueStacks"
APK_DIR="$ROOT/apk"
APK="$APK_DIR/netfly_tablet.v3.0.3.apk"

echo "============================================================"
echo " NETFLY v${NETFLY_VERSION} + BLUESTACKS AIR"
echo " macOS Apple Silicon Installation Helper"
echo "============================================================"

echo
echo "===== 1. SYSTEM CHECK ====="

ARCH="$(uname -m)"
echo "Architecture: $ARCH"

if [ "$ARCH" != "arm64" ]; then
    echo
    echo "ERROR:"
    echo "This installer requires an Apple Silicon Mac."
    echo "Detected architecture: $ARCH"
    exit 1
fi

MAC_VERSION="$(sw_vers -productVersion)"
echo "macOS version: $MAC_VERSION"

echo
echo "===== 2. AVAILABLE STORAGE ====="

df -h "$HOME" | tail -1

echo
echo "===== 3. HOMEBREW ====="

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew was not found."
    echo "Installing Homebrew..."

    /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "PASS: Homebrew is already installed."
fi

if ! command -v brew >/dev/null 2>&1; then
    echo
    echo "ERROR: Homebrew could not be installed."
    exit 1
fi

echo
echo "Homebrew:"
brew --version | head -1

echo
echo "===== 4. BLUESTACKS AIR ====="

if [ -d "/Applications/BlueStacks.app" ]; then
    echo "PASS: BlueStacks is already installed."
else
    echo "Installing BlueStacks Air..."
    brew install --cask bluestacks
fi

if [ ! -d "/Applications/BlueStacks.app" ]; then
    echo
    echo "ERROR: BlueStacks.app was not found in /Applications."
    exit 1
fi

echo "PASS: BlueStacks is ready."

echo
echo "===== 5. NETFLY APK ====="

mkdir -p "$APK_DIR"

if [ -f "$APK" ]; then
    CURRENT_SHA256="$(shasum -a 256 "$APK" | awk '{print $1}')"

    if [ "$CURRENT_SHA256" = "$NETFLY_SHA256" ]; then
        echo "PASS: The correct Netfly APK is already available."
    else
        echo "Existing APK checksum does not match."
        echo "The APK will be downloaded again."
        rm -f "$APK"
    fi
fi

if [ ! -f "$APK" ]; then
    echo "Downloading Netfly Tablet v${NETFLY_VERSION}..."

    curl \
        --fail \
        --location \
        --progress-bar \
        "$NETFLY_URL" \
        --output "$APK"
fi

echo
echo "===== 6. APK VERIFICATION ====="

ACTUAL_SHA256="$(shasum -a 256 "$APK" | awk '{print $1}')"

echo
echo "Expected SHA-256:"
echo "$NETFLY_SHA256"

echo
echo "Actual SHA-256:"
echo "$ACTUAL_SHA256"

if [ "$ACTUAL_SHA256" != "$NETFLY_SHA256" ]; then
    echo
    echo "ERROR: SHA-256 verification failed."
    echo "The downloaded APK does not match the expected checksum."
    rm -f "$APK"
    exit 1
fi

echo
echo "PASS: Netfly APK successfully verified."

echo
echo "===== 7. STARTING BLUESTACKS ====="

open -a BlueStacks

echo
echo "===== 8. APK READY ====="

open -R "$APK"

echo
echo "============================================================"
echo " INSTALLATION PREPARATION COMPLETE"
echo "============================================================"
echo
echo "BlueStacks:"
echo "/Applications/BlueStacks.app"
echo
echo "Netfly APK:"
echo "$APK"
echo
echo "SHA-256:"
echo "$ACTUAL_SHA256"
echo
echo "Complete the initial BlueStacks setup if prompted."
echo
echo "Then drag and drop the selected Netfly APK from Finder"
echo "onto the BlueStacks window to install it."
echo
echo "The APK is downloaded directly from the official"
echo "NFLAB GitHub release and is verified using SHA-256."
echo "============================================================"
