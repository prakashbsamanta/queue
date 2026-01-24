import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_state/ui/widgets/neo_error.dart';

void main() {
  testWidgets('NeoError renders message and retry button',
      (WidgetTester tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoError(
            error: 'Something went wrong',
            onRetry: () {
              retried = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Oops! Something went wrong.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retried, true);
  });

  testWidgets('NeoError renders without retry button when onRetry is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NeoError(
            error: 'Error message',
          ),
        ),
      ),
    );

    expect(find.text('Error message'), findsOneWidget);
    expect(find.text('Oops! Something went wrong.'), findsOneWidget);
    expect(find.text('Retry'), findsNothing); // No retry button
  });
}
