#!/bin/bash
set -e

echo "🟦 Web to APK Action (Java 21) Start"
echo "Java version:" 
java -version

APP_NAME="${INPUT_APP_NAME}"
APP_ID="${INPUT_APP_ID}"
BUILD_COMMAND="${INPUT_BUILD_COMMAND}"
WEB_DIR="${INPUT_WEB_DIR:-dist}"

echo "⚙️ Running user build command..."
sh -c "$BUILD_COMMAND"

echo "📁 Creating Capacitor wrapper..."
npm init -y
npm install @capacitor/core @capacitor/android

npx cap init "$APP_NAME" "$APP_ID" --web-dir="$WEB_DIR"

echo "📱 Adding Android platform..."
npx cap add android

echo "🔗 Syncing Web assets..."
npx cap sync

cd android

echo "🛠️ Setting compileOptions for Java 21 compatibility..."
# patch build.gradle 的 compileOptions
if grep -q "compileOptions" app/build.gradle; then
  sed -i "/compileOptions {/,/}/ s/sourceCompatibility .*/sourceCompatibility = JavaVersion.VERSION_21/" app/build.gradle
  sed -i "/compileOptions {/,/}/ s/targetCompatibility .*/targetCompatibility = JavaVersion.VERSION_21/" app/build.gradle
else
  cat << 'EOF' >> app/build.gradle

android {
  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
  }
}
EOF
fi

echo "🔨 Building APK with Gradle + Java 21..."
./gradlew assembleRelease

APK_PATH="app/build/outputs/apk/release/app-release.apk"

echo "🎉 APK built: $APK_PATH"
cp $APK_PATH /github/workspace/app-release.apk

echo "✅ Done. Output: app-release.apk"
