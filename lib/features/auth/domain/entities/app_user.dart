import 'package:equatable/equatable.dart';

enum UserRole { student, instructor }

/// Pure business object: no JSON, no Flutter. Equatable makes two users
/// with the same fields compare equal.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  @override
  List<Object?> get props => [id, name, email, role];
}