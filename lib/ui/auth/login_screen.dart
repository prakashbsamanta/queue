import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../logic/auth/auth_provider.dart';
import '../widgets/neo_error.dart';
import '../widgets/neo_text_field.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      
      if (mounted && ref.read(authControllerProvider).hasError) {
         // Error is displayed by the provider state watching
      }
    }
  }

  Future<void> _loginGoogle() async {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displayLarge,
                ).animate().fadeIn().moveY(begin: 10, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your progress',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 100.ms).moveY(begin: 10, end: 0),
                const SizedBox(height: 48),

                if (authState.hasError)
                   Padding(
                     padding: const EdgeInsets.only(bottom: 24),
                     child: NeoError(error: ref.read(authControllerProvider.notifier).getAuthExceptionMessage(authState.error) ?? authState.error!),
                   ).animate().fadeIn(),

                NeoTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                const SizedBox(height: 16),
                
                NeoTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).moveY(begin: 10, end: 0),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0),

                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                    ),
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                  ],
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: authState.isLoading ? null : _loginGoogle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 28), // Placeholder for Google Icon
                    label: const Text('Sign in with Google'),
                  ),
                ).animate().fadeIn(delay: 500.ms).moveY(begin: 10, end: 0),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account? ', style: TextStyle(color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () {
                         Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 550.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
