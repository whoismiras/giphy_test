import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giphy/core/widgets/error_view.dart';

void main() {
  testWidgets('shows the message and invokes onRetry when tapped', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'Network error',
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(find.text('Network error'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(retries, 1);
  });

  testWidgets('hides the retry button when onRetry is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ErrorView(message: 'No retry available')),
      ),
    );

    expect(find.text('No retry available'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });
}
