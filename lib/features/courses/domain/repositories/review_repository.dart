import '../entities/review.dart';

abstract class ReviewRepository {
  Future<CourseReviews> getCourseReviews(String courseId);

  Future<Review> submitReview({
    required String studentId,
    required String courseId,
    required int rating,
    String? comment,
  });

  Future<void> deleteReview(String reviewId);
}