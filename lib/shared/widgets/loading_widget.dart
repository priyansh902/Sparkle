

import 'package:flutter/material.dart';

/// A simple loading widget with an optional message
/// This widget displays a circular progress indicator along with an optional message below it. It is designed to be used across the app to indicate loading states in a visually appealing way. The circular progress indicator is styled with the app's primary color, and the message is displayed in a subtle gray color to complement the loading indicator. This widget helps to improve the user experience by providing clear feedback when the app is performing a task that requires waiting, such as fetching data or processing information. By using this LoadingWidget consistently throughout the app, users will have a clear understanding of when they need to wait and can feel reassured that the app is working on their request.
/// The LoadingWidget is flexible and can be used in various contexts by simply passing a custom message when needed. It is an essential part of the app's user interface, ensuring that users are informed about loading states in a clear and visually appealing manner, ultimately enhancing the overall user experience.


class LoadingWidget extends StatelessWidget {
  final String? message;
  
  const LoadingWidget({super.key, this.message});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF7B61FF),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}