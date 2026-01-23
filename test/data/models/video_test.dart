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
}
