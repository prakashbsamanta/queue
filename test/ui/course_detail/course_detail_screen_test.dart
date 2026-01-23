import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flow_state/ui/course_detail/course_detail_screen.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/models/video.dart';

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

  testWidgets('CourseDetailScreen renders course info and videos', (WidgetTester tester) async {
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
}
