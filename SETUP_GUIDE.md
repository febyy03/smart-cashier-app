# Smart Cashier - Complete Setup Guide

## Quick Start

### 1. Install Flutter Dependencies
```bash
flutter pub get
```

### 2. Configure Firebase

#### Option A: Using FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure your project
flutterfire configure
```

This will automatically:
- Create a Firebase project (or select existing)
- Register your Flutter app
- Download configuration files
- Generate `lib/firebase_options.dart`

#### Option B: Manual Configuration

1. Create a Firebase project at https://console.firebase.google.com/
2. Add your Flutter app to the project
3. Download configuration files:
   - `google-services.json` → Place in `android/app/`
   - `GoogleService-Info.plist` → Place in `ios/Runner/`
4. Update `lib/services/firebase_service.dart` with your credentials

### 3. Enable Firebase Services

In Firebase Console:

**Authentication:**
- Navigate to Authentication → Sign-in method
- Enable "Email/Password" provider

**Firestore Database:**
- Navigate to Firestore Database
- Click "Create database"
- Choose "Start in test mode"
- Select your preferred region

**Cloud Storage:**
- Navigate to Storage
- Click "Get started"
- Choose "Start in test mode"

### 4. Run the App
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## Firebase Configuration Details

### Update Firebase Service

If using manual configuration, edit `lib/services/firebase_service.dart`:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_API_KEY',              // From Firebase Console
    appId: 'YOUR_APP_ID',                // From Firebase Console
    messagingSenderId: 'YOUR_SENDER_ID', // From Firebase Console
    projectId: 'YOUR_PROJECT_ID',        // From Firebase Console
    storageBucket: 'YOUR_BUCKET',        // From Firebase Console
  ),
);
```

### Production Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAdmin() || request.auth.uid == userId;
    }
    
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAdmin();
    }
    
    match /categories/{categoryId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAdmin();
    }
    
    match /transactions/{transactionId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAdmin();
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Testing the App

### Create Test Accounts

1. Run the app
2. Click "Register"
3. Create an admin account:
   - Name: Admin User
   - Email: admin@test.com
   - Password: admin123
   - Role: Admin

4. Create a cashier account:
   - Name: Cashier User
   - Email: cashier@test.com
   - Password: cashier123
   - Role: Cashier

### Initial Data Setup

After creating admin account, you can:
1. Add product categories
2. Add products with images
3. Test transactions
4. View reports

## Troubleshooting

### Firebase Connection Issues
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Rebuild the app
flutter run
```

### Android Build Issues
```bash
# Update Android dependencies
cd android
./gradlew clean
cd ..
flutter run
```

### iOS Build Issues
```bash
# Update CocoaPods
cd ios
pod install
cd ..
flutter run
```

### Common Errors

**Error: "Firebase not initialized"**
- Solution: Ensure `FirebaseService.initialize()` is called in `main()`

**Error: "Permission denied"**
- Solution: Check Firestore security rules
- Ensure user is authenticated

**Error: "Storage upload failed"**
- Solution: Check Storage security rules
- Verify storage bucket name in configuration

## Development Tips

### Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart

### Debug Mode
```bash
flutter run --debug
```

### Release Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Check for Issues
```bash
flutter doctor
flutter analyze
```

## Next Steps

After successful setup:

1. ✅ Test authentication flow
2. ✅ Verify Firebase connection
3. 📝 Implement product management
4. 📝 Build transaction system
5. 📝 Add AI recommendations
6. 📝 Create reports dashboard
7. 📝 Implement dark mode
8. 📝 Add barcode scanner

## Support

For issues:
1. Check this guide
2. Review Firebase Console logs
3. Check Flutter logs: `flutter logs`
4. Open an issue on GitHub

---

**Current Status**: Phase 1 Complete - Authentication & Foundation Setup ✅