import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.durationMinutes,
    this.isPreview = false,
  });

  final String id;
  final String title;
  final int durationMinutes;
  final bool isPreview; // previewable without enrolling

  @override
  List<Object?> get props => [id, title, durationMinutes, isPreview];
}

class CourseModule extends Equatable {
  const CourseModule({required this.title, required this.lessons});

  final String title;
  final List<Lesson> lessons;

  @override
  List<Object?> get props => [title, lessons];
}

class CourseContent extends Equatable {
  const CourseContent({
    required this.objectives,
    required this.requirements,
    required this.modules,
  });

  final List<String> objectives;
  final List<String> requirements;
  final List<CourseModule> modules;

  int get lessonCount =>
      modules.fold(0, (sum, m) => sum + m.lessons.length);

  @override
  List<Object?> get props => [objectives, requirements, modules];
}