# Security Setup Guide

## 🚨 IMMEDIATE ACTION REQUIRED

### 1. Remove Exposed API Keys from Git History

Your `google-services.json` contains API keys that are now in git history. Follow these steps:

```bash
# Option 1: Using BFG Repo-Cleaner (recommended)
# Download from: https://rtyley.github.io/bfg-repo-cleaner/
java -jar bfg.jar --delete-files google-services.json
git reflog expire --expire=now --all && git gc --prune=now --aggressive

# Option 2: Using git filter-branch
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch android/app/google-services.json" \
  --prune-empty --tag-name-filter cat -- --all
```

### 2. Regenerate Firebase API Keys

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Go to Project Settings > General
4. Delete the current Android app
5. Re-add the Android app with new configuration
6. Download new `google-services.json`

### 3. Set Up Environment-Specific Configurations

Create separate Firebase projects:
- `smart-tag-dev` (development)
- `smart-tag-staging` (testing)
- `smart-tag-prod` (production)

Store configuration files outside git:
```
/secure-config/
  ├── dev/
  │   ├── google-services.json
  │   └── GoogleService-Info.plist
  ├── staging/
  │   ├── google-services.json
  │   └── GoogleService-Info.plist
  └── prod/
      ├── google-services.json
      └── GoogleService-Info.plist
```

### 4. Configure Firebase Security Rules

**Firestore Rules** (Firebase Console > Firestore Database > Rules):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Livestock data - user must be authenticated and own the farm
    match /livestock/{docId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow write: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
    
    // IoT tag data - authenticated users only
    match /iot_tags/{tagId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
  }
}
```

**Realtime Database Rules** (Firebase Console > Realtime Database > Rules):
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "iot_data": {
      "$tagId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

### 5. Enable App Check (Recommended)

Protect your Firebase resources from abuse:

1. Go to Firebase Console > App Check
2. Enable App Check for your apps
3. Add to your Flutter app:

```yaml
# pubspec.yaml
dependencies:
  firebase_app_check: ^0.2.1+0
```

```dart
// lib/main.dart
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );
  
  runApp(MyApp());
}
```

### 6. Secure API Keys in Code

Never hardcode API keys. Use environment variables or secure storage:

```dart
// Use flutter_dotenv for environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['API_KEY'];
}
```

### 7. Additional Security Measures

- Enable 2FA for all Firebase/Google Cloud accounts
- Restrict API keys to specific apps/domains in Google Cloud Console
- Set up billing alerts to detect unusual usage
- Regularly audit Firebase Authentication users
- Enable Firebase Security Monitoring
- Use HTTPS only for all network requests
- Implement certificate pinning for critical APIs

## Monitoring

Set up alerts for:
- Unusual authentication attempts
- Spike in API usage
- Failed security rule violations
- Unauthorized access attempts
