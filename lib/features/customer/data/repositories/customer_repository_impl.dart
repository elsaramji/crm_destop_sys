import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDatasource localDatasource;

  CustomerRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, List<Customer>>> getCustomers() async {
    try {
      final customers = await localDatasource.getCustomers();
      return Right(customers);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(String id) async {
    try {
      final customer = await localDatasource.getCustomerById(id);
      return Right(customer);
    } catch (e) {
      return Left(NotFoundFailure('Customer not found: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer?>> getCustomerByNationalId(String nationalId) async {
    try {
      final customer = await localDatasource.getCustomerByNationalId(nationalId);
      return Right(customer);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> createCustomer(Customer customer) async {
    try {
      final existing = await localDatasource.getCustomerByNationalId(customer.nationalId);
      if (existing != null) {
        return const Left(DuplicateFailure('A customer with this National ID already exists.'));
      }
      final created = await localDatasource.createCustomer(customer);
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer(Customer customer) async {
    try {
      final existing = await localDatasource.getCustomerByNationalId(customer.nationalId);
      if (existing != null && existing.id != customer.id) {
        return const Left(DuplicateFailure('Another customer with this National ID already exists.'));
      }
      final updated = await localDatasource.updateCustomer(customer);
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      await localDatasource.deleteCustomer(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> searchCustomers(String query) async {
    try {
      final results = await localDatasource.searchCustomers(query);
      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
