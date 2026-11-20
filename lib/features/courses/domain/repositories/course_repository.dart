import '../entities/course.dart';
import '../entities/course_content.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<Course> getCourseById(String id);
  Future<CourseContent> getContent(String courseId);
}