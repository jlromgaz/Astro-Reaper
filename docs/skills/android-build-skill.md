# Skill: Android Build

## Overview
Export checklist for generating functional Android builds.

## Prerequisites Check
- [ ] JDK 17+ installed and JAVA_HOME set
- [ ] Android SDK installed (API level 33+)
- [ ] Android NDK installed
- [ ] Godot 4.6 Android export templates downloaded
- [ ] Debug keystore generated OR release keystore ready

## Setup (First Time Only)

### 1. Configure Godot Editor Settings
```
Editor → Editor Settings → Export → Android
  - Android SDK Path: [your SDK path]
  - Debug Keystore: [path to debug.keystore]
  - Debug Keystore User: androiddebugkey
  - Debug Keystore Pass: android
```

### 2. Create Export Preset
```
Project → Export → Add preset → Android
  - Unique Name: com.yourdomain.astroreaper
  - Version Name: 0.1.0
  - Version Code: 1
  - Min SDK: 24
  - Target SDK: 34
  - Screen → Orientation: Landscape
  - Screen → Immersive Mode: true
  - Permissions: none (MVP)
```

### 3. Configure Project Settings
```
Project → Project Settings:
  - Display/Window/Size/Viewport Width: 480
  - Display/Window/Size/Viewport Height: 270
  - Display/Window/Stretch/Mode: viewport
  - Display/Window/Stretch/Aspect: expand
  - Display/Window/Handheld/Orientation: landscape
  - Rendering/Renderer/Rendering Method: mobile
```

## Build Steps

### Debug Build
1. Project → Export → Android preset
2. Click "Export Project..."
3. Choose filename: `astro-reaper-debug.apk`
4. Uncheck "Export with Debug"? → Leave checked for debug
5. Click Save

### Release Build
1. Set release keystore in export preset
2. Project → Export → Android preset
3. Click "Export Project..."
4. Uncheck "Export with Debug"
5. Choose filename: `astro-reaper-release.apk`
6. Click Save

## Post-Build Verification
- [ ] APK generated without errors
- [ ] APK size < 50 MB
- [ ] Install on device: `adb install astro-reaper-debug.apk`
- [ ] App launches without crash
- [ ] Orientation locked to landscape
- [ ] Touch input works
- [ ] Audio plays correctly
- [ ] No permission dialogs

## Troubleshooting
- **"No export template found"** → Download Android templates in Godot
- **"Debug keystore not configured"** → Generate with `keytool`
- **"SDK not found"** → Verify Android SDK path in Editor Settings
- **"Build failed"** → Check Output log for specific Java/Gradle errors
