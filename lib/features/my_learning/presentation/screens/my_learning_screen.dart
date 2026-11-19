import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/empty_view.dart';

/// Placeholder. Owner: visal (My Learning).
class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Learning')),
      body: const EmptyView(
        icon: Icons.play_circle_outline,
        title: 'No courses yet',
        message: 'Courses you enroll in will appear here.',
      ),
    );
  }
}