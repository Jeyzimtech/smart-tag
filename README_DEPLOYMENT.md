# Ceres Tag Monitor - Smart Livestock Management

A Flutter application for managing smart livestock tags with real-time tracking, health monitoring, and geofencing capabilities.

## Features

- 🐄 Livestock management and tracking
- 📍 Real-time GPS location monitoring
- 🔔 Smart alerts and notifications
- 📊 Health and activity analytics
- 🗺️ Geofencing and boundary alerts
- 📱 IoT tag pairing and management
- 🤖 AI-powered chatbot assistance
- 📈 Comprehensive reporting

## Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / Xcode
- Firebase account
- Physical IoT tags (for full functionality)

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd smart-tag-master
flutter pub get
```

### 2. Firebase Configuration

1. Create Firebase projects (dev, staging, prod)
2. Download configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
3. **IMPORTANT**: Never commit these files to git

### 3. Configure Firebase Security Rules

See `SECURITY_SETUP.md` for detailed instructions.

### 4. Android Setup

1. Update application ID in `android/app/build.gradle.kts`
2. Generate release keystore:
```bash
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```
3. Create `android/key.properties` (use `key.properties.template`)
4. Update signing configuration in build.gradle.kts

### 5. iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing with your Apple Developer account
3. Update bundle identifier
4. Set up provisioning profiles

## Running the App

### Development
```bash
flutter run
```

### Release Build
```bash
# Android
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# iOS
flutter build ios --release --obfuscate --split-debug-info=build/ios/outputs/symbols
```

## Project Structure

```
lib/
├── core/           # Theme, constants, utilities
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # Business logic, API calls
└── widgets/        # Reusable components
```

## Security Considerations

⚠️ **CRITICAL**: Before deploying to production:

1. Remove all API keys from git history
2. Set up environment-specific configurations
3. Configure Firebase Security Rules
4. Enable Firebase App Check
5. Use proper release signing

See `SECURITY_SETUP.md` for complete security checklist.

## Deployment

Follow the comprehensive checklist in `DEPLOYMENT_CHECKLIST.md` before releasing to production.

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Troubleshooting

### Bluetooth Issues
- Ensure location permissions are granted
- Check that Bluetooth is enabled
- Verify IoT tags are powered on

### Firebase Connection
- Verify google-services.json is in correct location
- Check Firebase project configuration
- Ensure internet connectivity

## Contributing

1. Create feature branch
2. Make changes
3. Run tests and linting
4. Submit pull request

## License

[Add your license here]

## Support

For issues and questions, please contact [your-email@example.com]
