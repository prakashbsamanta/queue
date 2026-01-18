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
      await ref.read(courseRepositoryProvider).addResourceToCourse(courseId, content, type);
    });
  }
}
