# ⏱️ Routine Stopwatch

A **Customizable Routine Stopwatch** Flutter app for managing specific timing routines for workouts or tasks. Set profile-based alarms that trigger at precise times with custom sounds!

![Platform](https://img.shields.io/badge/Platform-Android-green?logo=android)
![Flutter](https://img.shields.io/badge/Flutter-3.9+-blue?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ Features

- **8 Custom Profiles** - Create and name profiles for different routines (e.g., "Cardio A", "HIIT Timer")
- **Precise Trigger Times** - Set alarm to trigger at any MM:SS (e.g., 04:20)
- **8 Embedded Sounds** - Choose from Deep Beep, Buzzer, Bell, Chime, and more
- **Cycle-Based Duration** - Alarm plays in 30-second cycles (1 cycle = 30s, 3 cycles = 90s)
- **Infinite Mode** - "Play Until Stopped" option for endless alarm loops
- **Background Operation** - Timer continues when screen is locked or app is minimized
- **Local Storage** - All settings persist offline via SharedPreferences
- **No Internet Required** - Fully offline functionality

## 📱 Screenshots

| Home Screen | Settings | Profile Editor |
|:-----------:|:--------:|:--------------:|
| Stopwatch display with controls | List of 8 profiles | Edit name, time, sound, duration |

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **Target**: Android 10+ (API 29)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Audio**: audioplayers
- **Background Service**: flutter_foreground_task
- **Wake Lock**: wakelock_plus

## 🚀 Getting Started

### Prerequisites

- Flutter 3.9 or higher
- Android SDK with API 29+

### Installation

```bash
# Clone the repository
git clone https://github.com/MohammedAbdulwahab3/Timer.git
cd Timer

# Install dependencies
flutter pub get

# Generate launcher icons
flutter pub run flutter_launcher_icons

# Run the app
flutter run

# Build release APK
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── profile.dart          # Profile data model
├── providers/
│   └── app_provider.dart     # State management
├── services/
│   ├── audio_service.dart    # Sound playback
│   ├── storage_service.dart  # Local persistence
│   └── timer_service.dart    # Foreground service
├── screens/
│   ├── home_screen.dart      # Main stopwatch UI
│   ├── settings_screen.dart  # Profile list
│   └── profile_edit_screen.dart  # Edit profile
└── widgets/
    ├── stopwatch_display.dart    # MM:SS display
    ├── control_buttons.dart      # Start/Pause/Reset
    └── alarm_overlay.dart        # Stop alarm UI
```

## 🎯 Usage

1. **Select a Profile** - Tap the settings icon to view all 8 profiles
2. **Configure Profile** - Set trigger time, select sound, choose duration cycles
3. **Start Stopwatch** - Press the play button on the main screen
4. **Wait for Alarm** - Timer runs in background even with screen locked
5. **Stop Alarm** - Tap the large STOP button when alarm triggers

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Mohammed Abdulwahab**

---

⭐ **Star this repo** if you find it useful!
