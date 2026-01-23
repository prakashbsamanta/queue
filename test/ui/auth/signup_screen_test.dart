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
    when(mockAuthService.signUpWithEmail(any, any, any)).thenAnswer((_) async => null);

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
    await tester.enterText(find.widgetWithText(TextField, 'Full Name'), 'John Doe');
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'john@example.com');
    
    // Password field is tricky due to multiple fields.
    // "Password" hint.
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');

    // Tap Sign Up
    await tester.tap(find.text('Sign Up'));
    await tester.pump(); // Start logic
    await tester.pump(const Duration(milliseconds: 100)); // Processing
    await tester.pumpAndSettle();

    verify(mockAuthService.signUpWithEmail('john@example.com', 'password123', 'John Doe')).called(1);
    // Should pop?
    // We can't verify pop easily without navigator observer.
    // But verify call is enough for logic coverage.
  });
}
