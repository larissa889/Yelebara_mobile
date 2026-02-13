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
    double? pickupLatitude,
    double? pickupLongitude,
    double? weight,
    List<Map<String, dynamic>>? items,
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
          pickupLatitude: pickupLatitude,
          pickupLongitude: pickupLongitude,
          items: items,
          weight: weight,
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
      pickupLatitude: entity.pickupLatitude,
      pickupLongitude: entity.pickupLongitude,
      weight: entity.weight,
      items: entity.items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service_title': serviceTitle,
      'service_price': servicePrice,
      'amount': amount,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'pickup_at_home': pickupAtHome,
      'instructions': instructions,
      'service_icon_code': serviceIcon.codePoint,
      'service_color_code': serviceColor.value,
      'status': status.index,
      'paymentMethod': paymentMethod?.index,
      'transactionId': transactionId,
      'created_at': createdAt.toIso8601String(),
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'weight': weight,
      'items': items,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'].toString(),
      serviceTitle: map['service_title'] ?? map['serviceTitle'] ?? '',
      servicePrice: map['service_price'] ?? map['servicePrice'] ?? '',
      amount: map['amount'] != null
          ? double.tryParse(map['amount'].toString()) ?? 0.0
          : 0.0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      time: map['time'] != null && map['time'].toString().contains(':')
          ? TimeOfDay(
              hour: int.parse(map['time'].toString().split(':')[0]),
              minute: int.parse(map['time'].toString().split(':')[1]),
            )
          : const TimeOfDay(hour: 0, minute: 0),
      pickupAtHome: map['pickup_at_home'] == 1 || map['pickup_at_home'] == true,
      instructions: map['instructions'] ?? '',
      serviceIcon: IconData(
          map['service_icon_code'] ?? map['serviceIcon'] ?? 58264,
          fontFamily: 'MaterialIcons'),
      serviceColor: Color(
          map['service_color_code'] ?? map['serviceColor'] ?? 0xFF000000),
      status: OrderStatus.values[(map['status'] ?? 0) as int],
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.values[(map['paymentMethod']) as int]
          : null,
      transactionId: map['transactionId'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      pickupLatitude: map['pickup_latitude'] != null
          ? double.tryParse(map['pickup_latitude'].toString())
          : null,
      pickupLongitude: map['pickup_longitude'] != null
          ? double.tryParse(map['pickup_longitude'].toString())
          : null,
      weight: map['weight'] != null
          ? double.tryParse(map['weight'].toString())
          : null,
      items: map['items'] != null
          ? List<Map<String, dynamic>>.from(
              (map['items'] as List).map((e) => Map<String, dynamic>.from(e)))
          : null,
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
    double? pickupLatitude,
    double? pickupLongitude,
    double? weight,
    List<Map<String, dynamic>>? items,
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
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      weight: weight ?? this.weight,
      items: items ?? this.items,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  OrderEntity toEntity() {
    return OrderEntity(
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
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      weight: weight,
      items: items,
    );
  }
}
