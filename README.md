# 🐄 Ceres Tag Monitor - Smart Livestock Management System

A comprehensive Flutter application for managing smart livestock tags with real-time tracking, health monitoring, and geofencing capabilities.

![Flutter](https://img.shields.io/badge/Flutter-3.9.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)

## 🌟 Features

- **📍 Real-time GPS Tracking** - Monitor livestock location in real-time
- **🐄 Livestock Management** - Comprehensive animal records and profiles
- **🔔 Smart Alerts** - Geofence breaches, health alerts, and notifications
- **📊 Analytics Dashboard** - Health metrics, activity patterns, and insights
- **🗺️ Geofencing** - Set up virtual boundaries and receive alerts
- **📱 IoT Tag Management** - Pair and manage Bluetooth/GSM smart tags
- **🤖 AI Assistant** - AI-powered chatbot for farm management queries
- **📈 Reports** - Generate comprehensive livestock reports
- **☁️ Cloud Sync** - Automatic data synchronization with Firebase

## 📱 Screenshots

[Add screenshots here]

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode
- Firebase account
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/Jeyzimtech/smart-tag.git
cd smart-tag
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - **⚠️ IMPORTANT**: Never commit these files to git

4. **Run the app**
```bash
flutter run
```

## 🔧 Configuration

### Android Setup

1. Update application ID in `android/app/build.gradle.kts` if needed
2. For release builds, generate a keystore:
```bash
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```
3. Create `android/key.properties` using the template provided

### iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing with your Apple Developer account
3. Update bundle identifier

## 🏗️ Project Structure

```
lib/
├── core/              # Core utilities, theme, constants
│   └── theme/         # App theme and colors
├── models/            # Data models
├── providers/         # State management (Provider)
├── screens/           # UI screens
│   ├── auth/          # Authentication screens
│   ├── dashboard/     # Dashboard components
│   ├── livestock/     # Livestock management
│   ├── reports/       # Reporting screens
│   └── settings/      # Settings screens
├── services/          # Business logic and services
│   ├── auth_service.dart
│   ├── database_helper.dart
│   ├── iot_tag_service.dart
│   └── sync_service.dart
└── widgets/           # Reusable widgets
    ├── common/
    ├── dashboard/
    └── livestock/
```

## 🔐 Security

**⚠️ CRITICAL SECURITY NOTES:**

1. **Never commit sensitive files:**
   - `google-services.json`
   - `GoogleService-Info.plist`
   - `key.properties`
   - Any `.keystore` or `.jks` files

2. **Before deployment:**
   - Review `SECURITY_SETUP.md` for comprehensive security guidelines
   - Configure Firebase Security Rules
   - Set up environment-specific configurations
   - Enable Firebase App Check

3. **For detailed security setup**, see [SECURITY_SETUP.md](SECURITY_SETUP.md)

## 📦 Building for Production

### Android
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
# or for app bundle (recommended for Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### iOS
```bash
flutter build ios --release --obfuscate --split-debug-info=build/ios/outputs/symbols
```

## 📋 Deployment Checklist

Before deploying to production, complete all items in [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

Key items:
- [ ] Configure release signing
- [ ] Set up Firebase Security Rules
- [ ] Add app icons and splash screens
- [ ] Test on physical devices
- [ ] Remove debug code
- [ ] Configure crash reporting

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## 🛠️ Technologies Used

- **Flutter** - Cross-platform mobile framework
- **Firebase** - Backend services (Auth, Firestore, Realtime Database)
- **Provider** - State management
- **Flutter Blue Plus** - Bluetooth connectivity
- **Google Maps** - Location services
- **SQLite** - Local database
- **Google Generative AI** - AI chatbot

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- 🚧 Web (partial support)
- 🚧 Desktop (Windows, macOS, Linux)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Jeyzimtech** - [GitHub](https://github.com/Jeyzimtech)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and testers

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: [your-email@example.com]

## 🗺️ Roadmap

- [ ] Add offline mode support
- [ ] Implement push notifications
- [ ] Add multi-language support
- [ ] Integrate weather data
- [ ] Add veterinary appointment scheduling
- [ ] Implement breeding management
- [ ] Add marketplace for livestock

---

**⭐ If you find this project useful, please consider giving it a star!**
