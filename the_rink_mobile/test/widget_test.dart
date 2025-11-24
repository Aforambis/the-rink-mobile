// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:the_rink_mobile/main.dart';

void main() {
  testWidgets('The Rink app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TheRinkApp());

    // Verify that The Rink title appears
    expect(find.text('The Rink'), findsOneWidget);
    
    // Verify that the Home tab is visible
    expect(find.text('Home'), findsOneWidget);
    
    // Verify that Featured Events section appears
    expect(find.text('Featured Events'), findsOneWidget);
  });

  testWidgets('Navigation requires auth for restricted tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TheRinkApp());

    // Tap on Arena tab (should show auth modal)
    await tester.tap(find.text('Arena'));
    await tester.pumpAndSettle();

    // Verify auth modal appears
    expect(find.text('Sign in to join the fun!'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}