import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

/// Placeholder. Owner: thearong (Home dashboard).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Text(
          'Welcome, ${user?.name ?? 'Guest'}!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}