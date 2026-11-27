import 'package:dio/dio.dart';

import '../models/review_models.dart';

class ReviewRemoteDataSource {
  ReviewRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CourseReviewsModel> getCourseReviews(String courseId) async {
    final res =
        await _dio.get<Map<String, dynamic>>('/api/reviews/course/$courseId');
    return CourseReviewsModel.fromJson(res.data!);
  }

  Future<ReviewModel> submitReview({
    required String studentId,
    required String courseId,
    required int rating,
    String? comment,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/reviews',
      data: {
        'studentId': int.parse(studentId),
        'courseId': int.parse(courseId),
        'rating': rating,
        'comment': comment ?? '',
      },
    );
    return ReviewModel.fromJson(res.data!);
  }

  Future<void> deleteReview(String reviewId) async {
    await _dio.delete<dynamic>('/api/reviews/$reviewId');
  }
}