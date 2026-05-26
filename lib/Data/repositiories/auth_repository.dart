import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/core/interfaces/auth_interface.dart';
import 'package:sparkle_lite/core/services/mock_auth_service.dart';
import 'package:sparkle_lite/Data/models/user_model.dart';


/// Repository that abstracts authentication logic and interacts with the AuthInterface.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = MockAuthService();
  return AuthRepository(authService: authService);
});

class AuthRepository {
  final AuthInterface authService;
  
  AuthRepository({required this.authService});
  
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    return await authService.login(email: email, password: password);
  }
  
  Future<AuthResult> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    return await authService.signup(
      email: email,
      password: password,
      name: name,
    );
  }
  
  Future<void> logout() async {
    await authService.logout();
  }
  
  Future<bool> isLoggedIn() async {
    return await authService.isLoggedIn();
  }
  
  Future<bool> hasCompletedOnboarding() async {
    return await authService.hasCompletedOnboarding();
  }
  
  Future<void> setOnboardingCompleted(bool completed) async {
    await authService.setOnboardingCompleted(completed);
  }
  
  Future<String?> getCurrentUserId() async {
    return await authService.getCurrentUserId();
  }
  
  Future<UserModel?> getCurrentUser() async {
    return await authService.getCurrentUser();
  }
  
  Future<void> saveUserProfile(UserModel user) async {
    await authService.saveUserProfile(user);
  }
}