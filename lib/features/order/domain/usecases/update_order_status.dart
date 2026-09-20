import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class UpdateOrderStatusParams extends Equatable {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatusParams({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class UpdateOrderStatus implements UseCase<void, UpdateOrderStatusParams> {
  final OrderRepository repository;

  UpdateOrderStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateOrderStatusParams params) {
    return repository.updateOrderStatus(params.orderId, params.status);
  }
}
