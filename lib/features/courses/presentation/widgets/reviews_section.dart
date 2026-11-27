import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/entities/review.dart';
import '../viewmodels/enrollment_viewmodel.dart';
import '../viewmodels/reviews_viewmodel.dart';
import 'rating_stars.dart';

String _date(DateTime d) {
  final l = d.toLocal();
  return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
}

class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({super.key, required this.courseId});

  final String courseId;

  void _openForm(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ReviewForm(courseId: courseId),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Review review,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete your review?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref
          .read(reviewsControllerProvider)
          .delete(courseId: courseId, reviewId: review.id);
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the review.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    final reviewsAsync = ref.watch(courseReviewsProvider(courseId));
    final enrolled = ref.watch(enrolledCourseIdsProvider).contains(courseId);
    final studentId =
        ref.watch(authViewModelProvider.select((s) => s.user?.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        reviewsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Row(
            children: [
              Expanded(
                child: Text(
                  e is AppException ? e.message : 'Could not load reviews.',
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(courseReviewsProvider(courseId)),
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (data) {
            Review? mine;
            for (final r in data.reviews) {
              if (r.studentId == studentId) {
                mine = r;
                break;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.total > 0)
                  Row(
                    children: [
                      Text(
                        data.average.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingStars(rating: data.average),
                          const SizedBox(height: 2),
                          Text(
                            '${data.total} ${data.total == 1 ? 'review' : 'reviews'}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: outline),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Text(
                    'No reviews yet.',
                    style:
                        theme.textTheme.bodyMedium?.copyWith(color: outline),
                  ),
                const SizedBox(height: 12),
                if (!enrolled)
                  Text(
                    'Enroll in this course to leave a review.',
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: outline),
                  )
                else if (mine == null)
                  OutlinedButton.icon(
                    onPressed: () => _openForm(context),
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Write a review'),
                  ),
                const SizedBox(height: 8),
                for (final r in data.reviews)
                  _ReviewTile(
                    review: r,
                    isMine: r.studentId == studentId,
                    onDelete: () => _confirmDelete(context, ref, r),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.isMine,
    required this.onDelete,
  });

  final Review review;
  final bool isMine;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    final name = review.studentName.isEmpty ? 'Student' : review.studentName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                child: Text(name[0].toUpperCase()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMine ? '$name (you)' : name,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        RatingStars(rating: review.rating.toDouble(), size: 14),
                        if (review.createdAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _date(review.createdAt!),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: outline),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isMine)
                IconButton(
                  tooltip: 'Delete my review',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment, style: theme.textTheme.bodyMedium),
          ],
          const Divider(height: 24),
        ],
      ),
    );
  }
}

class _ReviewForm extends ConsumerStatefulWidget {
  const _ReviewForm({required this.courseId});

  final String courseId;

  @override
  ConsumerState<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<_ReviewForm> {
  final _comment = TextEditingController();
  int _rating = 0;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Choose a star rating.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    // Grab these before the await: the sheet is closed on success.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(reviewsControllerProvider).submit(
            courseId: widget.courseId,
            rating: _rating,
            comment: _comment.text.trim(),
          );
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Thanks for your review!')),
      );
    } on AppException catch (e) {
      if (mounted) setState(() => _busy = false);
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not save your review. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom, // keep above the keyboard
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rate this course',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Center(
              child: RatingPicker(
                value: _rating,
                onChanged: (v) => setState(() {
                  _rating = v;
                  _error = null;
                }),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _comment,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            AppPrimaryButton(
              label: 'Submit review',
              isLoading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}