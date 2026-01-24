import 'package:flutter_test/flutter_test.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/models/video.dart';

void main() {
  final testVideo = Video(
    id: 'v1',
    youtubeId: 'y1',
    title: 'Test Video',
    thumbnailUrl: 'thumb',
    durationSeconds: 100,
    watchedSeconds: 0,
    isCompleted: false,
  );

  test('Course model properties and copyWith', () {
    final course = Course(
      id: 'c1',
      title: 'Test Course',
      thumbnailUrl: 'thumb',
      sourceUrl: 'source',
      totalDuration: 100,
      videos: [testVideo],
      dateAdded: DateTime(2024, 1, 1),
    );

    expect(course.id, 'c1');
    expect(course.title, 'Test Course');
    expect(course.videos.length, 1);

    final updated = course.copyWith(title: 'Updated Title');
    expect(updated.title, 'Updated Title');
    expect(updated.id, 'c1'); // Unchanged
  });

  test('Course copyWith with duration changes', () {
    final course = Course(
      id: 'c1',
      title: 'Test Course',
      thumbnailUrl: 'thumb',
      sourceUrl: 'source',
      totalDuration: 100,
      videos: [],
      dateAdded: DateTime(2024, 1, 1),
    );

    final withDuration =
        course.copyWith(totalDuration: 200, watchedDuration: 100);
    expect(withDuration.totalDuration, 200);
    expect(withDuration.watchedDuration, 100);
  });

  test('Course copyWith with isCompleted flag', () {
    final course = Course(
      id: 'c1',
      title: 'Test Course',
      thumbnailUrl: 'thumb',
      sourceUrl: 'source',
      totalDuration: 100,
      videos: [],
      dateAdded: DateTime(2024, 1, 1),
    );

    expect(course.isCompleted, false);

    final completed = course.copyWith(isCompleted: true);
    expect(completed.isCompleted, true);
  });

  test('Course copyWith with lastPlayedVideoId', () {
    final course = Course(
      id: 'c1',
      title: 'Test Course',
      thumbnailUrl: 'thumb',
      sourceUrl: 'source',
      totalDuration: 100,
      videos: [testVideo],
      dateAdded: DateTime(2024, 1, 1),
    );

    expect(course.lastPlayedVideoId, null);

    final withLastPlayed = course.copyWith(lastPlayedVideoId: 'v1');
    expect(withLastPlayed.lastPlayedVideoId, 'v1');
  });

  test('Course copyWith with videos list update', () {
    final video2 = Video(
      id: 'v2',
      youtubeId: 'y2',
      title: 'Test Video 2',
      thumbnailUrl: 'thumb2',
      durationSeconds: 200,
      watchedSeconds: 0,
      isCompleted: false,
    );

    final course = Course(
      id: 'c1',
      title: 'Test Course',
      thumbnailUrl: 'thumb',
      sourceUrl: 'source',
      totalDuration: 100,
      videos: [testVideo],
      dateAdded: DateTime(2024, 1, 1),
    );

    final updated = course.copyWith(videos: [testVideo, video2]);
    expect(updated.videos.length, 2);
    expect(updated.videos[1].id, 'v2');
  });
}
