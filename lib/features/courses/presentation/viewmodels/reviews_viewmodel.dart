import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/api_review_repository.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import 'course_details_viewmodel.dart';
import 'courses_viewmodel.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ApiReviewRepository(ReviewRemoteDataSource(ref.read(dioProvider)));
});

final courseReviewsProvider =
    FutureProvider.family<CourseReviews, String>((ref, courseId) {
  return ref.read(reviewRepositoryProvider).getCourseReviews(courseId);
});

class ReviewsController {
  ReviewsController(this._ref);

  final Ref _ref;

  Future<void> submit({
    required String courseId,
    required int rating,
    String? comment,
  }) async {
    final studentId = _ref.read(authViewModelProvider).user?.id;
    if (studentId == null) throw const AppException('Please log in first.');

    await _ref.read(reviewRepositoryProvider).submitReview(
          studentId: studentId,
          courseId: courseId,
          rating: rating,
          comment: comment,
        );
    _refreshAll(courseId);
  }

  Future<void> delete({
    required String courseId,
    required String reviewId,
  }) async {
    await _ref.read(reviewRepositoryProvider).deleteReview(reviewId);
    _refreshAll(courseId);
  }

  /// A review changes the average rating, which is shown in three places.
  void _refreshAll(String courseId) {
    _ref.invalidate(courseReviewsProvider(courseId)); // the review list
    _ref.invalidate(courseDetailsProvider(courseId)); // header rating
    unawaited(_ref.read(coursesViewModelProvider.notifier).refresh()); // cards
  }
}

final reviewsControllerProvider = Provider<ReviewsController>((ref) {
  return ReviewsController(ref);
});