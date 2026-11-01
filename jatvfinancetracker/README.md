# JATV Finance Tracker

A cross-platform personal finance tracker built with Flutter and Firebase. It brings transaction logging, budgeting, goal-based savings, and family-shared expenses together behind a single themable, multilingual interface.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web-informational)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Firestore Collections](#firestore-collections)
- [Getting Started](#getting-started)
- [Localization](#localization)
- [Theming](#theming)
- [Team](#team)

---

## Overview

JATV Finance Tracker lets a user capture their day-to-day spending and income, set financial goals, keep budgets per category, and optionally share a household budget with family members. The app runs from a single Flutter codebase and uses Firebase Authentication for identity and Cloud Firestore as the real-time data store.

## Features

### Authentication & Account

- Email / password sign-up and sign-in via Firebase Auth
- Email verification flow with auto-polling (`sendEmailVerification` + `user.reload()`)
- Password reset by email (`sendPasswordResetEmail`)
- Change-email flow using `verifyBeforeUpdateEmail` so changes only apply after the user confirms the link
- Change-password flow that re-uses the reset-email mechanism
- 2FA scaffolding (toggle in Settings + verification code screen)
- Clean logout flow that also resets the theme to light for the next user

### Transactions

- Add, view, filter, sort, and delete transactions
- Three types: **income**, **expense**, **transfer**
- Per-user categories, auto-created on demand (e.g., a "Savings" category appears the first time a goal contribution is logged)
- Rich filter sheet (by type, by date range)
- Rich sort sheet (newest / oldest / highest amount / lowest amount)
- Date-range presets (This month, Last month, Last 7/30 days, All time)
- Transaction history page with pull-to-refresh and search

### Goals

- Create savings/debt/retirement/emergency goals with target amount and deadline
- Contribution flow — adding to a goal **auto-creates a `transfer` transaction** in the Savings category, keeping the audit trail honest
- Withdrawal flow — decreasing a goal prompts the user to clarify whether it's a **withdrawal** (logs a reverse transaction) or a **correction** (silent update)
- Insight messages ("At your current rate you'll reach your goal in X months")
- Visual progress bars and completed-goals section

### Budgets

- Weekly / monthly / yearly budgets per category
- Progress bar per budget with "near limit" and "over budget" states
- Aggregated "Total Budget This Month" card with overall spend indicator
- Alert banner when approaching limits
- Full-screen "all budgets" sheet when a user has many categories

### Family Plan

- Create a family group with a shared budget and personal allocations per member
- Add members by email lookup; identify admins
- Log shared expenses with per-person split
- Family insights card
- Multiple families per user supported

### Money Flow (Analytics)

- Overview tab with 6-month trend bar chart (income vs. expenses)
- Separate Income and Expense tabs with per-category breakdowns
- Net cash-flow card with positive/negative gradient and encouraging/warning message
- All amounts formatted with grouping

### Personalization

- **Dark mode** — centralized `ThemeController` + `AppTheme`, flips every main surface instantly
- **7 languages** — English, French, Spanish, German, Chinese, Japanese, Vietnamese — pickable in Settings, persisted per user
- Edit profile (first name, last name, email with verify-before-update)
- Change password via secure reset email

### Infrastructure

- Shared **`AppBottomNavBar`** widget used across all main pages
- **`appRouteObserver`** so pages like Home can auto-refresh when they become visible again
- MVVM separation — Models are pure data, Repositories wrap Firestore, ViewModels drive the UI via `ChangeNotifier`

---

## Tech Stack

| Layer | Choice |
|---|---|
| **UI Framework** | Flutter 3.x (Material 2) |
| **Language** | Dart 3.x |
| **Auth** | Firebase Authentication |
| **Database** | Cloud Firestore (NoSQL, document-based) |
| **State Management** | `ChangeNotifier` + `ListenableBuilder` (per-page view-models) |
| **Charts** | `fl_chart` |
| **Icons** | Material Icons (built in) |
| **Env Config** | `flutter_dotenv` |
| **IDs** | `uuid` |

See [`pubspec.yaml`](pubspec.yaml) for exact version constraints.

---

## Architecture

The app follows a clean **MVVM** split:

```
┌─────────────────────────────────────────────┐
│  View          (Flutter widgets / Screens)  │  listens to
│  ──────────────────────────────────────────  │  ViewModel
│  ViewModel     (ChangeNotifier)             │  calls
│  ──────────────────────────────────────────  │  Repository
│  Repository    (Firebase SDK wrapper)       │  reads/writes
│  ──────────────────────────────────────────  │  Firestore
│  Model         (plain Dart data classes)    │
└─────────────────────────────────────────────┘
```

**Rules of the layers**

- **Views** never touch Firestore directly — they only read from a ViewModel.
- **ViewModels** hold UI state (loading flags, errors, cached lists) and call repositories.
- **Repositories** map Firestore documents to typed Dart classes so ViewModels never see raw maps.
- **Models** are plain data: `User`, `Transaction`, `Goal`, `Categorie`, `Budget`, `UserSettings`, `FamilyMember`, `SharedExpense`.

---

## Project Structure

```
lib/
├── Model/              # Plain data classes
├── Repository/         # Firestore + Firebase Auth wrappers
├── viewModel/          # ChangeNotifier classes per feature
├── view/               # Pages and sheets
│   └── widgets/        # Shared widgets (AppBottomNavBar, …)
├── util/               # ThemeController, LanguageController,
│                       # AppLocalizations, AppRouteObserver, AppTheme
├── helper/             # Enums (TransactionType, GoalType, …)
├── config/             # FirebaseConfig
└── main.dart           # App entry point
```

---

## Firestore Collections

| Collection | Model | Key fields |
|---|---|---|
| `users` | `User` | `userID`, `firstName`, `lastName`, `email` |
| `transactions` | `Transaction` | `type`, `amount`, `date`, `categoryID`, `goalID?` |
| `categories` | `Categorie` | `categoryName`, `type` |
| `budgets` | `Budget` | `budgetName`, `amount`, `period`, `categoryID` |
| `goals` | `Goal` | `goalName`, `goalAmount`, `currentAmount`, `targetDate` |
| `userSettings` | `UserSettings` | `darkMode`, `twoFactorEnabled`, `language` |
| `familyGroups` | `FamilyGroup` | `groupName`, `totalBudget`, `adminUserID` |
| `familyMembers` | `FamilyMember` | `userID`, `displayName`, `budgetAllocation` |
| `sharedExpenses` | `SharedExpense` | `name`, `amount`, `paidByUserID`, `categoryIcon` |

### Composite indexes required

Some queries filter by `userID` and sort by another field — Firestore needs a composite index for each. The first time you run them, the console error gives you a one-click link to create them:

- `transactions`: `userID` ASC + `date` DESC
- `goals`: `userID` ASC + `targetDate` ASC
- `budgets`: `userID` ASC + any sort field used

---

## Getting Started

### Prerequisites

- Flutter SDK 3.11.0+
- A Firebase project with **Authentication (Email/Password)** and **Firestore** enabled
- Android Studio / Xcode / a Chrome install for development

### 1. Clone and install

```bash
git clone https://github.com/Thevinh0207/finance-tracker-App-dev-2.git
cd finance-tracker-App-dev-2/jatvfinancetracker
flutter pub get
```

### 2. Firebase configuration

Register an Android app in Firebase Console using the package name:

```
com.example.jatvfinancetracker
```

Download `google-services.json` and place it at:

```
android/app/google-services.json
```

For iOS, do the same with `GoogleService-Info.plist` in `ios/Runner/`.

### 3. Environment variables

Create a `.env` file at the project root (loaded by `flutter_dotenv`). The app reads Firebase options from there via `FirebaseConfig`. See [`lib/config/FirebaseConfig.dart`](lib/config/FirebaseConfig.dart) for which keys are expected.

### 4. Run

```bash
flutter run
```

Pick a device from the Flutter device picker (emulator, physical phone, or Chrome).

### Common pitfalls

- **"No matching client found for package name" at build time** → `google-services.json` doesn't contain the current `applicationId`. Re-download it after registering the app in Firebase Console.
- **"The query requires an index"** at runtime → click the URL in the error; it opens the Firestore console pre-filled with the composite index you need.
- **Pigeon channel errors on Android** → make sure `firebase_core`, `firebase_auth`, and `cloud_firestore` are pinned to compatible versions in `pubspec.yaml`.

---

## Localization

The app ships with 7 languages. All UI strings go through a single lookup function:

```dart
Text(AppLocalizations.tr('home_welcome'))
```

Adding a language is three steps:

1. Add a new `_xx` map to [`lib/util/AppLocalizations.dart`](lib/util/AppLocalizations.dart) with the same keys as `_en`.
2. Register it in the `_languages` map at the top of the file.
3. Add its display name to the dropdown in `ProfileSettingsPage`.

Missing keys fall back to English, then to the raw key — the app never crashes on partial translations.

---

## Theming

Dark mode is a single toggle in Settings:

- A global [`ThemeController`](lib/util/ThemeController.dart) (`ChangeNotifier`) holds the current mode.
- The root `MaterialApp` listens to it via `ListenableBuilder` and picks `AppTheme.light` or `AppTheme.dark` from [`AppTheme.dart`](lib/util/AppTheme.dart).
- Pages read colors through `Theme.of(context)` so switching themes is instant and app-wide.

Brand colors stay constant across both themes (blue `#4A90D9`, income green, expense red) — only surfaces and text colors flip.

---

## Team

| Developer | Email |
|---|---|
| **The Vinh Vuong** | vuongthevinh07@gmail.com |
| **James Luciano** | — |

Built as a group project for software-engineering coursework.

---

## License

Private student project — not currently published under an open-source license.
