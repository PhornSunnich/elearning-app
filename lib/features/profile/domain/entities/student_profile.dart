import 'package:equatable/equatable.dart';

class StudentProfile extends Equatable {
  const StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.major,
  });

  final String id;
  final String name;
  final String email;
  final int? age;
  final String? major;

  @override
  List<Object?> get props => [id, name, email, age, major];
}