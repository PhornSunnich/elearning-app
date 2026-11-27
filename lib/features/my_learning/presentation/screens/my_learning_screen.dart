import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../courses/presentation/viewmodels/enrollment_viewmodel.dart';

class MyLearningScreen extends ConsumerWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enrollments = ref.watch(enrollmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Learning')),
      body: enrollments.when(
        loading: () => const LoadingView(message: 'Loading your courses...'),
        error: (e, _) => ErrorView(
          message:
              e is AppException ? e.message : 'Could not load your courses.',
          onRetry: () => ref.invalidate(enrollmentsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return EmptyView(
              icon: Icons.play_circle_outline,
              title: 'No courses yet',
              message: 'Courses you enroll in will appear here.',
              actionLabel: 'Explore courses',
              onAction: () => context.go(AppRoutes.explore),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(enrollmentsProvider),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = list[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () =>
                        context.go(AppRoutes.courseDetails(e.courseId)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.courseTitle,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: e.progressFraction,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.isCompleted
                                ? 'Completed'
                                : '${e.progress.round()}% complete',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}