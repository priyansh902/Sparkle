
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/features/health_records/record_detail_screen.dart';
import 'package:sparkle_lite/features/health_records/records_list_screen.dart';
import 'package:sparkle_lite/features/health_records/upload_record_screen.dart';
import 'package:sparkle_lite/features/symptom_tracker/edit_symptom_screen.dart';
import 'package:sparkle_lite/features/symptom_tracker/symptom_history_screen.dart';
import 'package:sparkle_lite/features/symptom_tracker/add_symptom_screen.dart';
import 'package:sparkle_lite/features/welcome/welcome_screen.dart';
import 'package:sparkle_lite/features/auth/login_screen.dart';
import 'package:sparkle_lite/features/auth/signup_screen.dart';
import 'package:sparkle_lite/features/auth/onboarding_screen.dart';
import 'package:sparkle_lite/features/auth/health_profile_screen.dart';
import 'package:sparkle_lite/features/dashboard/dashboard_screen.dart';
import 'route_guards.dart';


/// Centralized router configuration using GoRouter
/// This defines all the routes in the app and applies route guards for authentication and onboarding flow control.
/// TODO: Add more routes as features are implemented
/// TODO: Implement nested routes for symptom details and record details
/// TODO: Add error handling for invalid routes and missing parameters
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
    GoRoute(
      path: AppConstants.routeAddSymptom,
      name: 'add-symptom',
      builder: (context, state) => const AddSymptomScreen(),
    ),
    GoRoute(
      path: AppConstants.routeSymptomHistory,
      name: 'symptom-history',
      builder: (context, state) => const SymptomHistoryScreen(),
    ),
    GoRoute(
      path: '${AppConstants.routeEditSymptom}',
      name: 'edit-symptom',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        if (id == null) {
          return const SymptomHistoryScreen();
        }
        return EditSymptomScreen(symptomId: id);
      },
    ),
    GoRoute(
  path: AppConstants.routeRecordsList,
  name: 'records-list',
  builder: (context, state) => const RecordsListScreen(),
),
GoRoute(
  path: AppConstants.routeUploadRecord,
  name: 'upload-record',
  builder: (context, state) => const UploadRecordScreen(),
),
GoRoute(
  path: '${AppConstants.routeRecordDetail}',
  name: 'record-detail',
  builder: (context, state) {
    final id = state.uri.queryParameters['id'];
    if (id == null) {
      return const RecordsListScreen();
    }
    return RecordDetailScreen(recordId: id);
  },
),
  ],
);