import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/features/orders/data/models/order_model.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';

class OrderLocalDataSource {
  final SharedPreferences sharedPreferences;

  OrderLocalDataSource(this.sharedPreferences);

  Future<String?> _getEmail() async {
    return sharedPreferences.getString('current_user_email');
  }

  Future<List<OrderModel>> loadOrders() async {
    final emailKey = await _getEmail();
    if (emailKey == null) return [];

    final ordersJson = sharedPreferences.getString('orders:$emailKey');
    if (ordersJson == null) return [];

    final List<dynamic> decoded = json.decode(ordersJson);
    return decoded.map((json) => OrderModel.fromMap(json)).toList();
  }

  Future<void> saveOrder(OrderModel order) async {
    final emailKey = await _getEmail();
    if (emailKey == null) return; // Should handle error or require auth

    final List<OrderModel> orders = await loadOrders();
    orders.insert(0, order); // Add new order at top

    await _persistOrders(emailKey, orders);
  }

  Future<void> updateOrder(OrderModel order) async {
    final emailKey = await _getEmail();
    if (emailKey == null) return;

    final List<OrderModel> orders = await loadOrders();
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      orders[index] = order;
      await _persistOrders(emailKey, orders);
    }
  }

  Future<void> deleteOrder(String orderId) async {
    final emailKey = await _getEmail();
    if (emailKey == null) return;

    final List<OrderModel> orders = await loadOrders();
    orders.removeWhere((o) => o.id == orderId);
    await _persistOrders(emailKey, orders);
  }

  Future<void> _persistOrders(String emailKey, List<OrderModel> orders) async {
    final encoded = json.encode(orders.map((o) => o.toMap()).toList());
    await sharedPreferences.setString('orders:$emailKey', encoded);
  }
}
