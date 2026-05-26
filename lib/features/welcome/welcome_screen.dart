import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';


/// Welcome screen shown to unauthenticated users
/// This screen serves as the entry point for new users, providing a warm welcome and guiding them towards signing up or logging in. It features a clean and engaging design with a prominent logo, a welcoming title and subtitle, and clear calls to action for both new and existing users. The "Get Started" button directs new users to the signup screen, while the "Already have an account? Sign In" link takes existing users to the login screen. The screen also includes a privacy note at the bottom to reassure users about data security. Overall, the WelcomeScreen is designed to create a positive first impression and encourage users to take the next step in their health journey with Sparkle Lite.
/// The WelcomeScreen is also designed to be responsive and visually appealing across different device sizes, ensuring a consistent user experience. The use of colors, typography, and spacing is carefully chosen to align with the overall branding of the app and create an inviting atmosphere for users as they begin their journey with Sparkle Lite.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'Your private companion for women\'s health and family wellness',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
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
                  color: Colors.grey[500],
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