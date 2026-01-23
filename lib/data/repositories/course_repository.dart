import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/course.dart';
import 'package:uuid/uuid.dart';
import '../models/video.dart';

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
        // await course.save(); // Redundant and hard to test without box
        
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
  Future<void> createEmptyCourse(String title) async {
    final course = Course(
      id: const Uuid().v4(),
      title: title,
      thumbnailUrl: '', // Default or generated placeholder
      sourceUrl: '',
      dateAdded: DateTime.now(),
      totalDuration: 0,
      watchedDuration: 0,
      isCompleted: false,
      videos: [],
    );
    await addCourse(course);
  }

  Future<void> addResourceToCourse(String courseId, String content, String type) async {
    final course = _courseBox.get(courseId);
    if (course != null) {
      final video = Video(
        id: const Uuid().v4(),
        youtubeId: '', 
        title: content,
        thumbnailUrl: '',
        durationSeconds: 0,
        resourceType: type,
        content: content,
      );
      course.videos.add(video);
      await course.save(); 
    }
  }

  Future<void> addVideoToCourse(String courseId, Video video) async {
    final course = _courseBox.get(courseId);
    if (course != null) {
      course.videos.add(video);
      // Recalculate total duration logic if needed, but for now just adding is fine
      // Actually we should probably update totalDuration
      final newTotalDuration = course.totalDuration + video.durationSeconds;
      final updatedCourse = course.copyWith(
        id: course.id,
        title: course.title,
        thumbnailUrl: course.thumbnailUrl,
        sourceUrl: course.sourceUrl,
        dateAdded: course.dateAdded,
        totalDuration: newTotalDuration,
        watchedDuration: course.watchedDuration,
        isCompleted: course.isCompleted,
        videos: course.videos, // Reference to HiveList is already mutated
      );
      // Since HiveList is live, we might just need to save. 
      // check if 'course.videos.add' updates the list. Yes it does for HiveList. 
      // But we also want to update the Course object fields (duration).
      
      // Let's rely on standard Hive save for the main object updates
       await _courseBox.put(course.id, updatedCourse);
    }
  }
}

@riverpod
CourseRepository courseRepository(CourseRepositoryRef ref) {
  // We assume the box is opened in main.dart
  final box = Hive.box<Course>('courses');
  return CourseRepository(box);
}
