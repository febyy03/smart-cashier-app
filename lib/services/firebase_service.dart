import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Firebase configuration - REPLACE WITH YOUR VALUES
class FirebaseService {
  static Future<void> initialize() async {
    try {
      // For development/testing - you can use Firebase Emulator
      // Uncomment the lines below if you want to use Firebase Emulator
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'demo-key',
          appId: 'demo-app-id',
          messagingSenderId: '123456789',
          projectId: 'demo-project',
        ),
      );

      // Production Firebase configuration
      // REPLACE THESE VALUES WITH YOUR ACTUAL FIREBASE CONFIG
      /*
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'YOUR_API_KEY_HERE',
          appId: 'YOUR_APP_ID_HERE',
          messagingSenderId: 'YOUR_MESSAGING_SENDER_ID_HERE',
          projectId: 'YOUR_PROJECT_ID_HERE',
          storageBucket: 'YOUR_STORAGE_BUCKET_HERE',
        ),
      );
      */

      if (kDebugMode) {
        print('✅ Firebase initialized successfully');
        print('🔥 Project ID: YOUR_PROJECT_ID_HERE');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Firebase: $e');
        print('💡 Make sure to:');
        print('   1. Create Firebase project at https://console.firebase.google.com/');
        print('   2. Enable Authentication (Email/Password)');
        print('   3. Create Firestore Database');
        print('   4. Enable Storage');
        print('   5. Download google-services.json to android/app/');
        print('   6. Update the FirebaseOptions above with your config');
      }
      rethrow;
    }
  }

  // Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      // This will throw an error if Firebase is not properly configured
      await Firebase.initializeApp();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase connection test failed: $e');
      }
      return false;
    }
  }
}