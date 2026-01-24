import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flow_state/ui/course_detail/course_detail_screen.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/models/video.dart';
import 'package:flow_state/data/repositories/course_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:flow_state/data/services/article_service.dart';
import 'package:flow_state/data/services/services_provider.dart';

class MockArticleService extends Mock implements ArticleService {
  @override
  Future<ArticleContent> fetchArticle(String url) {
    return super.noSuchMethod(
      Invocation.method(#fetchArticle, [url]),
      returnValue:
          Future.value(ArticleContent(title: '', contentHtml: '', url: '')),
    );
  }
}

class MockCourseRepository extends Mock implements CourseRepository {
  @override
  Future<void> updateCourse(Course course) {
    return super.noSuchMethod(
      Invocation.method(#updateCourse, [course]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Animate.restartOnHotReload = false;

    // Initialize sqflite_ffi for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getTemporaryDirectory' ||
            methodCall.method == 'getApplicationSupportDirectory') {
          return '/tmp';
        }
        return null;
      },
    );
  });

  final testVideo = Video(
    id: 'v1',
    youtubeId: 'y1',
    title: 'Test Video 1',
    thumbnailUrl: 'thumb',
    durationSeconds: 60,
    isCompleted: false,
    watchedSeconds: 0,
  );

  final testCourse = Course(
    id: '1',
    title: 'Test Course 1',
    thumbnailUrl: 'http://test.com/img.jpg',
    sourceUrl: 'url',
    totalDuration: 60,
    videos: [testVideo],
    dateAdded: DateTime.now(),
  );

  testWidgets('CourseDetailScreen renders course info and videos',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CourseDetailScreen(course: testCourse),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Course 1'), findsOneWidget);
      expect(find.text('Test Video 1'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget); // Progress
      expect(find.text('Complete'), findsOneWidget);
    });
  });

  testWidgets('CourseDetailScreen shows edit button',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: CourseDetailScreen(course: testCourse),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the edit button by icon
        expect(find.byIcon(Icons.edit), findsOneWidget);
      });
    });
  });

  testWidgets('CourseDetailScreen can toggle title editing mode',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        final mockRepo = MockCourseRepository();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              courseRepositoryProvider.overrideWith((ref) => mockRepo),
            ],
            child: MaterialApp(
              home: CourseDetailScreen(course: testCourse),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap edit button
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        // Should show TextField and check icon
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsNothing);

        // Tap save button
        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();

        // Should go back to normal mode
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.check), findsNothing);
      });
    });
  });

  testWidgets('CourseDetailScreen article course has larger title font',
      (WidgetTester tester) async {
    final urlVideo = Video(
      id: 'v2',
      youtubeId: '',
      title: 'Test Article',
      thumbnailUrl: '',
      durationSeconds: 0,
      isCompleted: false,
      resourceType: 'url',
      content: 'https://example.com',
    );
    final articleCourse = testCourse.copyWith(videos: [urlVideo]);

    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: CourseDetailScreen(course: articleCourse),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the title Text widget
        final titleFinder = find.text('Test Course 1');
        expect(titleFinder, findsOneWidget);

        // Get the Text widget and check fontSize
        final Text titleWidget = tester.widget(titleFinder);
        expect(titleWidget.style?.fontSize, equals(20));
      });
    });
  });

  testWidgets('CourseDetailScreen tapping URL resource opens ReaderScreen',
      (WidgetTester tester) async {
    final urlVideo = Video(
      id: 'v2',
      youtubeId: '',
      title: 'Test Article',
      thumbnailUrl: '',
      durationSeconds: 0,
      isCompleted: false,
      resourceType: 'url',
      content: 'https://example.com',
    );
    final courseWithUrl = testCourse.copyWith(videos: [urlVideo]);

    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        final mockService = MockArticleService();
        when(mockService.fetchArticle('https://example.com'))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return ArticleContent(title: 'T', contentHtml: 'C', url: '');
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              articleServiceProvider.overrideWith((ref) => mockService),
            ],
            child: MaterialApp(
              home: CourseDetailScreen(course: courseWithUrl),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Test Article'), findsOneWidget);
        await tester.tap(find.text('Test Article'));

        await tester.pump(); // Start nav animation
        await tester
            .pump(const Duration(milliseconds: 50)); // Reader Screen init

        // Expect loading state from ReaderScreen
        expect(find.text('Extracting content...'), findsOneWidget);
      });
    });
  });

  testWidgets('CourseDetailScreen delete course shows dialog',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: CourseDetailScreen(course: testCourse),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap delete button in app bar
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Delete Course?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);

        // Tap cancel to dismiss
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });
    });
  });

  testWidgets('CourseDetailScreen shows stats card',
      (WidgetTester tester) async {
    final courseWithProgress = testCourse.copyWith(
      totalDuration: 200,
      watchedDuration: 100,
    );

    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: CourseDetailScreen(course: courseWithProgress),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check for stats
        expect(find.text('50%'), findsOneWidget); // Progress
        expect(find.text('Complete'), findsOneWidget);
        expect(find.text('Left'), findsOneWidget);
        expect(find.text('Streak'), findsOneWidget);
      });
    });
  });

  testWidgets('CourseDetailScreen formats duration correctly',
      (WidgetTester tester) async {
    final courseWithTime = testCourse.copyWith(
      totalDuration: 7200, // 2 hours
      watchedDuration: 3600, // 1 hour
    );

    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: CourseDetailScreen(course: courseWithTime),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show formatted time
        expect(find.text('1h 0m'), findsOneWidget); // Remaining time
      });
    });
  });
}
