import 'package:dio/dio.dart';
import 'package:yelebara_mobile/features/orders/data/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrder(OrderModel order);
  Future<void> deleteOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await dio.get('/orders');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> ordersJson = data['orders'];
          return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Erreur de récupération des commandes: ${e.message}');
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await dio.post(
        '/orders',
        data: order.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return OrderModel.fromJson(data['order']);
        }
      }
      throw Exception('Erreur lors de la création de la commande');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
  
  // Note: Backend implementation for update/delete is missing in this phase 
  // but we keep the interface for future use or basic mocking.
  @override
  Future<OrderModel> updateOrder(OrderModel order) async {
    try {
      final response = await dio.put(
        '/orders/${order.id}',
        data: {
          'status': order.status.name, // Sending status string
          if (order.weight != null) 'weight': order.weight,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return OrderModel.fromJson(data['order']);
        }
      }
      throw Exception('Erreur lors de la mise à jour de la commande');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    // Placeholder - Logic to be implemented on backend
  }
}
