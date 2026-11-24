import '../../domain/entities/course.dart';
import '../../domain/entities/course_category.dart';
import '../../domain/entities/course_content.dart';
import '../../domain/entities/course_page.dart';

class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorEmail,
    required this.categoryId,
    required this.categoryName,
    required this.averageRating,
    required this.reviewCount,
    required this.lessonCount,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: (json['id'] as num).toString(),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        instructorEmail: json['instructorEmail'] as String?,
        categoryId: (json['categoryId'] as num?)?.toString(),
        categoryName: json['categoryName'] as String?,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        lessonCount: (json['lessonCount'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String title;
  final String description;
  final String? instructorEmail;
  final String? categoryId;
  final String? categoryName;
  final double averageRating;
  final int reviewCount;
  final int lessonCount;

  Course toEntity() => Course(
        id: id,
        title: title,
        description: description,
        // The API sends the instructor's email, so show the part before "@".
        instructor: instructorEmail?.split('@').first ?? 'Instructor',
        category: categoryName ?? '',
        categoryId: categoryId,
        rating: averageRating,
        reviewCount: reviewCount,
        lessonCount: lessonCount,
      );
}

class PagedCoursesModel {
  const PagedCoursesModel({
    required this.content,
    required this.pageNumber,
    required this.last,
  });

  factory PagedCoursesModel.fromJson(Map<String, dynamic> json) =>
      PagedCoursesModel(
        content: (json['content'] as List<dynamic>? ?? const [])
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 0,
        last: json['last'] as bool? ?? true,
      );

  final List<CourseModel> content;
  final int pageNumber;
  final bool last;

  CoursePage toPage() => CoursePage(
        items: content.map((c) => c.toEntity()).toList(),
        page: pageNumber,
        isLast: last,
      );
}

class LessonModel {
  const LessonModel({
    required this.id,
    required this.title,
    this.videoUrl,
    this.content,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
        id: (json['id'] as num).toString(),
        title: json['title'] as String? ?? '',
        videoUrl: json['videoUrl'] as String?,
        content: json['content'] as String?,
      );

  final String id;
  final String title;
  final String? videoUrl;
  final String? content;

  Lesson toEntity({bool isPreview = false}) => Lesson(
        id: id,
        title: title,
        videoUrl: videoUrl,
        content: content,
        isPreview: isPreview,
      );
}

class CategoryModel {
  const CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: (json['id'] as num).toString(),
        name: json['name'] as String? ?? '',
      );

  final String id;
  final String name;

  CourseCategory toEntity() => CourseCategory(id: id, name: name);
}