import 'package:flutter/material.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';

extension OrderStatusExtension on OrderEntity {
  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente de paiement';
      case OrderStatus.paid:
        return 'Payée';
      case OrderStatus.processing:
        return 'En cours';
      case OrderStatus.completed:
        return 'Terminée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paid:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
