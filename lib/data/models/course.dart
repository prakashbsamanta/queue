import 'package:hive/hive.dart';
import 'video.dart';

part 'course.g.dart';

@HiveType(typeId: 1)
class Course extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String thumbnailUrl;

  @HiveField(3)
  final String sourceUrl; // Playlist or Video URL

  @HiveField(4)
  final int totalDuration;

  @HiveField(5)
  int watchedDuration;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  List<Video> videos;

  @HiveField(8)
  String? lastPlayedVideoId;

  @HiveField(9)
  final DateTime dateAdded;

  Course({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.sourceUrl,
    required this.totalDuration,
    this.watchedDuration = 0,
    this.isCompleted = false,
    required this.videos,
    this.lastPlayedVideoId,
    required this.dateAdded,
  });

  Course copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    String? sourceUrl,
    int? totalDuration,
    int? watchedDuration,
    bool? isCompleted,
    List<Video>? videos,
    String? lastPlayedVideoId,
    DateTime? dateAdded,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      totalDuration: totalDuration ?? this.totalDuration,
      watchedDuration: watchedDuration ?? this.watchedDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      videos: videos ?? this.videos,
      lastPlayedVideoId: lastPlayedVideoId ?? this.lastPlayedVideoId,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
