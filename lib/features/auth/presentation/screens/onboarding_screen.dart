import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_primary_button.dart';

class _OnboardingPage {
  const _OnboardingPage(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}

const _pages = [
  _OnboardingPage(
    Icons.explore_rounded,
    'Discover Courses',
    'Browse hundreds of courses across many categories and find what fits you.',
  ),
  _OnboardingPage(
    Icons.play_circle_rounded,
    'Learn Your Way',
    'Watch video lessons, take quizzes, and even learn offline.',
  ),
  _OnboardingPage(
    Icons.workspace_premium_rounded,
    'Earn Certificates',
    'Track your progress and get certified when you complete a course.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.go(AppRoutes.login);

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLast ? null : _finish,
                child: Text(_isLast ? '' : 'Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon,
                              size: 96, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: theme.colorScheme.outline),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: active ? 24 : 8,
                  decoration: BoxDecoration(
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AppPrimaryButton(
                label: _isLast ? 'Get Started' : 'Next',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}