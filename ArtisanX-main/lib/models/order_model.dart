enum OrderStatus { readyToShip, processing, delivered, pending }

class OrderModel {
  final int id;
  final String orderCode;
  final int userId;
  final int productId;
  final String productName;
  final String? artisanName;
  final int quantity;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.userId,
    required this.productId,
    required this.productName,
    this.artisanName,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  String get statusDisplay {
    switch (status) {
      case OrderStatus.readyToShip:
        return 'Ready to ship';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.pending:
        return 'Pending';
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    OrderStatus parseStatus(String? st) {
      switch (st?.toLowerCase()) {
        case 'ready_to_ship':
        case 'ready to ship':
          return OrderStatus.readyToShip;
        case 'processing':
          return OrderStatus.processing;
        case 'delivered':
          return OrderStatus.delivered;
        default:
          return OrderStatus.pending;
      }
    }

    return OrderModel(
      id: json['id'] ?? 0,
      orderCode: json['order_code'] ?? '#AX1048',
      userId: json['user_id'] ?? 1,
      productId: json['product_id'] ?? 1,
      productName: json['product_name'] ?? 'Indigo Serving Bowl',
      artisanName: json['artisan_name'] ?? 'Asha Devi',
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 1499.0,
      status: parseStatus(json['status']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_code': orderCode,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'artisan_name': artisanName,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': statusDisplay.toLowerCase().replaceAll(' ', '_'),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
