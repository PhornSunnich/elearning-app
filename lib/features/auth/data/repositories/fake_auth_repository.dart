import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory stand-in for the backend. Demo account:
///   student@demo.com / Password1
class FakeAuthRepository implements AuthRepository {
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
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

class _Account {
  _Account({required this.user, required this.password});
  final AppUser user;
  final String password;
}