import '../entities/course.dart';
import '../entities/course_category.dart';
import '../entities/course_content.dart';
import '../entities/course_page.dart';

abstract class CourseRepository {
  Future<CoursePage> getCourses({
    String? search,
    String? categoryId,
    int page = 0,
    int size = 10,
  });

  Future<Course> getCourseById(String id);
  Future<CourseContent> getContent(String courseId);
  Future<List<CourseCategory>> getCategories();
}