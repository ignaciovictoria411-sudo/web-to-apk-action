FROM ubuntu:22.04

# 基础工具
RUN apt-get update && apt-get install -y \
  curl wget unzip git openjdk-17-jdk \
  && rm -rf /var/lib/apt/lists/*

# 设置 Java 17 环境变量（关键步骤）
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Node 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs

# Capacitor CLI
RUN npm install -g @capacitor/cli

# Android SDK
ENV ANDROID_HOME=/usr/local/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0/

RUN mkdir -p $ANDROID_HOME && cd $ANDROID_HOME && \
  wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O tools.zip && \
  unzip tools.zip && rm tools.zip && \
  mkdir -p cmdline-tools/latest && \
  mv cmdline-tools/* cmdline-tools/latest/ || true

RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
