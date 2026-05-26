
import 'package:flutter/material.dart';

/// A reusable primary button widget that can be used across the app for consistent styling.
/// The PrimaryButton is designed to be visually appealing and user-friendly, with a focus on clear communication and encouraging user action. It features a customizable text label, an onPressed callback for handling button taps, and optional loading and enabled states. When isLoading is true, the button shows a circular progress indicator instead of the text, and when isEnabled is false, the button is disabled to prevent user interaction. The styling of the button includes a specific background color, foreground color, rounded corners, and no elevation to match the overall design of the app. By using the PrimaryButton consistently throughout the app, developers can ensure a cohesive user experience and make it easy for users to identify actionable buttons.
/// The PrimaryButton can be easily integrated into various screens and contexts by simply providing the necessary parameters such as the button text, onPressed callback, and optional loading and enabled states. This widget helps to maintain a consistent look and feel across the app while providing a flexible and reusable component for handling user interactions with buttons. Overall, the PrimaryButton is an essential part of the app's UI toolkit, contributing to a polished and professional user interface.

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B61FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}