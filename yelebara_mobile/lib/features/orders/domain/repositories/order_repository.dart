import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders();
  Future<void> addOrder(OrderEntity order);
  Future<void> updateOrder(OrderEntity order);
  Future<void> deleteOrder(String orderId);
}
