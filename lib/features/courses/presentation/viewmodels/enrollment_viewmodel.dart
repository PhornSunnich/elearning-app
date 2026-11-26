import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/datasources/enrollment_remote_datasource.dart';
import '../../data/repositories/api_enrollment_repository.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/repositories/enrollment_repository.dart';

final enrollmentRepositoryProvider = Provider<EnrollmentRepository>((ref) {
  return ApiEnrollmentRepository(
    EnrollmentRemoteDataSource(ref.read(dioProvider)),
  );
});

/// The logged-in student's enrollments. Watching the student id means this
/// reloads on login and empties on logout by itself.
class EnrollmentsViewModel extends AsyncNotifier<List<Enrollment>> {
  @override
  Future<List<Enrollment>> build() async {
    final studentId =
        ref.watch(authViewModelProvider.select((s) => s.user?.id));
    if (studentId == null) return const [];
    return ref.read(enrollmentRepositoryProvider).getMyEnrollments(studentId);
  }

  /// Throws an AppException on failure; the screen shows its message.
  Future<void> enroll(String courseId) async {
    final studentId = ref.read(authViewModelProvider).user?.id;
    if (studentId == null) {
      throw const AppException('Please log in first.');
    }
    final created = await ref
        .read(enrollmentRepositoryProvider)
        .enroll(studentId: studentId, courseId: courseId);

    final current = state.value ?? const <Enrollment>[];
    state = AsyncData([
      ...current.where((e) => e.courseId != created.courseId),
      created,
    ]);
  }
}

final enrollmentsProvider =
    AsyncNotifierProvider<EnrollmentsViewModel, List<Enrollment>>(
  EnrollmentsViewModel.new,
);

/// Just the ids, for quick "is this course enrolled?" checks.
final enrolledCourseIdsProvider = Provider<Set<String>>((ref) {
  final list = ref.watch(enrollmentsProvider).value ?? const <Enrollment>[];
  return {for (final e in list) e.courseId};
});