import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:yelebara_mobile/features/orders/data/services/payment_service.dart';
import 'package:yelebara_mobile/features/orders/presentation/pages/payment_page.dart';
import 'package:yelebara_mobile/features/orders/presentation/extensions/order_status_extension.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderEntity order;
  
  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  // Fonction pour obtenir l'image du service
  Widget _getServiceImage(String serviceTitle) {
    switch (serviceTitle.toLowerCase()) {
      case 'lavage simple':
        return Image.asset(
          'assets/images/lavage_simple.png',
          width: 28,
          height: 28,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.local_laundry_service, color: Colors.white);
          },
        );
      case 'repassage':
        return Image.asset(
          'assets/images/repassage.png',
          width: 28,
          height: 28,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.iron_rounded, color: Colors.white);
          },
        );
      case 'pressing complet':
        return Image.asset(
          'assets/images/pressing_complet.png',
          width: 28,
          height: 28,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.checkroom, color: Colors.white);
          },
        );
      default:
        return Icon(order.serviceIcon, color: order.serviceColor, size: 28);
    }
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.paid:
        return Icons.payment;
      case OrderStatus.processing:
        return Icons.local_laundry_service;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la commande'),
        backgroundColor: order.serviceColor,
        foregroundColor: Colors.white,
        actions: [
          if (order.status == OrderStatus.pending)
            IconButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(order: order),
                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context); // Refresh handled by popping result
                }
              },
              icon: const Icon(Icons.payment),
              tooltip: 'Payer',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildServiceInfo(),
            const SizedBox(height: 16),
            _buildScheduleInfo(),
            const SizedBox(height: 16),
            _buildPaymentInfo(),
             if (order.instructions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInstructions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 3,
      color: order.statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: order.statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(),
                color: order.statusColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.statusLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: order.statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Commande #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: order.serviceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _getServiceImage(order.serviceTitle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.serviceTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.amount.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rendez-vous',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              DateFormat('dd/MM/yyyy').format(order.date),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.access_time,
              'Heure',
              _formatTime(order.time),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              order.pickupAtHome ? Icons.home : Icons.store,
              'Lieu',
              order.pickupAtHome ? 'Ramassage à domicile' : 'Au pressing',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paiement',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            if (order.paymentMethod != null) ...[
              _buildInfoRow(
                PaymentService.getPaymentMethodIcon(order.paymentMethod!),
                'Méthode',
                PaymentService.getPaymentMethodLabel(order.paymentMethod!),
              ),
              if (order.transactionId != null) ...[
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.receipt,
                  'Référence',
                  order.transactionId!,
                ),
              ],
            ] else ...[
              _buildInfoRow(
                Icons.payment,
                'Statut',
                'En attente de paiement',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Instructions particulières',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.instructions),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
