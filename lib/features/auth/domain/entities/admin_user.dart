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

  @override
  List<Object?> get props => [id, username, name, email, lastLoginAt];
}
