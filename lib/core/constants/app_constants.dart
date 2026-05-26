
class AppConstants {

  /// App Information
  static const String appName = 'Sparkle_lite';
  static const String appVersion = '1.0.0';

  /// API Endpoints
  static const String keyUserId = 'user_id';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  /// Validation Constants
  static const int minPasswordLength = 6;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  /// Route Names
  static const String routeWelcome = '/';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeOnboarding = '/onboarding';
  static const String routeHealthProfile = '/health-profile';
  static const String routeDashboard = '/dashboard';

}