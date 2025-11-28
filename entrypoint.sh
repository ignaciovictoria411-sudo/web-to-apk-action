#!/bin/bash
set -e

echo "🟦 Web to APK Action (Java 21 + SDK 36) Start"
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

npx cap init "$APP_NAME" "$APP_ID" --web-dir="$WEB_DIR

name: "Web to APK Action"
description: "Build any Web project (HTML/Vue/React/Vite) into an Android APK using Capacitor"
author: "cemcoe"
branding:
  icon: "package"
  color: "blue"

inputs:
  app_name:
    description: "App name"
    required: true
  app_id:
    description: "App package id (e.g. com.cemcoe.app)"
    required: true
  build_command:
    description: "Command to build the web project"
    required: true
  web_dir:
    description: "Web build output directory"
    required: false
    default: "dist"

runs:
  using: "docker"
  image: "Dockerfile"


echo "📱 Adding Android platform..."
npx cap add android

echo "🔗 Syncing Web assets..."
npx cap sync

cd android

echo "🛠️ Updating compileSdkVersion / targetSdkVersion to 36"
# variables.gradle 中如果有 sdk version 定义，可 patch
if grep -q "compileSdkVersion" variables.gradle; then
  sed -i "s/compileSdkVersion = [0-9]\\+/compileSdkVersion = 36/" variables.gradle
fi
if grep -q "targetSdkVersion" variables.gradle; then
  sed -i "s/targetSdkVersion = [0-9]\\+/targetSdkVersion = 36/" variables.gradle
fi

echo "🔨 Building APK with Gradle + Java 21 + SDK 36..."
./gradlew assembleRelease

APK_PATH="app/build/outputs/apk/release/app-release.apk"

echo "🔍 Searching for generated .apk file..."

# 【修改点】删除下面这行 cd，保持在 android 根目录下
# cd ./app/build 

pwd
# 【保持不变】这样路径就是对的： android/app/build/outputs/apk
APK_FILE=$(find app/build/outputs/apk -type f -name "*.apk" | grep -E "(release|debug)" | head -n 1 || true)

if [ -z "$APK_FILE" ]; then
  echo "❗ No APK file found..."
  exit 1
fi

echo "🎉 Found APK: $APK_FILE"
cp "$APK_FILE" /github/workspace/app-release.apk
echo "✅ Done. Output: app-release.apk"

