import 'package:flutter/material.dart';


/// A simple widget to display error messages in a user-friendly way.
/// This widget shows an error icon, the error message, and an optional retry button if a callback is provided. It is designed to be used across the app to display errors in a consistent and visually appealing manner. The error message is centered on the screen with appropriate padding, and the retry button is styled to match the app's color scheme. This widget helps to improve the user experience by providing clear feedback when something goes wrong and offering a way to try again if applicable.
/// The ErrorDisplayWidget is flexible and can be used in various contexts by simply passing the error message and an optional retry callback. It is a crucial part of the app's error handling strategy, ensuring that users are informed about issues in a clear and constructive way, while also providing an opportunity to recover from errors without frustration.
// class ErrorDisplayWidget extends StatelessWidget {
//   final String error;
//   final VoidCallback? onRetry;
  
//   const ErrorDisplayWidget({
//     super.key,
//     required this.error,
//     this.onRetry,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.red[300],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               error,
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                 color: Colors.grey[700],
//               ),
//             ),
//             if (onRetry != null) ...[
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: onRetry,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF7B61FF),
//                 ),
//                 child: const Text('Try Again'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }


class ErrorDisplayWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),

            const SizedBox(height: 16),

            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}