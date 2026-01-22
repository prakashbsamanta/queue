
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_state/core/services/auth_service.dart';
import 'package:flow_state/data/repositories/auth_repository.dart';

@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<User>(),
])
import 'auth_repository_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late AuthRepository authRepository;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    authRepository = AuthRepository(mockAuthService);
    mockUser = MockUser();
  });

  group('AuthRepository', () {
    const email = 'test@example.com';
    const password = 'password123';
    const name = 'Test User';

    test('signInWithEmail delegates to AuthService', () async {
      when(mockAuthService.signInWithEmail(email, password))
          .thenAnswer((_) async => mockUser);

      final result = await authRepository.signInWithEmail(email, password);

      verify(mockAuthService.signInWithEmail(email, password)).called(1);
      expect(result, mockUser);
    });

    test('signUpWithEmail delegates to AuthService', () async {
      when(mockAuthService.signUpWithEmail(email, password, name))
          .thenAnswer((_) async => mockUser);

      final result = await authRepository.signUpWithEmail(email, password, name);

      verify(mockAuthService.signUpWithEmail(email, password, name)).called(1);
      expect(result, mockUser);
    });

    test('signOut delegates to AuthService', () async {
      await authRepository.signOut();
      verify(mockAuthService.signOut()).called(1);
    });

    test('authStateChanges returns stream from AuthService', () {
      final stream = Stream<User?>.value(mockUser);
      when(mockAuthService.authStateChanges).thenAnswer((_) => stream);

      expect(authRepository.authStateChanges, stream);
    });
  });
}
