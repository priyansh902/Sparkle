import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkle_lite/routers/app_router.dart';

/// Main entry point of the Sparkle Lite app
/// This file initializes the app, sets up the main widget, and configures the router for navigating between different screens. It also initializes shared preferences to ensure that any necessary data is loaded before the app starts. The MyApp widget defines the overall theme and appearance of the app, including color schemes, typography, and input decoration styles. By using MaterialApp.router, it integrates the GoRouter for handling navigation in a clean and efficient way. This setup allows for a smooth user experience as users navigate through the various features of Sparkle Lite, such as onboarding, dashboard, symptom logging, and health record management. Overall, this file serves as the foundation for the entire app, ensuring that all necessary configurations are in place for a seamless user experience.


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  await SharedPreferences.getInstance();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sparkle Lite',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B61FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'GoogleFonts',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF2D2D2D),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7B61FF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[300]!),
          ),
        ),
      ),
    );
  }
}