# Campus Connect - Setup Guide

## ✅ Files Written
All Flutter source code is complete. Here's what was created:

```
campus_connect/
├── pubspec.yaml                    ← Dependencies
├── android/app/src/main/
│   └── AndroidManifest.xml         ← Permissions + Google Sign-In
└── lib/
    ├── main.dart                   ← App entry point
    ├── firebase_options.dart       ← YOUR CREDENTIALS GO HERE
    ├── models/
    │   ├── book_model.dart
    │   └── gate_info_model.dart
    ├── services/
    │   ├── auth_service.dart       ← Firebase Auth (Email + Google)
    │   ├── firestore_service.dart  ← Firestore + seed data
    │   ├── chat_service.dart       ← Gemini AI chatbot
    │   └── bookmark_service.dart   ← Local bookmarks
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── login_screen.dart
    │   ├── main_navigator.dart     ← Bottom nav shell
    │   ├── home_screen.dart        ← Dashboard
    │   ├── chatbot_screen.dart     ← Library AI Chat
    │   ├── gate_screen.dart        ← GATE info + countdown
    │   ├── library_screen.dart     ← Book catalog
    │   └── bookmarks_screen.dart
    ├── widgets/
    │   └── gradient_card.dart
    ├── utils/
    │   └── app_theme.dart          ← Dark theme design system
    └── scripts/
        └── seed_firestore.dart     ← One-time DB seed script
```

---

## 🚀 Step-by-Step Setup

### Step 1 — Flutter SDK Installation
The Flutter 3.29.3 SDK is downloading in the background via BITS Transfer (~1 GB).

**Monitor progress in PowerShell:**
```powershell
$job = Get-BitsTransfer | Where-Object {$_.DisplayName -eq "BITS Transfer"} | Select-Object -First 1
Write-Host "$([math]::Round($job.BytesTransferred/1MB,1)) MB / $([math]::Round($job.BytesTotal/1MB,1)) MB"
```

**Once complete, extract and set up PATH:**
```powershell
# 1. Extract SDK
Expand-Archive "$env:USERPROFILE\flutter_sdk.zip" -DestinationPath "C:\flutter" -Force

# 2. Add to PATH permanently
$flutterPath = "C:\flutter\flutter\bin"
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
[System.Environment]::SetEnvironmentVariable("PATH", "$currentPath;$flutterPath", "User")

# 3. Restart terminal, then verify
flutter --version
flutter doctor
```

---

### Step 2 — Firebase Setup (FREE)

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **"Add project"** → Name it `campus-connect`
3. Enable **Firestore Database** → Start in test mode
4. Enable **Authentication** → Email/Password + Google

**Install FlutterFire CLI and configure:**
```powershell
cd C:\Users\panda\OneDrive\Desktop\hcktn\campus_connect

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# This auto-generates firebase_options.dart with your real credentials
flutterfire configure
```

---

### Step 3 — Add Gemini API Key

1. Get a free key from [aistudio.google.com/apikey](https://aistudio.google.com/apikey)
2. Open `lib/services/chat_service.dart`
3. Replace `YOUR_GEMINI_API_KEY` with your key

---

### Step 4 — Install Dependencies & Run

```powershell
cd C:\Users\panda\OneDrive\Desktop\hcktn\campus_connect

flutter pub get
flutter run
```

---

### Step 5 — Seed the Database (Run Once)

After the app runs successfully, call this from the login screen
or run it in a test to populate Firestore with all books and GATE data:

The `FirestoreService().seedBooksData()` and `seedGateData()` methods
are ready — just call them once from the app or Dart console.

---

## 🎨 Design System

| Color | Usage |
|-------|-------|
| `#6C63FF` (Purple) | Primary, buttons, chatbot |
| `#00D9A5` (Teal) | GATE section, success states |
| `#FF6B6B` (Red) | Alerts, accent |
| `#FFD93D` (Yellow) | Search, warnings |
| `#0D0E1A` | Dark background |
| `#161829` | Card background |

## 📱 App Features Summary

- 🔐 **Auth** — Email/password + Google Sign-In via Firebase
- 🏠 **Dashboard** — 4 quick-access cards + hero banner
- 🤖 **AI Chatbot** — Gemini-powered library assistant with book context
- 📚 **Library** — Live Firestore catalog, availability filter, bookmarks
- 🎓 **GATE** — 6 branch cards, real-time countdown, detail view
- 🔖 **Bookmarks** — Offline-first via SharedPreferences
- 🔍 **Search** — Full-text book search from home screen
