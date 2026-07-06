# PaySave – Personal Finance Planner App

PaySave is a premium personal finance planner mobile app built with **Flutter** and **Firebase**.  
It helps users plan monthly income, track bills, manage expenses, set saving goals, and create installment reminders.

> PaySave is a planning and reminder app only. It does **not** transfer money, connect to bank accounts, process payments, or store wallet balances.

---

## App Overview

PaySave is designed for users who want a simple way to control monthly spending and avoid missing important payments.

Users can manually enter their income, expenses, bills, saving goals, and installment plans. The app then calculates the remaining balance and daily safe spending amount.

---

## Key Features

- User registration and login with Firebase Authentication
- Monthly income and budget planning
- Remaining balance calculation
- Daily safe spending calculation
- Bill reminders with due dates
- Installment payment reminders
- Saving goal tracking
- Expense tracking
- Premium dark UI design
- Firebase Firestore cloud database
- Local notification support
- Profile and settings pages
- Mobile responsive Flutter UI

---

## What PaySave Does Not Do

PaySave is not a banking or payment app.

It does not:

- Transfer money
- Send money
- Receive money
- Connect to bank accounts
- Store real wallet balance
- Process online payments
- Provide financial investment advice

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile app development |
| Dart | Programming language |
| Firebase Authentication | User login and registration |
| Cloud Firestore | Cloud database |
| Firebase Storage | Optional file/image storage |
| Provider | State management |
| flutter_local_notifications | Local reminders |
| fl_chart | Charts and reports |
| intl | Currency and date formatting |
| connectivity_plus | Internet connection checking |

---

## Main App Modules

### Authentication
Users can register, login, reset password, and logout.

### Home Dashboard
Shows monthly overview, remaining balance, daily safe spending, quick actions, and upcoming reminders.

### Monthly Planner
Users can enter income, rent, bills budget, savings target, and other spending categories.

### Bills
Users can add bills, set due dates, set reminder times, and mark bills as paid or unpaid.

### Installments
Users can add installment plans, track payment progress, and receive reminders.

### Savings
Users can create saving goals and track progress toward each goal.

### Expenses
Users can manually add expenses and monitor spending.

### Settings and Profile
Users can view account information and logout.

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

## Firebase Structure

```text
users/{uid}
users/{uid}/monthlyPlans/{planId}
users/{uid}/bills/{billId}
users/{uid}/installments/{installmentId}
users/{uid}/savings/{savingGoalId}
users/{uid}/expenses/{expenseId}
```

---

## Firestore Rules

Use these rules for user-protected data:

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      match /{document=**} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
  }
}
```

---

## Android Permissions

PaySave uses local notifications for bill and installment reminders.

Required Android permissions:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/pay_save.git
cd pay_save
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

Make sure your Android application ID matches Firebase:

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

Assets should be placed inside:

```text
assets/images/
```

Example `pubspec.yaml` asset setup:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/
```

---

## Screenshots

Add screenshots here after uploading them to GitHub.

```text
screenshots/home.png
screenshots/planner.png
screenshots/bills.png
screenshots/savings.png
screenshots/settings.png
```

Example:

```md
![Home Screen](screenshots/home.png)
```

---

## Future Improvements

- Monthly analytics dashboard
- Export reports as PDF
- More chart visualizations
- Custom categories
- Cloud backup improvements
- Reminder repeat customization
- Better offline support

---

## Project Purpose

This project was built as a portfolio-ready Flutter mobile app to demonstrate:

- Flutter UI development
- Firebase Authentication
- Firestore database design
- State management using Provider
- Clean project structure
- Real-world finance planning features
- Mobile app publishing readiness

---

## Developer

**PaySave App**  
Built with Flutter and Firebase.

---

## License

This project is for educational and portfolio use.  
You can update this section based on your preferred license.
