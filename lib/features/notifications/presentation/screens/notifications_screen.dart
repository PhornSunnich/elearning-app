import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/empty_view.dart';

/// Placeholder. Owner: saran (Notifications).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const EmptyView(
        icon: Icons.notifications_none,
        title: 'No notifications',
        message: "You're all caught up.",
      ),
    );
  }
}