import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/admin_user.dart';

class AdminModel {
  static AdminUser fromDrift(AdminsTableData row) {
    return AdminUser(
      id: row.id,
      username: row.username,
      name: row.name,
      email: row.email,
      lastLoginAt: row.lastLoginAt,
    );
  }

  static AdminsTableCompanion toCompanion(AdminUser user, {String password = 'admin123'}) {
    return AdminsTableCompanion.insert(
      id: user.id,
      username: user.username,
      name: user.name,
      email: user.email,
      passwordHash: password,
      lastLoginAt: Value(user.lastLoginAt),
    );
  }
}
