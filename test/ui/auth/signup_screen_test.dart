import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_state/ui/auth/signup_screen.dart';
import 'package:flow_state/core/services/auth_service.dart';
import 'package:flow_state/logic/auth/auth_provider.dart';

@GenerateNiceMocks([MockSpec<AuthService>()])
import 'signup_screen_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('SignUpScreen signs up user', (WidgetTester tester) async {
    when(mockAuthService.signUpWithEmail(any, any, any))
        .thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWith((ref) => mockAuthService),
        ],
        child: const MaterialApp(
          home: SignUpScreen(),
        ),
      ),
    );

    // Enter details
    await tester.enterText(
        find.widgetWithText(TextField, 'Full Name'), 'John Doe');
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'john@example.com');

    // Password field is tricky due to multiple fields.
    // "Password" hint.
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'password123');

    // Tap Sign Up
    await tester.tap(find.text('Sign Up'));
    await tester.pump(); // Start logic
    await tester.pump(const Duration(milliseconds: 100)); // Processing
    await tester.pumpAndSettle();

    verify(mockAuthService.signUpWithEmail(
            'john@example.com', 'password123', 'John Doe'))
        .called(1);
    // Should pop?
    // We can't verify pop easily without navigator observer.
    // But verify call is enough for logic coverage.
  });

  testWidgets('SignUpScreen renders correctly', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWith((ref) => mockAuthService),
          ],
          child: const MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  testWidgets('SignUpScreen validates empty fields',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWith((ref) => mockAuthService),
          ],
          child: const MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // Tap Sign Up without entering anything
      await tester.tap(find.text('Sign Up'));
      await tester.pump(const Duration(seconds: 1));

      // Should show validation errors
      expect(find.text('Please enter your name'), findsOneWidget);

      verifyNever(mockAuthService.signUpWithEmail(any, any, any));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  testWidgets('SignUpScreen validates email format',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWith((ref) => mockAuthService),
          ],
          child: const MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // Enter name but invalid email
      await tester.enterText(
          find.widgetWithText(TextField, 'Full Name'), 'John Doe');
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'notanemail');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password123');

      await tester.tap(find.text('Sign Up'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Please enter a valid email'), findsOneWidget);
      verifyNever(mockAuthService.signUpWithEmail(any, any, any));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
