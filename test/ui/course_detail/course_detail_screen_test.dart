import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flow_state/ui/course_detail/course_detail_screen.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/models/video.dart';
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

void main() {
  setUp(() {
    Animate.restartOnHotReload = false;
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
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: CourseDetailScreen(course: testCourse),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1)); // Animations

        expect(find.text('Test Course 1'), findsOneWidget);
        expect(find.text('Test Video 1'), findsOneWidget);
        expect(find.text('0%'), findsOneWidget); // Progress
        expect(find.text('Complete'), findsOneWidget);
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
}
