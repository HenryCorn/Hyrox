# Hyrox Watch — Apple Watch Companion App

A native watchOS app that mirrors your Hyrox workout from the iPhone and shows
live pace, heart rate, and calories directly on your wrist.

## Architecture

```
iPhone (Flutter)          Apple Watch (SwiftUI)
─────────────────         ──────────────────────────────────────
TimerProvider        ──►  WatchConnectivityManager
  exerciseIndex            exerciseName
  exerciseName             isRun
  isRunning                isRunning
  elapsedMs                elapsedMs
                      ◄──  sendCommand("next" | "pause")

HealthService (HK)        WatchHealthManager
  calories polling    ──►  HKAnchoredObjectQuery → heartRate
  (phone side)             CLLocationManager   → paceSecsPerKm
```

### Views

| View | Shown when | Notes |
|---|---|---|
| `WaitingView` | No workout started | Shows connection status |
| `RunningView` | `isRun == true` | Pace in **signal red** — the "one break" |
| `ExerciseView` | `isRun == false` | White timer, HR, calories |

## Setup in Xcode

1. Open `apps/mobile/ios/Runner.xcworkspace` in Xcode.
2. **File → Add Packages** — no additional packages needed (pure Swift).
3. **Add a new target**: File → New → Target → watchOS → App.
   - Product name: `HyroxWatch`
   - Bundle identifier: `com.yourteam.hyrox-tracker.watchkitapp`
4. Copy the Swift source files from `apps/watch/HyroxWatch/HyroxWatch/` into the new target.
5. Add the `WatchConnectivity` and `HealthKit` frameworks to the Watch target.
6. In the Watch target's `Info.plist`, set:
   - `WKCompanionAppBundleIdentifier` → your iOS bundle ID
7. Enable **HealthKit** capability on both the iOS and Watch targets.
8. Enable **WatchConnectivity** on the iOS target.

## Watch face layout (Nothing design)

```
┌─────────────────────────┐
│  1 KM RUN               │  ← Space Mono 11pt, gray
│                         │
│      05:23              │  ← Pace, Space Mono 40pt, SIGNAL RED
│       /KM               │
│                         │
│  BPM  │ CALS │  TIME    │  ← 3-column metrics row
│  158  │  312 │  24:10   │
│                         │
│ ▓▓▓▓▓▓░░░░░░░░░░░░░░░░░ │  ← Segmented progress bar
│                         │
│       [ NEXT ]          │  ← White pill button
└─────────────────────────┘
```

Run segments show pace in **#D71921** (signal red).
Station segments show the exercise timer in **#FFFFFF** (white).
