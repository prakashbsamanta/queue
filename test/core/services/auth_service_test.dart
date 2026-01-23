import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flow_state/core/services/auth_service.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<User>(),
  MockSpec<UserCredential>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
])
import 'auth_service_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late FirebaseAuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    authService =
        FirebaseAuthService(auth: mockAuth, googleSignIn: mockGoogleSignIn);
  });

  group('FirebaseAuthService', () {
    test('signInWithEmail returns user on success', () async {
      when(mockAuth.signInWithEmailAndPassword(
              email: 't@t.com', password: '123'))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      final result = await authService.signInWithEmail('t@t.com', '123');
      expect(result, mockUser);
      verify(mockAuth.signInWithEmailAndPassword(
              email: 't@t.com', password: '123'))
          .called(1);
    });

    test('signUpWithEmail creates user and updates display name', () async {
      when(mockAuth.createUserWithEmailAndPassword(
              email: 't@t.com', password: '123'))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockAuth.currentUser).thenReturn(mockUser);

      final result =
          await authService.signUpWithEmail('t@t.com', '123', 'Test');

      expect(result, mockUser);
      verify(mockUser.updateDisplayName('Test')).called(1);
      verify(mockUser.reload()).called(1);
    });

    test('signOut calls signOut on both providers', () async {
      await authService.signOut();
      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockAuth.signOut()).called(1);
    });

    test('getAuthExceptionMessage returns correct message', () {
      final e = FirebaseAuthException(code: 'user-not-found');
      expect(authService.getAuthExceptionMessage(e),
          'There is no user corresponding to this email.');
      expect(authService.getAuthExceptionMessage('error'), 'error');
    });
  });
}
