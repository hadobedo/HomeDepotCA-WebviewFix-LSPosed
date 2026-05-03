#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$ROOT_DIR/hd-webview-spoof"
BUILD_DIR="$MODULE_DIR/build"
CLASSES_DIR="$BUILD_DIR/classes"
DEX_DIR="$BUILD_DIR/dex"
OUT_APK="$MODULE_DIR/HDWebViewSpoof.apk"

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "${ANDROID_SDK_ROOT}" ]]; then
  echo "ANDROID_SDK_ROOT or ANDROID_HOME must be set" >&2
  exit 1
fi

PLATFORM_DIR="$ANDROID_SDK_ROOT/platforms/android-36"
if [[ ! -d "$PLATFORM_DIR" && -d "$ANDROID_SDK_ROOT/platforms/android-36.1" ]]; then
  PLATFORM_DIR="$ANDROID_SDK_ROOT/platforms/android-36.1"
fi

ANDROID_JAR="$PLATFORM_DIR/android.jar"
BUILD_TOOLS_DIR="$ANDROID_SDK_ROOT/build-tools/36.1.0"
if [[ ! -d "$BUILD_TOOLS_DIR" ]]; then
  BUILD_TOOLS_DIR="$(find "$ANDROID_SDK_ROOT/build-tools" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n 1)"
fi

JAVAC_BIN="${JAVAC_BIN:-javac}"
if command -v javac >/dev/null 2>&1; then
  JAVAC_BIN="$(command -v javac)"
fi

rm -rf "$CLASSES_DIR" "$DEX_DIR" "$BUILD_DIR/unsigned.apk" "$BUILD_DIR/aligned.apk" "$OUT_APK" "$OUT_APK.idsig"
mkdir -p "$CLASSES_DIR" "$DEX_DIR"

"$JAVAC_BIN" -source 8 -target 8 -bootclasspath "$ANDROID_JAR" -d "$CLASSES_DIR" \
  $(find "$MODULE_DIR/src" -name '*.java' | sort)

"$BUILD_TOOLS_DIR/d8" --min-api 29 --classpath "$ANDROID_JAR" --classpath "$CLASSES_DIR" \
  --output "$DEX_DIR" $(find "$CLASSES_DIR/com/nick" -name '*.class' | sort)

"$BUILD_TOOLS_DIR/aapt" package -f \
  -M "$MODULE_DIR/AndroidManifest.xml" \
  -S "$MODULE_DIR/res" \
  -A "$MODULE_DIR/assets" \
  -I "$ANDROID_JAR" \
  -F "$BUILD_DIR/unsigned.apk"

zip -q -j "$BUILD_DIR/unsigned.apk" "$DEX_DIR/classes.dex"

"$BUILD_TOOLS_DIR/zipalign" -f 4 "$BUILD_DIR/unsigned.apk" "$BUILD_DIR/aligned.apk"

if [[ -n "${KEYSTORE_PATH:-}" ]]; then
  "$BUILD_TOOLS_DIR/apksigner" sign \
    --ks "$KEYSTORE_PATH" \
    --ks-key-alias "${KEY_ALIAS:?KEY_ALIAS must be set}" \
    --ks-pass "pass:${KEYSTORE_PASSWORD:?KEYSTORE_PASSWORD must be set}" \
    --key-pass "pass:${KEY_PASSWORD:-$KEYSTORE_PASSWORD}" \
    --out "$OUT_APK" \
    "$BUILD_DIR/aligned.apk"
else
  cp "$BUILD_DIR/aligned.apk" "$OUT_APK"
fi

echo "Built $OUT_APK"
