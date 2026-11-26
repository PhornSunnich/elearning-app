import '../../domain/entities/course_progress.dart';

class CourseProgressModel {
  const CourseProgressModel({
    required this.completedIds,
    required this.completedCount,
    required this.totalCount,
    required this.percentage,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    final lessons = json['lessons'] as List<dynamic>? ?? const [];
    return CourseProgressModel(
      completedIds: {
        for (final l in lessons)
          if ((l as Map<String, dynamic>)['completed'] == true)
            (l['lessonId'] as num).toString(),
      },
      completedCount: (json['completedLessonsCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalLessonsCount'] as num?)?.toInt() ?? 0,
      percentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0,
    );
  }

  final Set<String> completedIds;
  final int completedCount;
  final int totalCount;
  final double percentage;

  CourseProgress toEntity() => CourseProgress(
        completedLessonIds: completedIds,
        completedCount: completedCount,
        totalCount: totalCount,
        percentage: percentage,
      );
}