import 'package:equatable/equatable.dart';

enum CourseLevel { beginner, intermediate, advanced }

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.description,
    required this.category,
    required this.level,
    required this.price, // 0 = free
    required this.rating,
    required this.durationHours,
    required this.lessonCount,
  });

  final String id;
  final String title;
  final String instructor;
  final String description;
  final String category;
  final CourseLevel level;
  final double price;
  final double rating;
  final double durationHours;
  final int lessonCount;

  bool get isFree => price == 0;

  @override
  List<Object?> get props => [id, title, instructor, category, level, price];
}