import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../viewmodels/courses_viewmodel.dart';
import '../widgets/course_card.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      // AsyncValue.when forces you to handle all three states.
      body: courses.when(
        loading: () => const LoadingView(message: 'Loading courses...'),
        error: (error, _) => ErrorView(
          message: error is AppException
              ? error.message
              : 'Could not load courses.',
          onRetry: () => ref.invalidate(coursesViewModelProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyView(
              icon: Icons.school_outlined,
              title: 'No courses yet',
              message: 'Check back soon for new courses.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(coursesViewModelProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => CourseCard(course: list[i]),
            ),
          );
        },
      ),
    );
  }
}