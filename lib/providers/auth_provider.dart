import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/models/user_model.dart';
import 'package:sparkle_lite/Data/repositiories/auth_repository.dart';

/// State definition
/// AuthState represents the current authentication status of the user, including loading state, authentication status, user information, and any error messages. It provides a copyWith method for easy state updates and an initial factory constructor for the default state.
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });
  
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
  
  static const initial = AuthState();
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  
  AuthNotifier(this._authRepository) : super(AuthState.initial) {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
      );
    }
  }
  
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    
    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
      return false;
    }
  }
  
  /// Handles user signup by calling the AuthRepository and updating state accordingly.
  Future<bool> signup(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authRepository.signup(
      email: email,
      password: password,
      name: name,
    );
    
    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
      return false;
    }
  }
  
  /// Logs out the user by calling the AuthRepository and resetting the state to initial.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    state = AuthState.initial;
  }
  
  /// Marks onboarding as completed by updating the AuthRepository and ensuring the state reflects this change.
  Future<void> completeOnboarding() async {
    await _authRepository.setOnboardingCompleted(true);
  }
  
  /// Updates the user's profile information by saving it through the AuthRepository and updating the state with the new user data.
  Future<void> updateProfile(UserModel updatedUser) async {
    await _authRepository.saveUserProfile(updatedUser);
    state = state.copyWith(user: updatedUser);
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authRepository.deleteAccount();
      state = AuthState.initial;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}


// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepository);
});