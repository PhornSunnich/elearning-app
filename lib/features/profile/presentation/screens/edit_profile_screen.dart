import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/student_profile.dart';
import '../viewmodels/profile_viewmodel.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: profile.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e is AppException ? e.message : 'Could not load profile.',
          onRetry: () => ref.invalidate(myProfileProvider),
        ),
        data: (p) => _EditForm(profile: p),
      ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.profile});

  final StudentProfile profile;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _age =
      TextEditingController(text: widget.profile.age?.toString() ?? '');
  late final _major = TextEditingController(text: widget.profile.major ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _major.dispose();
    super.dispose();
  }

  String? _validateAge(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    final n = int.tryParse(v.trim());
    if (n == null || n < 5 || n > 120) return 'Enter a valid age';
    return null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(profileControllerProvider).save(
            name: _name.text.trim(),
            age: int.tryParse(_age.text.trim()),
            major: _major.text.trim().isEmpty ? null : _major.text.trim(),
          );
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated.')));
      router.pop();
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppTextField(
            label: 'Full name',
            controller: _name,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: (v) => Validators.required(v, field: 'Name'),
          ),
          const SizedBox(height: 16),
          // The email is the login, so it is shown but not editable.
          TextFormField(
            initialValue: widget.profile.email,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Age (optional)',
            controller: _age,
            prefixIcon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: _validateAge,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Major (optional)',
            controller: _major,
            prefixIcon: Icons.school_outlined,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(label: 'Save changes', isLoading: _busy, onPressed: _save),
        ],
      ),
    );
  }
}