/// This file defines all the constant values used throughout the app, such as route names, API keys, and validation rules.
/// Centralizing these values helps maintain consistency and makes it easier to update them in the future.
/// TODO: Add more constants as needed, such as error messages, default values, and UI strings.
/// TODO: Consider organizing constants into separate classes or files if the list grows too large.
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
  static const String keySymptoms = 'symptoms';
  static const String keyHealthRecords = 'health_records';
  static const String keyAIInsights = 'ai_insights';
  static const String keyDoctorSummaries = 'doctor_summaries';  
  static const String keyPrivacySettings = 'privacy_settings';  
  static const String keyFamilyMembers = 'family_members'; 

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

/// Symptom Tracking Routes
  static const String routeAddSymptom = '/add-symptom';
  static const String routeSymptomHistory = '/symptom-history';
  static const String routeEditSymptom = '/edit-symptom';

/// Health Record Routes 
  static const String routeRecordsList = '/records';
  static const String routeUploadRecord = '/upload-record';
  static const String routeRecordDetail = '/record-detail';

  ///time line and Ai Insight Routes
  static const String routeTimeline = '/timeline';
  static const String routeAIInsightInput = '/ai-insight-input';
  static const String routeAIInsightResult = '/ai-insight-result';

  /// doctor communication routes
  static const String routeDoctorSummary = '/doctor-summary';
  static const String routeSummaryPreview = '/summary-preview';
  static const String routePrivacySettings = '/privacy-settings';
  static const String routeNotificationSettings = '/notification-settings';
  static const String routeFamilyList = '/family-list';
  static const String routeAddFamilyMember = '/add-family-member';
  
  // Responsive Design Breakpoints
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 1200;
  static const double breakpointDesktop = 1201;

}