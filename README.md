# Pomoro 🍅

A beautiful, premium Apple-style Pomodoro timer for iOS and macOS built with SwiftUI.

---

## Features

- **Smart Timer** – Circular ring timer with auto-advancing sessions
- **Task Integration** – Link tasks to sessions, track pomodoro counts
- **Statistics** – Daily/weekly charts powered by Swift Charts
- **Focus Mode** – Immersive fullscreen mode with ambient animations
- **CloudKit Sync** – Real-time sync between iPhone and Mac via SwiftData
- **Widgets** – Home Screen, Lock Screen, and Dynamic Island support
- **macOS Menu Bar** – Mini controller in the Mac menu bar
- **Siri/Shortcuts** – Start, pause, and skip via App Intents
- **Onboarding** – Beautiful animated introduction flow
- **Themes** – Dark mode first with system light/dark support

---

## Project Structure

```
Pomoro/
├── Pomoro/                          # Main app target
│   ├── PomoroApp.swift              # App entry point, SwiftData container
│   ├── ContentView.swift            # Root navigation (TabView / NavigationSplitView)
│   ├── Design/
│   │   └── DesignSystem.swift       # Colors, typography, spacing, animations
│   ├── Models/
│   │   ├── SessionType.swift        # Focus / Short Break / Long Break enum
│   │   ├── PomodoroTask.swift       # SwiftData task model
│   │   ├── PomodoroSession.swift    # SwiftData session history model
│   │   └── AppSettings.swift       # AppStorage-backed settings
│   ├── ViewModels/
│   │   ├── TimerViewModel.swift     # @Observable timer engine
│   │   ├── TaskViewModel.swift      # Task CRUD operations
│   │   └── StatisticsViewModel.swift # Stats computation
│   ├── Services/
│   │   ├── NotificationService.swift # UNUserNotifications
│   │   ├── HapticService.swift       # UIFeedbackGenerator (iOS)
│   │   └── SoundService.swift        # AVAudioPlayer
│   ├── Features/
│   │   ├── Timer/
│   │   │   ├── TimerView.swift        # Main timer screen
│   │   │   ├── CircularTimerView.swift # Animated ring
│   │   │   └── SessionControlsView.swift
│   │   ├── Tasks/
│   │   │   ├── TaskListView.swift
│   │   │   ├── TaskRowView.swift
│   │   │   └── AddTaskSheet.swift
│   │   ├── Statistics/
│   │   │   └── StatisticsView.swift   # Charts + stat cards
│   │   ├── Settings/
│   │   │   └── SettingsView.swift
│   │   ├── Focus/
│   │   │   └── FocusModeView.swift    # Fullscreen immersive mode
│   │   └── Onboarding/
│   │       └── OnboardingView.swift
│   ├── Components/
│   │   ├── GlassCard.swift           # GlassCard, SessionTypeBadge, MiniProgressRing
│   │   ├── PomoroTabBar.swift        # Custom iOS tab bar
│   │   ├── EmptyStateView.swift
│   │   └── ScaleButtonStyle (in SessionControlsView.swift)
│   └── Platform/
│       ├── AppIntents.swift          # Siri / Shortcuts integration
│       ├── iOS/
│       │   ├── LiveActivityManager.swift
│       │   └── LiveActivityWidgetView.swift
│       └── macOS/
│           └── MenuBarView.swift      # MenuBarExtra window
│
└── PomoroWidget/                     # Widget Extension target
    ├── PomoroWidgetBundle.swift
    ├── WidgetSharedData.swift         # Shared data model + App Group
    └── TimerWidget.swift              # Home Screen + Lock Screen widgets
```

---

## Setup Instructions

### 1. Create Xcode Project

1. Open Xcode → **File → New → Project**
2. Choose **Multiplatform → App**
3. Product Name: `Pomoro`
4. Bundle ID: `com.yourname.pomoro`
5. Use **SwiftData** for storage
6. Minimum deployments: iOS 17.0, macOS 14.0

### 2. Add Source Files

Drag all files from this directory into the Xcode project, maintaining the folder structure.

### 3. Add Widget Extension

1. **File → New → Target → Widget Extension**
2. Name it `PomoroWidget`
3. Uncheck "Include Live Activity" (we handle it manually)
4. Add `PomoroWidget/` source files to this target
5. Add `PomoroWidget/WidgetSharedData.swift` to **both** the main app target AND the widget target

### 4. Configure App Group (for Widget sync)

1. In the main app target → **Signing & Capabilities → + Capability → App Groups**
2. Add: `group.com.yourname.pomoro`
3. Do the same for the Widget Extension target
4. Update `appGroupID` in `WidgetSharedData.swift` to match your group ID

### 5. Enable CloudKit

1. Main app target → **Signing & Capabilities → + Capability → iCloud**
2. Check **CloudKit**
3. Create a container: `iCloud.com.yourname.pomoro`
4. The `ModelConfiguration(cloudKitDatabase: .automatic)` in `PomoroApp.swift` handles the rest

### 6. Live Activity (iOS only)

1. Add `NSSupportsLiveActivities` = `YES` to your `Info.plist`
2. Add the `ActivityKit` framework to the main target

### 7. Menu Bar (macOS)

The `MenuBarExtra` in `PomoroApp.swift` is wrapped in `#if os(macOS)`. No extra setup needed.

### 8. Siri / App Intents

Add `NSUserActivityTypes` and `INIntentIdentifiers` to `Info.plist` if needed, or just let Xcode auto-configure via the `AppShortcutsProvider`.

---

## Required Frameworks

| Framework        | Purpose                      |
|------------------|------------------------------|
| SwiftUI          | All UI                       |
| SwiftData        | Local + CloudKit persistence |
| CloudKit         | Cross-device sync            |
| Charts           | Statistics charts            |
| WidgetKit        | Home/Lock Screen widgets     |
| ActivityKit      | Live Activity / Dynamic Island |
| AppIntents       | Siri & Shortcuts             |
| UserNotifications| Session alerts               |
| AVFoundation     | Ambient sounds               |

---

## Design System

All design tokens are in `Design/DesignSystem.swift` under the `PDS` namespace:

```swift
PDS.Colors.focusRed        // Session accent
PDS.Typography.timerDisplay // 72pt thin rounded
PDS.Spacing.md             // 16pt
PDS.Radius.large           // 20pt corners
PDS.Animation.spring       // response: 0.4, damping: 0.75
```

---

## Architecture

- **MVVM** with `@Observable` (iOS 17+ macro)
- `@Environment` for dependency injection
- `@Query` for reactive SwiftData fetching
- `ModelContext` injected via `.onAppear`
- `AppSettings` uses `@AppStorage` for instant persistence

---

## Extending the App

### Add a new setting
1. Add `@AppStorage("key") var myPref: Bool = false` in `AppSettings.swift`
2. Add a `Toggle` row in `SettingsView.swift`

### Add a new stat
1. Add a computed property to `StatisticsViewModel.swift`
2. Add a `StatCard` in `StatisticsView.swift`

### Customize timer durations
Edit defaults in `AppSettings.swift`:
```swift
@AppStorage("focusDuration") var focusDuration: Double = 25  // minutes
```

---

## License

MIT — Build something great.
# pomoro
