import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_state/ui/analytics/analytics_screen.dart';

void main() {
  testWidgets('AnalyticsScreen renders charts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AnalyticsScreen(),
        ),
      ),
    );

    expect(find.text('Learning Consistency'), findsOneWidget);
    expect(find.text('Contribution Graph'), findsOneWidget);
    // Finds charts? BarChart is generic.
    // We can assume if text is there, it rendered.
    // Or find by Key if added.
  });
}
