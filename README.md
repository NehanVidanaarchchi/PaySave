# PaySave – Personal Finance Planner App

PaySave is a premium Flutter mobile app for personal finance planning. It helps users plan monthly income, track bills, manage expenses, set saving goals, and create installment reminders.

> **Note:** PaySave is a planning and reminder app only. It does **not** transfer money, connect to bank accounts, process payments, or store real wallet balances.

---

## Overview

PaySave is designed for users who want a simple way to control monthly spending and avoid missing important payments.

Users can manually enter their monthly income, expenses, bills, saving goals, and installment plans. The app calculates the remaining balance and daily safe spending amount, helping users understand how much they can safely spend each day.

---

## Key Features

- Firebase Authentication login and registration
- Monthly income and budget planning
- Remaining balance calculation
- Daily safe spending calculation
- Bill reminders with due dates
- Installment payment reminders
- Saving goal tracking
- Expense tracking
- Premium dark mobile UI
- Local notification support
- Firebase Firestore cloud database
- Profile and settings pages
- App icon and image assets support

---

## What PaySave Does Not Do

PaySave is not a banking app or payment app.

It does not:

- Transfer money
- Send or receive money
- Connect to bank accounts
- Store real wallet balances
- Process online payments
- Provide investment advice

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile app development |
| Dart | Main programming language |
| Firebase Core | Firebase initialization |
| Firebase Authentication | User login and registration |
| Cloud Firestore | User data storage |
| Firebase Storage | Optional image/file storage |
| Provider | State management |
| Flutter Local Notifications | Bill and installment reminders |
| Timezone | Notification scheduling support |
| fl_chart | Charts and analytics UI |
| intl | Currency and date formatting |
| connectivity_plus | Internet connection checking |
| shared_preferences | Local app preferences |
| flutter_launcher_icons | App icon generation |

---

## Main App Modules

### Authentication
Users can register, login, reset their password, and logout.

### Home Dashboard
Shows the monthly overview, remaining balance, daily safe spending, quick actions, and upcoming reminders.

### Monthly Planner
Allows users to enter monthly income, rent, bills budget, saving target, and other budget categories.

### Bills
Users can add bills, set due dates, set reminder times, and mark bills as paid or unpaid.

### Installments
Users can create installment plans, track payment progress, and receive payment reminders.

### Savings
Users can create saving goals and track progress toward each goal.

### Expenses
Users can manually add expenses and monitor spending.

### Settings and Profile
Users can view account details, app information, and logout.

---

## Folder Structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── app_routes.dart
│   └── app_theme.dart
├── core/
│   ├── constants/
│   ├── helpers/
│   ├── services/
│   └── widgets/
├── data/
│   ├── firebase/
│   ├── models/
│   └── repositories/
├── features/
│   ├── auth/
│   ├── bills/
│   ├── expenses/
│   ├── home/
│   ├── installments/
│   ├── onboarding/
│   ├── planner/
│   ├── saving/
│   ├── settings/
│   └── splash/
└── providers/
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/NehanVidanaarchchi/PaySave.git
cd PaySave
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Install Firebase CLI and FlutterFire CLI if needed:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

Login to Firebase:

```bash
firebase login
```

Configure Firebase:

```bash
flutterfire configure
```

Select your Firebase project and Android platform.

The setup should generate:

```text
lib/firebase_options.dart
android/app/google-services.json
```

### 4. Run the app

```bash
flutter run
```

---

## Important Setup Notes

Make sure your Android application ID matches the Firebase Android app.

Current package name:

```text
com.example.pay_save
```

If you change the package name, update it in:

```text
android/app/build.gradle.kts
Firebase Console
flutterfire configure
```

---

## App Icon and Assets

Assets are stored inside:

```text
assets/images/
```

Example `pubspec.yaml` setup:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/
```

To generate launcher icons, run:

```bash
dart run flutter_launcher_icons
```

---

## Project Purpose

This project was built as a portfolio-ready Flutter mobile app to demonstrate:

- Flutter UI development
- Firebase Authentication
- Firestore database design
- Provider state management
- Local notification scheduling
- Clean project structure
- Real-world finance planning features
- Mobile app publishing readiness

---

## Developer

**PaySave App**  
Built with Flutter and Firebase.

---
