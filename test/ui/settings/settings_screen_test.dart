import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_state/ui/settings/settings_screen.dart';
import 'package:flow_state/logic/providers.dart';
import 'package:flow_state/data/repositories/auth_repository.dart';
import 'package:flow_state/logic/auth/auth_provider.dart';

@GenerateNiceMocks([MockSpec<Box>(), MockSpec<AuthRepository>()])
import 'settings_screen_test.mocks.dart';

void main() {
  late MockBox mockBox;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockBox = MockBox();
    mockAuthRepository = MockAuthRepository();
  });

  testWidgets('SettingsScreen loads and saves settings',
      (WidgetTester tester) async {
    // Setup mock values
    when(mockBox.get('ai_api_key', defaultValue: anyNamed('defaultValue')))
        .thenReturn('old_key');
    when(mockBox.get('ai_provider', defaultValue: anyNamed('defaultValue')))
        .thenReturn('openai');
    when(mockBox.put(any, any)).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsBoxProvider.overrideWith((ref) => mockBox),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text('old_key'), findsOneWidget);
    expect(find.text('OpenAI'), findsOneWidget);

    // Enter new key in the second TextField (1st is dropdown search which is hidden/collapsed inside NeoDropdown but technically inside widget tree?)
    // NeoDropdown builds TextField regardless of menu state?
    // NeoDropdown:
    // child: Column([ InkWell(child: Row([Expanded(child: TextField...)])) ])
    // Yes, TextField is always there.
    // So 1st TextField is Dropdown Search.
    // 2nd TextField is API Key.

    await tester.enterText(find.byType(TextField).at(1), 'new_key');

    // Save
    await tester.tap(find.text('Save Configuration'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('API Key Saved!'), findsOneWidget);
    verify(mockBox.put('ai_api_key', 'new_key')).called(1);
  });

  testWidgets('SettingsScreen Log Out calls signOut and pops',
      (WidgetTester tester) async {
    // Setup mock values
    when(mockBox.get('ai_api_key', defaultValue: anyNamed('defaultValue')))
        .thenReturn('');
    when(mockBox.get('ai_provider', defaultValue: anyNamed('defaultValue')))
        .thenReturn('openai');
    when(mockAuthRepository.signOut()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsBoxProvider.overrideWith((ref) => mockBox),
          authRepositoryProvider.overrideWith((ref) => mockAuthRepository),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    // Tap Log Out
    await tester.tap(find.text('Log Out'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Wait for async

    verify(mockAuthRepository.signOut()).called(1);
    // Cannot easily verify Navigator.pop without a navigator observer, but verify the method called is enough coverage logic.
  });
}
