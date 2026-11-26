import '../../../../core/network/api_error.dart';
import '../../domain/entities/course_progress.dart';
import '../../domain/repositories/lesson_progress_repository.dart';
import '../datasources/lesson_progress_remote_datasource.dart';

class ApiLessonProgressRepository implements LessonProgressRepository {
  ApiLessonProgressRepository(this._remote);

  final LessonProgressRemoteDataSource _remote;

  @override
  Future<CourseProgress> getCourseProgress({
    required String studentId,
    required String courseId,
  }) {
    return guardApi(() async {
      final model = await _remote.getCourseProgress(
        studentId: studentId,
        courseId: courseId,
      );
      return model.toEntity();
    });
  }

  @override
  Future<void> setLessonCompleted({
    required String studentId,
    required String lessonId,
    required bool completed,
  }) {
    return guardApi(
      () => _remote.setLessonCompleted(
        studentId: studentId,
        lessonId: lessonId,
        completed: completed,
      ),
    );
  }
}