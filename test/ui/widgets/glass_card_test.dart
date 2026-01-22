import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_state/ui/widgets/glass_card.dart';

void main() {
  testWidgets('GlassCard renders child and handles tap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassCard(
            onTap: () { tapped = true; },
            child: const Text('Glass Content'),
          ),
        ),
      ),
    );

    expect(find.text('Glass Content'), findsOneWidget);
    
    await tester.tap(find.byType(GlassCard));
    expect(tapped, true);
  });
}
