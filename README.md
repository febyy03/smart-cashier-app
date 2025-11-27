# Smart Cashier (Kasir Cerdas)

A comprehensive Flutter-based Point of Sale (POS) system with Firebase backend, featuring AI-powered product recommendations, real-time inventory management, and advanced reporting.

## Features

### 1. Authentication & User Management
- ✅ Login & Register with email/password
- ✅ Password reset via email
- ✅ Role-based access control (Admin/Cashier)
- User profile management

### 2. Product Management
- CRUD operations for products
- Product categorization
- Image upload for products
- Real-time stock tracking
- Barcode/QR code support
- Low stock alerts

### 3. Transaction System
- Quick POS interface
- Multi-item cart management
- Tax and discount calculations
- Multiple payment methods (Cash/Digital)
- Receipt generation (PDF)
- Transaction history

### 4. AI Recommendations
- Frequently bought together analysis
- Popular products tracking
- High-stock product prioritization
- Customer purchase history analysis

### 5. Reports & Analytics
- Daily/Weekly/Monthly sales reports
- Product performance analytics
- Category breakdown charts
- Cashier performance metrics
- Export to PDF/Excel

### 6. Additional Features
- Dark mode support
- QR/Barcode scanner
- Push notifications
- Multi-device sync
- Offline capability (coming soon)

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Storage
  - Cloud Functions (optional)
- **State Management**: Provider
- **Charts**: FL Chart
- **PDF Generation**: pdf & printing packages

## Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `smart-cashier` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create Project"

### Step 2: Add Flutter App to Firebase

1. In Firebase Console, click the Flutter icon
2. Register your app with package name: `com.example.flutter_smart_cashier`
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Follow Firebase CLI setup instructions or use FlutterFire CLI:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter app
flutterfire configure
```

### Step 3: Enable Firebase Services

In Firebase Console:

1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"

2. **Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Start in "Test mode" (change to production rules later)
   - Choose your region

3. **Storage**
   - Go to Storage
   - Click "Get started"
   - Start in "Test mode"

### Step 4: Update Firebase Configuration

Update `lib/services/firebase_service.dart` with your Firebase configuration:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  ),
);
```

Or use the auto-generated `firebase_options.dart` from FlutterFire CLI.

### Step 5: Firestore Security Rules

Add these security rules in Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAdmin() || request.auth.uid == userId;
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAdmin();
    }
    
    // Categories collection
    match /categories/{categoryId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAdmin();
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAdmin();
    }
    
    // Settings collection
    match /settings/{document=**} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
  }
}
```

### Step 6: Storage Security Rules

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

## Installation

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd flutter_smart_cashier
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase (see Firebase Setup above)

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── config/
│   ├── routes.dart          # App navigation routes
│   └── theme.dart           # App theme configuration
├── models/
│   ├── user_model.dart      # User data model
│   ├── product_model.dart   # Product data model
│   ├── category_model.dart  # Category data model
│   └── transaction_model.dart # Transaction data model
├── providers/
│   └── auth_provider.dart   # Authentication state management
├── screens/
│   ├── auth/               # Authentication screens
│   ├── home/               # Dashboard & main navigation
│   ├── products/           # Product management screens
│   ├── transactions/       # Transaction screens
│   ├── reports/            # Reports & analytics screens
│   └── settings/           # Settings screens
├── services/
│   ├── firebase_service.dart # Firebase initialization
│   └── auth_service.dart    # Authentication service
└── main.dart               # App entry point
```

## Default Credentials

For testing, you can create an admin account:
- Email: admin@smartcashier.com
- Password: admin123
- Role: Admin

## Roadmap

- [x] Authentication system
- [x] Basic app structure
- [ ] Product management (CRUD)
- [ ] Transaction processing
- [ ] AI recommendations
- [ ] Reports & analytics
- [ ] Dark mode
- [ ] Barcode scanner
- [ ] Notifications
- [ ] Export functionality
- [ ] Offline mode

## Getting Started with Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please open an issue on GitHub.

---

**Note**: This is the initial setup with authentication system completed. More features will be implemented in subsequent updates.