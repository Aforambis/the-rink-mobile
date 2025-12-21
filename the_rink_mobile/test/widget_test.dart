import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Simple test to verify testing framework works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('The Rink'),
          ),
        ),
      ),
    );

    // Verify text appears
    expect(find.text('The Rink'), findsOneWidget);
  });
}
