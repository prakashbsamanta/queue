import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_state/ui/widgets/neo_text_field.dart';

void main() {
  testWidgets('NeoTextField renders correctly', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoTextField(
            controller: controller,
            hintText: 'Enter text',
          ),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Enter text'), findsOneWidget);
  });

  testWidgets('NeoTextField with prefix and suffix icons',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoTextField(
            controller: controller,
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email),
            suffixIcon: const Icon(Icons.visibility),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('NeoTextField obscures text when obscureText is true',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoTextField(
            controller: controller,
            hintText: 'Password',
            obscureText: true,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, true);
  });

  testWidgets('NeoTextField triggers onChanged callback',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    String? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoTextField(
            controller: controller,
            hintText: 'Type here',
            onChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'test input');
    expect(changedValue, 'test input');
  });

  testWidgets('NeoTextField is read only when readOnly is true',
      (WidgetTester tester) async {
    final controller = TextEditingController(text: 'initial');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoTextField(
            controller: controller,
            hintText: 'Read only',
            readOnly: true,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.readOnly, true);
  });
}
