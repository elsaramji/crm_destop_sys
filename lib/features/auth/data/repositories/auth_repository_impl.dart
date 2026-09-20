import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, AdminUser>> login(String username, String password) async {
    try {
      final user = await localDatasource.login(username, password);
      if (user != null) {
        return Right(user);
      }
      return const Left(AuthFailure('Invalid username or password. Use admin / admin123'));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUser?>> getCurrentUser() async {
    try {
      final user = await localDatasource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDatasource.logout();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
