import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.initFlutter();
  await Hive.openBox<String>('settings');

  final container = ProviderContainer();

  // Fire-and-forget: wakes the sleeping Render server while the splash
  // screen shows. GET /api/categories is public, so it needs no token.
  unawaited(
    container
        .read(dioProvider)
        .get<dynamic>('/api/categories')
        .then((_) {}, onError: (_) {}),
  );

  // Restore the saved session BEFORE the first screen, so the router
  // guard already knows who is logged in (even on a browser refresh).
  await container.read(authViewModelProvider.notifier).restoreSession();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ElearningApp(),
    ),
  );
}