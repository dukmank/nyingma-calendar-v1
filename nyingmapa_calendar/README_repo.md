# Nyingma Calendar – Technical Architecture Documentation

This document explains the Nyingma Calendar project in full technical detail so that any new developer (UI, backend, or full‑stack) can understand how the system works without prior context.

---

# 1. Project Philosophy

This project is intentionally structured with **strict separation of concerns**:

- UI does NOT parse JSON
- UI does NOT interpret raw astrology maps
- UI does NOT touch repository logic
- Business logic is isolated from visual styling

The architecture is designed to:

- Support long‑term iteration
- Allow UI redesign without breaking logic
- Allow data source replacement (API instead of local JSON)
- Support scaling to advanced astrology logic

---

# 2. High-Level Architecture Overview

The app follows a layered structure:

```
Assets JSON
  ↓
DataSource (local)
  ↓
Model (JSON → Domain mapping)
  ↓
Repository (Domain abstraction)
  ↓
Riverpod Provider
  ↓
ViewModel (UI-ready state)
  ↓
Screen / Widget
```

Each layer has a single responsibility.

---

# 3. Directory Structure Explained

```
lib/
├── main.dart
├── app_shell.dart
│
├── core/
│   ├── astrology/
│   │   └── astrology_engine.dart
│   ├── localization/
│   │   └── language_provider.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_spacing.dart
│
├── data/
│   ├── datasources/
│   │   ├── json_loader.dart
│   │   ├── calendar_local_ds.dart
│   │   └── event_local_ds.dart
│   ├── models/
│   │   ├── day_model.dart
│   │   └── event_model.dart
│   └── repositories/
│       ├── calendar_repository_impl.dart
│       └── event_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── day_entity.dart
│   │   └── event_entity.dart
│   └── repositories/
│       ├── calendar_repository.dart
│       └── event_repository.dart
│
└── features/
    ├── calendar/
    │   ├── providers/
    │   ├── view_models/
    │   │   └── calendar_day_vm.dart
    │   ├── screens/
    │   └── widgets/
    │
    ├── day_detail/
    │   ├── view_models/
    │   │   └── day_detail_vm.dart
    │   ├── screens/
    │   └── widgets/
    │       └── astrology_section.dart
    │
    └── events/
        ├── providers/
        └── screens/
```

---

# 4. Domain Layer (Pure Business Schema)

## day_entity.dart
Represents one calendar day in full structure.

Includes:
- GregorianEntity
- TibetanEntity
- DayContentEntity
- DayVisualEntity
- DayExtraLabelsEntity
- List<String> eventIds
- Map<String, AstroItemEntity> astrology
- DayFlagsEntity flags

This layer contains ZERO UI logic.

---

# 5. Data Layer

## json_loader.dart
Low-level utility to load JSON from assets.
Used by local data sources.

## calendar_local_ds.dart
Loads month JSON from:
```
assets/data/calendar/<YEAR>/<YYYY_MM>.json
```

## event_local_ds.dart
Loads:
```
assets/data/events/events_master.json
```

## day_model.dart / event_model.dart
Responsible for:
- JSON decoding
- Null safety
- Type conversion
- Fallback handling

These map raw JSON → Domain Entities.

---

# 6. Repository Layer

Repositories abstract data source access.

UI NEVER calls datasource directly.

calendar_repository_impl.dart provides:
- getMonth()
- getDay()


event_repository_impl.dart provides:
- getById()
- getByDate()
- getAll()

Future replacement with API would only modify repository implementation.

---

# 7. ViewModel Layer

This is critical for UI developers.

UI should only read ViewModels.

## calendar_day_vm.dart
Used for Calendar grid.

Exposes:
- dayNumber
- isHighlight
- gregorianMonthLabelEn
- gregorianDayNameEn
- lunarDate
- lunarMonthLabelBo
- lunarYearLabelBo
- dayElement
- monthAnimal
- eventIds

Grid UI should never access DayEntity directly.

## day_detail_vm.dart
Used for Day Detail screen.

Responsible for:
- Resolving eventIds → full EventEntity list
- Exposing language-safe fields
- Building astrologyCards via AstrologyEngine

Important:
UI does NOT interpret astrology map directly.

---

# 8. Astrology System

Raw data:
```
Map<String, AstroItemEntity>
```

UI-ready data:
```
List<AstrologyCard>
```

AstrologyEngine responsibilities:
- Map raw key → readable title
- Map raw status → AstrologyStatus enum
- Provide consistent structured card model

AstrologySection:
- Reads structured cards
- Uses AppColors + AppSpacing
- Applies language toggle

UI should NOT implement status mapping logic.

---

# 9. Language System

Managed by Riverpod provider:
```
languageProvider
```

Supports:
- English
- Tibetan

Persistence:
- SharedPreferences

All screens must read:
```
final language = ref.watch(languageProvider);
```

Do not hardcode language conditionals outside screens/widgets.

---

# 10. Theme System

All visual tokens centralized.

## app_colors.dart
Defines:
- backgroundPrimary
- backgroundCard
- textPrimary
- textSecondary
- accentGold
- accentMaroon
- astrology status colors

## app_spacing.dart
4pt grid spacing system.

UI must not hardcode numbers like 12, 16, 24.

---

# 11. Asset Structure

Hero images expected at:
```
assets/images/<heroImageKey>.png
```

JSON expected at:
```
assets/data/calendar/
assets/data/events/
```

Ensure pubspec.yaml includes:

```
flutter:
  assets:
    - assets/images/
    - assets/data/
```

---

# 12. Known Extension Points

Future improvements may include:

1. Swipe month animation via PageView
2. Grouped event list by month
3. Structured astrology popup model
4. ARB localization system
5. Replace local JSON with remote API

