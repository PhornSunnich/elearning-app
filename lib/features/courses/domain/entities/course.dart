import 'package:equatable/equatable.dart';

enum CourseLevel { beginner, intermediate, advanced }

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.description,
    required this.category,
    this.categoryId,
    this.level, // the API has no level
    this.price = 0, // the API has no price: everything is free
    this.rating = 0,
    this.reviewCount = 0,
    this.durationHours, // the API has no duration
    this.lessonCount = 0,
  });

  final String id;
  final String title;
  final String instructor;
  final String description;
  final String category;
  final String? categoryId;
  final CourseLevel? level;
  final double price;
  final double rating;
  final int reviewCount;
  final double? durationHours;
  final int lessonCount;

  bool get isFree => price == 0;
  bool get hasRating => reviewCount > 0;

  @override
  List<Object?> get props => [id, title, instructor, category, price, rating];
}