import 'package:yelebara_mobile/features/orders/data/datasources/order_local_datasource.dart';
import 'package:yelebara_mobile/features/orders/data/models/order_model.dart';
import 'package:yelebara_mobile/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:yelebara_mobile/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<List<OrderEntity>> getOrders() async {
    // Try remote first
    try {
      final remoteOrders = await remoteDataSource.getOrders();
      // Cache them (optional for now, but good practice)
      // await localDataSource.cacheOrders(remoteOrders); 
      return remoteOrders.map((m) => m.toEntity()).toList();
    } catch (e) {
      // If remote fails, fallback to local? 
      // For now, let's just return local if remote fails, or rethrow?
      // Since we want to connect backend, let's prioritize remote and maybe return local as backup.
      return await localDataSource.loadOrders();
    }
  }

  @override
  Future<void> addOrder(OrderEntity order) async {
    final orderModel = OrderModel.fromEntity(order);
    // Send to backend
    final createdOrder = await remoteDataSource.createOrder(orderModel);
    // Save to local
    await localDataSource.saveOrder(createdOrder);
  }

  @override
  Future<void> updateOrder(OrderEntity order) async {
    final orderModel = OrderModel.fromEntity(order);
    // Backend update (mocked in datasource for now)
    await remoteDataSource.updateOrder(orderModel);
    await localDataSource.updateOrder(orderModel);
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await remoteDataSource.deleteOrder(orderId);
    await localDataSource.deleteOrder(orderId);
  }
}
