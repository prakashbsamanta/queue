import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_state/logic/add_course_logic.dart';
import 'package:flow_state/data/services/youtube_service.dart';
import 'package:flow_state/data/services/services_provider.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/models/video.dart';
import 'package:flow_state/data/repositories/course_repository.dart';
// import 'package:hive/hive.dart';

// Create Fakes
class FakeYouTubeService implements YouTubeService {
  bool extractCourseCalled = false;

  @override
  Future<Course> extractCourse(String url) async {
    extractCourseCalled = true;
    return Course(
      id: '123', 
      title: 'Test Course', 
      thumbnailUrl: 'http://test.com/1.jpg', 
      sourceUrl: url, 
      totalDuration: 100, 
      videos: [
        Video(id: 'v1', youtubeId: 'y1', title: 'Video 1', thumbnailUrl: '', durationSeconds: 100)
      ], 
      dateAdded: DateTime.now()
    );
  }


}

class FakeCourseRepository implements CourseRepository {
  bool addCourseCalled = false;
  Course? addedCourse;

  @override
  Future<void> addCourse(Course course) async {
    addCourseCalled = true;
    addedCourse = course;
  }

  @override
  Future<void> deleteCourse(String id) async {}

  @override
  List<Course> getAllCourses() => [];

  @override
  Future<void> updateCourse(Course course) async {}

  @override
  Future<void> updateVideoProgress(String courseId, String videoId, int positionSeconds) async {}

  @override
  Future<void> createEmptyCourse(String title) async {
    // Stub implementation
  }

  @override
  Future<void> addResourceToCourse(String courseId, String content, String type) async {
    // Stub implementation
  }

  @override
  Future<void> addVideoToCourse(String courseId, Video video) async {
    // Stub implementation
  }
}

void main() {
  late FakeYouTubeService fakeYouTubeService;
  late FakeCourseRepository fakeCourseRepository;

  setUp(() {
    fakeYouTubeService = FakeYouTubeService();
    fakeCourseRepository = FakeCourseRepository();
  });

  test('Add Course Logic Test', () async {
    final container = ProviderContainer(
      overrides: [
        youTubeServiceProvider.overrideWith((ref) => fakeYouTubeService),
        courseRepositoryProvider.overrideWith((ref) => fakeCourseRepository),
      ],
    );

    // Call addCourse
    await container.read(addCourseLogicProvider.notifier).addCourseFromUrl('https://youtube.com/playlist?list=Test');

    // Verify loading and success
    // Wait for the async operation to complete? 
    // Since addCourseFromUrl awaits internally, and we await it, it should be done.
    
    // Check provider state. It should be AsyncData(void) if successful.
    final state = container.read(addCourseLogicProvider);
    expect(state.hasError, false);
    
    // Verify mocks called
    expect(fakeYouTubeService.extractCourseCalled, true);
    expect(fakeCourseRepository.addCourseCalled, true);
    expect(fakeCourseRepository.addedCourse?.id, '123');
    
    container.dispose();
  });
}
