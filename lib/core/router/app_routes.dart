class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  // Bottom navigation tabs
  static const home = '/home';
  static const explore = '/explore';
  static const myLearning = '/my-learning';
  static const notifications = '/notifications';
  static const profile = '/profile';

  static String courseDetails(String id) => '/explore/course/$id';

  static String resetPasswordFor(String email) =>
    Uri(path: resetPassword, queryParameters: {'email': email}).toString();

  static String lesson(String courseId, String lessonId) =>
      '/explore/course/$courseId/lesson/$lessonId';
  
}