// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
  
  Future<UserCredential?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Start the interactive sign-in process
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      
      if (gUser == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }
      
      // Obtain auth details from the request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      
      // Create a new credential for the user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      
      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      _isLoading = false;
      notifyListeners();
      return userCredential;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