Architecture already supports these.

---

# 13. Developer Contract

UI developers may:
- Redesign layouts
- Add animations
- Modify spacing via AppSpacing
- Modify colors via AppColors

UI developers must NOT:
- Parse JSON
- Access repositories directly
- Map astrology statuses manually

---

# 14. Running the App

Install:
```
flutter pub get
```

Run:
```
flutter run
```

If language persistence added:
```
flutter pub add shared_preferences
```

---

This repository is a structured technical foundation for scalable product development.
# Nyingma Calendar

## Product & Technical Architecture Documentation

Nyingma Calendar is a hybrid Tibetan + Gregorian calendar application designed with a scalable clean architecture.  
This repository represents the **core technical foundation** of the product.

This document explains:
- Product context
- Architectural decisions
- Data schema strategy
- State management
- Extension strategy
- Developer responsibilities

---

# 1. Project Context

### Product Purpose
Nyingma Calendar provides:
- Gregorian calendar system
- Tibetan lunar calendar system
- Daily astrology interpretation
- Religious event tracking
- Dual-language support (English / Tibetan)

### Target Users
- Practitioners of Tibetan Buddhism
- Astrology-aware users
- Cultural calendar followers

### Current Stage
Technical MVP – Core data engine completed.  
UI/UX refinement and product polish ongoing.

---

# 2. Architectural Philosophy

The project enforces **strict separation of concerns**:

- UI does NOT parse JSON
- UI does NOT interpret raw astrology maps
- UI does NOT access repositories directly
- Business logic is isolated from styling
- Theme tokens are centralized

This ensures:
- UI redesign does not break logic
- Data source can switch from local JSON → API
- Astrology logic can scale independently

---

# 3. High-Level Data Flow

```
Assets JSON
   ↓
LocalDataSource
   ↓
Model (JSON → Domain)
   ↓
Repository
   ↓
Riverpod Provider
   ↓
ViewModel
   ↓
Screen / Widget
```

Each layer has a single responsibility.

---

# 4. Directory Structure

```
lib/
├── main.dart
├── app_shell.dart
│
├── core/
│   ├── astrology/
│   ├── localization/
│   └── theme/
│
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   └── repositories/
│
└── features/
    ├── calendar/
    ├── day_detail/
    └── events/
```

---

# 5. Data Schema & Versioning

### Calendar Schema
Each day includes:
- Gregorian block
- Tibetan block
- Content block
- Visual block
- Event IDs
- Astrology map
- Flags

### Schema Version Policy
Current schema: **v2**  
Any breaking schema change must:
1. Be documented
2. Update model mapping
3. Maintain backward compatibility when possible

---

# 6. Domain Layer

Pure business schema only.
No Flutter imports.
No UI logic.

Primary entities:
- DayEntity
- EventEntity
- AstroItemEntity
- DayFlagsEntity

---

# 7. Data Layer

Responsible for:
- Loading JSON
- Null safety
- Type mapping
- Fallback handling

### json_loader.dart
Low-level asset loader.

### calendar_local_ds.dart
Loads monthly calendar files.

### event_local_ds.dart
Loads events_master.json.

Future API migration only modifies this layer.

---

# 8. Repository Layer

Abstracts data access.

UI never accesses datasource directly.

Repositories expose:
- getMonth()
- getDay()
- getAll()
- getByDate()

---

# 9. ViewModel Layer

UI must only read ViewModels.

### calendar_day_vm.dart
Used for grid.
Exposes formatted day-level data.

### day_detail_vm.dart
Resolves:
- eventIds → EventEntity list
- astrology → structured cards
- language-safe fields

---

# 10. Astrology System

Raw input:
```
Map<String, AstroItemEntity>
```

Structured output:
```
List<AstrologyCard>
```

AstrologyEngine responsibilities:
- Map raw key → readable title
- Map raw status → enum
- Provide typed card model

UI must NOT re-interpret astrology statuses.

---

# 11. Language System

Managed via Riverpod.
Persisted with SharedPreferences.

Screens must read:
```
final language = ref.watch(languageProvider);
```

Language fallback rule:
- Prefer Tibetan field when BO selected
- Fallback to English if null

---

# 12. Theme System

All visual tokens centralized.

### AppColors
Defines:
- background
- surface
- text
- accent
- astrology status colors

### AppSpacing
4pt grid spacing system.

No hardcoded color or spacing values in feature files.

---

# 13. Error Handling Strategy

Current:
- JSON errors throw exceptions
- Missing assets cause Flutter runtime errors

Future production hardening may include:
- Graceful fallback screens
- Logging integration
- Crash reporting

---

# 14. Navigation Flow

```
CalendarScreen
    ↓ tap day
DayDetailScreen

AppShell handles bottom navigation.
```

---

# 15. Known Extension Points

Planned enhancements:
1. Swipe month animation (PageView)
2. Group events by month
3. Structured astrology popup model
4. Full ARB localization
5. Replace local JSON with remote API
6. Offline caching strategy

Architecture already supports these changes.

---

# 16. Developer Contract

UI developers may:
- Redesign layouts
- Add animations
- Modify spacing via AppSpacing
- Modify colors via AppColors
- Rebuild AstrologySection visuals

UI developers must NOT:
- Parse JSON
- Access repositories directly
- Map astrology statuses manually

---

# 17. Running the App

Install:
```
flutter pub get
```

Run:
```
flutter run
```

If language persistence is enabled:
```
flutter pub add shared_preferences
```

---

## Maintainer Note

This repository represents the scalable technical backbone of Nyingma Calendar.  
All new features should respect the current layer boundaries and separation principles.