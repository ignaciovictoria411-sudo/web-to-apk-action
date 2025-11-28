FROM ubuntu:22.04

# 基础 + 安装 OpenJDK 21
RUN apt-get update && apt-get install -y \
    curl wget unzip git openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# 安装 Node 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# 安装 Capacitor CLI
RUN npm install -g @capacitor/cli

# Android SDK 设置
ENV ANDROID_HOME=/usr/local/android-sdk

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
com.cemcoe.app
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/36.0.0/

RUN mkdir -p $ANDROID_HOME && cd $ANDROID_HOME && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O tools.zip && \
    unzip tools.zip && rm tools.zip && \
    mkdir -p cmdline-tools/latest && \
    mv cmdline-tools/* cmdline-tools/latest/ || true

RUN yes | sdkmanager --licenses

# 安装平台和 build-tools: android-36
RUN sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
