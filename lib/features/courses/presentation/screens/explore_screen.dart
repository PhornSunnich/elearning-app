import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/course_category.dart';
import '../viewmodels/courses_viewmodel.dart';
import '../widgets/course_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _scroll = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref.read(coursesViewModelProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {}); // refresh the clear (x) button
    _debounce?.cancel();
    // Wait until the user stops typing, so we don't call the API per key.
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(coursesViewModelProvider.notifier).setSearch(value.trim());
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    ref.read(coursesViewModelProvider.notifier).setSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coursesViewModelProvider);
    final notifier = ref.read(coursesViewModelProvider.notifier);
    final categories =
        ref.watch(categoriesProvider).value ?? const <CourseCategory>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search courses',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      ),
              ),
            ),
          ),
          if (categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: state.categoryId == null,
                      onSelected: (_) => notifier.setCategory(null),
                    ),
                  ),
                  for (final c in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: state.categoryId == c.id,
                        onSelected: (_) => notifier.setCategory(
                          state.categoryId == c.id ? null : c.id,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(child: _buildBody(state, notifier)),
        ],
      ),
    );
  }

  Widget _buildBody(CoursesState state, CoursesViewModel notifier) {
    switch (state.status) {
      case CoursesStatus.loading:
        return const LoadingView(
          message: 'Loading courses...\nThe server may take a moment to wake up.',
        );
      case CoursesStatus.error:
        return ErrorView(
          message: state.errorMessage ?? 'Could not load courses.',
          onRetry: () => notifier.refresh(),
        );
      case CoursesStatus.ready:
        if (state.items.isEmpty) {
          return EmptyView(
            icon: Icons.school_outlined,
            title: 'No courses found',
            message: state.search.isEmpty && state.categoryId == null
                ? 'Check back soon for new courses.'
                : 'Try a different search or category.',
          );
        }
        return RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              if (i >= state.items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final course = state.items[i];
              return CourseCard(
                course: course,
                onTap: () =>
                    context.push(AppRoutes.courseDetails(course.id)),
              );
            },
          ),
        );
    }
  }
}