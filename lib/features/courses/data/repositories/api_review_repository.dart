import '../../../../core/network/api_error.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ApiReviewRepository implements ReviewRepository {
  ApiReviewRepository(this._remote);

  final ReviewRemoteDataSource _remote;

  @override
  Future<CourseReviews> getCourseReviews(String courseId) {
    return guardApi(
      () async => (await _remote.getCourseReviews(courseId)).toEntity(),
    );
  }

  @override
  Future<Review> submitReview({
    required String studentId,
    required String courseId,
    required int rating,
    String? comment,
  }) {
    return guardApi(() async {
      final created = await _remote.submitReview(
        studentId: studentId,
        courseId: courseId,
        rating: rating,
        comment: comment,
      );
      return created.toEntity();
    });
  }

  @override
  Future<void> deleteReview(String reviewId) {
    return guardApi(() => _remote.deleteReview(reviewId));
  }
}