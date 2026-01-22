import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/auth/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';
import '../widgets/neo_loading.dart';
import '../widgets/neo_error.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateChangesProvider);

    return authStateAsync.when(
      data: (user) {
        if (user != null) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: NeoLoading(message: 'Checking Authentication...'),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: NeoError(error: err),
        ),
      ),
    );
  }
}
