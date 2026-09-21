#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLATFORM="${1:-all}"
SCANNER_DIR="$ROOT_DIR/scanner"
WORK_DIR="$SCANNER_DIR/build"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cp "$ROOT_DIR/package.json" "$WORK_DIR/package.json"
if [[ -f "$ROOT_DIR/package-lock.json" ]]; then
  cp "$ROOT_DIR/package-lock.json" "$WORK_DIR/package-lock.json"
fi
cp "$ROOT_DIR/scanner/capacitor.config.ts" "$WORK_DIR/capacitor.config.ts"
cp -R "$ROOT_DIR/mobile-shell" "$WORK_DIR/mobile-shell"
cp -R "$ROOT_DIR/assets" "$WORK_DIR/assets"
cp -R "$ROOT_DIR/scripts" "$WORK_DIR/scripts"
cd "$WORK_DIR"
if [[ -f package-lock.json ]]; then
  npm ci
else
  npm install --no-package-lock
fi
case "$PLATFORM" in
  android)
    npx cap add android
    npx cap sync android
    node scripts/mobile-configure-native.mjs android
    ;;
  ios)
    [[ "$(uname -s)" == "Darwin" ]] || { echo "iOS scanner builds require macOS" >&2; exit 1; }
    npx cap add ios
    python3 - ios/App/Podfile <<'PY'
from pathlib import Path
import re, sys
p=Path(sys.argv[1]); t=p.read_text(); p.write_text(re.sub(r"platform :ios, '[^']+'", "platform :ios, '15.5'", t))
PY
    npx cap sync ios
    node scripts/mobile-configure-native.mjs ios
    ;;
  *) echo "Usage: $0 [android|ios]" >&2; exit 2;;
esac
echo "GeoWeedo Scanner ${PLATFORM} project ready at $WORK_DIR"
