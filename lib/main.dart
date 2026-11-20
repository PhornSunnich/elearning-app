import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Restore the saved session BEFORE the first screen, so the router
  // guard already knows who is logged in (even on a browser refresh).
  final container = ProviderContainer();
  await container.read(authViewModelProvider.notifier).restoreSession();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ElearningApp(),
    ),
  );
}