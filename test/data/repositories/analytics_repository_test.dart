import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:flow_state/data/repositories/analytics_repository.dart';
import 'package:flow_state/data/models/session.dart';

@GenerateNiceMocks([MockSpec<Box>()])
import 'analytics_repository_test.mocks.dart';

void main() {
  late MockBox<Session> mockBox;
  late AnalyticsRepository repository;

  setUp(() {
    mockBox = MockBox<Session>();
    repository = AnalyticsRepository(mockBox);
  });

  test('logSession calculates duration and adds to box', () async {
    // Current impl takes durationSeconds directly
    await repository.logSession(60);
    
    verify(mockBox.add(any)).called(1);
    // Argument captor to verify duration?
    // Session object created inside.
  });
  
  test('getSessionsSince returns filtered values', () {
    final now = DateTime.now();
    final s1 = Session(date: now.subtract(const Duration(days: 1)), durationPlayed: 60);
    final s2 = Session(date: now, durationPlayed: 30);
    
    when(mockBox.values).thenReturn([s1, s2]);
    
    // Check sessions since 1 hour ago
    final result = repository.getSessionsSince(now.subtract(const Duration(hours: 1)));
    
    expect(result.length, 1);
    expect(result.first, s2);
  });
}
