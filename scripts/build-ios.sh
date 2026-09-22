#!/usr/bin/env bash
set -euo pipefail
APP="${1:?geoweedo or scanner}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$ROOT/build/$APP"
rm -rf "$WORK"; mkdir -p "$WORK/www"
cp "$ROOT/package.json" "$WORK/package.json"
cp "$ROOT/apps/$APP/capacitor.config.ts" "$WORK/capacitor.config.ts"
printf '<!doctype html><html><body>GeoWeedo</body></html>\n' > "$WORK/www/index.html"
cd "$WORK"
npm install --no-package-lock
npx cap add ios
npx cap sync ios
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Debug -sdk iphonesimulator -derivedDataPath ios/DerivedData CODE_SIGNING_ALLOWED=NO build
cd ios/DerivedData/Build/Products/Debug-iphonesimulator
zip -qry "$ROOT/${APP}-ios-simulator.zip" App.app
