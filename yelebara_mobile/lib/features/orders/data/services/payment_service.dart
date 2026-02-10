import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';

class PaymentService {
  /// Simule un paiement en ligne
  static Future<PaymentResult> processPayment({
    required OrderEntity order,
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(seconds: 2));

    // Simulation de succès (90% de chance)
    final success = Random().nextDouble() > 0.1;

    if (success) {
      final transactionId = _generateTransactionId();
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        message: 'Paiement effectué avec succès',
      );
    } else {
      return PaymentResult(
        success: false,
        message: 'Échec du paiement. Veuillez réessayer.',
      );
    }
  }

  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'TXN${timestamp}_$random';
  }

  static String getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.moovMoney:
        return 'Moov Money';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  static IconData getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return Icons.phone_android;
      case PaymentMethod.moovMoney:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.money;
    }
  }
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String message;

  PaymentResult({
    required this.success,
    this.transactionId,
    required this.message,
  });
}
