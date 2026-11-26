import 'package:dio/dio.dart';

import '../models/progress_models.dart';

class LessonProgressRemoteDataSource {
  LessonProgressRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CourseProgressModel> getCourseProgress({
    required String studentId,
    required String courseId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/lesson-progress/course/$courseId/student/$studentId',
    );
    return CourseProgressModel.fromJson(res.data!);
  }

  Future<void> setLessonCompleted({
    required String studentId,
    required String lessonId,
    required bool completed,
  }) async {
    await _dio.put<dynamic>(
      '/api/lesson-progress/complete',
      queryParameters: {
        'studentId': studentId,
        'lessonId': lessonId,
        'completed': completed,
      },
    );
  }
}