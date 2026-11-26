import '../../../../core/network/api_error.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../datasources/enrollment_remote_datasource.dart';

class ApiEnrollmentRepository implements EnrollmentRepository {
  ApiEnrollmentRepository(this._remote);

  final EnrollmentRemoteDataSource _remote;

  @override
  Future<List<Enrollment>> getMyEnrollments(String studentId) {
    return guardApi(() async {
      final list = await _remote.getMyEnrollments(studentId);
      return list.map((e) => e.toEntity()).toList();
    });
  }

  @override
  Future<Enrollment> enroll({
    required String studentId,
    required String courseId,
  }) {
    return guardApi(() async {
      final created =
          await _remote.enroll(studentId: studentId, courseId: courseId);
      return created.toEntity();
    });
  }
}