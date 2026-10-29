#!/bin/bash
set -eu
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
BUILD_TOOLS="$SDK/build-tools/35.0.0"
ANDROID_JAR="$SDK/platforms/android-28/android.jar"
BUILD_DIR="$APP_DIR/../../work/floating-home-build"
JAVA_HOME="$(/usr/libexec/java_home)"
export JAVA_HOME
mkdir -p "$BUILD_DIR/classes" "$BUILD_DIR/dex"
"$BUILD_TOOLS/aapt" package -f -M "$APP_DIR/AndroidManifest.xml" -I "$ANDROID_JAR" -F "$BUILD_DIR/unsigned.apk"
"$JAVA_HOME/bin/javac" -source 8 -target 8 -bootclasspath "$ANDROID_JAR:$BUILD_TOOLS/core-lambda-stubs.jar" -d "$BUILD_DIR/classes" "$APP_DIR"/src/local/frame/floatinghome/*.java
find "$BUILD_DIR/classes" -name '*.class' > "$BUILD_DIR/classes.list"
"$BUILD_TOOLS/d8" --min-api 23 --lib "$ANDROID_JAR" --output "$BUILD_DIR/dex" @"$BUILD_DIR/classes.list"
cp "$BUILD_DIR/dex/classes.dex" "$BUILD_DIR/classes.dex"
(cd "$BUILD_DIR" && "$BUILD_TOOLS/aapt" add unsigned.apk classes.dex)
"$BUILD_TOOLS/zipalign" -f 4 "$BUILD_DIR/unsigned.apk" "$BUILD_DIR/aligned.apk"
if [ ! -f "$BUILD_DIR/local-signing.p12" ]; then
    "$JAVA_HOME/bin/keytool" -genkeypair -keystore "$BUILD_DIR/local-signing.p12" -storepass localbuild -keypass localbuild -alias floatinghome -keyalg RSA -keysize 2048 -validity 10000 -dname 'CN=Local Floating Home' >/dev/null 2>&1
fi
"$BUILD_TOOLS/apksigner" sign --ks "$BUILD_DIR/local-signing.p12" --ks-pass pass:localbuild --key-pass pass:localbuild --out "$APP_DIR/../FloatingHome.apk" "$BUILD_DIR/aligned.apk"
"$BUILD_TOOLS/apksigner" verify --min-sdk-version 23 "$APP_DIR/../FloatingHome.apk"
