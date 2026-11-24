import '../../../../core/network/api_error.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_category.dart';
import '../../domain/entities/course_content.dart';
import '../../domain/entities/course_page.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_datasource.dart';

class ApiCourseRepository implements CourseRepository {
  ApiCourseRepository(this._remote);

  final CourseRemoteDataSource _remote;

  @override
  Future<CoursePage> getCourses({
    String? search,
    String? categoryId,
    int page = 0,
    int size = 10,
  }) {
    return guardApi(() async {
      final result = await _remote.getCourses(
        search: search,
        categoryId: categoryId,
        page: page,
        size: size,
      );
      return result.toPage();
    });
  }

  @override
  Future<Course> getCourseById(String id) {
    return guardApi(() async => (await _remote.getCourse(id)).toEntity());
  }

  @override
  Future<CourseContent> getContent(String courseId) {
    return guardApi(() async {
      final lessons = await _remote.getLessons(courseId);
      return CourseContent(
        objectives: const [], // not in the API
        requirements: const [], // not in the API
        modules: [
          CourseModule(
            title: 'Lessons',
            lessons: [
              for (var i = 0; i < lessons.length; i++)
                // The first lesson counts as a free preview.
                lessons[i].toEntity(isPreview: i == 0),
            ],
          ),
        ],
      );
    });
  }

  @override
  Future<List<CourseCategory>> getCategories() {
    return guardApi(() async {
      final list = await _remote.getCategories();
      return list.map((c) => c.toEntity()).toList();
    });
  }
}