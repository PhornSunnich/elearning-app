import 'package:dio/dio.dart';

import '../models/enrollment_model.dart';

class EnrollmentRemoteDataSource {
  EnrollmentRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<EnrollmentModel>> getMyEnrollments(String studentId) async {
    final res =
        await _dio.get<List<dynamic>>('/api/courses/$studentId/enrollments');
    return (res.data ?? const [])
        .map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EnrollmentModel> enroll({
    required String studentId,
    required String courseId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/courses/enroll',
      // The API ids are numbers.
      data: {
        'studentId': int.parse(studentId),
        'courseId': int.parse(courseId),
      },
    );
    return EnrollmentModel.fromJson(res.data!);
  }
}