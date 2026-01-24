import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_state/ui/widgets/neo_button.dart';

void main() {
  testWidgets('NeoButton primary style renders correctly',
      (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoButton(
            text: 'Click Me',
            onPressed: () => pressed = true,
            isPrimary: true,
          ),
        ),
      ),
    );

    expect(find.text('Click Me'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, true);
  });

  testWidgets('NeoButton secondary style renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoButton(
            text: 'Secondary',
            onPressed: () {},
            isPrimary: false,
          ),
        ),
      ),
    );

    expect(find.text('Secondary'), findsOneWidget);
  });

  testWidgets('NeoButton with icon renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoButton(
            text: 'With Icon',
            onPressed: () {},
            icon: Icons.add,
          ),
        ),
      ),
    );

    expect(find.text('With Icon'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('NeoButton full width renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoButton(
            text: 'Full Width',
            onPressed: () {},
            isFullWidth: true,
          ),
        ),
      ),
    );

    expect(find.text('Full Width'), findsOneWidget);
    // Verify SizedBox wrapper is present
    expect(find.byType(SizedBox), findsWidgets);
  });
}
