import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../data/repositories/api_course_repository.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_category.dart';
import '../../domain/repositories/course_repository.dart';

/// The ONE place that chooses the data source. To use demo data again,
/// return FakeCourseRepository() here.
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return ApiCourseRepository(CourseRemoteDataSource(ref.read(dioProvider)));
});

final categoriesProvider = FutureProvider<List<CourseCategory>>((ref) {
  return ref.read(courseRepositoryProvider).getCategories();
});

enum CoursesStatus { loading, ready, error }

class CoursesState extends Equatable {
  const CoursesState({
    this.status = CoursesStatus.loading,
    this.items = const [],
    this.search = '',
    this.categoryId,
    this.page = 0,
    this.isLast = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final CoursesStatus status;
  final List<Course> items;
  final String search;
  final String? categoryId;
  final int page;
  final bool isLast;
  final bool isLoadingMore;
  final String? errorMessage;

  CoursesState copyWith({
    CoursesStatus? status,
    List<Course>? items,
    String? search,
    String? categoryId,
    bool clearCategory = false,
    int? page,
    bool? isLast,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CoursesState(
      status: status ?? this.status,
      items: items ?? this.items,
      search: search ?? this.search,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      page: page ?? this.page,
      isLast: isLast ?? this.isLast,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, items, search, categoryId, page, isLast, isLoadingMore, errorMessage];
}

class CoursesViewModel extends Notifier<CoursesState> {
  int _requestId = 0; // lets us ignore out-of-date responses

  @override
  CoursesState build() {
    Future.microtask(() => _fetch(reset: true));
    return const CoursesState();
  }

  Future<void> refresh() => _fetch(reset: true);

  void setSearch(String value) {
    if (value == state.search) return;
    state = state.copyWith(search: value);
    _fetch(reset: true);
  }

  void setCategory(String? id) {
    state = id == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(categoryId: id);
    _fetch(reset: true);
  }

  Future<void> loadMore() async {
    if (state.status != CoursesStatus.ready ||
        state.isLast ||
        state.isLoadingMore) {
      return;
    }
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    final requestId = ++_requestId;
    final nextPage = reset ? 0 : state.page + 1;

    state = reset
        ? state.copyWith(
            status: CoursesStatus.loading,
            items: const [],
            page: 0,
            isLast: false,
            isLoadingMore: false,
            clearError: true,
          )
        : state.copyWith(isLoadingMore: true);

    try {
      final result = await ref.read(courseRepositoryProvider).getCourses(
            search: state.search.isEmpty ? null : state.search,
            categoryId: state.categoryId,
            page: nextPage,
          );
      if (requestId != _requestId) return; // a newer request replaced this one
      state = state.copyWith(
        status: CoursesStatus.ready,
        items: reset ? result.items : [...state.items, ...result.items],
        page: result.page,
        isLast: result.isLast,
        isLoadingMore: false,
      );
    } catch (e) {
      if (requestId != _requestId) return;
      final message =
          e is AppException ? e.message : 'Could not load courses.';
      state = reset
          ? state.copyWith(status: CoursesStatus.error, errorMessage: message)
          : state.copyWith(isLoadingMore: false);
    }
  }
}

final coursesViewModelProvider =
    NotifierProvider<CoursesViewModel, CoursesState>(CoursesViewModel.new);