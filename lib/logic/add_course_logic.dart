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
      try { // dispose is not needed if provider handles it or if service is disposable. 
            // YouTubeService has dispose, but provider won't call it automatically unless we use autoDispose and ref.onDispose.
            // But we are creating a new one in provider each time? No, default is autoDispose.
            // Actually, let's keep it simple. ref.read gives us the service.
            // The service is recreated? No, default provider caches it.
        final course = await youtubeService.extractCourse(url);
        await ref.read(courseRepositoryProvider).addCourse(course);
      } finally {
        // We probably shouldn't dispose the shared service here.
        // youtubeService.dispose(); 
      }
    });
  }
}
