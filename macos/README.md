# Pomodo macOS App

A beautiful Pomodoro timer app for macOS with menu bar integration.

## Features

- Native macOS app with SwiftUI
- **Menu Bar Widget** - Control timer from the menu bar
- 6 beautiful themes (Cozy, Night City, Winter, Spring, Summer, Fall)
- Ambient animations (rain, snow, cherry blossoms, etc.)
- Illustrated study room with animated elements
- Desktop notifications for timer completion
- Daily statistics tracking
- Keyboard shortcuts for quick control

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+

## Project Setup

### 1. Create Xcode Project

1. Open Xcode
2. Create a new project: **File → New → Project**
3. Select **macOS → App**
4. Configure:
   - Product Name: `Pomodo`
   - Team: Your development team
   - Organization Identifier: `com.yourname`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - ✅ Include Tests (optional)

### 2. Add Source Files

Copy the source files from this directory into your Xcode project:

```
Pomodo/
├── Sources/
│   ├── App/
│   │   └── PomodoApp.swift
│   ├── Models/
│   │   ├── SessionType.swift
│   │   ├── TimerState.swift
│   │   ├── AppSettings.swift
│   │   └── DailyStats.swift
│   ├── ViewModels/
│   │   └── PomodoroViewModel.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── HeaderView.swift
│   │   ├── TimerView.swift
│   │   ├── ControlsView.swift
│   │   ├── SettingsView.swift
│   │   ├── SettingsWindowView.swift
│   │   ├── ThemePickerView.swift
│   │   ├── MenuBarView.swift
│   │   ├── StudyRoomView.swift
│   │   └── AmbientView.swift
│   ├── Managers/
│   │   ├── NotificationManager.swift
│   │   └── SoundManager.swift
│   ├── Theme/
│   │   ├── AppTheme.swift
│   │   └── ThemeManager.swift
│   └── Extensions/
│       └── Color+Hex.swift
└── Resources/
    └── Info.plist
```

### 3. Add App Icons

1. Open `Assets.xcassets` in Xcode
2. Select `AppIcon`
3. Generate icons from the SVG in `Assets.xcassets/AppIcon.appiconset/icon-source.svg`
4. Required sizes for macOS:
   - 16x16 @1x and @2x
   - 32x32 @1x and @2x
   - 128x128 @1x and @2x
   - 256x256 @1x and @2x
   - 512x512 @1x and @2x

### 4. Configure Signing

1. Select the project in the navigator
2. Go to **Signing & Capabilities**
3. Select your Team
4. Ensure "Automatically manage signing" is checked

### 5. Build & Run

1. Select **My Mac** as the run destination
2. Press **⌘R** to build and run

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Space` | Start/Pause timer |
| `⌘R` | Reset timer |
| `⌘N` | Skip to next session |
| `⌘,` | Open Settings |

## Menu Bar Features

The app includes a menu bar extra that shows:
- Current timer status (icon changes when running)
- Timer countdown
- Quick controls (Start/Pause, Reset, Skip)
- Daily stats
- Quick access to main window and settings

## Project Structure

```
Pomodo/
├── Sources/
│   ├── App/           # App entry point with menu bar
│   ├── Models/        # Data models
│   ├── ViewModels/    # Business logic
│   ├── Views/         # SwiftUI views
│   ├── Managers/      # Services (notifications, sound)
│   ├── Theme/         # Theme system
│   └── Extensions/    # Swift extensions
└── Resources/         # Plist, assets
```

## Differences from iOS Version

| Feature | iOS | macOS |
|---------|-----|-------|
| Live Activities | ✅ | N/A |
| Menu Bar Widget | N/A | ✅ |
| Haptic Feedback | ✅ | N/A |
| Keyboard Shortcuts | N/A | ✅ |
| Window Management | N/A | ✅ |
| Settings Window | Sheet | Native (⌘,) |

## Sharing Code with iOS

The following files can be shared between iOS and macOS:
- `SessionType.swift`
- `TimerState.swift`
- `AppSettings.swift`
- `DailyStats.swift`
- `AppTheme.swift`
- `ThemeManager.swift`
- `Color+Hex.swift`
- Most of `PomodoroViewModel.swift`

To share code, you can:
1. Create a **Multiplatform** project in Xcode
2. Use **conditional compilation** with `#if os(macOS)` / `#if os(iOS)`
3. Create a **shared Swift Package**

## App Sandbox

For App Store distribution, enable the App Sandbox:

1. Go to **Signing & Capabilities**
2. Click **+ Capability**
3. Add **App Sandbox**
4. Configure permissions as needed

## Notarization (for distribution outside App Store)

If distributing outside the App Store:

```bash
# Archive the app
xcodebuild archive -scheme Pomodo -archivePath ./build/Pomodo.xcarchive

# Export the app
xcodebuild -exportArchive -archivePath ./build/Pomodo.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist

# Notarize
xcrun notarytool submit ./build/Pomodo.app --apple-id YOUR_APPLE_ID --team-id YOUR_TEAM_ID --password YOUR_APP_SPECIFIC_PASSWORD --wait

# Staple
xcrun stapler staple ./build/Pomodo.app
```

## License

MIT License - See main project repository.

---

Built with SwiftUI for macOS 13.0+
