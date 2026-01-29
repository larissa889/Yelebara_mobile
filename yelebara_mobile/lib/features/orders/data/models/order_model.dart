import 'package:flutter/material.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required String id,
    required String serviceTitle,
    required String servicePrice,
    required double amount,
    required DateTime date,
    required TimeOfDay time,
    required bool pickupAtHome,
    required String instructions,
    required IconData serviceIcon,
    required Color serviceColor,
    OrderStatus status = OrderStatus.pending,
    PaymentMethod? paymentMethod,
    String? transactionId,
    required DateTime createdAt,
  }) : super(
          id: id,
          serviceTitle: serviceTitle,
          servicePrice: servicePrice,
          amount: amount,
          date: date,
          time: time,
          pickupAtHome: pickupAtHome,
          instructions: instructions,
          serviceIcon: serviceIcon,
          serviceColor: serviceColor,
          status: status,
          paymentMethod: paymentMethod,
          transactionId: transactionId,
          createdAt: createdAt,
        );

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      serviceTitle: entity.serviceTitle,
      servicePrice: entity.servicePrice,
      amount: entity.amount,
      date: entity.date,
      time: entity.time,
      pickupAtHome: entity.pickupAtHome,
      instructions: entity.instructions,
      serviceIcon: entity.serviceIcon,
      serviceColor: entity.serviceColor,
      status: entity.status,
      paymentMethod: entity.paymentMethod,
      transactionId: entity.transactionId,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceTitle': serviceTitle,
      'servicePrice': servicePrice,
      'amount': amount,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'pickupAtHome': pickupAtHome,
      'instructions': instructions,
      'serviceIcon': serviceIcon.codePoint,
      'serviceColor': serviceColor.value,
      'status': status.index,
      'paymentMethod': paymentMethod?.index,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      serviceTitle: map['serviceTitle'],
      servicePrice: map['servicePrice'],
      amount: map['amount'] != null
          ? double.tryParse(map['amount'].toString()) ?? 0.0
          : 0.0,
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(map['time'].toString().split(':')[0]),
        minute: int.parse(map['time'].toString().split(':')[1]),
      ),
      pickupAtHome: map['pickupAtHome'] ?? false,
      instructions: map['instructions'] ?? '',
      serviceIcon: IconData(map['serviceIcon'], fontFamily: 'MaterialIcons'),
      serviceColor: Color(map['serviceColor']),
      status: OrderStatus.values[(map['status'] ?? 0) as int],
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.values[(map['paymentMethod']) as int]
          : null,
      transactionId: map['transactionId'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
  
  @override
  OrderModel copyWith({
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
  }) {
    return OrderModel(
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
    );
  }
}
