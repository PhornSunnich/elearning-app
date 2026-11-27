import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/api_profile_repository.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ApiProfileRepository(ProfileRemoteDataSource(ref.read(dioProvider)));
});

/// autoDispose: nothing stays cached after the profile screens close, and
/// nothing calls the API once the user has logged out.
final myProfileProvider = FutureProvider.autoDispose<StudentProfile>((ref) {
  final id = ref.watch(authViewModelProvider.select((s) => s.user?.id));
  if (id == null) throw const AppException('Please log in first.');
  return ref.read(profileRepositoryProvider).getMyProfile();
});

class ProfileController {
  ProfileController(this._ref);

  final Ref _ref;

  Future<void> save({
    required String name,
    int? age,
    String? major,
  }) async {
    final updated = await _ref
        .read(profileRepositoryProvider)
        .updateProfile(name: name, age: age, major: major);

    _ref.invalidate(myProfileProvider);

    // Keep the saved session in step, so "Welcome, <name>" on Home updates.
    final user = _ref.read(authViewModelProvider).user;
    if (user != null) {
      await _ref.read(authViewModelProvider.notifier).updateUser(
            AppUser(
              id: user.id,
              name: updated.name,
              email: user.email,
              role: user.role,
            ),
          );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final profile = await _ref.read(myProfileProvider.future);
    await _ref.read(profileRepositoryProvider).changePassword(
          profile: profile,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
  }
}

final profileControllerProvider = Provider<ProfileController>((ref) {
  return ProfileController(ref);
});