import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/session.dart';

part 'analytics_repository.g.dart';

class AnalyticsRepository {
  final Box<Session> _sessionBox;

  AnalyticsRepository(this._sessionBox);

  Future<void> logSession(int durationSeconds) async {
    final session = Session(
      date: DateTime.now(),
      durationPlayed: durationSeconds,
    );
    await _sessionBox.add(session);
  }

  List<Session> getSessionsSince(DateTime date) {
    return _sessionBox.values.where((s) => s.date.isAfter(date)).toList();
  }
}

@riverpod
AnalyticsRepository analyticsRepository(AnalyticsRepositoryRef ref) {
  final box = Hive.box<Session>('sessions');
  return AnalyticsRepository(box);
}
