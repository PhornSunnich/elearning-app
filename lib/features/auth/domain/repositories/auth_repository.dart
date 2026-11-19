import '../entities/app_user.dart';

/// The contract. The ViewModel depends on THIS, never on a concrete class.
abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<void> logout();
}