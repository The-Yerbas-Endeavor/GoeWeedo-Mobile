#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PLATFORM="${1:-all}"
MASCOT_PATH="$ROOT_DIR/assets/geoweedo-icon-master.png"
MASCOT_URL="https://raw.githubusercontent.com/The-Yerbas-Endeavor/GeoWeedo/main/public/assets/geoweedo/geoweedo-icon-master.png"
SHELL_MASCOT_PATH="$ROOT_DIR/mobile-shell/geoweedo-mascot.png"

echo "GeoWeedo Mobile bootstrap"
echo "Repository: GoeWeedo-Mobile"
echo "Platform: ${PLATFORM}"

npm install

ensure_mascot_asset() {
  if [[ ! -s "$MASCOT_PATH" ]]; then
    mkdir -p "$(dirname "$MASCOT_PATH")"
    echo "GeoWeedo mascot asset missing; fetching canonical asset from GeoWeedo main..."

    if command -v curl >/dev/null 2>&1; then
      curl -fL --retry 3 --retry-delay 2 "$MASCOT_URL" -o "$MASCOT_PATH"
    elif command -v wget >/dev/null 2>&1; then
      wget -O "$MASCOT_PATH" "$MASCOT_URL"
    else
      echo "ERROR: curl or wget is required to fetch the GeoWeedo mascot asset." >&2
      exit 1
    fi
  fi

  if [[ ! -s "$MASCOT_PATH" ]]; then
    echo "ERROR: GeoWeedo mascot asset is missing or empty." >&2
    exit 1
  fi

  mkdir -p "$(dirname "$SHELL_MASCOT_PATH")"
  cp "$MASCOT_PATH" "$SHELL_MASCOT_PATH"

  echo "GeoWeedo mascot asset ready: $MASCOT_PATH"
  echo "Packaged offline shell mascot: $SHELL_MASCOT_PATH"
}

configure_native() {
  node scripts/mobile-configure-native.mjs "$1"
}

add_android() {
  ensure_mascot_asset

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
  ensure_mascot_asset

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
