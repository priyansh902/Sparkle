import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkle_lite/shared/widgets/empty_state_widget.dart';

/// This test suite focuses on validating the functionality of the EmptyStateWidget, ensuring that it correctly displays the provided title, message, and icon. It also tests the conditional rendering of the button based on the presence of buttonText and onButtonPressed parameters. The tests verify that the widget behaves as expected in different scenarios, such as when a button is provided or when it is not, to ensure that the user interface remains consistent and functional across various states of the application.
/// Note: To run these tests, ensure that the EmptyStateWidget is implemented with the necessary parameters and that it correctly handles the rendering logic for the title, message, icon, and button. The tests will check for the presence of the specified text and icon, as well as the functionality of the button when it is included in the widget. This comprehensive testing approach helps to ensure that the EmptyStateWidget provides a reliable and user-friendly experience in the application.

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('Empty state displays title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No Symptoms Yet',
              message: 'Start tracking your health journey',
              icon: Icons.favorite_outline,
            ),
          ),
        ),
      );

      expect(find.text('No Symptoms Yet'), findsOneWidget);
      expect(find.text('Start tracking your health journey'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    });

    testWidgets('Empty state shows button when provided', (tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No Records',
              message: 'Upload your first record',
              buttonText: 'Upload Record',
              onButtonPressed: () {
                buttonPressed = true;
              },
              icon: Icons.folder_outlined,
            ),
          ),
        ),
      );

      expect(find.text('Upload Record'), findsOneWidget);
      
      await tester.tap(find.text('Upload Record'));
      expect(buttonPressed, true);
    });

    testWidgets('Empty state does not show button when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No Data',
              message: 'No data available',
              icon: Icons.info_outline,
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}