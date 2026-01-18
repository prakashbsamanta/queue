import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 2)
class Session extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int durationPlayed; // in seconds

  Session({
    required this.date,
    required this.durationPlayed,
  });
}
