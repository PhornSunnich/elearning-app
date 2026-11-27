import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/auth_models.dart';

/// The only class that knows the auth URLs and JSON shapes.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(res.data!);
  }

  Future<void> register({
    required String email,
    required String password,
    required String role,
  }) async {
    await _dio.post<dynamic>(
      ApiConstants.register,
      data: {'email': email, 'password': password, 'role': role},
    );
  }

  Future<StudentModel> getMyProfile() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.studentsMe);
    return StudentModel.fromJson(res.data!);
  }

  Future<StudentModel> saveMyProfile({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.studentsMe,
      data: {'name': name, 'email': email, 'password': password},
    );
    return StudentModel.fromJson(res.data!);
  }
}