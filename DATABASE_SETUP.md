# Hybrid Database System - Offline & Online

## Architecture

```
Local SQLite (Offline) ←→ Sync Service ←→ Firebase Firestore (Online)
```

## Features

✓ **Offline-First**: All data stored locally in SQLite
✓ **Auto-Sync**: Syncs with Firebase when online
✓ **Conflict Resolution**: Local changes take priority
✓ **Background Sync**: Syncs every 5 minutes automatically

## Database Tables

### 1. livestock
- id (PRIMARY KEY)
- tagId (TEXT)
- breed (TEXT)
- age (INTEGER)
- species (TEXT)
- herd (TEXT)
- status (TEXT) - 'active' or 'deleted'
- dateRegistered (TEXT)
- synced (INTEGER) - 0 = not synced, 1 = synced

### 2. deleted_livestock
- id (PRIMARY KEY)
- tagId (TEXT)
- breed (TEXT)
- category (TEXT)
- reason (TEXT)
- deletedDate (TEXT)
- synced (INTEGER)

### 3. sensor_data
- id (PRIMARY KEY)
- tagId (TEXT)
- latitude (REAL)
- longitude (REAL)
- temperature (REAL)
- humidity (REAL)
- activity (INTEGER)
- timestamp (TEXT)
- synced (INTEGER)

## Usage

### Add Livestock (Offline)
```dart
await DatabaseHelper.instance.insertLivestock({
  'tagId': '1234',
  'breed': 'Holstein',
  'age': 3,
      // Only allow the owner (userId) to read/update/delete documents.
      // For creates, verify the incoming `userId` matches the authenticated uid.
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
  'herd': 'Herd A',
  'dateRegistered': DateTime.now().toIso8601String(),
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
```

      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
```dart
await SyncService().syncToCloud();
```

### Get All Livestock
      allow read, write: if true;
final livestock = await DatabaseHelper.instance.getAllLivestock();
```

## Firebase Setup

1. Enable Firestore in Firebase Console
2. Create collections:
   - `livestock`
   - `deleted_livestock`
   - `sensor_data`
   - `livestock_tags` (for GSM data)

3. Set Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /livestock/{document} {
      allow read, write: if request.auth != null;
    }
    match /deleted_livestock/{document} {
      allow read, write: if request.auth != null;
    }
    match /sensor_data/{document} {
      allow read, write: if request.auth != null;
    }
    match /livestock_tags/{document} {
      allow read, write: if true; // For GSM module access
    }
  }
}
```

## Benefits

1. **Works Offline**: App functions without internet
2. **Data Persistence**: Never lose data
3. **Real-time Sync**: Updates across devices
4. **Backup**: Cloud backup of all records
5. **Scalable**: Handles thousands of records

## Integration

The sync happens automatically:
- On app start
- Every 5 minutes
- When user manually syncs (Settings → Sync Data)
- When adding/updating/deleting livestock

## Testing

1. Add livestock offline
2. Check SQLite database
3. Go online
4. Sync runs automatically
5. Check Firebase Console for data
