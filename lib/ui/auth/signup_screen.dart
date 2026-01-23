import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../logic/auth/auth_provider.dart';
import '../widgets/neo_error.dart';
import '../widgets/neo_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
      
      if (mounted && !ref.read(authControllerProvider).hasError) {
         // Success - Auto navigating via AuthWrapper usually, but here we can just pop
         // Or if we replace Login with AuthWrapper, the stream updates. 
         // Since we pushed SignUp from Login, if auth state changes, AuthWrapper (if is parent) will rebuild.
         // If Login is shown by AuthWrapper, and login pushes SignUp, then AuthWrapper rebuilds -> Dashboard.
         // We should pop SignUp if we want to return to flow or let AuthWrapper handle it.
         // Usually AuthWrapper is at root. So Login is replaced by Dashboard. 
         // But SignUp is on top of Login. So we should pop to root?
         // Actually, if AuthWrapper sees user, it puts Dashboard. Which replaces Login logic.
         // So assuming AuthWrapper is at MaterialApp home.
         // We might need to pop all route if we are in a stack.
         Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  'Create Account',
                  style: Theme.of(context).textTheme.displayLarge,
                ).animate().fadeIn().moveY(begin: 10, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Start your learning journey today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 100.ms).moveY(begin: 10, end: 0),
                const SizedBox(height: 48),

                if (authState.hasError)
                   Padding(
                     padding: const EdgeInsets.only(bottom: 24),
                     child: NeoError(error: ref.read(authControllerProvider.notifier).getAuthExceptionMessage(authState.error) ?? authState.error!),
                   ).animate().fadeIn(),

                NeoTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your name';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                const SizedBox(height: 16),

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
                ).animate().fadeIn(delay: 300.ms).moveY(begin: 10, end: 0),
                const SizedBox(height: 16),
                
                NeoTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0),
                
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _signUp,
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
                            'Sign Up',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ).animate().fadeIn(delay: 500.ms).moveY(begin: 10, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
