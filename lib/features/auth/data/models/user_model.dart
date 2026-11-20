import '../../domain/entities/app_user.dart';

/// Data-layer twin of AppUser. It knows about JSON; the entity does not.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromEntity(AppUser user) => UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: UserRole.values.byName(json['role'] as String),
      );

  final String id;
  final String name;
  final String email;
  final UserRole role;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
      };

  AppUser toEntity() =>
      AppUser(id: id, name: name, email: email, role: role);
}