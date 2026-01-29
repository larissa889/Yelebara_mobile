import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:yelebara_mobile/features/orders/presentation/providers/order_provider.dart';
import 'package:yelebara_mobile/features/orders/presentation/widgets/order_card.dart';
import 'package:yelebara_mobile/features/home/presentation/widgets/client_bottom_nav.dart';

class ClientOrdersPage extends ConsumerStatefulWidget {
  const ClientOrdersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ClientOrdersPage> createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends ConsumerState<ClientOrdersPage> {

  @override
  void initState() {
    super.initState();
    // Riverpod handles loading, but we can trigger a refresh here if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final orders = orderState.orders;
    final isLoading = orderState.isLoading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => context.go('/home'),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Mes Commandes',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${orders.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _navigateToCreateOrder(context),
            icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
            tooltip: 'Nouvelle commande',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        order: order,
                        onTap: () {}, // TODO: Detail view
                        onPay: order.status == OrderStatus.pending
                            ? () {} // TODO: Payment
                            : null,
                        onDelete: () => _deleteOrder(context, ref, order),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: const ClientBottomNav(activeIndex: 2),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune commande',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par créer une nouvelle commande',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateOrder(context),
            icon: const Icon(Icons.add),
            label: const Text('Créer une commande'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateOrder(BuildContext context) {
     context.push(
      '/create-order',
      extra: {
        'serviceTitle': 'Nouvelle commande',
        'servicePrice': '5000 FCFA',
        'serviceIcon': Icons.local_laundry_service,
        'serviceColor': Colors.orange.shade700,
        // No existing order for creation
      },
    ).then((_) {
      // Refresh list after returning
       ref.read(orderProvider.notifier).loadOrders();
    });
  }

  Future<void> _deleteOrder(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la commande'),
        content: Text(
          order.status == OrderStatus.paid
              ? 'Cette commande a déjà été payée. Voulez-vous vraiment la supprimer ?'
              : 'Voulez-vous vraiment supprimer cette commande ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(orderProvider.notifier).deleteOrder(order.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande supprimée')),
        );
      }
    }
  }
}



