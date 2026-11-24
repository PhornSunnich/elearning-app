import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// Turns any Dio failure into a message that is safe to show the user.
AppException mapDioError(DioException e, {String? unauthorizedMessage}) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const AppException(
        'The server is taking too long. It may be waking up, please try again.',
      );
    case DioExceptionType.connectionError:
      return const AppException(
        'Cannot reach the server. Check your internet connection.',
      );
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode ?? 0;
      if (status == 401 && unauthorizedMessage != null) {
        return AppException(unauthorizedMessage);
      }
      final serverMessage = _messageFromBody(e.response?.data);
      if (serverMessage != null) return AppException(serverMessage);
      if (status == 401) return const AppException('Please log in again.');
      if (status == 403) {
        return const AppException('You do not have permission to do that.');
      }
      if (status == 404) return const AppException('Not found.');
      if (status == 409) return const AppException('This already exists.');
      if (status >= 500) {
        return const AppException('Server error. Please try again later.');
      }
      return const AppException('Request failed. Please try again.');
    default:
      return const AppException('Something went wrong. Please try again.');
  }
}

String? _messageFromBody(Object? data) {
  if (data is Map && data['message'] is String) {
    final m = (data['message'] as String).trim();
    if (m.isNotEmpty) return m;
  }
  return null;
}