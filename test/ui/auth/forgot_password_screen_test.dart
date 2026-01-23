import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_state/ui/auth/forgot_password_screen.dart';
import 'package:flow_state/core/services/auth_service.dart';
import 'package:flow_state/logic/auth/auth_provider.dart';

@GenerateNiceMocks([MockSpec<AuthService>()])
import 'forgot_password_screen_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('ForgotPasswordScreen sends reset email', (WidgetTester tester) async {
    when(mockAuthService.sendPasswordResetEmail(any)).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWith((ref) => mockAuthService),
        ],
        child: const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ),
    );

    expect(find.text('Reset Password'), findsOneWidget);

    // Enter email
    await tester.enterText(find.byType(TextField), 'john@example.com');

    // Tap Reset
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    verify(mockAuthService.sendPasswordResetEmail('john@example.com')).called(1);
    // expect(find.text('Check your email for reset link'), findsOneWidget);
  });
}
