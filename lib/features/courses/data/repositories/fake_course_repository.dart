import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';

/// Hard-coded data. Phase 3 replaces this with a Dio-based repository.
class FakeCourseRepository implements CourseRepository {
  static const _courses = [
    Course(
      id: 'c1',
      title: 'Flutter for Beginners',
      instructor: 'Dara Sok',
      description: 'Build your first mobile app with Flutter and Dart.',
      category: 'Mobile',
      level: CourseLevel.beginner,
      price: 0,
      rating: 4.7,
      durationHours: 8.5,
      lessonCount: 42,
    ),
    Course(
      id: 'c2',
      title: 'Advanced State Management with Riverpod',
      instructor: 'Sophea Chan',
      description: 'Providers, notifiers, async state and testing.',
      category: 'Mobile',
      level: CourseLevel.advanced,
      price: 29.99,
      rating: 4.9,
      durationHours: 6,
      lessonCount: 30,
    ),
    Course(
      id: 'c3',
      title: 'PostgreSQL Fundamentals',
      instructor: 'Vannak Heng',
      description: 'Design schemas and write efficient SQL queries.',
      category: 'Database',
      level: CourseLevel.beginner,
      price: 19.99,
      rating: 4.5,
      durationHours: 10,
      lessonCount: 55,
    ),
    Course(
      id: 'c4',
      title: 'REST API Design with JWT',
      instructor: 'Sreyneang Kim',
      description: 'Secure authentication, tokens and API best practices.',
      category: 'Backend',
      level: CourseLevel.intermediate,
      price: 24.99,
      rating: 4.6,
      durationHours: 7.5,
      lessonCount: 36,
    ),
    Course(
      id: 'c5',
      title: 'UI/UX Design Basics',
      instructor: 'Mony Lim',
      description: 'Layout, color, typography and prototyping.',
      category: 'Design',
      level: CourseLevel.beginner,
      price: 0,
      rating: 4.4,
      durationHours: 5,
      lessonCount: 24,
    ),
  ];

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 900));

  @override
  Future<List<Course>> getCourses() async {
    await _delay();
    return _courses;
  }

  @override
  Future<Course> getCourseById(String id) async {
    await _delay();
    return _courses.firstWhere(
      (c) => c.id == id,
      orElse: () => throw const AppException('Course not found'),
    );
  }
}