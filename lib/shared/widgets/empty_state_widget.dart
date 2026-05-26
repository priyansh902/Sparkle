import 'package:flutter/material.dart';


//// Reusable widget for displaying an empty state with a title, message, and optional action button. This widget is used across the app to show friendly messages when there is no data to display, such as no symptoms logged or no health records uploaded. It includes an icon, a title, a message, and an optional button that can trigger a callback when pressed. The design is clean and consistent with the overall app theme, providing a positive user experience even when there is no content to show.
/// The EmptyStateWidget is flexible and can be used in various contexts by customizing the title, message, icon, and button action. It helps to guide users towards taking action, such as adding a new symptom log or uploading a health record, while also providing reassurance that their data is private and secure. Overall, this widget plays an important role in maintaining user engagement and encouraging interaction with the app's features, even when there is no existing data to display.
/// The EmptyStateWidget is designed to be visually appealing and user-friendly, with a focus on clear communication and encouraging user action. The use of icons, typography, and spacing is carefully chosen to create a welcoming and informative experience for users when they encounter an empty state in the app. By providing a consistent and engaging empty state experience, the EmptyStateWidget helps to enhance the overall user experience and keep users motivated to interact with their health data.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData icon;
  
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.icon = Icons.favorite_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add),
                label: Text(buttonText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}