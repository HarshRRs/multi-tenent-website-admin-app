import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rockster/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('LoginScreen password visibility button has tooltip', (WidgetTester tester) async {
    // Build the LoginScreen
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    // Find the visibility toggle IconButton
    // final visibilityButtonFinder = find.byType(IconButton);

    // There might be more than one IconButton, so we can check by Icon
    // The initial state is obscured, so we look for visibility_outlined
    final iconFinder = find.byIcon(Icons.visibility_outlined);
    final buttonFinder = find.ancestor(of: iconFinder, matching: find.byType(IconButton));

    expect(buttonFinder, findsOneWidget);

    // Get the widget
    final IconButton button = tester.widget(buttonFinder);

    // Check if tooltip is present and correct
    expect(button.tooltip, isNotNull, reason: 'Password visibility button should have a tooltip');
    // Verify first tooltip
    expect(button.tooltip, 'Show password');

    // Tap to toggle
    await tester.tap(buttonFinder);
    await tester.pump();

    // Now it should be 'Hide password' and the icon should have changed
    final iconFinderToggled = find.byIcon(Icons.visibility_off_outlined);
    final buttonFinderToggled = find.ancestor(of: iconFinderToggled, matching: find.byType(IconButton));
    
    expect(buttonFinderToggled, findsOneWidget);
    final IconButton buttonToggled = tester.widget(buttonFinderToggled);
    expect(buttonToggled.tooltip, 'Hide password');
  });
}
