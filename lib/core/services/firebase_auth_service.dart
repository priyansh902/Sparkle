import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkle_lite/Data/models/user_model.dart';
import '../constants/app_constants.dart';
import '../interfaces/auth_interface.dart';

class FirebaseAuthService implements AuthInterface {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        final appUser = UserModel(
          id: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? '',
          createdAt: DateTime.now(),
        );
        
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserId, user.uid);
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        
        return AuthResult(
          success: true,
          userId: user.uid,
          user: appUser,
        );
      }
      return AuthResult(success: false, error: 'Login failed');
    } on firebase.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<AuthResult> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        
        final appUser = UserModel(
          id: user.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
        );
        
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserId, user.uid);
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        
        return AuthResult(
          success: true,
          userId: user.uid,
          user: appUser,
        );
      }
      return AuthResult(success: false, error: 'Signup failed');
    } on firebase.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, completed);
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveUserProfile(UserModel user) async {
    // Update Firebase user profile
    await _auth.currentUser?.updateDisplayName(user.name);
  }

  String _getAuthErrorMessage(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}