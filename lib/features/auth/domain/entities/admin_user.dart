import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String username;
  final String name;
  final String email;
  final DateTime? lastLoginAt;

  const AdminUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.lastLoginAt,
  });

  AdminUser copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    DateTime? lastLoginAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [id, username, name, email, lastLoginAt];
}
