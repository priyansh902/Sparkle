import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/Data/repositiories/auth_repository.dart';
import 'package:sparkle_lite/core/services/mock_auth_service.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';

/// RouteGuards class contains static methods for guarding routes based on authentication status and onboarding completion. The guardRedirect method checks if the user is logged in and whether they have completed onboarding, redirecting them to the appropriate screen based on their status. This ensures that unauthenticated users are directed to the login screen, while authenticated users are directed to the dashboard or onboarding screens as needed. The guards help maintain a secure and user-friendly navigation flow throughout the app.
/// The guardRedirect method is designed to be used with the GoRouter configuration, allowing for seamless integration of route guarding logic. It checks the user's authentication status and onboarding completion status by interacting with the AuthRepository, which abstracts away the details of how authentication and onboarding data are stored and managed. This approach promotes a clean separation of concerns and makes it easier to maintain and update the authentication logic in the future. Overall, the RouteGuards class plays a crucial role in ensuring that users have a smooth and secure experience as they navigate through the app.
/// The RouteGuards class can be easily extended in the future to include additional guards for other routes or features, such as role-based access control or feature flag checks. By centralizing the route guarding logic in a single class, it becomes easier to manage and update the navigation flow of the app as new features are added or authentication requirements change. The use of async logic in the guardRedirect method allows for flexibility in how authentication and onboarding status are determined, whether through local storage, network requests, or other means. Overall, the RouteGuards class is a key component of the app's navigation architecture, ensuring that users are directed to the appropriate screens based on their authentication and onboarding status.
class RouteGuards {
  static Future<String?> guardRedirect(BuildContext context, GoRouterState state) async {
    final authRepo = AuthRepository(authService: MockAuthService());
    final isLoggedIn = await authRepo.isLoggedIn();
    
    // Welcome/Login routes - if logged in, go to dashboard
    if (state.matchedLocation == AppConstants.routeWelcome ||
        state.matchedLocation == AppConstants.routeLogin) {
      if (isLoggedIn) {
        final hasOnboarding = await authRepo.hasCompletedOnboarding();
        if (!hasOnboarding) {
          return AppConstants.routeOnboarding;
        }
        return AppConstants.routeDashboard;
      }
      return null;
    }
    
    // Protected routes - require login
    if (state.matchedLocation != AppConstants.routeWelcome &&
        state.matchedLocation != AppConstants.routeLogin &&
        state.matchedLocation != AppConstants.routeSignup) {
      if (!isLoggedIn) {
        return AppConstants.routeLogin;
      }
      
      // Onboarding check
      if (state.matchedLocation != AppConstants.routeOnboarding &&
          state.matchedLocation != AppConstants.routeHealthProfile) {
        final hasOnboarding = await authRepo.hasCompletedOnboarding();
        if (!hasOnboarding) {
          return AppConstants.routeOnboarding;
        }
      }
    }
    
    return null;
  }
}
