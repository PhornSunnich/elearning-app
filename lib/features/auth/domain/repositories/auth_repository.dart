import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<void> logout();

  /// The user saved on this device, or null if nobody is logged in.
  Future<AppUser?> restoreSession();

  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> updateCachedUser(AppUser user);
}