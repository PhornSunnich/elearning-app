import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

/// Placeholder. thearong replaces this with the real dashboard.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome, ${user?.name ?? 'Guest'}!',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () async {
                await ref.read(authViewModelProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}