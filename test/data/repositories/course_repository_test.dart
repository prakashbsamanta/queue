import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:flow_state/data/repositories/course_repository.dart';
import 'package:flow_state/data/models/course.dart';
import 'package:flow_state/data/models/video.dart';

@GenerateNiceMocks([MockSpec<Box>()])
import 'course_repository_test.mocks.dart';

void main() {
  late MockBox<Course> mockBox;
  late CourseRepository repository;

  setUp(() {
    mockBox = MockBox<Course>();
    repository = CourseRepository(mockBox);
  });

  final testCourse = Course(
    id: '1',
    title: 'Test Course',
    thumbnailUrl: 'url',
    sourceUrl: 'source',
    totalDuration: 100,
    videos: [],
    dateAdded: DateTime.now(),
  );

  test('getAllCourses returns values from box sorted by date', () {
    final course1 = testCourse.copyWith(
        id: '1', dateAdded: DateTime.now().subtract(const Duration(days: 1)));
    final course2 = testCourse.copyWith(id: '2', dateAdded: DateTime.now());

    when(mockBox.values).thenReturn([course1, course2]);

    final result = repository.getAllCourses();

    expect(result, [course2, course1]); // Expect reverse chronological
  });

  test('addCourse puts course in box', () async {
    await repository.addCourse(testCourse);
    verify(mockBox.put(testCourse.id, testCourse)).called(1);
  });

  test('updateCourse puts course in box', () async {
    await repository.updateCourse(testCourse);
    verify(mockBox.put(testCourse.id, testCourse)).called(1);
  });

  test('deleteCourse removes from box', () async {
    await repository.deleteCourse('1');
    verify(mockBox.delete('1')).called(1);
  });

  test('createEmptyCourse creates a default course and adds it', () async {
    await repository.createEmptyCourse('New Course');
    verify(mockBox.put(any, any)).called(1);
  });

  test('updateVideoProgress updates video and saves course', () async {
    // Setup
    final video = Video(
        id: 'v1',
        youtubeId: 'y1',
        title: 'V1',
        thumbnailUrl: 't',
        durationSeconds: 100,
        watchedSeconds: 0,
        isCompleted: false);
    final course = Course(
        id: 'c1',
        title: 'C1',
        thumbnailUrl: 't',
        sourceUrl: 'u',
        totalDuration: 100,
        videos: [video],
        dateAdded: DateTime.now());

    when(mockBox.get('c1')).thenReturn(course);

    await repository.updateVideoProgress('c1', 'v1', 50);

    // Check if video updated
    expect(course.videos.first.watchedSeconds, 50);
    expect(course.videos.first.isCompleted, false);

    // Check save called
    // Since mockBox.put is called by updateCourse inside updateVideoProgress
    verify(mockBox.put('c1', any)).called(1);
  });

  test('addResourceToCourse adds video and saves course', () async {
    final course = Course(
        id: 'c1',
        title: 'C1',
        thumbnailUrl: 't',
        sourceUrl: 'u',
        totalDuration: 0,
        videos: [],
        dateAdded: DateTime.now());
    when(mockBox.get('c1')).thenReturn(course);

    await repository.addResourceToCourse('c1', 'http://link', 'url');

    expect(course.videos.length, 1);
    expect(course.videos.first.content, 'http://link');
    expect(course.videos.first.resourceType, 'url');
    // Save called on course object which calls box.put? No, HiveList/HiveObject checks.
    // Repo calls course.save() which relies on HiveObject.
    // Since we mocked Box but not Course.save() (extension method using box), checking save is tricky if Course is just a data class.
    // But Course extends HiveObject?
    // Let's assume Hive interactions work or check if we can verify box usage.
    // HiveObject.save() calls box.put(key, this).
    verify(mockBox.put('c1', course)).called(1);
  });

  test('addVideoToCourse adds video and updates total duration', () async {
    final course = Course(
        id: 'c1',
        title: 'C1',
        thumbnailUrl: 't',
        sourceUrl: 'u',
        totalDuration: 100,
        videos: [],
        dateAdded: DateTime.now());
    when(mockBox.get('c1')).thenReturn(course);

    final video = Video(
        id: 'v2',
        youtubeId: 'y2',
        title: 'V2',
        thumbnailUrl: 't',
        durationSeconds: 50,
        watchedSeconds: 0,
        isCompleted: false);

    await repository.addVideoToCourse('c1', video);

    // Check video added
    expect(course.videos.length, 1);
    expect(course.videos.first.id, 'v2');

    // Check total duration update
    // Verify puts updated course
    final captured = verify(mockBox.put('c1', captureAny)).captured;
    final savedCourse = captured.first as Course;
    expect(savedCourse.totalDuration, 150);
  });
}
