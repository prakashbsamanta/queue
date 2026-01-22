
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_state/ui/auth/auth_wrapper.dart';
import 'package:flow_state/logic/auth/auth_provider.dart';
import 'package:flow_state/ui/auth/login_screen.dart';
import 'package:flow_state/ui/dashboard/dashboard_screen.dart';

// We don't need build_runner here if we just override the stream provider
// But we do need a MockUser to emit valid data.
// We can assume MockUser is available if we export it from somewhere, 
// but simplified: we can just use a specific type or null.

class MockUser extends Mock implements User {}

void main() {
  testWidgets('AuthWrapper shows LoginScreen when user is null', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            home: AuthWrapper(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2)); // Wait for Stream and Animations

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);
      
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  testWidgets('AuthWrapper shows DashboardScreen when user is present', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final mockUser = MockUser();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateChangesProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
          child: const MaterialApp(
            home: AuthWrapper(),
          ),
        ),
      );
       await tester.pump(const Duration(seconds: 2)); // Wait for Stream and Animations

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
