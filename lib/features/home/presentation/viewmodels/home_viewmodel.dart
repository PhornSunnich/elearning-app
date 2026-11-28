import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../courses/domain/entities/course.dart';
import '../../../courses/presentation/viewmodels/courses_viewmodel.dart';

/// The API cannot sort by rating, so we load one page and rank it here.
final popularCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final page =
      await ref.read(courseRepositoryProvider).getCourses(page: 0, size: 20);

  final sorted = [...page.items]
    ..sort((a, b) {
      final byRating = b.rating.compareTo(a.rating);
      return byRating != 0 ? byRating : b.reviewCount.compareTo(a.reviewCount);
    });

  return sorted.take(5).toList();
});