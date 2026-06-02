import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkle_lite/Data/models/user_model.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/core/interfaces/auth_interface.dart';

/// A mock authentication service for testing and development purposes.
/// This simulates user login, signup, and session management without connecting to a real backend.
/// It uses in-memory storage for user data and SharedPreferences for session persistence.
/// TODO: Implement more robust error handling and validation logic.
/// TODO: Add support for password reset and email verification in the future.
class MockAuthService implements AuthInterface {
  // Mock user storage (in-memory for demo)
  final Map<String, Map<String, dynamic>> _mockUsers = {};
  
  MockAuthService() {
    _initMockUser();
  }
  
  void _initMockUser() {
    _mockUsers['test@example.com'] = {
      'password': 'password123',
      'userId': 'mock_user_123',
      'name': 'Sarah Johnson',
    };
  }
  
  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Validation
    if (email.isEmpty) {
      return AuthResult(success: false, error: 'Email is required');
    }
    if (password.isEmpty) {
      return AuthResult(success: false, error: 'Password is required');
    }
    if (password.length < AppConstants.minPasswordLength) {
      return AuthResult(
        success: false, 
        error: 'Password must be at least ${AppConstants.minPasswordLength} characters'
      );
    }
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check if user exists
    final userData = _mockUsers[email.toLowerCase()];
    if (userData == null) {
      return AuthResult(success: false, error: 'User not found');
    }
    
    if (userData['password'] != password) {
      return AuthResult(success: false, error: 'Invalid password');
    }
    
    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserId, userData['userId']);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserEmail, email);
    await prefs.setString(AppConstants.keyUserName, userData['name']);
    
    return AuthResult(
      success: true,
      userId: userData['userId'],
      user: UserModel(
        id: userData['userId'],
        email: email,
        name: userData['name'],
        createdAt: DateTime.now(),
      ),
    );
  }
  
  @override
  Future<AuthResult> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    // Validation
    if (email.isEmpty) {
      return AuthResult(success: false, error: 'Email is required');
    }
    if (name.isEmpty) {
      return AuthResult(success: false, error: 'Name is required');
    }
    if (password.isEmpty) {
      return AuthResult(success: false, error: 'Password is required');
    }
    if (password.length < AppConstants.minPasswordLength) {
      return AuthResult(
        success: false, 
        error: 'Password must be at least ${AppConstants.minPasswordLength} characters'
      );
    }
    
    // Email format validation
    final emailRegex = RegExp(AppConstants.emailRegex);
    if (!emailRegex.hasMatch(email)) {
      return AuthResult(success: false, error: 'Enter a valid email address');
    }
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check if user already exists
    if (_mockUsers.containsKey(email.toLowerCase())) {
      return AuthResult(success: false, error: 'Email already registered');
    }
    
    // Create new user
    final newUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _mockUsers[email.toLowerCase()] = {
      'password': password,
      'userId': newUserId,
      'name': name,
    };
    
    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserId, newUserId);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserEmail, email);
    await prefs.setString(AppConstants.keyUserName, name);
    
    return AuthResult(
      success: true,
      userId: newUserId,
      user: UserModel(
        id: newUserId,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      ),
    );
  }
  
  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyUserName);
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserId);
  }
  
  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.keyUserId);
    final email = prefs.getString(AppConstants.keyUserEmail);
    final name = prefs.getString(AppConstants.keyUserName);
    
    if (userId == null || email == null) return null;
    
    return UserModel(
      id: userId,
      email: email,
      name: name ?? '',
      createdAt: DateTime.now(),
    );
  }
  
  @override
  Future<void> saveUserProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserName, user.name);
   
  }

  @override
  Future<void> deleteAccount() async {
    // Clear all user data
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.keyUserId);
    
    if (userId != null) {
      await prefs.remove('${AppConstants.keySymptoms}_$userId');
      await prefs.remove('${AppConstants.keyHealthRecords}_$userId');
      await prefs.remove('${AppConstants.keyAIInsights}_$userId');
      await prefs.remove('${AppConstants.keyDoctorSummaries}_$userId');
      await prefs.remove('${AppConstants.keyFamilyMembers}_$userId');
    }
    
    await logout();
  }
  
  @override
  Future<bool> isEmailVerified() {
    // TODO: implement isEmailVerified
    throw UnimplementedError();
  }
  
  @override
  Future<void> sendVerificationEmail() {
    // TODO: implement sendVerificationEmail
    throw UnimplementedError();
  }



}