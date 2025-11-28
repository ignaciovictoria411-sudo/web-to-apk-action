# Web to APK GitHub Action

将任意 Web 项目（HTML / Vue / React / Vite / Next / Nuxt）  
一键打包成 **Android APK**。

无需 Android Studio  
无需 Java  
无需原生开发经验

只需 GitHub Actions。

---

## 🚀 使用方法

在你的项目中创建：

`.github/workflows/build-apk.yml`

```yaml
name: Build APK

on:
  workflow_dispatch:

jobs:
  apk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: cemcoe/web-to-apk-action@v1
        with:
          app_name: "MyApp"
          app_id: "com.cemcoe.app"
          build_command: "npm install && npm run build"
          web_dir: "dist"
