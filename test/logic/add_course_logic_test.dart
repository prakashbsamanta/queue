import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_state/logic/add_course_logic.dart';
import 'package:flow_state/data/services/youtube_service.dart';
import 'package:flow_state/data/services/services_provider.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/repositories/course_repository.dart';

@GenerateNiceMocks([MockSpec<YouTubeService>(), MockSpec<CourseRepository>()])
import 'add_course_logic_test.mocks.dart';

void main() {
  late MockYouTubeService mockYouTubeService;
  late MockCourseRepository mockCourseRepository;

  setUp(() {
    mockYouTubeService = MockYouTubeService();
    mockCourseRepository = MockCourseRepository();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        youTubeServiceProvider.overrideWith((ref) => mockYouTubeService),
        courseRepositoryProvider.overrideWith((ref) => mockCourseRepository),
      ],
    );
  }

  test('Add Course Success', () async {
    final container = createContainer();
    final course = Course(
      id: '123', 
      title: 'Test Course', 
      thumbnailUrl: 'thumb', 
      sourceUrl: 'url', 
      totalDuration: 100, 
      videos: [], 
      dateAdded: DateTime.now()
    );

    when(mockYouTubeService.extractCourse(any)).thenAnswer((_) async => course);

    // Call addCourse
    await container.read(addCourseLogicProvider.notifier).addCourseFromUrl('https://youtube.com/playlist?list=Test');

    // Verify
    final state = container.read(addCourseLogicProvider);
    expect(state.hasError, false);
    expect(state.isLoading, false);
    
    verify(mockYouTubeService.extractCourse(any)).called(1);
    verify(mockCourseRepository.addCourse(course)).called(1);
    
    container.dispose();
  });

  test('Add Course Failure - API Error', () async {
    final container = createContainer();

    when(mockYouTubeService.extractCourse(any)).thenThrow(Exception('API Failed'));

    // Call addCourse
    await container.read(addCourseLogicProvider.notifier).addCourseFromUrl('https://youtube.com/playlist?list=Fail');

    // Verify error state
    final state = container.read(addCourseLogicProvider);
    expect(state.hasError, true);
    expect(state.error.toString(), contains('API Failed'));
    
    verifyNever(mockCourseRepository.addCourse(any));
    
    container.dispose();
  });
}
