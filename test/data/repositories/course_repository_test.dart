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
    final course1 = testCourse.copyWith(id: '1', dateAdded: DateTime.now().subtract(const Duration(days: 1)));
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
    final video = Video(id: 'v1', youtubeId: 'y1', title: 'V1', thumbnailUrl: 't', durationSeconds: 100, watchedSeconds: 0, isCompleted: false);
    final course = Course(id: 'c1', title: 'C1', thumbnailUrl: 't', sourceUrl: 'u', totalDuration: 100, videos: [video], dateAdded: DateTime.now());
    
    when(mockBox.get('c1')).thenReturn(course);
    
    await repository.updateVideoProgress('c1', 'v1', 50);
    
    // Check if video updated
    expect(course.videos.first.watchedSeconds, 50);
    expect(course.videos.first.isCompleted, false);
    
    // Check save called
    // Since mockBox.put is called by updateCourse inside updateVideoProgress
    verify(mockBox.put('c1', any)).called(1);
  });
}
