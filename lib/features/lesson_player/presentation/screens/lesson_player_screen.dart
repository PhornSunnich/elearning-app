import 'package:chewie/chewie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../courses/domain/entities/course_content.dart';
import '../../../courses/presentation/viewmodels/course_details_viewmodel.dart';
import '../../../courses/presentation/viewmodels/enrollment_viewmodel.dart';
import '../../domain/entities/course_progress.dart';
import '../viewmodels/lesson_progress_viewmodel.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  bool _busy = false;

  Future<void> _toggleComplete(Lesson lesson, bool currentlyDone) async {
    setState(() => _busy = true);
    try {
      await ref.read(lessonProgressControllerProvider).setCompleted(
            courseId: widget.courseId,
            lessonId: lesson.id,
            completed: !currentlyDone,
          );
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save your progress.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _goTo(Lesson lesson) {
    // Replace, so Back returns to the course instead of the previous lesson.
    context.pushReplacement(AppRoutes.lesson(widget.courseId, lesson.id));
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(courseContentProvider(widget.courseId));
    final enrolled =
        ref.watch(enrolledCourseIdsProvider).contains(widget.courseId);
    final progress = ref.watch(courseProgressProvider(widget.courseId)).value ??
        CourseProgress.empty;

    return contentAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const LoadingView(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: e is AppException ? e.message : 'Could not load the lesson.',
          onRetry: () =>
              ref.invalidate(courseContentProvider(widget.courseId)),
        ),
      ),
      data: (content) {
        final lessons = content.modules.expand((m) => m.lessons).toList();
        final index = lessons.indexWhere((l) => l.id == widget.lessonId);
        if (index < 0) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorView(message: 'Lesson not found.'),
          );
        }
        final lesson = lessons[index];
        final canWatch = enrolled || lesson.isPreview;
        final done = progress.isCompleted(lesson.id);
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(title: Text(lesson.title)),
          body: Column(
            children: [
              if (canWatch)
                // The key restarts the player when the lesson changes.
                _VideoArea(key: ValueKey(lesson.id), url: lesson.videoUrl)
              else
                const _LockedArea(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      lesson.title,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lesson ${index + 1} of ${lessons.length}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                    if (enrolled) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (progress.percentage / 100).clamp(0.0, 1.0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.percentage.round()}% of the course complete',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                    if ((lesson.content ?? '').isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(lesson.content!, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 24),
                    if (enrolled)
                      AppPrimaryButton(
                        label: done ? 'Mark as not complete' : 'Mark as complete',
                        icon:
                            done ? Icons.undo : Icons.check_circle_outline,
                        isLoading: _busy,
                        onPressed: () => _toggleComplete(lesson, done),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: index > 0
                                ? () => _goTo(lessons[index - 1])
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            label: const Text('Previous'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: index < lessons.length - 1
                                ? () => _goTo(lessons[index + 1])
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            label: const Text('Next'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LockedArea extends StatelessWidget {
  const _LockedArea();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: Colors.white70, size: 40),
            SizedBox(height: 8),
            Text('Enroll in this course to watch',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _VideoArea extends StatefulWidget {
  const _VideoArea({super.key, required this.url});

  final String? url;

  @override
  State<_VideoArea> createState() => _VideoAreaState();
}

class _VideoAreaState extends State<_VideoArea> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.url;
    if (url == null || url.isEmpty) return;
    try {
      final video = VideoPlayerController.networkUrl(Uri.parse(url));
      _video = video;
      await video.initialize();
      if (!mounted) return; // dispose() already released the controller
      setState(() {
        _chewie = ChewieController(
          videoPlayerController: video,
          autoPlay: false,
          allowFullScreen: true,
          allowPlaybackSpeedChanging: true,
          playbackSpeeds: const [0.5, 0.75, 1, 1.25, 1.5, 2],
          aspectRatio: video.value.aspectRatio,
        );
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    final url = widget.url;
    if (url == null || url.isEmpty) {
      child = const Text('This lesson has no video.',
          style: TextStyle(color: Colors.white70));
    } else if (_failed) {
      child = const Text('Could not load the video.',
          style: TextStyle(color: Colors.white70));
    } else if (_chewie == null) {
      child = const CircularProgressIndicator();
    } else {
      child = Chewie(controller: _chewie!);
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}