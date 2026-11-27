import 'package:dio/dio.dart';

import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProfileModel> getMyProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/students/me');
    return ProfileModel.fromJson(res.data!);
  }

  Future<ProfileModel> updateMyProfile({
    required String name,
    int? age,
    String? major,
    String? currentPassword,
    String? newPassword,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/students/me',
            data: {
        'name': name,
        'age': ?age,
        'major': ?major,
        'currentPassword': ?currentPassword,
        'newPassword': ?newPassword,
      },
    );
    return ProfileModel.fromJson(res.data!);
  }
}