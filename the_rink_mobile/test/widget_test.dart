import 'package:flutter_test/flutter_test.dart';

import 'package:the_rink_mobile/main.dart';

void main() {
  testWidgets('The Rink app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that The Rink title appears
    expect(find.text('The Rink'), findsOneWidget);
    
    // Verify that the Home tab is visible
    expect(find.text('Home'), findsOneWidget);
    
    // Verify that Featured Events section appears
    expect(find.text('Featured Events'), findsOneWidget);
  });

  testWidgets('Navigation requires auth for restricted tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap on Arena tab (should show auth modal)
    await tester.tap(find.text('Arena'));
    await tester.pumpAndSettle();

    // Verify auth modal appears
    expect(find.text('Sign in to join the fun!'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}