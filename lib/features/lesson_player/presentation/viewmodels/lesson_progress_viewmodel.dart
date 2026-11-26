import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../courses/presentation/viewmodels/enrollment_viewmodel.dart';
import '../../data/datasources/lesson_progress_remote_datasource.dart';
import '../../data/repositories/api_lesson_progress_repository.dart';
import '../../domain/entities/course_progress.dart';
import '../../domain/repositories/lesson_progress_repository.dart';

final lessonProgressRepositoryProvider =
    Provider<LessonProgressRepository>((ref) {
  return ApiLessonProgressRepository(
    LessonProgressRemoteDataSource(ref.read(dioProvider)),
  );
});

/// Progress of the logged-in student in one course. `.family` = one
/// instance per course id.
final courseProgressProvider =
    FutureProvider.family<CourseProgress, String>((ref, courseId) async {
  final studentId = ref.watch(authViewModelProvider.select((s) => s.user?.id));
  if (studentId == null) return CourseProgress.empty;
  return ref
      .read(lessonProgressRepositoryProvider)
      .getCourseProgress(studentId: studentId, courseId: courseId);
});

class LessonProgressController {
  LessonProgressController(this._ref);

  final Ref _ref;

  Future<void> setCompleted({
    required String courseId,
    required String lessonId,
    required bool completed,
  }) async {
    final studentId = _ref.read(authViewModelProvider).user?.id;
    if (studentId == null) throw const AppException('Please log in first.');

    await _ref.read(lessonProgressRepositoryProvider).setLessonCompleted(
          studentId: studentId,
          lessonId: lessonId,
          completed: completed,
        );

    // Reload what depends on progress.
    _ref.invalidate(courseProgressProvider(courseId));
    _ref.invalidate(enrollmentsProvider); // My Learning progress bar
  }
}

final lessonProgressControllerProvider =
    Provider<LessonProgressController>((ref) {
  return LessonProgressController(ref);
});