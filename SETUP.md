# 📿 Nyingma Calendar — Setup & Architecture Guide

> **Nyingma Buddhist Calendar — Ancient Wisdom, Modern Life**
> Ứng dụng lịch Phật giáo Nyingma đa nền tảng, hỗ trợ song ngữ Anh - Tạng (English / བོད་སྐད།)

---

## 📋 Mục lục

- [Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [Cài đặt nhanh](#-cài-đặt-nhanh)
- [Cấu trúc dự án](#-cấu-trúc-dự-án)
- [Kiến trúc ứng dụng](#-kiến-trúc-ứng-dụng)
- [Các màn hình chính](#-các-màn-hình-chính)
- [Quản lý State (Riverpod)](#-quản-lý-state-riverpod)
- [Hệ thống đa ngôn ngữ](#-hệ-thống-đa-ngôn-ngữ-i18n)
- [Dữ liệu chiêm tinh](#-dữ-liệu-chiêm-tinh-astrology)
- [Build & Deploy](#-build--deploy)
- [Troubleshooting](#-troubleshooting)

---

## 🔧 Yêu cầu hệ thống

| Công cụ       | Phiên bản tối thiểu | Ghi chú                        |
|---------------|---------------------|---------------------------------|
| **Flutter**   | 3.x (SDK ≥ 3.0.0)  | `flutter --version` để kiểm tra |
| **Dart**      | ≥ 3.0.0             | Đi kèm Flutter SDK              |
| **Git**       | Bất kỳ              | Quản lý mã nguồn                |
| **Windows**   | 10/11               | Cho Windows build                |
| **Xcode**     | 15+                 | Cho iOS/macOS build              |
| **Android Studio** | Bất kỳ         | Cho Android build + emulator     |

---

## 🚀 Cài đặt nhanh

### 1. Clone project

```bash
git clone <repo-url> "Nyingma Calendar"
cd "Nyingma Calendar"
```

### 2. Cài đặt dependencies

```bash
cd nyingmapa_calendar
flutter pub get
```

### 3. Chạy ứng dụng

```bash
# Windows (Development)
flutter run -d windows

# Windows (Release — khuyến nghị, tránh lỗi C++ debug toolchain)
flutter build windows --release
.\build\windows\x64\runner\Release\nyingmapa_calendar.exe

# Android
flutter run -d <device-id>

# iOS (cần macOS + Xcode)
flutter run -d <ios-device>

# Web
flutter run -d chrome
```

### 4. Hot Restart (khi develop)

```
r  → Hot reload
R  → Hot restart
q  → Thoát
```

---

## 📂 Cấu trúc dự án

```
Nyingma Calendar/
├── README.md                          # Readme gốc
├── SETUP.md                           # ← Bạn đang đọc file này
├── images/                            # Asset ảnh gốc (97 files)
├── Tibetan Astrology/                 # Dữ liệu Excel/CSV chiêm tinh
├── Visual mockup and flow/            # Mockup thiết kế giao diện
│
└── nyingmapa_calendar/                # ★ FLUTTER PROJECT CHÍNH
    ├── pubspec.yaml                   # Dependencies & asset declarations
    ├── lib/                           # Source code Dart
    │   ├── main.dart                  # Entry point
    │   ├── app/                       # App shell & routing
    │   ├── core/                      # Core utilities
    │   │   ├── theme/                 # AppColors, AppSpacing
    │   │   ├── localization/          # Language provider
    │   │   └── astrology/             # Astrology calculation engine
    │   ├── data/                      # Data layer (Clean Architecture)
    │   │   ├── datasources/           # JSON loaders, calendar/event data sources
    │   │   ├── models/                # DayModel, EventModel
    │   │   └── repositories/          # Repository implementations
    │   ├── domain/                    # Domain layer
    │   │   ├── entities/              # DayEntity, EventEntity
    │   │   └── repositories/          # Repository interfaces
    │   ├── features/                  # Feature modules (Clean Architecture)
    │   │   ├── astrology/providers/   # 15 astrology data providers
    │   │   ├── auspicious/providers/  # Auspicious days provider
    │   │   ├── calendar/              # Calendar screen, widgets, providers
    │   │   ├── day_detail/            # Day detail screen, widgets
    │   │   └── events/                # Events screen, providers
    │   ├── screens/                   # UI Screens (active)
    │   │   ├── home_shell.dart        # Bottom navigation container
    │   │   ├── calendar_home_screen.dart  # ★ Main calendar + hero card + astrology
    │   │   ├── auspicious_days_screen.dart
    │   │   ├── events_screen.dart
    │   │   ├── practice_screen.dart
    │   │   ├── settings_screen.dart
    │   │   └── onboarding_screen.dart
    │   ├── services/                  # Service layer
    │   │   ├── theme_provider.dart    # Theme & language Riverpod providers
    │   │   ├── translations.dart      # ★ Bilingual EN/BO translation strings
    │   │   ├── local_data_service.dart # Local JSON data service
    │   │   ├── api_service.dart       # HTTP API service
    │   │   └── app_localizations.dart
    │   └── theme/
    │       └── app_theme.dart         # Light & Dark theme definitions
    │
    └── assets/
        ├── data/
        │   ├── calendar/2026/         # Daily calendar data (month JSON files)
        │   ├── calendar/2027/
        │   ├── events/                # Processed event data
        │   ├── raw/                   # ★ 24 raw JSON files (astrology source)
        │   ├── index/                 # Data indexes
        │   ├── meta/                  # Metadata
        │   └── astrology/             # Astrology reference data
        └── images/
            ├── others/                # General images
            ├── Auspicious days/
            ├── Birthday/
            ├── Events 3/
            ├── events 2/
            ├── Guru Rinpoche 12 manefistation/
            ├── astrology/             # Astrology category images
            └── parinirvana/
```

---

## 🏗 Kiến trúc ứng dụng

### Clean Architecture + Riverpod

```
┌─────────────────────────────────────────────┐
│                  UI Layer                    │
│  screens/ ← ConsumerStatefulWidget          │
│  (calendar_home, events, practice, ...)     │
├─────────────────────────────────────────────┤
│              State Management               │
│  Riverpod Providers                         │
│  ├── languageProvider (StateNotifier)       │
│  ├── themeNotifierProvider (StateNotifier)  │
│  ├── 15x FutureProvider (astrology data)   │
│  ├── practiceProvider (StateNotifier)      │
│  └── userEventsProvider (StateNotifier)    │
├─────────────────────────────────────────────┤
│              Service Layer                  │
│  LocalDataService ← JSON asset loading     │
│  ThemeService ← SharedPreferences          │
│  Translations (T class) ← EN/BO strings   │
├─────────────────────────────────────────────┤
│               Data Layer                    │
│  json_loader.dart ← rootBundle.loadString  │
│  assets/data/raw/*.json                    │
│  assets/data/calendar/**/*.json            │
└─────────────────────────────────────────────┘
```

### Luồng dữ liệu

```
JSON Assets → json_loader → Provider (parse/clean) → Widget (display)
                                 ↑
                         Riverpod cache
                    (load 1 lần, dùng mãi)
```

---

## 📱 Các màn hình chính

| #  | Tab             | File                          | Chức năng chính                                     |
|----|-----------------|-------------------------------|-----------------------------------------------------|
| 1  | **Calendar**    | `calendar_home_screen.dart`   | Hero card, lịch tháng, sự kiện, 15 mục chiêm tinh  |
| 2  | **Auspicious**  | `auspicious_days_screen.dart` | Ngày tốt lành, milestone, view detail               |
| 3  | **Events**      | `events_screen.dart`          | Danh sách sự kiện năm, chi tiết sự kiện             |
| 4  | **Practice**    | `practice_screen.dart`        | Theo dõi tu tập, streak, tạo sự kiện cá nhân        |
| 5  | **Settings**    | `settings_screen.dart`        | Profile, ngôn ngữ, theme, thông báo, export         |

### Calendar Home Screen (Màn hình chính)

Đây là màn hình phức tạp nhất, bao gồm:

- **Hero Card**: Hiển thị ngày hiện tại với element/animal/year theo lịch Tây Tạng
- **Calendar Grid**: Lưới tháng với highlight ngày đặc biệt (Guru Rinpoche, ...)
- **Monthly Events**: 4 sự kiện đầu tháng, click xem chi tiết modal
- **Astrology Section**: Grid 15 mục chiêm tinh, mỗi mục click ra modal detail:

| Mục | Provider | Custom View |
|-----|----------|-------------|
| Hair Cutting | `hairCuttingProvider` | ✅ `_buildHairCuttingRiverpod` |
| Naga Days | `nagaDaysProvider` | ✅ `_buildNagaDaysRiverpod` |
| Flag Days | `flagAvoidanceProvider` | ✅ `_buildFlagRiverpod` |
| Restrictions | `restrictionProvider` | ✅ `_buildRestrictionsRiverpod` |
| Auspicious Times | `auspiciousTimingProvider` | ✅ `_buildAuspiciousTimingView` |
| Fire Deity | `fireRitualProvider` | ✅ `_buildFireDeityView` |
| Empty Vase | `emptyVaseProvider` | ✅ `_buildEmptyVaseView` |
| Life Force (M) | `lifeForceMAleProvider` | ✅ `_buildLifeForceView` |
| Life Force (F) | `lifeForceFemaleProvider` | ✅ `_buildLifeForceView` |
| Horse Death | `horseDeathProvider` | ✅ `_buildHorseDeathView` |
| Gu Mig | `guMigProvider` | ✅ `_buildGuMigView` |
| Fatal Weekdays | `fatalWeekdaysProvider` | ✅ `_buildFatalWeekdaysView` |
| Torma | `tormaOfferingProvider` | ✅ `_buildTormaView` |
| Parkha | `tibetanAstrologyProvider` | ✅ `_buildTibAstrologyView` |

---

## 🔄 Quản lý State (Riverpod)

### Providers chính

```dart
// services/theme_provider.dart
final languageProvider = StateNotifierProvider<LanguageNotifier, String>
// Giá trị: 'en' hoặc 'bo'
// Lưu vào SharedPreferences key 'language'

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>
// Giá trị: ThemeMode.light / ThemeMode.dark / ThemeMode.system

final highContrastProvider = StateNotifierProvider<HighContrastNotifier, bool>

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>
```

### Sử dụng trong Widget

```dart
// Đọc giá trị (rebuild khi thay đổi)
final lang = ref.watch(languageProvider);
final isBo = lang == 'bo';

// Đọc giá trị (không rebuild)
final isBo = ref.read(languageProvider) == 'bo';

// Cập nhật
ref.read(languageProvider.notifier).setLanguage('bo');
ref.read(themeNotifierProvider.notifier).setTheme(ThemeMode.dark);
```

---

## 🌐 Hệ thống đa ngôn ngữ (i18n)

### File: `lib/services/translations.dart`

```dart
// Sử dụng
final label = T.t('nav_calendar', isBo);
// isBo = true  → 'ཟླ་ཐོ།'
// isBo = false → 'Calendar'
```

### Cách thêm chuỗi mới

1. Thêm key vào `_en` map:
```dart
'my_new_key': 'English text',
```

2. Thêm key vào `_bo` map:
```dart
'my_new_key': 'བོད་ཡིག་ཚིག་གྲུབ།',
```

3. Sử dụng trong widget:
```dart
Text(T.t('my_new_key', isBo))
```

### Hiện tại hỗ trợ ~100 translation keys cho:
- Navigation labels
- Calendar screen
- Astrology items (15 mục)
- Auspicious/Events/Practice/Settings screens
- Detail modals & buttons

---

## 🔮 Dữ liệu chiêm tinh (Astrology)

### Nguồn dữ liệu: `assets/data/raw/` (24 JSON files)

Tất cả JSON được export từ Excel/CSV nên có format đặc biệt:
- Cột đầu tiên có tên dài (ví dụ: `"FATAL WEEKDAYS"`)
- Các cột tiếp theo là `"Unnamed: 1"`, `"Unnamed: 2"`, ...
- 1-3 hàng đầu là mô tả/header, **không phải data**

### Parser: `lib/features/astrology/providers/astrology_providers.dart`

Mỗi provider:
1. Load raw JSON từ assets
2. Tìm header row (match pattern)
3. Skip description rows
4. Map "Unnamed: N" → tên field có nghĩa
5. Trả về `List<Map<String, dynamic>>` đã clean

**Ví dụ — Fatal Weekdays:**

```
Raw JSON:
  Row 0: "Life-Soul and Fatal Weekdays" (description)
  Row 1: "སྲོག་དང་གཤིན་ཉིན།" (Tibetan description)
  Row 2: null
  Row 3: "Birth Sign" | "Soul & Life-Force" | "Fatal Day" (HEADER)
  Row 4: "Rat" | "Wednesday & Tuesday" | "Saturday" (DATA)
  ...

Parsed:
  [
    { birth_sign: "Rat", soul_day: "Wednesday & Tuesday", fatal_day: "Saturday" },
    ...
  ]
```

---

## 📦 Dependencies

| Package | Phiên bản | Mục đích |
|---------|-----------|----------|
| `flutter_riverpod` | ^2.5.1 | State management |
| `shared_preferences` | ^2.2.0 | Lưu cài đặt người dùng |
| `intl` | ^0.19.0 | Date formatting |
| `google_fonts` | ^6.1.0 | Typography |
| `http` | ^1.1.0 | HTTP client |
| `cached_network_image` | ^3.3.0 | Image caching |
| `table_calendar` | ^3.0.9 | Calendar widget |
| `shimmer` | ^3.0.0 | Loading animations |
| `flutter_svg` | ^2.0.9 | SVG rendering |
| `url_launcher` | ^6.2.1 | Mở URL external |
| `flutter_local_notifications` | ^17.0.0 | Push notifications |

---

## 🏭 Build & Deploy

### Windows Release

```bash
cd nyingmapa_calendar
flutter clean
flutter pub get
flutter build windows --release
```

Output: `build/windows/x64/runner/Release/nyingmapa_calendar.exe`

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS (cần macOS)

```bash
flutter build ios --release
```

### Web (Firebase Hosting)

```bash
flutter build web --release
firebase deploy --only hosting
```

Config: `firebase.json` + `.firebaserc`

---

## 🐛 Troubleshooting

### ❌ Windows Debug build lỗi C++ CMake

```
CMake Error: ... MSVC ...
```

**Giải pháp**: Dùng Release build thay vì Debug:
```bash
flutter build windows --release
```

### ❌ Assets không load được

Kiểm tra `pubspec.yaml` → mục `flutter.assets` đã khai báo đúng đường dẫn.

```bash
flutter clean
flutter pub get
```

### ❌ Riverpod ConsumerWidget lỗi

Đảm bảo:
- Widget extends `ConsumerWidget` hoặc `ConsumerStatefulWidget`
- `main.dart` wrap `ProviderScope` ở root
- State class extends `ConsumerState<T>`

### ❌ Chuyển ngôn ngữ không cập nhật

Kiểm tra widget có dùng `ref.watch(languageProvider)` trong `build()`:
```dart
@override
Widget build(BuildContext context) {
  final lang = ref.watch(languageProvider); // ← bắt buộc watch
  final isBo = lang == 'bo';
  ...
}
```

### ❌ JSON data hiện raw keys (\"Unnamed: 1\")

Provider chưa parse đúng. Kiểm tra file `astrology_providers.dart`:
- Header row pattern có match không?
- Skip rows đủ chưa?

---

## 📝 Quy ước code

| Quy tắc | Chi tiết |
|---------|----------|
| **State management** | Riverpod `StateNotifierProvider` cho reactive state |
| **Ngôn ngữ** | `ref.watch(languageProvider)` → `isBo` boolean |
| **Translations** | `T.t('key', isBo)` cho mọi chuỗi UI |
| **Theme** | `AppColors.navy`, `AppColors.maroon`, `AppColors.gold`, ... |
| **Color scheme** | Maroon (#800020) primary, Navy (#1B2333) text, Gold (#C5A54E) accent |
| **File naming** | `snake_case.dart` |
| **Widget** | `ConsumerStatefulWidget` nếu cần state, `ConsumerWidget` nếu không |

---

## 📞 Liên hệ & Hỗ trợ

- **Version**: 2.4.0
- **SDK**: Flutter 3.x / Dart ≥ 3.0.0
- **Platforms**: Windows, Android, iOS, Web, macOS, Linux
- **License**: Private

---

*Cập nhật lần cuối: 02/03/2026*
