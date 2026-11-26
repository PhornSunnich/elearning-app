import '../../domain/entities/enrollment.dart';

class EnrollmentModel {
  const EnrollmentModel({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.progress,
    required this.enrolledAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentModel(
        id: (json['id'] as num).toString(),
        courseId: (json['courseId'] as num).toString(),
        courseTitle: json['courseTitle'] as String? ?? '',
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
        enrolledAt: DateTime.tryParse(json['enrolledAt'] as String? ?? ''),
      );

  final String id;
  final String courseId;
  final String courseTitle;
  final double progress;
  final DateTime? enrolledAt;

  Enrollment toEntity() => Enrollment(
        id: id,
        courseId: courseId,
        courseTitle: courseTitle,
        progress: progress,
        enrolledAt: enrolledAt,
      );
}