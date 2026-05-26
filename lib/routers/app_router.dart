
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/features/welcome/welcome_screen.dart';
import 'package:sparkle_lite/features/auth/login_screen.dart';
import 'package:sparkle_lite/features/auth/signup_screen.dart';
import 'package:sparkle_lite/features/auth/onboarding_screen.dart';
import 'package:sparkle_lite/features/auth/health_profile_screen.dart';
import 'package:sparkle_lite/features/dashboard/dashboard_screen.dart';
import 'route_guards.dart';


/// Centralized router configuration using GoRouter
final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.routeWelcome,
  redirect: (context, state) async {
    return await RouteGuards.guardRedirect(context, state);
  },
  routes: [
    GoRoute(
      path: AppConstants.routeWelcome,
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppConstants.routeLogin,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppConstants.routeSignup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppConstants.routeOnboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppConstants.routeHealthProfile,
      name: 'health-profile',
      builder: (context, state) => const HealthProfileScreen(),
    ),
    GoRoute(
      path: AppConstants.routeDashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);