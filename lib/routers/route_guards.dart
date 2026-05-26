import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/Data/repositiories/auth_repository.dart';
import 'package:sparkle_lite/core/services/mock_auth_service.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';

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
