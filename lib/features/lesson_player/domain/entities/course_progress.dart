import 'package:equatable/equatable.dart';

class CourseProgress extends Equatable {
  const CourseProgress({
    required this.completedLessonIds,
    required this.completedCount,
    required this.totalCount,
    required this.percentage,
  });

  static const empty = CourseProgress(
    completedLessonIds: {},
    completedCount: 0,
    totalCount: 0,
    percentage: 0,
  );

  final Set<String> completedLessonIds;
  final int completedCount;
  final int totalCount;

  /// 0 to 100 (check the scale in Swagger).
  final double percentage;

  bool isCompleted(String lessonId) => completedLessonIds.contains(lessonId);

  @override
  List<Object?> get props =>
      [completedLessonIds, completedCount, totalCount, percentage];
}