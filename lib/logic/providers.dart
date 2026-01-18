import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/course.dart';
// import '../data/repositories/course_repository.dart';

part 'providers.g.dart';

@riverpod
Stream<List<Course>> allCourses(AllCoursesRef ref) async* {
  // Access the box directly or via repository if we exposed the box.
  // Ideally repository handles this.
  // For now, getting box from Hive since repository is just a wrapper.
  final box = Hive.box<Course>('courses');
  
  // Yield initial value
  yield box.values.toList()..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  
  // Yield on changes
  await for (final _ in box.watch()) {
    yield box.values.toList()..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }
}

@riverpod
Course? currentFocus(CurrentFocusRef ref) {
  final coursesAsync = ref.watch(allCoursesProvider);
  
  return coursesAsync.when(
    data: (courses) {
       // Find the most recently played course or just the first one if active?
       // Logic: Course with lastPlayedVideoId and not completed? 
       // Or just the one with most recent update? 
       // We'll pick the first one that is not completed.
       try {
         return courses.firstWhere((c) => !c.isCompleted && c.watchedDuration > 0, 
           orElse: () => courses.isNotEmpty ? courses.first : throw 'No courses');
       } catch (e) {
         return null;
       }
    },
    error: (_, __) => null,
    loading: () => null,
  );
}
