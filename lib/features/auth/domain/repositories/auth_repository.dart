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

  /// Sends a reset code to the email (always succeeds, so the app never
  /// reveals which emails have accounts).
  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}