import 'package:equatable/equatable.dart';

class Enrollment extends Equatable {
  const Enrollment({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.progress,
    this.enrolledAt,
  });

  final String id;
  final String courseId;
  final String courseTitle;

  /// Percent, 0 to 100 (assumed: check the value in Swagger).
  final double progress;
  final DateTime? enrolledAt;

  double get progressFraction => (progress / 100).clamp(0.0, 1.0);
  bool get isCompleted => progress >= 100;

  @override
  List<Object?> get props => [id, courseId, courseTitle, progress];
}