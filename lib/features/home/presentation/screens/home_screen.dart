import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../courses/domain/entities/course_content.dart';
import '../../../courses/domain/entities/enrollment.dart';
import '../../../courses/presentation/viewmodels/course_details_viewmodel.dart';
import '../../../courses/presentation/viewmodels/courses_viewmodel.dart';
import '../../../courses/presentation/viewmodels/enrollment_viewmodel.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../../../lesson_player/presentation/viewmodels/lesson_progress_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(enrollmentsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(popularCoursesProvider);
    try {
      await ref.read(popularCoursesProvider.future);
    } catch (_) {
      // The section shows its own error message and Retry button.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawName = ref.watch(
          authViewModelProvider.select((s) => s.user?.name.trim()),
        ) ??
        '';
    final displayName = rawName.isEmpty ? 'Learner' : rawName;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              _HomeHeader(
                displayName: displayName,
                isDark: isDark,
                onToggleTheme: () => ref
                    .read(themeModeProvider.notifier)
                    .set(isDark ? ThemeMode.light : ThemeMode.dark),
              ),
              const SizedBox(height: 22),
              _SearchBarBox(onTap: () => context.go(AppRoutes.explore)),
              const SizedBox(height: 24),
              const _CategoryChips(),
              const _SectionTitle('Continue Learning'),
              const SizedBox(height: 12),
              const _ContinueLearningSection(),
              const SizedBox(height: 24),
              const _PopularSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- header

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.displayName,
    required this.isDark,
    required this.onToggleTheme,
  });

  final String displayName;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initial =
        String.fromCharCode(displayName.runes.first).toUpperCase();

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.outline),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onToggleTheme,
          tooltip: 'Switch theme',
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _SearchBarBox extends StatelessWidget {
  const _SearchBarBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: scheme.outline, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search courses, topics, or skills...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message =
        error is AppException ? (error as AppException).message : 'Could not load.';
    return Row(
      children: [
        Icon(Icons.error_outline,
            color: Theme.of(context).colorScheme.error, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

// ------------------------------------------------------------ categories

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Categories'),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final category = categories[i];
              return ActionChip(
                label: Text(category.name),
                onPressed: () {
                  // Open Explore already filtered by this category.
                  ref
                      .read(coursesViewModelProvider.notifier)
                      .setCategory(category.id);
                  context.go(AppRoutes.explore);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ------------------------------------------------------ continue learning

/// The unfinished course the student is closest to completing.
Enrollment? _pickContinue(List<Enrollment> list) {
  final active = list.where((e) => !e.isCompleted).toList();
  if (active.isEmpty) return null;

  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  active.sort((a, b) {
    final byProgress = b.progress.compareTo(a.progress);
    if (byProgress != 0) return byProgress;
    return (b.enrolledAt ?? epoch).compareTo(a.enrolledAt ?? epoch);
  });
  return active.first;
}

class _ContinueLearningSection extends ConsumerWidget {
  const _ContinueLearningSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollments = ref.watch(enrollmentsProvider);

    return enrollments.when(
      loading: () => const _SectionLoading(),
      error: (e, _) => _SectionError(
        error: e,
        onRetry: () => ref.invalidate(enrollmentsProvider),
      ),
      data: (list) {
        final active = _pickContinue(list);
        if (active == null) {
          return _StartLearningCard(
            finishedAll: list.isNotEmpty,
            onExplore: () => context.go(AppRoutes.explore),
          );
        }
        return _ContinueLearningCard(enrollment: active);
      },
    );
  }
}

class _ContinueLearningCard extends ConsumerWidget {
  const _ContinueLearningCard({required this.enrollment});

  final Enrollment enrollment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final courseId = enrollment.courseId;

    final content = ref.watch(courseContentProvider(courseId)).value;
    final progress = ref.watch(courseProgressProvider(courseId)).value;

    // The next lesson the student has not completed yet.
    final lessons =
        content?.modules.expand((m) => m.lessons).toList() ?? const <Lesson>[];
    Lesson? next;
    if (lessons.isNotEmpty) {
      next = lessons.firstWhere(
        (l) => !(progress?.isCompleted(l.id) ?? false),
        orElse: () => lessons.first,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'IN PROGRESS',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${enrollment.progress.round()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            enrollment.courseTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            next == null ? 'Open the course' : 'Next: ${next.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: enrollment.progressFraction,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(
              next == null
                  ? AppRoutes.courseDetails(courseId)
                  : AppRoutes.lesson(courseId, next.id),
            ),
            child: const Text('Continue Lesson'),
          ),
        ],
      ),
    );
  }
}

class _StartLearningCard extends StatelessWidget {
  const _StartLearningCard({
    required this.finishedAll,
    required this.onExplore,
  });

  final bool finishedAll;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            finishedAll
                ? Icons.workspace_premium_outlined
                : Icons.play_circle_outline,
            size: 40,
            color: scheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            finishedAll ? "You're all caught up!" : 'Nothing in progress yet',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            finishedAll
                ? 'Find your next course to keep learning.'
                : 'Enroll in a course and it will show up here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onExplore,
            child: const Text('Explore courses'),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- popular

class _PopularSection extends ConsumerWidget {
  const _PopularSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popular = ref.watch(popularCoursesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle('Popular Courses'),
            TextButton(
              onPressed: () => context.go(AppRoutes.explore),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        popular.when(
          loading: () => const _SectionLoading(),
          error: (e, _) => _SectionError(
            error: e,
            onRetry: () => ref.invalidate(popularCoursesProvider),
          ),
          data: (courses) {
            if (courses.isEmpty) {
              return Text(
                'No courses yet. Check back soon.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.outline),
              );
            }
            return Column(
              children: [
                for (final course in courses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CourseCard(
                      course: course,
                      onTap: () =>
                          context.go(AppRoutes.courseDetails(course.id)),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}