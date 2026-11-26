import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_content.dart';
import '../viewmodels/course_details_viewmodel.dart';
import '../viewmodels/enrollment_viewmodel.dart';

class CourseDetailsScreen extends ConsumerStatefulWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDetailsScreen> createState() =>
      _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  bool _enrolling = false;

    Future<void> _enroll() async {
    setState(() => _enrolling = true);
    try {
      await ref.read(enrollmentsProvider.notifier).enroll(widget.courseId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrolled! Find it in My Learning.')),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not enroll. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailsProvider(widget.courseId));
    final enrolled = ref.watch(enrolledCourseIdsProvider).contains(widget.courseId);

    return Scaffold(
      appBar: AppBar(title: const Text('Course details')),
      body: courseAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e is AppException ? e.message : 'Could not load course.',
          onRetry: () =>
              ref.invalidate(courseDetailsProvider(widget.courseId)),
        ),
        data: (course) => Column(
          children: [
            Expanded(child: _Body(course: course)),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: AppPrimaryButton(
                  label: enrolled
                      ? 'Enrolled'
                      : course.isFree
                          ? 'Enroll for free'
                          : 'Enroll now · \$${course.price.toStringAsFixed(2)}',
                  icon: enrolled ? Icons.check_circle : null,
                  isLoading: _enrolling,
                  onPressed: enrolled ? null : _enroll,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final content = ref.watch(courseContentProvider(course.id));
    final enrolled = ref.watch(enrolledCourseIdsProvider).contains(course.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.play_circle_rounded,
              size: 64, color: scheme.primary),
        ),
        const SizedBox(height: 16),
        Text(course.title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('By ${course.instructor}',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.outline)),
        const SizedBox(height: 12),
                Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _Stat(
              Icons.star_rounded,
              course.hasRating
                  ? '${course.rating.toStringAsFixed(1)} (${course.reviewCount} reviews)'
                  : 'No reviews yet',
            ),
            if (course.durationHours != null)
              _Stat(Icons.schedule, '${course.durationHours}h'),
            _Stat(Icons.menu_book_outlined, '${course.lessonCount} lessons'),
            if (course.category.isNotEmpty)
              _Stat(Icons.category_outlined, course.category),
          ],
        ),
        const SizedBox(height: 20),
        Text('About this course', style: _heading(theme)),
        const SizedBox(height: 8),
        Text(course.description, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        content.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: LoadingView(message: 'Loading curriculum...'),
          ),
          error: (e, _) => ErrorView(
            message: 'Could not load curriculum.',
            onRetry: () => ref.invalidate(courseContentProvider(course.id)),
          ),
            data: (c) => _Content(content: c, enrolled: enrolled),
        ),
      ],
    );
  }

  TextStyle? _heading(ThemeData theme) =>
      theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.content, required this.enrolled});

  final CourseContent content;
  final bool enrolled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    Widget bullets(List<String> items, IconData icon) => Column(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.objectives.isNotEmpty) ...[
          Text("What you'll learn", style: heading),
          const SizedBox(height: 8),
          bullets(content.objectives, Icons.check_circle_outline),
          const SizedBox(height: 20),
        ],
        if (content.requirements.isNotEmpty) ...[
          Text('Requirements', style: heading),
          const SizedBox(height: 8),
          bullets(content.requirements, Icons.arrow_right_alt),
          const SizedBox(height: 20),
        ],
        Text('Curriculum · ${content.lessonCount} lessons', style: heading),
        const SizedBox(height: 8),
        if (content.lessonCount == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No lessons have been added yet.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        for (final module in content.modules)
          if (module.lessons.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                shape: const Border(),
                initiallyExpanded: content.modules.length == 1,
                title: Text(module.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('${module.lessons.length} lessons'),
                children: [
                  for (final lesson in module.lessons)
                    ListTile(
                      dense: true,
                      leading: Icon(
                        lesson.isPreview || enrolled
                            ? Icons.play_circle_outline
                            : Icons.lock_outline,
                        color: lesson.isPreview || enrolled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      title: Text(lesson.title),
                      trailing: _trailing(theme, lesson),
                    ),
                ],
              ),
            ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget? _trailing(ThemeData theme, Lesson lesson) {
    final style = theme.textTheme.bodySmall;
    final minutes = lesson.durationMinutes;
    if (minutes == null) {
      return lesson.isPreview ? Text('Preview', style: style) : null;
    }
    return Text(
      lesson.isPreview ? 'Preview · $minutes min' : '$minutes min',
      style: style,
    );
  }
}