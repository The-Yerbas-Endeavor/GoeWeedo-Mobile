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
npx cap add android
# Capacitor normally supplies INTERNET itself; assert it before building.
grep -q 'android.permission.INTERNET' android/app/src/main/AndroidManifest.xml
npx cap sync android
cd android
./gradlew --no-daemon assembleDebug
