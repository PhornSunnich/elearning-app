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

