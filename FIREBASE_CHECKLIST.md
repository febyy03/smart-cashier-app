# Firebase Setup Checklist

Use this checklist to ensure Firebase is properly configured for Smart Cashier.

## ☐ Firebase Project Setup

- [ ] Created Firebase project at https://console.firebase.google.com/
- [ ] Project name: `smart-cashier` (or your choice)
- [ ] Selected billing plan (Spark/Free is sufficient for development)
- [ ] Noted down Project ID: `________________`

## ☐ Flutter App Registration

- [ ] Added Flutter app to Firebase project
- [ ] Package name: `com.example.flutter_smart_cashier`
- [ ] Downloaded configuration files:
  - [ ] `google-services.json` (Android)
  - [ ] `GoogleService-Info.plist` (iOS)
- [ ] Placed files in correct locations:
  - [ ] `android/app/google-services.json`
  - [ ] `ios/Runner/GoogleService-Info.plist`

## ☐ Firebase Services Enabled

### Authentication
- [ ] Enabled Email/Password sign-in method
- [ ] (Optional) Enabled Google sign-in
- [ ] (Optional) Enabled other providers

### Firestore Database
- [ ] Created Firestore database
- [ ] Selected region: `________________`
- [ ] Started in Test mode (will update rules later)
- [ ] Created collections structure:
  - [ ] `users`
  - [ ] `products`
  - [ ] `categories`
  - [ ] `transactions`
  - [ ] `settings`

### Cloud Storage
- [ ] Enabled Cloud Storage
- [ ] Started in Test mode
- [ ] Created folders:
  - [ ] `products/` (for product images)

## ☐ Security Rules Configured

### Firestore Rules
- [ ] Copied security rules from SETUP_GUIDE.md
- [ ] Published rules in Firebase Console
- [ ] Tested rules with authenticated user
- [ ] Tested rules with unauthenticated user

### Storage Rules
- [ ] Copied storage rules from SETUP_GUIDE.md
- [ ] Published rules in Firebase Console
- [ ] Tested file upload
- [ ] Tested file read

## ☐ App Configuration

- [ ] Installed FlutterFire CLI: `dart pub global activate flutterfire_cli`
- [ ] Ran `flutterfire configure`
- [ ] Generated `lib/firebase_options.dart`
- [ ] Updated `lib/services/firebase_service.dart` with credentials
- [ ] Verified Firebase initialization in `main.dart`

## ☐ Dependencies Installed

- [ ] Ran `flutter pub get`
- [ ] All packages installed successfully
- [ ] No version conflicts

## ☐ Testing

### Authentication Testing
- [ ] App launches without errors
- [ ] Can navigate to Register screen
- [ ] Can create new user account
- [ ] User data saved in Firestore `users` collection
- [ ] Can login with created account
- [ ] Can logout successfully
- [ ] Can reset password (email sent)

### Firebase Connection Testing
- [ ] Check Firebase Console → Authentication → Users
- [ ] Verify test user appears in list
- [ ] Check Firestore → Data
- [ ] Verify user document created
- [ ] Check Firebase Console → Usage
- [ ] Verify API calls are being made

## ☐ Production Readiness (Before Launch)

- [ ] Updated Firestore rules to production mode
- [ ] Updated Storage rules to production mode
- [ ] Enabled App Check (optional but recommended)
- [ ] Set up Firebase Analytics
- [ ] Configured Crashlytics
- [ ] Set up Performance Monitoring
- [ ] Configured budget alerts
- [ ] Backed up Firestore data
- [ ] Tested on real devices
- [ ] Tested offline behavior

## Common Issues & Solutions

### Issue: "Firebase not initialized"
**Solution:**
```dart
// Ensure this is in main.dart before runApp()
await FirebaseService.initialize();
```

### Issue: "Permission denied" in Firestore
**Solution:**
1. Check user is authenticated
2. Verify security rules are published
3. Check user role in Firestore

### Issue: "Storage upload fails"
**Solution:**
1. Check Storage rules
2. Verify bucket name in configuration
3. Check file size limits

### Issue: "google-services.json not found"
**Solution:**
1. Download from Firebase Console
2. Place in `android/app/` directory
3. Run `flutter clean` and rebuild

## Firebase Console URLs

- Project Overview: `https://console.firebase.google.com/project/YOUR_PROJECT_ID`
- Authentication: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication`
- Firestore: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore`
- Storage: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/storage`
- Settings: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings`

## Support Resources

- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire Documentation: https://firebase.flutter.dev/
- Firebase Console: https://console.firebase.google.com/
- Stack Overflow: https://stackoverflow.com/questions/tagged/firebase

---

**Status**: ☐ Not Started | ⏳ In Progress | ✅ Complete

**Last Updated**: _________________

**Completed By**: _________________