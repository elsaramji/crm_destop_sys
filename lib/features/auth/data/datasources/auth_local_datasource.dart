import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/admin_user.dart';
import '../models/admin_model.dart';

abstract class AuthLocalDatasource {
  Future<AdminUser?> login(String username, String password);
  Future<AdminUser?> getCurrentUser();
  Future<void> logout();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final AppDatabase database;
  AdminUser? _currentUser;

  AuthLocalDatasourceImpl(this.database);

  @override
  Future<AdminUser?> login(String username, String password) async {
    final query = database.select(database.adminsTable)
      ..where((t) => t.username.equals(username.trim().toLowerCase()));
    final admin = await query.getSingleOrNull();

    if (admin != null && admin.passwordHash == password) {
      final now = DateTime.now();
      await (database.update(database.adminsTable)..where((t) => t.id.equals(admin.id))).write(
        AdminsTableCompanion(lastLoginAt: Value(now)),
      );
      _currentUser = AdminModel.fromDrift(admin).copyWith(lastLoginAt: now);
      return _currentUser;
    }
    return null;
  }

  @override
  Future<AdminUser?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final first = await (database.select(database.adminsTable)..limit(1)).getSingleOrNull();
    if (first != null) {
      _currentUser = AdminModel.fromDrift(first);
      return _currentUser;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}
