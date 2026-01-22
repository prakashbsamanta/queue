
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
  });
}
