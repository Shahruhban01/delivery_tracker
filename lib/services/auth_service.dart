import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isGoogleSignInInitialized = false;
  GoogleSignInAccount? _currentGoogleUser;

  User? get currentUser => _auth.currentUser;
  GoogleSignInAccount? get currentGoogleUser => _currentGoogleUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();
      _isGoogleSignInInitialized = true;
      
      // Listen to authentication events to track current user
      GoogleSignIn.instance.authenticationEvents.listen((event) {
        _handleAuthenticationEvent(event);
      });

      // Attempt silent sign-in
      await GoogleSignIn.instance.attemptLightweightAuthentication();
    } catch (e) {
      debugPrint('Google Sign-In initialization error: $e');
    }
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        _currentGoogleUser = user;
        notifyListeners();
        break;
      case GoogleSignInAuthenticationEventSignOut():
        _currentGoogleUser = null;
        notifyListeners();
        break;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!_isGoogleSignInInitialized) {
        await _initializeGoogleSignIn();
      }

      // Authenticate the user (this will show Google Sign-In UI)
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw Exception('Platform does not support authenticate');
      }

      await GoogleSignIn.instance.authenticate(scopeHint: ['email']);
      
      // Get the signed-in user from the event stream
      if (_currentGoogleUser == null) {
        throw Exception('No user signed in');
      }

      // Get ID token for Firebase authentication
      final GoogleSignInAuthentication googleAuth = 
          await _currentGoogleUser!.authentication;

      // Create Firebase credential with ID token only
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<ConfirmationResult> signInWithPhone(String phoneNumber) async {
    try {
      return await _auth.signInWithPhoneNumber(phoneNumber);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_isGoogleSignInInitialized && _currentGoogleUser != null) {
      await GoogleSignIn.instance.disconnect();
    }
    await _auth.signOut();
    _currentGoogleUser = null;
  }

  // Get access token if needed for API calls (separate from authentication)
  Future<String?> getGoogleAccessToken() async {
    if (_currentGoogleUser == null) return null;
    
    try {
      final GoogleSignInAuthentication auth = await _currentGoogleUser!.authentication;
      return auth.idToken;
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }
}
