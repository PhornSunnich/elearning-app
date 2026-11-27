import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// In-memory stand-in for the backend. Demo account:
///   student@demo.com / Password1
/// Accounts live in memory (lost on refresh), but the SESSION is saved
/// on the device, like a real app.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._local);

  final AuthLocalDataSource _local;

  final Map<String, _Account> _accounts = {
    'student@demo.com': _Account(
      user: const AppUser(
        id: '1',
        name: 'Demo Student',
        email: 'student@demo.com',
        role: UserRole.student,
      ),
      password: 'Password1',
    ),
  };

  Future<void> _fakeNetworkDelay() =>
      Future.delayed(const Duration(milliseconds: 800));

  Future<void> _saveSession(AppUser user) => _local.saveSession(
        user: user,
        accessToken: 'fake-access-${user.id}',
        refreshToken: 'fake-refresh-${user.id}',
      );

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await _fakeNetworkDelay();
    final account = _accounts[email.toLowerCase()];
    if (account == null || account.password != password) {
      throw const AppException('Invalid email or password');
    }
    await _saveSession(account.user);
    return account.user;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await _fakeNetworkDelay();
    final key = email.toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AppException('An account with this email already exists');
    }
    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: key,
      role: role,
    );
    _accounts[key] = _Account(user: user, password: password);
    await _saveSession(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _local.clear();
  }

  @override
  Future<AppUser?> restoreSession() => _local.readUser();

  @override
  Future<void> requestPasswordReset(String email) async {
    await _fakeNetworkDelay();
    // Real backend: emails a code. Fake: the code is always 123456.
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _fakeNetworkDelay();
    if (code != '123456') {
      throw const AppException('Invalid or expired code');
    }
    final account = _accounts[email.toLowerCase()];
    if (account == null) {
      throw const AppException('Invalid or expired code');
    }
    account.password = newPassword;
  }

  @override
  Future<void> updateCachedUser(AppUser user) => _local.saveUser(user);

}

class _Account {
  _Account({required this.user, required this.password});
  final AppUser user;
  String password;
}