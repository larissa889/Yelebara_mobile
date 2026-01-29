import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelebara_mobile/features/auth/presentation/controllers/auth_provider.dart';
import 'package:yelebara_mobile/features/orders/data/datasources/order_local_datasource.dart';
import 'package:yelebara_mobile/features/orders/data/repositories/order_repository_impl.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:yelebara_mobile/features/orders/domain/repositories/order_repository.dart';

// DI Providers
final orderLocalDataSourceProvider = Provider<OrderLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OrderLocalDataSource(prefs);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(orderLocalDataSourceProvider));
});

// State
class OrderState {
  final bool isLoading;
  final List<OrderEntity> orders;
  final String? errorMessage;

  const OrderState({
    this.isLoading = false,
    this.orders = const [],
    this.errorMessage,
  });

  OrderState copyWith({
    bool? isLoading,
    List<OrderEntity>? orders,
    String? errorMessage,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }
}

// Notifier
class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(const OrderState()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final orders = await _repository.getOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur de chargement');
    }
  }

  Future<void> addOrder(OrderEntity order) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.addOrder(order);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur ajout commande');
    }
  }

  Future<void> updateOrder(OrderEntity order) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateOrder(order);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur modification commande');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.deleteOrder(orderId);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erreur suppression');
    }
  }
}

// Provider
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repository);
});
