import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    return await _authService.signInWithEmail(email, password);
  }

  Future<User?> signUpWithEmail(String email, String password, String name) async {
    return await _authService.signUpWithEmail(email, password, name);
  }

  Future<User?> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  String? getAuthExceptionMessage(dynamic error) {
    return _authService.getAuthExceptionMessage(error);
  }
}
