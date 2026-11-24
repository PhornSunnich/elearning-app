import 'package:material_ui/material_ui.dart';

import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, this.onTap});

  final Course course;
  final VoidCallback? onTap;

  String? get _levelLabel => switch (course.level) {
        CourseLevel.beginner => 'Beginner',
        CourseLevel.intermediate => 'Intermediate',
        CourseLevel.advanced => 'Advanced',
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final small = theme.textTheme.bodySmall;

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
                    if (course.category.isNotEmpty)
                      Text(
                        course.category,
                        style: small?.copyWith(
                            color: scheme.primary, fontWeight: FontWeight.w600),
                      ),
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(course.instructor,
                        style: small?.copyWith(color: scheme.outline)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(
                              course.hasRating
                                  ? '${course.rating.toStringAsFixed(1)} (${course.reviewCount})'
                                  : 'New',
                              style: small,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_outlined,
                                size: 14, color: scheme.outline),
                            const SizedBox(width: 2),
                            Text('${course.lessonCount} lessons', style: small),
                          ],
                        ),
                        if (course.durationHours != null)
                          Text('${course.durationHours}h', style: small),
                        if (_levelLabel != null) Text(_levelLabel!, style: small),
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