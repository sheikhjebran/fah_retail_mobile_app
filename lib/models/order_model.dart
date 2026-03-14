import 'package:equatable/equatable.dart';
import 'address_model.dart';
import 'product_model.dart';

/// Order model for FAH Retail App
class OrderModel extends Equatable {
  final int id;
  final int userId;
  final String orderNumber;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final AddressModel? deliveryAddress;
  final List<OrderItemModel>? items;
  final List<OrderStatusHistoryModel>? statusHistory;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.deliveryAddress,
    this.items,
    this.statusHistory,
    this.createdAt,
  });

  /// Get formatted order number
  String get formattedOrderNumber => '#$orderNumber';

  /// Check if order is paid
  bool get isPaid => paymentStatus == 'paid';

  /// Check if order can be cancelled
  bool get canCancel => status == 'pending' || status == 'order_placed';

  /// Check if order is delivered
  bool get isDelivered => status == 'delivered';

  /// Check if order is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Get item count
  int get itemCount {
    if (items == null) return 0;
    return items!.fold(0, (sum, item) => sum + item.qty);
  }

  /// Create OrderModel from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      orderNumber: json['order_number'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      status: json['status'] as String,
      deliveryAddress:
          json['delivery_address'] != null
              ? AddressModel.fromJson(
                json['delivery_address'] as Map<String, dynamic>,
              )
              : null,
      items:
          json['items'] != null
              ? (json['items'] as List)
                  .map(
                    (e) => OrderItemModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      statusHistory:
          json['status_history'] != null
              ? (json['status_history'] as List)
                  .map(
                    (e) => OrderStatusHistoryModel.fromJson(
                      e as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  /// Convert OrderModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'status': status,
      'delivery_address': deliveryAddress?.toJson(),
      'items': items?.map((e) => e.toJson()).toList(),
      'status_history': statusHistory?.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  OrderModel copyWith({
    int? id,
    int? userId,
    String? orderNumber,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? status,
    AddressModel? deliveryAddress,
    List<OrderItemModel>? items,
    List<OrderStatusHistoryModel>? statusHistory,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    orderNumber,
    totalAmount,
    paymentMethod,
    paymentStatus,
    status,
    deliveryAddress,
    items,
    statusHistory,
    createdAt,
  ];
}

/// Order item model
class OrderItemModel extends Equatable {
  final int id;
  final int orderId;
  final int productId;
  final ProductModel? product;
  final int qty;
  final double price;
  final double? discountPrice;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    this.product,
    required this.qty,
    required this.price,
    this.discountPrice,
  });

  /// Get item total
  double get total {
    final unitPrice = discountPrice ?? price;
    return unitPrice * qty;
  }

  /// Get savings
  double get savings {
    if (discountPrice == null) return 0;
    return (price - discountPrice!) * qty;
  }

  /// Create OrderItemModel from JSON
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      product:
          json['product'] != null
              ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
              : null,
      qty: json['qty'] as int,
      price: (json['price'] as num).toDouble(),
      discountPrice:
          json['discount_price'] != null
              ? (json['discount_price'] as num).toDouble()
              : null,
    );
  }

  /// Convert OrderItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product': product?.toJson(),
      'qty': qty,
      'price': price,
      'discount_price': discountPrice,
    };
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    productId,
    product,
    qty,
    price,
    discountPrice,
  ];
}

/// Order status history model
class OrderStatusHistoryModel extends Equatable {
  final int id;
  final int orderId;
  final String status;
  final String? note;
  final DateTime timestamp;

  const OrderStatusHistoryModel({
    required this.id,
    required this.orderId,
    required this.status,
    this.note,
    required this.timestamp,
  });

  /// Get status label
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Order Pending';
      case 'order_placed':
        return 'Order Accepted';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Create OrderStatusHistoryModel from JSON
  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      status: json['status'] as String,
      note: json['note'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert OrderStatusHistoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'status': status,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, orderId, status, note, timestamp];
}

/// Place order request model
class PlaceOrderRequest {
  final int addressId;
  final String paymentMethod;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  const PlaceOrderRequest({
    required this.addressId,
    required this.paymentMethod,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'address_id': addressId,
      'payment_method': paymentMethod,
      if (razorpayOrderId != null) 'razorpay_order_id': razorpayOrderId,
      if (razorpayPaymentId != null) 'razorpay_payment_id': razorpayPaymentId,
      if (razorpaySignature != null) 'razorpay_signature': razorpaySignature,
    };
  }
}

/// Update order status request
class UpdateOrderStatusRequest {
  final String status;
  final String? note;

  const UpdateOrderStatusRequest({required this.status, this.note});

  Map<String, dynamic> toJson() {
    return {'status': status, if (note != null) 'note': note};
  }
}
