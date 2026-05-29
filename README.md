# Sparkle Lite

A Flutter-based Women & Family Health Companion that helps users track periods, symptoms, health records, and doctor visits while providing AI-assisted health insights.

## Features

### 📱 Mobile App
- User Authentication (Login / Signup)
- Interactive Onboarding
- Health Profile Setup
- Dashboard with Quick Actions
- Period Tracking
- Symptom Logging
- Health Records Management
- Health Timeline
- AI-Powered Health Insights
- Doctor Visit Summary Generator
- Family Profile Management
- Privacy & Notification Settings
- Profile Management
- Dark/Light Theme Support

### 🌐 Web Dashboard
- Responsive Dashboard
- Health Records Manager
- Timeline History
- Doctor Summary View
- Appearance & Privacy Settings

---

## 🛠️ Tech Stack

| Category | Technology |
|-----------|------------|
| Framework | Flutter 3.22 |
| Language | Dart 3.4 |
| State Management | Riverpod |
| Navigation | go_router |
| Backend | Firebase |
| Database | Firestore |
| Storage | Firebase Storage |
| Local Storage | SharedPreferences |

---

## Supported Platforms

- 🤖 Android
- 🍎 iOS
- 🌐 Web

---

## 🏗️ Project Architecture

- Feature-first folder structure
- Repository Pattern
- Riverpod State Management
- Firebase-ready services
- Responsive UI architecture
- Reusable widgets and utilities

---

## 🔧 Installation

### Prerequisites

- Flutter SDK 3.22+
- Dart SDK 3.4+
- Android Studio or VS Code
- Chrome (for web development)

### 📥 Clone Repository

```bash
git clone https://github.com/yourusername/sparkle_lite.git
cd sparkle_lite
```

### 📦 Install Dependencies

```bash
flutter pub get
```

### ▶️ Run Application

#### 🤖 Mobile

```bash
flutter run
```

#### 🌐  Web

```bash
flutter run -d chrome
```

---

## 🔥 Firebase Configuration (Optional)

Sparkle Lite supports both Mock Services and Firebase.

### Steps

1. Create a Firebase Project
2. Enable Authentication
3. Enable Firestore
4. Enable Firebase Storage
5. Add platform configuration files
6. Run:

```bash
flutterfire configure
```

### Android

Place:

```text
android/app/google-services.json
```

### iOS

Place:

```text
ios/Runner/GoogleService-Info.plist
```

---

## 📱 Responsive Design

| Device | Width | Layout |
|----------|---------|---------|
| Mobile | < 600px | Bottom Navigation |
| Tablet | 600px - 1200px | Sidebar Layout |
| Desktop | > 1200px | Multi-Column Dashboard |

---

## 🔒 Privacy Features

- Health information hidden from notifications
- Separate family and personal data management
- Educational AI insights (non-diagnostic)
- Firebase security rules for user isolation

---

## 🧪 Testing

Run all tests:

```bash
flutter test
```

Run coverage:

```bash
flutter test --coverage
```

Run a specific test:

```bash
flutter test test/unit/example_test.dart
```

---

## 📦 Build

### 🤖 Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### 🍎 iOS

```bash
flutter build ios --release
```

### 🌐 Web

```bash
flutter build web --release
```

---

## Deployment

### Netlify

```bash
flutter build web
netlify deploy --prod
```

---

## 📁 Project Structure

```text
sparkle_lite/
│
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── interfaces/
│   │   └── services/
│   │
│   ├── data/
│   │   ├── models/
│   │   └── repositories/
│   │
│   ├── providers/
│   │
│   ├── routing/
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   └── utils/
│   │
│   └── features/
│
├── test/
├── web/
├── android/
├── ios/
├── linux/
├── macos/
├── windows/
│
├── pubspec.yaml
└── README.md
```

---

## 🎯 Key Technical Decisions

| Decision | Reason |
|-----------|---------|
| Riverpod | Scalable and testable state management |
| go_router | Declarative navigation and web support |
| Repository Pattern | Better separation of concerns |
| Firebase | Fast backend integration |
| Responsive Utilities | Consistent experience across devices |
| Feature-Based Structure | Easier maintenance and scalability |

---

## 🚧 Future Enhancements

- Push Notifications
- Offline Support
- PDF Export for Doctor Summaries
- CI/CD Pipeline
- Accessibility Improvements
- Advanced Health Analytics

---

## 📝 License

This project is licensed under the UnKnown License.

---

## 👩‍💻 Author

**Priyanshu Kumar**  
Flutter Developer | Mobile & Web Applications

---

## 🙏 Acknowledgements

- Flutter
- Firebase
- Riverpod
- Material 

---

Built with ❤️ Flutter for modern healthcare experiences.