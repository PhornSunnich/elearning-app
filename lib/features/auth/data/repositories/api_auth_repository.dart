import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_error.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required this._remote,
    required this._local,
  });

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  /// Runs [run]; converts Dio errors to user-friendly AppExceptions.
  Future<T> _guard<T>(
    Future<T> Function() run, {
    String? unauthorizedMessage,
  }) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw mapDioError(e, unauthorizedMessage: unauthorizedMessage);
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) {
    return _guard(
      () async {
        final auth = await _remote.login(email: email, password: password);
        // Store the token first: the profile call below needs it.
        await _local.saveToken(auth.token);
        try {
          final profile = await _loadOrCreateProfile(
            email: email,
            password: password,
          );
          final user = profile.toEntity();
          await _local.saveSession(user: user, accessToken: auth.token);
          return user;
        } catch (_) {
          await _local.clear(); // never keep a half-finished login
          rethrow;
        }
      },
      unauthorizedMessage: 'Invalid email or password',
    );
  }

  /// Accounts created outside the app may have no student profile yet.
  Future<StudentModel> _loadOrCreateProfile({
    required String email,
    required String password,
  }) async {
    try {
      return await _remote.getMyProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _remote.saveMyProfile(
          name: email.split('@').first,
          email: email,
          password: password,
        );
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    return _guard(() async {
      await _remote.register(
        email: email,
        password: password,
        role: roleToApi(role),
      );
      // The API's register has no "name", so: log in, then save the profile.
      final auth = await _remote.login(email: email, password: password);
      await _local.saveToken(auth.token);
      try {
        final profile = await _remote.saveMyProfile(
          name: name,
          email: email,
          password: password,
        );
        final user = profile.toEntity();
        await _local.saveSession(user: user, accessToken: auth.token);
        return user;
      } catch (_) {
        await _local.clear();
        rethrow;
      }
    });
  }

  @override
  Future<void> logout() => _local.clear();

  @override
  Future<AppUser?> restoreSession() => _local.readUser();

  // The backend has no password-reset endpoints yet.
  @override
  Future<void> requestPasswordReset(String email) async {
    throw const AppException('Password reset is not available yet.');
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    throw const AppException('Password reset is not available yet.');
  }

  @override
  Future<void> updateCachedUser(AppUser user) => _local.saveUser(user);

  
}