import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AdminUser>> login(String username, String password);
  Future<Either<Failure, AdminUser?>> getCurrentUser();
  Future<Either<Failure, void>> logout();
}
