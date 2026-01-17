# Pomodo iOS App

A beautiful Pomodoro timer app with Live Activities support for Dynamic Island and Lock Screen.

## Features

- Pomodoro timer with work/break sessions
- **Live Activities** - See your timer on Dynamic Island and Lock Screen
- 6 beautiful themes (Cozy, Night City, Winter, Spring, Summer, Fall)
- Ambient animations (rain, snow, cherry blossoms, etc.)
- Illustrated study room with animated elements
- Local notifications for timer completion
- Haptic feedback
- Daily statistics tracking

## Requirements

- macOS with Xcode 15+
- iOS 16.1+ (for Live Activities)
- iPhone 14 Pro+ for Dynamic Island (Lock Screen works on all iOS 16.1+ devices)
- Apple Developer Account (for device testing and App Store)

## Project Setup

### 1. Create Xcode Project

1. Open Xcode
2. Create a new project: **File → New → Project**
3. Select **iOS → App**
4. Configure:
   - Product Name: `Pomodo`
   - Team: Your development team
   - Organization Identifier: `com.yourname`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: None
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
│   │   ├── ThemePickerView.swift
│   │   ├── StudyRoomView.swift
│   │   └── AmbientView.swift
│   ├── Managers/
│   │   ├── NotificationManager.swift
│   │   ├── LiveActivityManager.swift
│   │   ├── HapticManager.swift
│   │   └── SoundManager.swift
│   └── Theme/
│       ├── AppTheme.swift
│       └── ThemeManager.swift
└── Resources/
    └── Info.plist
```

### 3. Add Widget Extension (for Live Activities)

1. In Xcode: **File → New → Target**
2. Select **iOS → Widget Extension**
3. Configure:
   - Product Name: `PomodoWidget`
   - ✅ Include Live Activity
   - ❌ Include Configuration App Intent (not needed)

4. Copy widget files from `PomodoWidget/` directory:
   - `PomodoActivityAttributes.swift`
   - `PomodoLiveActivity.swift`
   - `PomodoWidgetBundle.swift`

5. **Important:** Add `PomodoActivityAttributes.swift` to **both targets** (main app and widget extension) so they share the same data model.

### 4. Configure Info.plist

Ensure your main app's Info.plist includes:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

### 5. Add App Icons

1. Open `Assets.xcassets` in Xcode
2. Select `AppIcon`
3. Generate icons from the SVG in `Assets.xcassets/AppIcon.appiconset/icon-source.svg`
4. Or use [appicon.co](https://appicon.co) to generate from a 1024x1024 PNG

### 6. Build & Run

1. Select your target device (Simulator or physical device)
2. Press **⌘R** to build and run
3. For Live Activities testing, use a physical iPhone 14 Pro+ for Dynamic Island

## Project Structure

```
Pomodo/
├── Sources/
│   ├── App/           # App entry point
│   ├── Models/        # Data models
│   ├── ViewModels/    # Business logic
│   ├── Views/         # SwiftUI views
│   ├── Managers/      # Services (notifications, haptics, etc.)
│   ├── Theme/         # Theme system
│   └── Extensions/    # Swift extensions
├── Resources/         # Plist, assets
└── PomodoWidget/      # Live Activity extension
```

## Theme Colors

Each theme has work mode and break mode colors:

| Theme | Work Background | Work Accent | Break Background | Break Accent |
|-------|-----------------|-------------|------------------|--------------|
| Cozy | #2C1810 | #D4956A | #1A2F1A | #7CB87C |
| Night | #0D0D1A | #FF6B9D | #0A1A2A | #00D4FF |
| Winter | #1A2A3A | #87CEEB | #2A3A4A | #B0E0E6 |
| Spring | #2D1F2D | #FFB7C5 | #1F2D1F | #98D998 |
| Summer | #1A2A3A | #FFD700 | #2A3A2A | #90EE90 |
| Fall | #2A1A0A | #D2691E | #1A2A1A | #8FBC8F |

## Testing Live Activities

### Simulator
- Live Activities work in iOS Simulator (iOS 16.1+)
- Dynamic Island preview is limited - test appearance only

### Physical Device
- Required for true Dynamic Island testing
- Ensure device is iPhone 14 Pro or later
- Enable Live Activities in Settings → Pomodo

### Debug Tips
- Use `print()` statements in `LiveActivityManager` to debug
- Check Console.app for activity lifecycle events
- Activities auto-end after 8 hours

## App Store Submission

1. Archive: **Product → Archive**
2. Validate app in Organizer
3. Upload to App Store Connect
4. Fill in App Store listing details
5. Submit for review

### Required Screenshots
- 6.7" (iPhone 14 Pro Max): 1290 x 2796
- 6.5" (iPhone 11 Pro Max): 1242 x 2688
- 5.5" (iPhone 8 Plus): 1242 x 2208

## License

MIT License - See main project repository.

---

Built with SwiftUI and ActivityKit for iOS 16.1+
