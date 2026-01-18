import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/course.dart';
// import '../models/video.dart';

part 'course_repository.g.dart';

class CourseRepository {
  final Box<Course> _courseBox;

  CourseRepository(this._courseBox);

  List<Course> getAllCourses() {
    return _courseBox.values.toList()..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  Future<void> addCourse(Course course) async {
    await _courseBox.put(course.id, course);
  }

  Future<void> updateCourse(Course course) async {
    await _courseBox.put(course.id, course);
  }

  Future<void> deleteCourse(String id) async {
    await _courseBox.delete(id);
  }

  Future<void> updateVideoProgress(String courseId, String videoId, int positionSeconds) async {
    final course = _courseBox.get(courseId);
    if (course != null) {
      final videoIndex = course.videos.indexWhere((v) => v.id == videoId);
      if (videoIndex != -1) {
        final video = course.videos[videoIndex];
        
        // Calculate new watched Duration for course
        // This logic is simplified; a real implementation would track unique segments watched.
        // For now, we assume linear progression.
        
        final updatedVideo = video.copyWith(
          watchedSeconds: positionSeconds,
          isCompleted: positionSeconds >= (video.durationSeconds * 0.9), // 90% threshold
        );

        course.videos[videoIndex] = updatedVideo;
        await course.save();
        
        // Update course total progress
        int totalWatched = course.videos.fold(0, (sum, v) => sum + v.watchedSeconds);
        final updatedCourse = course.copyWith(
          lastPlayedVideoId: videoId,
          watchedDuration: totalWatched,
          isCompleted: course.videos.every((v) => v.isCompleted),
        );
        
        await updateCourse(updatedCourse);
      }
    }
  }
}

@riverpod
CourseRepository courseRepository(CourseRepositoryRef ref) {
  // We assume the box is opened in main.dart
  final box = Hive.box<Course>('courses');
  return CourseRepository(box);
}
