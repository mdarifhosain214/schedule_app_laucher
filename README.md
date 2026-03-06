# App Scheduler

A Flutter Android application that lets users schedule installed apps to auto-launch at specific times. Built with **Clean Architecture** and **Riverpod** state management.

## Features

- **App Discovery** – Browse all installed apps in a searchable grid with icons
- **Schedule Creation** – Pick any app, set a future date/time, add an optional label
- **Conflict Detection** – Real-time warnings when scheduling overlaps with existing schedules
- **Schedule Management** – View, edit, toggle, and delete scheduled launches
- **Background Execution** – Uses Android AlarmManager for exact alarms that work even when the app is closed
- **Execution History** – Track all past schedule executions with success/failure status
- **Modern UI** – Dark theme with Material Design 3, gradients, and smooth interactions

## Architecture

```
lib/
├── core/                          # Shared utilities, theme, constants, services
│   ├── constants/app_constants.dart
│   ├── services/
│   │   ├── alarm_service.dart     # Android AlarmManager wrapper
│   │   └── notification_service.dart
│   ├── theme/app_theme.dart       # Material Design 3 dark/light theme
│   └── utils/date_time_utils.dart
├── data/                          # Data layer
│   ├── datasources/
│   │   ├── app_discovery_datasource.dart  # Platform channel to Android
│   │   └── local_database.dart           # SQLite database
│   ├── models/
│   │   ├── schedule_model.dart           # DB serialization
│   │   └── schedule_history_model.dart
│   └── repositories/
│       ├── app_repository_impl.dart
│       └── schedule_repository_impl.dart
├── domain/                        # Business logic (pure Dart)
│   ├── entities/
│   │   ├── app_info.dart
│   │   ├── schedule.dart
│   │   └── schedule_history.dart
│   ├── repositories/
│   │   ├── app_repository.dart    # Abstract interfaces
│   │   └── schedule_repository.dart
│   └── usecases/
│       ├── get_installed_apps.dart
│       ├── manage_schedules.dart
│       └── schedule_app_launch.dart
├── presentation/                  # UI layer
│   ├── pages/
│   │   ├── home_page.dart
│   │   ├── app_discovery_page.dart
│   │   ├── schedule_form_page.dart
│   │   └── history_page.dart
│   ├── providers/app_providers.dart   # Riverpod state management
│   └── widgets/
│       ├── app_card.dart
│       ├── schedule_card.dart
│       └── conflict_warning.dart
└── main.dart
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Database | SQLite (sqflite) |
| Background Tasks | android_alarm_manager_plus |
| Notifications | flutter_local_notifications |
| App Discovery | Custom Android Platform Channel |
| Architecture | Clean Architecture (Domain → Data → Presentation) |

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.11
- Android SDK 34
- A real Android device (recommended for full functionality)

### Run
```bash
flutter pub get
flutter run
```

### Build APK
```bash
flutter build apk --debug
```

## Android Permissions

| Permission | Purpose |
|-----------|---------|
| `SCHEDULE_EXACT_ALARM` | Schedule precise app launches |
| `QUERY_ALL_PACKAGES` | Discover all installed apps |
| `RECEIVE_BOOT_COMPLETED` | Re-register alarms after reboot |
| `POST_NOTIFICATIONS` | Show launch notifications |
| `WAKE_LOCK` | Keep device awake for alarm callbacks |

## Key Design Decisions

1. **Custom Platform Channels** over `device_apps` package – Full control over Android PackageManager queries with icon extraction
2. **SQLite** over Hive/Isar – Simpler setup, no code generation, well-suited for relational schedule data
3. **One-shot alarms** – Each schedule registers a single alarm; executed schedules are deactivated
4. **Minute-level conflict detection** – Two schedules conflict if they share the same minute window

## Known Limitations

- **Android 12+ Exact Alarm Restrictions**: The app requests `SCHEDULE_EXACT_ALARM` permission but some OEM Android skins may still restrict background execution
- **Battery Optimization**: Aggressive battery optimization on some devices (Xiaomi, Huawei) may kill background services
- **Android Only**: iOS is not supported due to platform-level restrictions on launching other apps

## Screenshots

> Screenshots require running the app on a real Android device. See the demo video for a full walkthrough.
