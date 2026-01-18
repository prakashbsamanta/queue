import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flow_state/main.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_state/data/services/youtube_service.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/models/video.dart';
import 'package:flow_state/data/models/session.dart';
import 'package:flow_state/data/services/services_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 1. Mock Implementation
class FakeYouTubeService implements YouTubeService {
  @override
  Future<Course> extractCourse(String url) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return Course(
      id: 'mock_course_id_123',
      title: 'Mocked YouTube Course',
      thumbnailUrl: 'https://via.placeholder.com/150',
      sourceUrl: url,
      totalDuration: 3600,
      videos: [
        Video(
          id: 'mock_video_1', 
          youtubeId: 'mock_yt_1', 
          title: 'Mocked Video Lesson 1', 
          thumbnailUrl: 'https://via.placeholder.com/150', 
          durationSeconds: 1800,
        ),
         Video(
          id: 'mock_video_2', 
          youtubeId: 'mock_yt_2', 
          title: 'Mocked Video Lesson 2', 
          thumbnailUrl: 'https://via.placeholder.com/150', 
          durationSeconds: 1800,
        ),
      ],
      dateAdded: DateTime.now(),
    );
  }

  @override
  void dispose() {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
      // Initialize Hive for tests
      // In integration tests on device, this writes to real device storage/cache.
      // We might want to clear boxes first to ensure clean state.
      await Hive.initFlutter();
      
      // Register Adapters
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(VideoAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CourseAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SessionAdapter());

      // Open Boxes (and clear them for test isolation)
      final courseBox = await Hive.openBox<Course>('courses');
      final sessionBox = await Hive.openBox<Session>('sessions');
      
      await courseBox.clear();
      await sessionBox.clear();
  });

  testWidgets('E2E: App Startup & Add Course via Mocked YouTube', (tester) async {
    // 2. Load App with Overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          youTubeServiceProvider.overrideWithValue(FakeYouTubeService()),
        ],
        child: const app.FlowStateApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 3. Verify Startup (Dashboard)
    expect(find.text('Ready to Flow?'), findsOneWidget); // App Title (Header)
    expect(find.byIcon(Icons.add), findsOneWidget); // FAB exists

    // 4. Open Add Course Modal
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(); // Wait for modal animation

    expect(find.text('Add New Knowledge Source'), findsOneWidget);

    // 5. Enter Mocked YouTube URL
    // We target the TextFormField that has the specific hint text or decoration
    // But since the new modal uses logic to switch hints, let's just find by Type TextField
    // There is one TextField for the URL input initially.
    await tester.enterText(find.byType(TextField), 'https://youtube.com/watch?v=mock_video');
    await tester.pumpAndSettle();

    // 6. Tap Create Course
    // The button text is "Create Course"
    await tester.tap(find.text('Create Course'));
    
    // 7. Wait for "Network" (Mock delay 500ms) + Animation
    // We need to pump frames to allow the async operation in Logic to complete and update state
    await tester.pump(const Duration(milliseconds: 600)); 
    await tester.pumpAndSettle();

    // 8. Verify Modal Closed & Course Added
    expect(find.text('Add New Knowledge Source'), findsNothing); // Modal closed
    expect(find.text('Mocked YouTube Course'), findsWidgets); // Course appears (Grid + potentially Focus Card)
  });
}
