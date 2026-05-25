
abstract class AuthInterface {

/// Logs in a user with the provided email and password.
  Future<({bool success, String? userId, String? error})> login({
    required String email, 
    required String password
  });

/// Signs up a new user with the provided email, password, and name.
  Future<({bool success, String? userId, String? error})> signup({
    required String email,
    required String password,
    required String name,
  });

/// Logs out the currently authenticated user.
  Future<void> logout();
  Future<bool> isLoggedIn();
  String? getCurrentUserId();

}