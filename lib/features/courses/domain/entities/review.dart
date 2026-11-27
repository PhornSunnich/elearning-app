import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.studentId,
    required this.studentName,
    this.createdAt,
  });

  final String id;
  final int rating; // 1 to 5
  final String comment;
  final String studentId;
  final String studentName;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, rating, comment, studentId];
}

class CourseReviews extends Equatable {
  const CourseReviews({
    required this.average,
    required this.total,
    required this.reviews,
  });

  static const empty = CourseReviews(average: 0, total: 0, reviews: []);

  final double average;
  final int total;
  final List<Review> reviews;

  @override
  List<Object?> get props => [average, total, reviews];
}