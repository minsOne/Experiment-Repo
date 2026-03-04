#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

DESTINATIONS=(
  "platform=iOS Simulator,name=iPhone 15"
  "platform=iOS Simulator,name=iPad (10th generation)"
)

mkdir -p .dismiss-probe-matrix

for destination in "${DESTINATIONS[@]}"; do
  echo "[Run] $destination"
  safe_name=$(echo "$destination" | tr ' /()' '__')
  xcodebuild \
    -project DismissProbe.xcodeproj \
    -scheme DismissProbe \
    -destination "$destination" \
    test | tee ".dismiss-probe-matrix/test-${safe_name}.log"
  echo "[Done] $destination"
  echo
  done
