// This is a basic Flutter widget test.
//
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:event_bite/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RocksterApp()));

    // Verify that the splash screen or login screen appears.
    // We expect 'COSMOS' text from the login screen (assuming no auth token persistence mock)
    // or just that the app builds without crashing.
    
    // Determining if we are on Login Screen by finding "COSMOS" or "BUSINESS ADMIN"
    // Note: Animations might need settling, but infinite animations will cause pumpAndSettle to timeout.
    // So we pump for a specific duration to let intro animations finish.
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('COSMOS'), findsAtLeastNWidgets(1));
    expect(find.text('BUSINESS ADMIN'), findsOneWidget);
  });
}
