import 'package:flutter_test/flutter_test.dart';
import 'package:flow_state/data/models/session.dart';

void main() {
  test('Session model properties', () {
    final date = DateTime(2024, 1, 1, 10, 30);
    final session = Session(
      date: date,
      durationPlayed: 300, // 5 minutes
    );

    expect(session.date, date);
    expect(session.durationPlayed, 300);
  });

  test('Session model with different durations', () {
    final date = DateTime.now();

    // Zero duration session
    final zeroSession = Session(date: date, durationPlayed: 0);
    expect(zeroSession.durationPlayed, 0);

    // Long session (1 hour)
    final longSession = Session(date: date, durationPlayed: 3600);
    expect(longSession.durationPlayed, 3600);
  });
}
