import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_state/ui/auth/login_screen.dart';
import 'package:flow_state/logic/auth/auth_provider.dart';
import 'package:flow_state/data/repositories/auth_repository.dart';

import 'package:flutter_animate/flutter_animate.dart';

// Generate Mocks
@GenerateNiceMocks([MockSpec<AuthRepository>()])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    // Disable flutter_animate for testing or make it instant
    Animate.restartOnHotReload = false;
    // Animate.timeDilation = 0.0; // This sometimes causes issues if widgets depend on finite duration
  });

  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.byType(TextField),
          findsAtLeastNWidgets(2)); // Email and Password

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  testWidgets('Tapping Sign In with empty fields does not call repository',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump(const Duration(seconds: 2));

      verifyNever(mockAuthRepository.signInWithEmail(any, any));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  // Note: Testing full form submission requires entering text, ensuring validation passes,
  // and then verifying the repository call.
  // For brevity/stability in this initial suite, checking rendering and overrides is a good start.

  testWidgets('LoginScreen shows validation errors for invalid email',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));

      // Enter invalid email
      await tester.enterText(find.byType(TextField).first, 'invalidemail');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  testWidgets('LoginScreen shows validation error for empty password',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));

      // Enter email but no password
      await tester.enterText(find.byType(TextField).first, 'test@example.com');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  testWidgets('LoginScreen has Forgot Password link',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Forgot Password?'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  testWidgets('LoginScreen has Sign Up link', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
