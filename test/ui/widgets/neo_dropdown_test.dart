import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_state/ui/widgets/neo_dropdown.dart';

void main() {
  const entries = [
    NeoDropdownEntry(value: 'a', label: 'Apple'),
    NeoDropdownEntry(value: 'b', label: 'Banana'),
    NeoDropdownEntry(value: 'c', label: 'Cherry'),
  ];

  testWidgets('NeoDropdown renders hint text when null', (WidgetTester tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoDropdown<String>(
            selectedValue: selected,
            entries: entries,
            onSelected: (val) { selected = val; },
            hintText: 'Select Fruit',
          ),
        ),
      ),
    );

    expect(find.text('Select Fruit'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
  });

  testWidgets('NeoDropdown opens menu and selects item', (WidgetTester tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return NeoDropdown<String>(
                selectedValue: selected,
                entries: entries,
                onSelected: (val) { 
                  setState(() { selected = val; });
                },
              );
            },
          ),
        ),
      ),
    );

    // Tap to open
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    // Check items visible
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);

    // Select Banana
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    // Check selected value updated in UI (Search field text update)
    expect(selected, 'b');
    expect(find.text('Banana'), findsOneWidget); // In display field
    expect(find.text('Apple'), findsNothing); // Menu closed
  });

  testWidgets('NeoDropdown filters entries', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoDropdown<String>(
            selectedValue: null,
            entries: entries,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    // Open menu
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    // Type "Cher"
    await tester.enterText(find.byType(TextField), 'Cher');
    await tester.pumpAndSettle();

    // Check filtering
    expect(find.text('Cherry'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
  });
}
