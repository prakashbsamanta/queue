import 'package:flutter_test/flutter_test.dart';
import 'package:flow_state/data/models/video.dart';

void main() {
  test('Video model properties and copyWith', () {
    final video = Video(
      id: 'v1',
      youtubeId: 'y1',
      title: 'V1',
      thumbnailUrl: 't',
      durationSeconds: 100,
      watchedSeconds: 10,
      isCompleted: false,
    );

    expect(video.id, 'v1');

    final updated = video.copyWith(watchedSeconds: 50, isCompleted: true);
    expect(updated.watchedSeconds, 50);
    expect(updated.isCompleted, true);
    expect(updated.id, 'v1'); // Unchanged

    final same = video.copyWith();
    expect(same.id, video.id);
  });

  test('Video model with resourceType and content', () {
    final video = Video(
      id: 'v1',
      youtubeId: '',
      title: 'Article',
      thumbnailUrl: '',
      durationSeconds: 0,
      resourceType: 'url',
      content: 'https://example.com/article',
    );

    expect(video.resourceType, 'url');
    expect(video.content, 'https://example.com/article');

    final updated = video.copyWith(
      resourceType: 'text',
      content: 'Updated content',
    );
    expect(updated.resourceType, 'text');
    expect(updated.content, 'Updated content');
  });

  test('Video copyWith preserves all fields', () {
    final video = Video(
      id: 'v1',
      youtubeId: 'y1',
      title: 'Title',
      thumbnailUrl: 'thumb',
      durationSeconds: 300,
      watchedSeconds: 100,
      isCompleted: false,
      resourceType: 'youtube',
      content: 'https://youtube.com',
    );

    final updated = video.copyWith(
      id: 'v2',
      youtubeId: 'y2',
      title: 'New Title',
      thumbnailUrl: 'new_thumb',
      durationSeconds: 600,
    );

    expect(updated.id, 'v2');
    expect(updated.youtubeId, 'y2');
    expect(updated.title, 'New Title');
    expect(updated.thumbnailUrl, 'new_thumb');
    expect(updated.durationSeconds, 600);
    // These should be preserved from original
    expect(updated.watchedSeconds, 100);
    expect(updated.isCompleted, false);
    expect(updated.resourceType, 'youtube');
    expect(updated.content, 'https://youtube.com');
  });
}
