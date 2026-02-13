import 'package:flutter/material.dart';

enum OrderStatus {
  pending,      // En attente de paiement
  paid,         // Payée
  assigned,     // Assignée à un presseur
  processing,   // En cours de traitement
  completed,    // Terminée
  cancelled     // Annulée
}

enum PaymentMethod {
  mobileTransfer,
  creditCard,
  cash
}

class OrderEntity {
  final String id;
  final String serviceTitle;
  final String servicePrice;
  final double amount;
  final DateTime date;
  final TimeOfDay time;
  final bool pickupAtHome;
  final String instructions;
  final IconData serviceIcon;
  final Color serviceColor;
  final OrderStatus status;
  final PaymentMethod? paymentMethod;
  final String? transactionId;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.serviceTitle,
    required this.servicePrice,
    required this.amount,
    required this.date,
    required this.time,
    required this.pickupAtHome,
    required this.instructions,
    required this.serviceIcon,
    required this.serviceColor,
    this.status = OrderStatus.pending,
    this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    this.pickupLatitude,
    this.pickupLongitude,
    this.weight,
    this.items,
  });

  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? weight;
  final List<Map<String, dynamic>>? items;

  OrderEntity copyWith({
    String? id,
    String? serviceTitle,
    String? servicePrice,
    double? amount,
    DateTime? date,
    TimeOfDay? time,
    bool? pickupAtHome,
    String? instructions,
    IconData? serviceIcon,
    Color? serviceColor,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    String? transactionId,
    DateTime? createdAt,
    double? pickupLatitude,
    double? pickupLongitude,
    double? weight,
    List<Map<String, dynamic>>? items,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      servicePrice: servicePrice ?? this.servicePrice,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      pickupAtHome: pickupAtHome ?? this.pickupAtHome,
      instructions: instructions ?? this.instructions,
      serviceIcon: serviceIcon ?? this.serviceIcon,
      serviceColor: serviceColor ?? this.serviceColor,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      weight: weight ?? this.weight,
      items: items ?? this.items,
    );
  }
}
