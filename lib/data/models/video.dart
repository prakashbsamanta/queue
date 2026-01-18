import 'package:hive/hive.dart';

part 'video.g.dart';

@HiveType(typeId: 0)
class Video extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String youtubeId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String thumbnailUrl;

  @HiveField(4)
  final int durationSeconds;

  @HiveField(5)
  int watchedSeconds;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  final String? resourceType; // 'youtube', 'url', 'text'

  @HiveField(8)
  final String? content; // The url or text body

  Video({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.thumbnailUrl,
    required this.durationSeconds,
    this.watchedSeconds = 0,
    this.isCompleted = false,
    this.resourceType,
    this.content,
  });

  Video copyWith({
    String? id,
    String? youtubeId,
    String? title,
    String? thumbnailUrl,
    int? durationSeconds,
    int? watchedSeconds,
    bool? isCompleted,
    String? resourceType,
    String? content,
  }) {
    return Video(
      id: id ?? this.id,
      youtubeId: youtubeId ?? this.youtubeId,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      resourceType: resourceType ?? this.resourceType,
      content: content ?? this.content,
    );
  }
}
