import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';

/// This test suite focuses on validating the functionality of the PrimaryButton widget, ensuring that it correctly displays the provided text, handles the onPressed callback, and manages its loading and enabled states appropriately. The tests verify that the button displays a loading indicator when isLoading is true, does not show the loading indicator when isLoading is false, and that it is disabled when isEnabled is false. Additionally, the tests check that the button's text is displayed correctly when not in a loading state. These tests are essential for maintaining the reliability of the PrimaryButton widget as it is a key component of user interactions in the application.
/// Note: To run these tests, ensure that the PrimaryButton widget is implemented with the necessary parameters and that it correctly handles the rendering logic for the text, loading indicator, and enabled/disabled states. The tests will check for the presence of the specified text and loading indicator based on the provided parameters, as well as the functionality of the onPressed callback when the button is tapped. This comprehensive testing approach helps to ensure that the PrimaryButton widget provides a consistent and user-friendly experience in the application.

void main() {
  group('PrimaryButton Widget Tests', () {
    testWidgets('Primary button displays text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('Primary button calls onPressed when tapped', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Submit',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      expect(pressed, true);
    });

    testWidgets('Primary button shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Saving',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Check for CircularProgressIndicator instead of text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Text should not be visible when loading
    });

    testWidgets('Primary button does not show loading indicator when isLoading is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Submit',
              onPressed: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('Primary button is disabled when isEnabled is false', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Disabled',
              onPressed: () {
                pressed = true;
              },
              isEnabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      expect(pressed, false);
    });

    testWidgets('Primary button shows text when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Save Changes',
              onPressed: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}