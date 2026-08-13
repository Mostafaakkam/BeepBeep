import 'order_item_model.dart';

class Order {
  final int id;
  final int userId;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      deliveryAddress: json['delivery_address'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total': total,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
  
  String get formattedStatus {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
  
  String get formattedPaymentMethod {
    switch (paymentMethod) {
      case 'cash_on_delivery':
        return 'Cash on Delivery';
      default:
        return paymentMethod;
    }
  }
  
  String get formattedPaymentStatus {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus;
    }
  }
  
  bool get isCancellable => status == 'pending';
}
