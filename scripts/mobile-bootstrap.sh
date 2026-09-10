#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PLATFORM="${1:-all}"

echo "GeoWeedo Mobile bootstrap"
echo "Repository: GoeWeedo-Mobile"
echo "Platform: ${PLATFORM}"

npm install

configure_native() {
  node scripts/mobile-configure-native.mjs "$1"
}

add_android() {
  if [[ -d android && ! -f android/variables.gradle ]]; then
    echo "Android platform is incomplete (missing android/variables.gradle); regenerating it."
    rm -rf android
  fi

  if [[ ! -d android ]]; then
    npx cap add android
  fi

  [[ -f android/variables.gradle ]] || {
    echo "ERROR: Capacitor Android generation did not create android/variables.gradle" >&2
    exit 1
  }

  npx cap sync android
  configure_native android
  echo "Android project ready: $ROOT_DIR/android"
}

add_ios() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Skipping iOS project generation: Xcode/iOS builds require macOS."
    echo "Run './scripts/mobile-bootstrap.sh ios' on the Mac used for App Store builds."
    return 0
  fi

  if [[ ! -d ios ]]; then
    npx cap add ios
  fi

  npx cap sync ios
  configure_native ios
  echo "iOS project ready: $ROOT_DIR/ios"
}

case "$PLATFORM" in
  android) add_android ;;
  ios) add_ios ;;
  all)
    add_android
    add_ios
    ;;
  *)
    echo "Usage: $0 [android|ios|all]" >&2
    exit 2
    ;;
esac

echo
cat <<'EOF'
Native plugins enabled:
  App/back handling
  Geolocation
  Haptics
  Network state
  Share sheet
  Barcode/QR scanner

Next steps:
  Android: npx cap open android
  iOS:     npx cap open ios
EOF
