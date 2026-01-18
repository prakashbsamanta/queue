import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/course_repository.dart';
import '../data/services/services_provider.dart';

part 'add_course_logic.g.dart';

@riverpod
class AddCourseLogic extends _$AddCourseLogic {
  @override
  FutureOr<void> build() {
    // Initial state is idle (void)
  }

  Future<void> addCourseFromUrl(String url) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final youtubeService = ref.read(youTubeServiceProvider);
      try {
        final course = await youtubeService.extractCourse(url);
        await ref.read(courseRepositoryProvider).addCourse(course);
      } finally {
        // No disposal needed here
      }
    });
  }

  Future<void> addCourseByName(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(courseRepositoryProvider).createEmptyCourse(name);
    });
  }

  Future<void> addToExistingCourse(String courseId, String content, String type) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (type == 'youtube') {
        final youtubeService = ref.read(youTubeServiceProvider);
        // Reuse the extraction logic. 
        // Note: extractCourse returns a Course object with a list of videos.
        final extractedCourse = await youtubeService.extractCourse(content);
        
        for (final video in extractedCourse.videos) {
          // Ensure we persist the resource type and content url
          final videoToAdd = video.copyWith(
             resourceType: 'youtube',
             content: content.contains('playlist') ? 'https://youtube.com/watch?v=${video.youtubeId}' : content,
          );
          await ref.read(courseRepositoryProvider).addVideoToCourse(courseId, videoToAdd);
        }
      } else {
        await ref.read(courseRepositoryProvider).addResourceToCourse(courseId, content, type);
      }
    });
  }
}
