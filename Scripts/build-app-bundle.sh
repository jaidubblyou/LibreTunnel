#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# LibreTunnel — build-app-bundle.sh
#
# Builds a release binary via SwiftPM and assembles it into a real macOS
# .app bundle, then ad-hoc signs it (see Documentation/adr/0004 — no paid
# Apple Developer ID is required or used here).
#
# This script is the SINGLE place that knows how to turn the SwiftPM build
# output into a distributable .app. It exists specifically so we are not
# hand-authoring an .xcodeproj (see Documentation/adr, "dependency strategy":
# SwiftPM only, no Xcode-project lock-in).
#
# Usage:
#   ./Scripts/build-app-bundle.sh
#
# Output:
#   ./dist/LibreTunnel.app
#
# NOTE: this script has been written carefully but has not been executed in
# the environment that produced it (no macOS/Xcode toolchain was available —
# see PROJECT_STATE.md, Session Checkpoint). Please run it on real hardware
# and report any issues; treat it as IMPLEMENTED but NOT YET TESTED until
# confirmed.

set -euo pipefail

APP_NAME="LibreTunnel"
BUNDLE_ID="org.libretunnel.app"
BUILD_DIR=".build/release"
DIST_DIR="dist"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"

echo "==> Building ${APP_NAME} (release)"
swift build -c release

echo "==> Assembling ${APP_BUNDLE}"
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Read the version from git if possible, else fall back to 0.0.0-dev.
VERSION="$(git describe --tags --always 2>/dev/null || echo "0.0.0-dev")"
BUILD_NUMBER="$(git rev-parse --short HEAD 2>/dev/null || echo "0")"

cat > "${APP_BUNDLE}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.developer-tools</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSArchitecturePriority</key>
    <array>
        <string>arm64</string>
    </array>
</dict>
</plist>
PLIST

echo "==> Ad-hoc signing (no Apple Developer ID — see Documentation/adr/0004)"
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "==> Verifying signature"
codesign --verify --verbose=2 "${APP_BUNDLE}"

echo ""
echo "Done: ${APP_BUNDLE}"
echo ""
echo "This build is ad-hoc signed, not notarized. On another Mac, Gatekeeper"
echo "will show an 'unidentified developer' warning on first launch. The"
echo "user needs to right-click the app and choose Open once — no Terminal"
echo "required. See README.md, 'Installing', for the exact wording we show"
echo "end users."
