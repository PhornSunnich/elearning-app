import 'package:dio/dio.dart';

import '../models/course_models.dart';

class CourseRemoteDataSource {
  CourseRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PagedCoursesModel> getCourses({
    String? search,
    String? categoryId,
    required int page,
    required int size,
  }) async {
    final res = await _dio.get(
      '/api/courses',
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.isNotEmpty) 'search': search,
        ?categoryId: categoryId,
      },
    );
    return PagedCoursesModel.fromJson(res.data!);
  }

  Future<CourseModel> getCourse(String id) async {
    final res = await _dio.get('/api/courses/$id');
    return CourseModel.fromJson(res.data!);
  }

  Future<List<LessonModel>> getLessons(String courseId) async {
    final res = await _dio.get<List<dynamic>>('/api/lessons/course/$courseId');
    return (res.data ?? const [])
        .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final res = await _dio.get<List<dynamic>>('/api/categories');
    return (res.data ?? const [])
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}