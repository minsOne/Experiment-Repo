#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

SCHEME="DismissProbe"
DESTINATION="${1:-platform=iOS Simulator,name=iPhone 15}"

xcodegen generate
xcodebuild \
  -project DismissProbe.xcodeproj \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  test
