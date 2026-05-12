# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # install dependencies
flutter run              # run on connected device/emulator
flutter analyze          # lint (uses flutter_lints)
flutter test             # run all tests
flutter test test/foo_test.dart   # run a single test file
flutter build apk        # Android release build
flutter build ios        # iOS release build
```

## Architecture

**GINBEC Mobile App** — a meeting room booking and scheduling app for a Cambodian Buddhist national education authority. The UI includes Khmer-language labels; two custom Khmer fonts (`KhmerOSSiemreap`, `KhmerOSMoulLightRegular`) are declared in `pubspec.yaml`.

### Navigation shell

`MainScreen` (`lib/screens/mainscreen.dart`) is a bottom-nav shell that owns 4 tabs: **Home**, **Meetings**, **Alerts**, **Settings**. It swaps between page widgets using a `_selectedIndex` with `setState`. Currently `main.dart` boots directly into `MainScreen` (login is bypassed during development). The login flow (`LoginScreen` → `RegisterAccount` / `ResetPassword` / `OtpScreen`) exists in `lib/screens/login_screen/` and uses imperative `Navigator.push`.

### State management

No external state management library — the app uses plain `StatefulWidget` + `setState` throughout.

### Data layer

No backend integration yet. `lib/models/booking.dart` defines the `Booking` model (with `BookingStatus` enum). All screen data is currently hardcoded. When services are added they should go in `lib/services/`.

### Color system

All brand colors live in `GColor` (`lib/config/color.dart`) as static getters:
- `primarycolor` — `#F55000` (orange-red, main CTA color)
- `secondarycolor` — `#FC9400` (amber)
- `backgroundcolor` — `#FFFDF1` (warm off-white, used as scaffold bg)

Always use `GColor` getters instead of raw hex values.

### Widgets

Reusable widgets in `lib/widgets/` include `RoundTextField`, `RoundButton`, `TranspButton`, `ActionButton`, `TabButton`, `TabSwitch`, `AvatarWidget`, `DashCard`, `EventCard`, `NotificationCard`, `Bookingcard`, and `HoverableText`. Screen-specific helpers (`_StatusBadge`, `_InfoRow`) live inside their widget file, not exported.

### Utilities

`lib/utils/formatters.dart` — date/time formatting helpers used by `Bookingcard`.

## Conventions

- Screens go in `lib/screens/<feature>/` (one folder per screen group); reusable widgets go in `lib/widgets/`.
- All colors via `GColor`; fonts referenced by family name (`KhmerOSSiemreap`, `KhmerOSMoulLightRegular`).
- Assets (images, icons) are placed under `lib/assets/` and declared in `pubspec.yaml` under `flutter: assets: - lib/assets/`.
- Widget filenames use snake_case; class names use PascalCase. Note `Available_roomcard.dart` is an existing exception — new files should be fully snake_case.

## In-progress / stubs

- `lib/screens/alert_screen/alert.dart` and `lib/widgets/Available_roomcard.dart` are currently empty (placeholder files).
- The Alerts and Settings tabs in `MainScreen` still render `Home()` as a placeholder.
- `LoginScreen` is fully built but not yet wired as the app entry point.