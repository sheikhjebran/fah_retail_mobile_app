import 'package:equatable/equatable.dart';
import 'address_model.dart';
import 'product_model.dart';

/// Parse datetime from API (treats as UTC since backend uses utcnow)
DateTime? _parseDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    final parsed = DateTime.parse(dateString);
    // If no timezone info, treat as UTC (backend uses datetime.utcnow())
    if (!dateString.contains('Z') && !dateString.contains('+')) {
      return DateTime.utc(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
        parsed.microsecond,
      );
    }
    return parsed;
  } catch (e) {
    return null;
  }
}

/// Order model for FAH Retail App
class OrderModel extends Equatable {
  final int id;
  final int userId;
  final String orderNumber;
  final double totalAmount;
  final double discountAmount;
  final double deliveryFeeAmount;
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
    this.discountAmount = 0,
    this.deliveryFeeAmount = 0,
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

  /// Get address (convenience getter for deliveryAddress)
  AddressModel? get address => deliveryAddress;

  /// Get subtotal (calculated from items or total - delivery + discount)
  double get subtotal {
    if (items != null && items!.isNotEmpty) {
      return items!.fold(0.0, (sum, item) => sum + item.total);
    }
    // Fallback: calculate from total
    return totalAmount - deliveryFeeAmount + discountAmount;
  }

  /// Get delivery fee
  double get deliveryFee => deliveryFeeAmount;

  /// Get discount amount
  double get discount => discountAmount;

  /// Get estimated delivery date
  DateTime? get estimatedDelivery {
    if (createdAt == null) return null;
    return createdAt!.add(const Duration(days: 5));
  }

  /// Create OrderModel from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      orderNumber: json['order_number'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      discountAmount:
          json['discount_amount'] != null
              ? (json['discount_amount'] as num).toDouble()
              : 0,
      deliveryFeeAmount:
          json['delivery_fee'] != null
              ? (json['delivery_fee'] as num).toDouble()
              : 0,
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
      createdAt: _parseDateTime(json['created_at'] as String?),
    );
  }

  /// Convert OrderModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'delivery_fee': deliveryFeeAmount,
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
    double? discountAmount,
    double? deliveryFeeAmount,
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
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryFeeAmount: deliveryFeeAmount ?? this.deliveryFeeAmount,
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
    discountAmount,
    deliveryFeeAmount,
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

  /// Get subtotal (alias for total)
  double get subtotal => total;

  /// Get quantity (alias for qty)
  int get quantity => qty;

  /// Get product name (convenience getter)
  String get productName => product?.name ?? 'Unknown Product';

  /// Get product image (convenience getter)
  String? get productImage => product?.primaryImage;

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
      timestamp: _parseDateTime(json['timestamp'] as String?) ?? DateTime.now(),
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
