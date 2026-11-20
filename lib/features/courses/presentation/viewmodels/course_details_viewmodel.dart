import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/course_content.dart';
import 'courses_viewmodel.dart';

/// `.family` = a provider that takes a parameter (the course id).
final courseDetailsProvider =
    FutureProvider.family<Course, String>((ref, id) {
  return ref.read(courseRepositoryProvider).getCourseById(id);
});

final courseContentProvider =
    FutureProvider.family<CourseContent, String>((ref, id) {
  return ref.read(courseRepositoryProvider).getContent(id);
});

/// Fake enrollment: remembers enrolled course ids in memory.
/// visal's My Learning screen will read this (then the real API).
class EnrollmentViewModel extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  Future<void> enroll(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    state = {...state, courseId}; // new Set, so listeners are notified
  }
}

final enrollmentProvider =
    NotifierProvider<EnrollmentViewModel, Set<String>>(
  EnrollmentViewModel.new,
);