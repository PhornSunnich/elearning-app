import '../../../../core/network/api_error.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<StudentProfile> getMyProfile() {
    return guardApi(() async => (await _remote.getMyProfile()).toEntity());
  }

  @override
  Future<StudentProfile> updateProfile({
    required String name,
    int? age,
    String? major,
  }) {
    return guardApi(() async {
      final updated = await _remote.updateMyProfile(
        name: name,
        age: age,
        major: major,
      );
      return updated.toEntity();
    });
  }

  @override
  Future<void> changePassword({
    required StudentProfile profile,
    required String currentPassword,
    required String newPassword,
  }) {
    return guardApi(
      () => _remote.updateMyProfile(
        name: profile.name,
        age: profile.age,
        major: profile.major,
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }
}