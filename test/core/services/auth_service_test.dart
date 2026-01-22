
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flow_state/core/services/auth_service.dart';

// Generate Mocks
@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
])
import 'auth_service_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late FirebaseAuthService authService;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    
    // Inject mocks
    authService = FirebaseAuthService(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('AuthService', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('signInWithEmail calls FirebaseAuth signInWithEmailAndPassword', () async {
      // Arrange
      when(mockAuth.signInWithEmailAndPassword(email: email, password: password))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      // Act
      final result = await authService.signInWithEmail(email, password);

      // Assert
      verify(mockAuth.signInWithEmailAndPassword(email: email, password: password)).called(1);
      expect(result, mockUser);
    });

    test('signOut calls signOut on both providers', () async {
      // Act
      await authService.signOut();

      // Assert
      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockAuth.signOut()).called(1);
    });
    
    test('signUpWithEmail creates user and updates display name', () async {
        const name = "Test User";
        when(mockAuth.createUserWithEmailAndPassword(email: email, password: password))
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockAuth.currentUser).thenReturn(mockUser);

        final result = await authService.signUpWithEmail(email, password, name);
        
        verify(mockAuth.createUserWithEmailAndPassword(email: email, password: password)).called(1);
        verify(mockUser.updateDisplayName(name)).called(1);
        expect(result, mockUser);
    });

    test('signInWithGoogle signs in and returns user', () async {
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      final mockOAuthCredential = MockUserCredential(); // Credential return is usually UserCredential

      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleAuth.accessToken).thenReturn('access_token');
      when(mockGoogleAuth.idToken).thenReturn('id_token');
      when(mockAuth.signInWithCredential(any)).thenAnswer((_) async => mockOAuthCredential);
      when(mockOAuthCredential.user).thenReturn(mockUser);

      final result = await authService.signInWithGoogle();

      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockAuth.signInWithCredential(any)).called(1);
      expect(result, mockUser);
    });

    test('signInWithGoogle returns null if cancelled', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await authService.signInWithGoogle();

      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockAuth.signInWithCredential(any));
      expect(result, null);
    });

    test('sendPasswordResetEmail calls firebase auth', () async {
      await authService.sendPasswordResetEmail(email);
      verify(mockAuth.sendPasswordResetEmail(email: email)).called(1);
    });

    test('getAuthExceptionMessage returns correct messages', () {
      expect(authService.getAuthExceptionMessage(FirebaseAuthException(code: 'user-not-found')), 'There is no user corresponding to this email.');
      expect(authService.getAuthExceptionMessage(FirebaseAuthException(code: 'wrong-password')), contains('user record corresponding'));
      expect(authService.getAuthExceptionMessage('Random Error'), 'Random Error');
    });

    test('currentUser returns auth.currentUser', () {
      when(mockAuth.currentUser).thenReturn(mockUser);
      expect(authService.currentUser, mockUser);
    });
  });
}
