import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'session_events.dart';

/// Adds `Authorization: Bearer <token>` to every request except login and
/// register. If the server answers 401, the session is announced as expired.
/// (The API has no refresh token, so there is nothing to retry.)
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens, this._events);

  final TokenStorage _tokens;
  final SessionEvents _events;

  static const _publicPaths = ['/api/auth/login', '/api/auth/register'];

  bool _isPublic(RequestOptions o) => _publicPaths.contains(o.path);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options)) {
      final token = await _tokens.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !_isPublic(err.requestOptions)) {
      _events.expire();
    }
    handler.next(err);
  }
}