import '../../domain/entities/student_profile.dart';

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.major,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: (json['id'] as num).toString(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        age: (json['age'] as num?)?.toInt(),
        major: json['major'] as String?,
      );

  final String id;
  final String name;
  final String email;
  final int? age;
  final String? major;

  StudentProfile toEntity() => StudentProfile(
        id: id,
        name: name,
        email: email,
        age: age,
        major: major,
      );
}