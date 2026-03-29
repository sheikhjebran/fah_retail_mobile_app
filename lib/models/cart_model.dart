import 'package:hive/hive.dart';

part 'cart_model.g.dart';

/// Cart item model for FAH Retail App (Hive-compatible, flat storage)
@HiveType(typeId: 0)
class CartItemModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int productId;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final DateTime? createdAt;

  // Flat fields for offline display (no nested objects)
  @HiveField(4)
  final String? productName;

  @HiveField(5)
  final String? productImage;

  @HiveField(6)
  final double? price;

  @HiveField(7)
  final double? subtotal;

  // Product data for detail view
  @HiveField(8)
  final String? productDescription;

  @HiveField(9)
  final double? productOriginalPrice;

  @HiveField(10)
  final double? productDiscountPrice;

  @HiveField(11)
  final bool? productHasDiscount;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    this.createdAt,
    this.productName,
    this.productImage,
    this.price,
    this.subtotal,
    this.productDescription,
    this.productOriginalPrice,
    this.productDiscountPrice,
    this.productHasDiscount,
  });

  /// Get item total price
  double get totalPrice => subtotal ?? (price != null ? price! * quantity : 0);

  /// Get item original total price (before discount)
  double get originalTotalPrice =>
      productOriginalPrice != null ? productOriginalPrice! * quantity : price != null ? price! * quantity : 0;

  /// Get savings amount
  double get savings {
    if (productHasDiscount != true || productDiscountPrice == null) return 0;
    return (productOriginalPrice ?? price ?? 0 - productDiscountPrice!) * quantity;
  }

  /// Get product name
  String get productNameValue => productName ?? 'Unknown Product';

  /// Get product image
  String? get productImageUrl => productImage;

  /// Get unit price
  double get unitPrice => productDiscountPrice ?? price ?? 0;

  /// Check if product has discount
  bool get hasDiscount => productHasDiscount ?? false;

  /// Get display price (discounted or regular)
  double get displayPrice => productDiscountPrice ?? price ?? 0;

  /// Create CartItemModel from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return CartItemModel(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      quantity: parseInt(json['quantity'], 1),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      productName: json['product_name']?.toString(),
      productImage: json['product_image']?.toString(),
      price: parseDouble(json['price']),
      subtotal: parseDouble(json['subtotal']),
      productDescription: json['product_description']?.toString(),
      productOriginalPrice: parseDouble(json['product_original_price']),
      productDiscountPrice: parseDouble(json['product_discount_price']),
      productHasDiscount: json['product_has_discount'] as bool?,
    );
  }

  /// Convert CartItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'created_at': createdAt?.toIso8601String(),
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'subtotal': subtotal,
      'product_description': productDescription,
      'product_original_price': productOriginalPrice,
      'product_discount_price': productDiscountPrice,
      'product_has_discount': productHasDiscount,
    };
  }

  /// Create a copy with updated values
  CartItemModel copyWith({
    int? id,
    int? productId,
    int? quantity,
    DateTime? createdAt,
    String? productName,
    String? productImage,
    double? price,
    double? subtotal,
    String? productDescription,
    double? productOriginalPrice,
    double? productDiscountPrice,
    bool? productHasDiscount,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      productDescription: productDescription ?? this.productDescription,
      productOriginalPrice: productOriginalPrice ?? this.productOriginalPrice,
      productDiscountPrice: productDiscountPrice ?? this.productDiscountPrice,
      productHasDiscount: productHasDiscount ?? this.productHasDiscount,
    );
  }

  /// Get props for equality (used by Hive)
  List<Object?> get props => [
        id,
        productId,
        quantity,
        createdAt,
        productName,
        productImage,
        price,
        subtotal,
        productDescription,
        productOriginalPrice,
        productDiscountPrice,
        productHasDiscount,
      ];
}

/// Cart model representing the entire cart (Hive-compatible)
@HiveType(typeId: 1)
class CartModel extends HiveObject {
  @HiveField(0)
  final List<CartItemModel> items;

  @HiveField(1)
  final DateTime? lastUpdated;

  CartModel({this.items = const [], this.lastUpdated});

  /// Get total number of items in cart
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get number of unique items in cart
  int get uniqueItemCount => items.length;

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Get total items count (convenience getter)
  int get totalItems => itemCount;

  /// Get total amount (convenience getter)
  double get totalAmount => subtotal;

  /// Get cart subtotal
  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Get original price total
  double get originalTotal =>
      items.fold(0, (sum, item) => sum + item.originalTotalPrice);

  /// Get total savings
  double get totalSavings => items.fold(0, (sum, item) => sum + item.savings);

  /// Check if product is in cart
  bool containsProduct(int productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Get cart item by product ID
  CartItemModel? getItemByProductId(int productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Create CartModel from JSON
  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'];
    List<CartItemModel> items = [];

    if (itemsList != null && itemsList is List) {
      items = itemsList
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return CartModel(
      items: items,
      lastUpdated: DateTime.now(),
    );
  }

  /// Convert CartModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  CartModel copyWith({List<CartItemModel>? items, DateTime? lastUpdated}) {
    return CartModel(
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get props for equality
  List<Object?> get props => [items, lastUpdated];
}

/// Add to cart request model
class AddToCartRequest {
  final int productId;
  final int quantity;

  const AddToCartRequest({required this.productId, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity};
  }
}

/// Update cart request model
class UpdateCartRequest {
  final int cartItemId;
  final int quantity;

  const UpdateCartRequest({required this.cartItemId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'cart_item_id': cartItemId, 'quantity': quantity};
  }
}
