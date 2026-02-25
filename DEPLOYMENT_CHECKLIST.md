# Deployment Checklist

## ⚠️ CRITICAL - Must Complete Before Production

### 1. Security
- [ ] **REMOVE google-services.json from git history** (use `git filter-branch` or BFG Repo-Cleaner)
- [ ] Move google-services.json to secure location (not in version control)
- [ ] Create separate Firebase projects for dev/staging/production
- [ ] Review and configure Firebase Security Rules
- [ ] Set up environment-specific configurations

### 2. Android Release Signing
- [ ] Generate release keystore: `keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release`
- [ ] Create `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=release
storeFile=<path-to-keystore>
```
- [ ] Update `android/app/build.gradle.kts` to use release signing config
- [ ] Store keystore securely (NEVER commit to git)

### 3. iOS Configuration
- [ ] Configure signing in Xcode with valid Apple Developer account
- [ ] Set up provisioning profiles
- [ ] Update bundle identifier to match your Apple Developer account

### 4. App Store Preparation
- [ ] Create app icons (Android: 512x512, iOS: 1024x1024)
- [ ] Add launcher icons using `flutter pub run flutter_launcher_icons`
- [ ] Create splash screen
- [ ] Prepare store listings and screenshots
- [ ] Write privacy policy and terms of service (replace placeholders)

### 5. Testing
- [ ] Test on physical Android devices (multiple versions)
- [ ] Test on physical iOS devices
- [ ] Test Bluetooth connectivity with actual IoT tags
- [ ] Test location/geofencing features
- [ ] Test offline functionality
- [ ] Perform security testing

### 6. Code Quality
- [ ] Run `flutter analyze` and fix all issues
- [ ] Run `flutter test` and ensure all tests pass
- [ ] Add integration tests for critical flows
- [ ] Remove all TODO comments or address them

### 7. Performance
- [ ] Profile app performance
- [ ] Optimize images and assets
- [ ] Test on low-end devices
- [ ] Check app size and optimize if needed

### 8. Monitoring
- [ ] Set up Firebase Crashlytics
- [ ] Configure Firebase Analytics
- [ ] Set up remote config for feature flags

## Build Commands

### Android Release Build
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
# or for app bundle (recommended for Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### iOS Release Build
```bash
flutter build ios --release --obfuscate --split-debug-info=build/ios/outputs/symbols
```

## Post-Deployment
- [ ] Monitor crash reports
- [ ] Monitor user feedback
- [ ] Set up CI/CD pipeline
- [ ] Plan for regular updates and maintenance
