import 'package:equatable/equatable.dart';

import 'course.dart';

/// One page of the course list (the API is paged).
class CoursePage extends Equatable {
  const CoursePage({
    required this.items,
    required this.page,
    required this.isLast,
  });

  final List<Course> items;
  final int page;
  final bool isLast;

  @override
  List<Object?> get props => [items, page, isLast];
}