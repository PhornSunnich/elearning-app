import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../viewmodels/profile_viewmodel.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(profileControllerProvider).changePassword(
            currentPassword: _current.text,
            newPassword: _new.text,
          );
      messenger.showSnackBar(
        const SnackBar(content: Text('Password changed.')),
      );
      router.pop();
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not change the password.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AppTextField(
              label: 'Current password',
              controller: _current,
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Enter your current password'
                  : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'New password',
              controller: _new,
              prefixIcon: Icons.lock_reset,
              isPassword: true,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final base = Validators.password(v);
                if (base != null) return base;
                if (v == _current.text) {
                  return 'Choose a different password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Confirm new password',
              controller: _confirm,
              prefixIcon: Icons.lock_reset,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (v) => Validators.confirmPassword(v, _new.text),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Update password',
              isLoading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}