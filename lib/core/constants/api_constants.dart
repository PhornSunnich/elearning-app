class ApiConstants {
  ApiConstants._();

  /// Override at run time:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://student-management-system-eg8t.onrender.com',
  );

  // Render's free plan sleeps; the first request can take up to a minute.
  static const connectTimeout = Duration(seconds: 60);
  static const receiveTimeout = Duration(seconds: 60);

  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const studentsMe = '/api/students/me';
}