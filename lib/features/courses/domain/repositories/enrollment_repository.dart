import '../entities/enrollment.dart';

abstract class EnrollmentRepository {
  Future<List<Enrollment>> getMyEnrollments(String studentId);

  Future<Enrollment> enroll({
    required String studentId,
    required String courseId,
  });
}