import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/app_user.dart';
import '../models/user_model.dart';

/// Saves, reads and clears the logged-in session on the device.
class AuthLocalDataSource {
  AuthLocalDataSource(this._tokens, this._storage);

  final TokenStorage _tokens;
  final FlutterSecureStorage _storage;

  static const _userKey = 'cached_user';

  Future<void> saveToken(String accessToken) =>
      _tokens.save(accessToken: accessToken);

    /// Updates only the cached user (after a profile edit); tokens are kept.
  Future<void> saveUser(AppUser user) => _storage.write(
        key: _userKey,
        value: jsonEncode(UserModel.fromEntity(user).toJson()),
      );

  Future<void> saveSession({
    required AppUser user,
    required String accessToken,
    String? refreshToken,
  }) async {
    await _tokens.save(accessToken: accessToken, refreshToken: refreshToken);
    await _storage.write(
      key: _userKey,
      value: jsonEncode(UserModel.fromEntity(user).toJson()),
    );
  }

  /// Returns the saved user, or null when nobody is logged in.
  Future<AppUser?> readUser() async {
    final token = await _tokens.readAccessToken();
    final raw = await _storage.read(key: _userKey);
    if (token == null || raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json).toEntity();
    } catch (_) {
      await clear(); // corrupted data: start clean
      return null;
    }
  }

  Future<void> clear() async {
    await _tokens.clear();
    await _storage.delete(key: _userKey);
  }
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(
    ref.read(tokenStorageProvider),
    ref.read(secureStorageProvider),
  );
});
