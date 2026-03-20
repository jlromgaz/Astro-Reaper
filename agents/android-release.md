# 📱 Android Release Agent

## Role
Responsible for touch input, Android performance, build profiles, signing, export, and pre-release checklist.

## Responsibilities
- Configure and optimize touch input (virtual joystick)
- Ensure stable performance on Android devices
- Configure Android export presets
- Manage APK/AAB signing
- Maintain pre-release checklist

## Android Export Configuration

### Prerequisites
```
- JDK 17+
- Android SDK (API level 33+)
- Android NDK
- Godot 4.6 export templates (Android)
- Debug keystore / release keystore
```

### Export Preset Settings
```
min_sdk: 24 (Android 7.0)
target_sdk: 34 (Android 14)
orientation: landscape
screen/immersive_mode: true
permissions: none required for MVP
graphics/opengl3: true (fallback to opengl2 if needed)
```

### Screen Configuration
```
display/window/size/viewport_width: 480
display/window/size/viewport_height: 270
display/window/stretch/mode: viewport
display/window/stretch/aspect: expand
display/window/handheld/orientation: landscape
```

## Touch Input Configuration

### Virtual Joystick Requirements
- Activation zone: bottom-left corner (25% of screen)
- Joystick radius: ~60px at viewport resolution
- Dead zone: 10% of radius
- Visual feedback: semi-transparent, becomes opaque on touch
- Must not interfere with UI elements

### Touch Zones
```
┌────────────────────────────────────────────┐
│                    HUD                      │
│                                             │
│                                             │
│  [JOYSTICK     ]              [   UI/INFO ] │
│  [   ZONE      ]              [   ZONE    ] │
└────────────────────────────────────────────┘
```

## Performance Targets
- **FPS:** 60 stable, minimum 30
- **RAM:** < 200 MB
- **APK size:** < 50 MB
- **Battery:** 30-minute session without excessive heating
- **Load time:** < 3 seconds to gameplay

## Pre-Release Checklist
- [ ] Build compiled without errors
- [ ] APK signed with release keystore
- [ ] Tested on at least 2 Android devices
- [ ] No crashes in 5 consecutive runs
- [ ] Joystick functional and comfortable
- [ ] UI readable on 5"-7" screens
- [ ] Audio functional (SFX + music)
- [ ] Game over / restart functional
- [ ] APK size verified
- [ ] Minimum permissions verified
- [ ] App icon and name configured
