import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    // Initialize Firebase with auto-generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configure Firestore
    await _configureFirestore();
  }
  
  static Future<void> _configureFirestore() async {
    final firestore = FirebaseFirestore.instance;
    
    // Enable offline persistence
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
  
  // Get Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  // Get current platform name
  static String get currentPlatform {
    return DefaultFirebaseOptions.currentPlatform.projectId;
  }
  
  // Check if Firebase is initialized
  static bool get isInitialized {
    return Firebase.apps.isNotEmpty;
  }
}


