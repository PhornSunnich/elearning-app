import 'package:material_ui/material_ui.dart';

import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, this.onTap});

  final Course course;
  final VoidCallback? onTap;

  String get _levelLabel => switch (course.level) {
        CourseLevel.beginner => 'Beginner',
        CourseLevel.intermediate => 'Intermediate',
        CourseLevel.advanced => 'Advanced',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.play_lesson_rounded,
                    size: 40, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course.instructor,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.outline),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text(course.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall),
                        const SizedBox(width: 10),
                        Icon(Icons.schedule, size: 14, color: scheme.outline),
                        const SizedBox(width: 2),
                        Text('${course.durationHours}h',
                            style: theme.textTheme.bodySmall),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(_levelLabel,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.isFree
                          ? 'Free'
                          : '\$${course.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: course.isFree
                            ? const Color(0xFF16A34A)
                            : scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}