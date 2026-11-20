import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/fake_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_local_datasource.dart';

/// Dependency injection: the ONE place that decides which implementation
/// is used. Phase 3 changes this line to the real API repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FakeAuthRepository(ref.read(authLocalDataSourceProvider));
});

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;

  @override
  List<Object?> get props => [status, user, errorMessage];
}

/// The ViewModel. Riverpod 3.x style: a Notifier with a build() that
/// returns the initial state. The UI watches `state`, and calls methods.
class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> login({required String email, required String password}) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final user = await _repo.login(email: email, password: password);
      state = AuthState(status: AuthStatus.success, user: user);
    } on AppException catch (e) {
      state = AuthState(status: AuthStatus.failure, errorMessage: e.message);
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final user = await _repo.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      state = AuthState(status: AuthStatus.success, user: user);
    } on AppException catch (e) {
      state = AuthState(status: AuthStatus.failure, errorMessage: e.message);
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

    /// Called once in main() before the first screen.
  Future<void> restoreSession() async {
    try {
      final user = await _repo.restoreSession();
      if (user != null) {
        state = AuthState(status: AuthStatus.success, user: user);
      }
    } catch (_) {
      // Storage unavailable: start logged out instead of crashing.
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(); // back to initial
  }

}

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);