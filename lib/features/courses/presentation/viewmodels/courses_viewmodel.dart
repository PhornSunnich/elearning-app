import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/fake_course_repository.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return FakeCourseRepository();
});

/// AsyncNotifier: Riverpod's built-in loading / error / data handling.
/// The state is an `AsyncValue<List<Course>>.`
class CoursesViewModel extends AsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() {
    return ref.read(courseRepositoryProvider).getCourses();
  }
}

final coursesViewModelProvider =
    AsyncNotifierProvider<CoursesViewModel, List<Course>>(
  CoursesViewModel.new,
);