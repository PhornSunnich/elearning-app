import '../entities/course_progress.dart';

abstract class LessonProgressRepository {
  Future<CourseProgress> getCourseProgress({
    required String studentId,
    required String courseId,
  });

  Future<void> setLessonCompleted({
    required String studentId,
    required String lessonId,
    required bool completed,
  });
}