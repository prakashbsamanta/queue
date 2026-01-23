import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flow_state/ui/dashboard/dashboard_screen.dart';
import 'package:flow_state/logic/providers.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  setUp(() {
    Animate.restartOnHotReload = false;
  });

  final testCourse = Course(
    id: '1',
    title: 'Test Course 1',
    thumbnailUrl: 'http://test.com/img.jpg',
    sourceUrl: 'url',
    totalDuration: 100,
    watchedDuration: 50,
    videos: [],
    dateAdded: DateTime.now(),
  );

  testWidgets('DashboardScreen renders empty state when no courses', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allCoursesProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No courses yet. Add one to start.'), findsOneWidget);
    });
  });

  testWidgets('DashboardScreen renders courses and current focus', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              allCoursesProvider.overrideWith((ref) => Stream.value([testCourse])),
            ],
            child: const MaterialApp(home: DashboardScreen()),
          ),
        );
        await tester.pump(const Duration(seconds: 1)); 

        expect(find.text('Good Morning,'), findsOneWidget);
        expect(find.text('My Library'), findsOneWidget);
        expect(find.text('Test Course 1'), findsAtLeastNWidgets(1));
        expect(find.text('RESUME LEARNING'), findsOneWidget); // Current Focus
      });
    });
  });
}
