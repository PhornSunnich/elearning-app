import '../entities/student_profile.dart';

abstract class ProfileRepository {
  Future<StudentProfile> getMyProfile();

  Future<StudentProfile> updateProfile({
    required String name,
    int? age,
    String? major,
  });

  /// The profile is passed in so its current values are sent along with the
  /// password. Otherwise the server could treat missing fields as "clear".
  Future<void> changePassword({
    required StudentProfile profile,
    required String currentPassword,
    required String newPassword,
  });
}