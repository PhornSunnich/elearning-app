import '../../domain/entities/review.dart';

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.studentId,
    required this.studentName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: (json['id'] as num).toString(),
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String? ?? '',
        studentId: (json['studentId'] as num?)?.toString() ?? '',
        studentName: json['studentName'] as String? ?? 'Student',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      );

  final String id;
  final int rating;
  final String comment;
  final String studentId;
  final String studentName;
  final DateTime? createdAt;

  Review toEntity() => Review(
        id: id,
        rating: rating,
        comment: comment,
        studentId: studentId,
        studentName: studentName,
        createdAt: createdAt,
      );
}

class CourseReviewsModel {
  const CourseReviewsModel({
    required this.average,
    required this.total,
    required this.reviews,
  });

  factory CourseReviewsModel.fromJson(Map<String, dynamic> json) =>
      CourseReviewsModel(
        average: (json['averageRating'] as num?)?.toDouble() ?? 0,
        total: (json['totalReviews'] as num?)?.toInt() ?? 0,
        reviews: (json['reviews'] as List<dynamic>? ?? const [])
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final double average;
  final int total;
  final List<ReviewModel> reviews;

  CourseReviews toEntity() => CourseReviews(
        average: average,
        total: total,
        reviews: reviews.map((r) => r.toEntity()).toList(),
      );
}