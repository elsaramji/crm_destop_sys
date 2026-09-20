import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/admin_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<AdminUser?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, AdminUser?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
