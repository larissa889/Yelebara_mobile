import 'package:yelebara_mobile/features/orders/data/datasources/order_local_datasource.dart';
import 'package:yelebara_mobile/features/orders/data/models/order_model.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:yelebara_mobile/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;

  OrderRepositoryImpl(this.localDataSource);

  @override
  Future<List<OrderEntity>> getOrders() async {
    return await localDataSource.loadOrders();
  }

  @override
  Future<void> addOrder(OrderEntity order) async {
    final orderModel = OrderModel.fromEntity(order);
    await localDataSource.saveOrder(orderModel);
  }

  @override
  Future<void> updateOrder(OrderEntity order) async {
    final orderModel = OrderModel.fromEntity(order);
    await localDataSource.updateOrder(orderModel);
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await localDataSource.deleteOrder(orderId);
  }
}
