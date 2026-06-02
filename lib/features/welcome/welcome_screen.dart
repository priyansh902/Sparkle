import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';

/// Welcome screen shown to unauthenticated users
/// This screen serves as the entry point for new users, providing a warm welcome and guiding them towards signing up or logging in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B61FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa,
                  size: 60,
                  color: Color(0xFF7B61FF),
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Welcome to Sparkle Lite',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'Your private companion for women\'s health and family wellness',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Buttons
              PrimaryButton(
                text: 'Get Started',
                onPressed: () {
                  context.go(AppConstants.routeSignup);
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go(AppConstants.routeLogin);
                },
                child: Text(
                  'Already have an account? Sign In',
                  style: TextStyle(
                    color: const Color(0xFF7B61FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              // Privacy note
              Text(
                'Your health data is private and secure',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}