

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkle_lite/core/interfaces/auth_interface.dart';

class MockAuthService implements AuthInterface {

  static const String _userIdKey = 'mock_user_id';
  static const String _isLoggedInKey = 'is_logged_in';

    @override
    Future<({bool success, String? userId, String? error})> login({
      required String email, 
      required String password
    }) async {
      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        return (success: false, userId: null, error: 'Email and password required');
      }
      
      if (password.length < 6) {
        return (success: false, userId: null, error: 'Password too short');
      }
      
      // Mock success
      const mockUserId = 'mock_user_123';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, mockUserId);
      await prefs.setBool(_isLoggedInKey, true);
      
      return (success: true, userId: mockUserId, error: null);
    }
    
    @override
    Future<({bool success, String? userId, String? error})> signup({
      required String email,
      required String password,
      required String name,
    }) async {
      // Same as login for mock
      return login(email: email, password: password);
    }
    
    @override
    Future<void> logout() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.setBool(_isLoggedInKey, false);
    }
    
    @override
    Future<bool> isLoggedIn() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    }
    
    @override
    String? getCurrentUserId() {
      // In real app, this would be synchronous from secure storage
      return 'mock_user_123';
    }
}