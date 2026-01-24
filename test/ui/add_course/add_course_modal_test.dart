import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_state/ui/add_course/add_course_modal.dart';
// import 'package:flow_state/logic/add_course_logic.dart'; // Unused
import 'package:flow_state/logic/providers.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/models/video.dart';
import 'package:flow_state/data/services/youtube_service.dart';
import 'package:flow_state/data/services/services_provider.dart';
import 'package:flow_state/data/repositories/course_repository.dart';
import 'package:flow_state/ui/widgets/neo_error.dart';

@GenerateNiceMocks([MockSpec<YouTubeService>(), MockSpec<CourseRepository>()])
import 'add_course_modal_test.mocks.dart';

void main() {
  late MockYouTubeService mockYouTubeService;
  late MockCourseRepository mockCourseRepository;

  setUp(() {
    mockYouTubeService = MockYouTubeService();
    mockCourseRepository = MockCourseRepository();
  });

  testWidgets('AddCourseModal creates new course from URL',
      (WidgetTester tester) async {
    final course = Course(
        id: '1',
        title: 'New Course',
        thumbnailUrl: 't',
        sourceUrl: 'u',
        totalDuration: 1,
        videos: [],
        dateAdded: DateTime.now());

    when(mockYouTubeService.extractCourse(any)).thenAnswer((_) async => course);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          youTubeServiceProvider.overrideWith((ref) => mockYouTubeService),
          courseRepositoryProvider.overrideWith((ref) => mockCourseRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AddCourseModal()),
        ),
      ),
    );

    // Enter URL
    await tester.enterText(
        find.byType(TextField).first, 'https://youtube.com/playlist?list=Test');
    await tester.pumpAndSettle();

    // Tap Create
    await tester.tap(find.text('Create Course'));
    await tester.pump(); // Start logic
    await tester.pump(const Duration(seconds: 2)); // Wait for async
    await tester.pumpAndSettle(); // Finish animations

    // Verify
    expect(find.byType(NeoError), findsNothing);
    verify(mockYouTubeService.extractCourse(any)).called(1);
    verify(mockCourseRepository.addCourse(course)).called(1);
    // expect(find.text('Course Created'), findsOneWidget);
  });

  testWidgets('AddCourseModal adds to existing course',
      (WidgetTester tester) async {
    final existingCourse = Course(
        id: 'c1',
        title: 'Existing Course',
        thumbnailUrl: 't',
        sourceUrl: 'u',
        totalDuration: 0,
        videos: [],
        dateAdded: DateTime.now());

    // Mock YouTube extraction returning a course with video (logic extracts course then takes video)
    final video = Video(
        id: 'v1',
        youtubeId: 'y1',
        title: 'V1',
        thumbnailUrl: 't',
        durationSeconds: 60,
        watchedSeconds: 0,
        isCompleted: false);
    final extractedCourse = Course(
        id: 'extracted',
        title: 'Start',
        thumbnailUrl: 't',
        sourceUrl: 'u',
        totalDuration: 60,
        videos: [video],
        dateAdded: DateTime.now());

    when(mockYouTubeService.extractCourse(any))
        .thenAnswer((_) async => extractedCourse);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          youTubeServiceProvider.overrideWith((ref) => mockYouTubeService),
          courseRepositoryProvider.overrideWith((ref) => mockCourseRepository),
          allCoursesProvider
              .overrideWith((ref) => Stream.value([existingCourse])),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AddCourseModal()),
        ),
      ),
    );
    await tester.pumpAndSettle(); // Wait for stream to load data

    // Toggle switch
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Select course from dropdown
    await tester.tap(find.text('Select Course'));
    await tester.pumpAndSettle();

    // Tap the item (Existing Course)
    // There might be 2 widgets with text (in dropdown and selected).
    // The dropdown item is in the overlay.
    await tester.tap(find.text('Existing Course').last);
    await tester.pumpAndSettle();

    // Enter URL
    await tester.enterText(
        find.byType(TextField).last, 'https://youtube.com/watch?v=y1');
    await tester.pumpAndSettle();

    // Tap Add Resource
    await tester.tap(find.text('Add Resource'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify
    verify(mockYouTubeService.extractCourse(any)).called(1);
    // Verify repository call
    // Note argument matcher for Video might be tricky if copyWith changed it.
    // Logic calls next: video.copyWith(resourceType: 'youtube', content: ...)
    verify(mockCourseRepository.addVideoToCourse('c1', any)).called(1);
  });

  testWidgets('AddCourseModal pre-fills text field when initialUrl is provided',
      (WidgetTester tester) async {
    const initialUrl = 'https://example.com/shared';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          youTubeServiceProvider.overrideWith((ref) => mockYouTubeService),
          courseRepositoryProvider.overrideWith((ref) => mockCourseRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AddCourseModal(initialUrl: initialUrl)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(initialUrl), findsOneWidget);
  });

  testWidgets('AddCourseModal creates course from non-YouTube URL',
      (WidgetTester tester) async {
    const testUrl = 'https://www.example.com/article';
    final createdCourse = Course(
        id: 'new-course',
        title: 'example.com',
        thumbnailUrl: '',
        sourceUrl: '',
        totalDuration: 0,
        videos: [],
        dateAdded: DateTime.now());

    // Mock creating an empty course
    when(mockCourseRepository.createEmptyCourse(any)).thenAnswer((_) async {});
    when(mockCourseRepository.addResourceToCourse(any, any, any))
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          youTubeServiceProvider.overrideWith((ref) => mockYouTubeService),
          courseRepositoryProvider.overrideWith((ref) => mockCourseRepository),
          allCoursesProvider
              .overrideWith((ref) => Stream.value([createdCourse])),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AddCourseModal()),
        ),
      ),
    );

    // Enter non-YouTube URL
    await tester.enterText(find.byType(TextField).first, testUrl);
    await tester.pumpAndSettle();

    // Tap Create
    await tester.tap(find.text('Create Course'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify course was created with domain name
    verify(mockCourseRepository.createEmptyCourse('example.com')).called(1);
    // Verify URL was added as resource
    verify(mockCourseRepository.addResourceToCourse(
            'new-course', testUrl, 'url'))
        .called(1);
  });

  testWidgets('AddCourseModal shows error when validation fails',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          youTubeServiceProvider.overrideWith((ref) => mockYouTubeService),
          courseRepositoryProvider.overrideWith((ref) => mockCourseRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AddCourseModal()),
        ),
      ),
    );

    // Tap Create without entering anything
    await tester.tap(find.text('Create Course'));
    await tester.pumpAndSettle();

    // Should show validation error
    expect(find.text('Please enter content'), findsOneWidget);
  });

  testWidgets('AddCourseModal creates course from plain text',
      (WidgetTester tester) async {
    const courseName = 'My Custom Course';

    when(mockCourseRepository.createEmptyCourse(any)).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          youTubeServiceProvider.overrideWith((ref) => mockYouTubeService),
          courseRepositoryProvider.overrideWith((ref) => mockCourseRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AddCourseModal()),
        ),
      ),
    );

    // Enter plain text (not a URL)
    await tester.enterText(find.byType(TextField).first, courseName);
    await tester.pumpAndSettle();

    // Tap Create
    await tester.tap(find.text('Create Course'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify course was created with the text as name
    verify(mockCourseRepository.createEmptyCourse(courseName)).called(1);
  });
}
