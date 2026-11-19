import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/empty_view.dart';

/// Placeholder. Owner: thearong (Course discovery).
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: const EmptyView(
        icon: Icons.explore_outlined,
        title: 'Explore courses',
        message: 'Course discovery is coming soon.',
      ),
    );
  }
}