import '../../domain/entities/app_user.dart';

/// Role strings sent to and received from the API. If your backend uses a
/// different format (for example ROLE_STUDENT), change ONLY these two.
String roleToApi(UserRole role) => role.name.toUpperCase();

UserRole roleFromApi(String? value) =>
    (value ?? '').toLowerCase().contains('instructor')
        ? UserRole.instructor
        : UserRole.student;

/// Response of POST /api/auth/login
class AuthResponseModel {
  const AuthResponseModel({
    required this.token,
    required this.email,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        token: json['token'] as String,
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? '',
      );

  final String token;
  final String email;
  final String role;
}

/// Response of GET/POST /api/students/me
class StudentModel {
  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: (json['id'] as num).toString(), // API ids are numbers
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? '',
      );

  final String id;
  final String name;
  final String email;
  final String role;

  AppUser toEntity() => AppUser(
        id: id,
        name: name.isEmpty ? email.split('@').first : name,
        email: email,
        role: roleFromApi(role),
      );
}