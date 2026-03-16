import 'package:equatable/equatable.dart';
import 'product_model.dart';

/// Cart item model for FAH Retail App
class CartItemModel extends Equatable {
  final int id;
  final int productId;
  final ProductModel? product;
  final int quantity;
  final DateTime? createdAt;

  // Flat fields from backend response
  final String? _productName;
  final String? _productImage;
  final double? _price;
  final double? _subtotal;

  const CartItemModel({
    required this.id,
    required this.productId,
    this.product,
    required this.quantity,
    this.createdAt,
    String? productName,
    String? productImage,
    double? price,
    double? subtotal,
  }) : _productName = productName,
       _productImage = productImage,
       _price = price,
       _subtotal = subtotal;

  /// Get item total price
  double get totalPrice {
    if (_subtotal != null) return _subtotal;
    if (product == null) return _price != null ? _price * quantity : 0;
    return product!.displayPrice * quantity;
  }

  /// Get item original total price (before discount)
  double get originalTotalPrice {
    if (product == null) return _price != null ? _price * quantity : 0;
    return product!.price * quantity;
  }

  /// Get savings amount
  double get savings {
    if (product == null || !product!.hasDiscount) return 0;
    return (product!.price - product!.discountPrice!) * quantity;
  }

  /// Get product name (convenience getter)
  String get productName => product?.name ?? _productName ?? 'Unknown Product';

  /// Get product image (convenience getter)
  String? get productImage => product?.displayImage ?? _productImage;

  /// Get unit price (convenience getter)
  double get price => product?.displayPrice ?? _price ?? 0;

  /// Get subtotal (convenience getter)
  double get subtotal => totalPrice;

  /// Create CartItemModel from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse int from int or String
    int parseInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Helper to parse double from num or String
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return CartItemModel(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      product:
          json['product'] != null
              ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
              : null,
      quantity: parseInt(json['quantity'], 1),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      // Flat fields from backend
      productName: json['product_name']?.toString(),
      productImage: json['product_image']?.toString(),
      price: parseDouble(json['price']),
      subtotal: parseDouble(json['subtotal']),
    );
  }

  /// Convert CartItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product': product?.toJson(),
      'quantity': quantity,
      'created_at': createdAt?.toIso8601String(),
      'product_name': _productName,
      'product_image': _productImage,
      'price': _price,
      'subtotal': _subtotal,
    };
  }

  /// Create a copy with updated values
  CartItemModel copyWith({
    int? id,
    int? productId,
    ProductModel? product,
    int? quantity,
    DateTime? createdAt,
    String? productName,
    String? productImage,
    double? price,
    double? subtotal,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      productName: productName ?? _productName,
      productImage: productImage ?? _productImage,
      price: price ?? _price,
      subtotal: subtotal ?? _subtotal,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    product,
    quantity,
    createdAt,
    _productName,
    _productImage,
    _price,
    _subtotal,
  ];
}

/// Cart model representing the entire cart
class CartModel extends Equatable {
  final List<CartItemModel> items;

  const CartModel({this.items = const []});

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
      items =
          itemsList
              .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    return CartModel(items: items);
  }

  /// Convert CartModel to JSON
  Map<String, dynamic> toJson() {
    return {'items': items.map((e) => e.toJson()).toList()};
  }

  /// Create a copy with updated values
  CartModel copyWith({List<CartItemModel>? items}) {
    return CartModel(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
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
