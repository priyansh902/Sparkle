
import 'package:sparkle_lite/Data/models/user_model.dart';

/// Abstract interface for authentication operations
abstract class AuthInterface {
  Future<AuthResult> login({
    required String email,
    required String password,
  });
  
  Future<AuthResult> signup({
    required String email,
    required String password,
    required String name,
  });
  
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<bool> hasCompletedOnboarding();
  Future<void> setOnboardingCompleted(bool completed);
  Future<String?> getCurrentUserId();
  Future<UserModel?> getCurrentUser();
  Future<void> saveUserProfile(UserModel user);
}

/// Result class for authentication operations
class AuthResult {
  final bool success;
  final String? userId;
  final String? error;
  final UserModel? user;
  
  AuthResult({
    required this.success,
    this.userId,
    this.error,
    this.user,
  });
}