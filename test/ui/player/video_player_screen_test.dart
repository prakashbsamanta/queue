import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_state/ui/player/video_player_screen.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/models/video.dart';
import 'package:flow_state/data/repositories/course_repository.dart';
import 'package:flow_state/data/repositories/analytics_repository.dart';

@GenerateNiceMocks([MockSpec<CourseRepository>(), MockSpec<AnalyticsRepository>()])
import 'video_player_screen_test.mocks.dart';

void main() {
  late MockCourseRepository mockCourseRepository;
  late MockAnalyticsRepository mockAnalyticsRepository;

  setUp(() {
    mockCourseRepository = MockCourseRepository();
    mockAnalyticsRepository = MockAnalyticsRepository();
  });

  final testVideo = Video(
    id: 'v1',
    youtubeId: 'y1',
    title: 'Test Video',
    thumbnailUrl: 'thumb',
    durationSeconds: 100,
  );

  final testCourse = Course(
    id: '1',
    title: 'Test Course',
    thumbnailUrl: 'thumb',
    sourceUrl: 'url',
    totalDuration: 100,
    videos: [testVideo],
    dateAdded: DateTime.now(),
  );

  testWidgets('VideoPlayerScreen shows not supported message on Desktop', (WidgetTester tester) async {
    // Force MacOS
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseRepositoryProvider.overrideWith((ref) => mockCourseRepository),
          analyticsRepositoryProvider.overrideWith((ref) => mockAnalyticsRepository),
        ],
        child: MaterialApp(
          home: VideoPlayerScreen(
            course: testCourse,
            initialVideoId: 'v1',
          ),
        ),
      ),
    );

    expect(find.text('Video Playback Not Supported on Desktop/Web'), findsOneWidget);
    
    // Pump an empty widget to trigger dispose() while platform override is still active
    await tester.pumpWidget(const SizedBox());
    
    debugDefaultTargetPlatformOverride = null; // Reset
  });
}
