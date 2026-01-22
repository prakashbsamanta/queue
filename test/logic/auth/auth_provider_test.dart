import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_state/logic/auth/auth_provider.dart';
import 'package:flow_state/data/repositories/auth_repository.dart';

@GenerateNiceMocks([MockSpec<AuthRepository>()])
import 'auth_provider_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  test('signOut calls repository', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => mockAuthRepository),
      ],
    );

    await container.read(authControllerProvider.notifier).signOut();
    
    verify(mockAuthRepository.signOut()).called(1);
  });

  test('signInWithGoogle calls repository', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => mockAuthRepository),
      ],
    );

    await container.read(authControllerProvider.notifier).signInWithGoogle();
    
    verify(mockAuthRepository.signInWithGoogle()).called(1);
  });

  test('getAuthExceptionMessage delegates to repository', () {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => mockAuthRepository),
      ],
    );
    
    when(mockAuthRepository.getAuthExceptionMessage('error')).thenReturn('Parsed Error');

    final msg = container.read(authControllerProvider.notifier).getAuthExceptionMessage('error');
    expect(msg, 'Parsed Error');
  });
}
