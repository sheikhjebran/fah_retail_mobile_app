import 'package:equatable/equatable.dart';
import 'product_model.dart';

/// Cart item model for FAH Retail App
class CartItemModel extends Equatable {
  final int id;
  final int productId;
  final ProductModel? product;
  final int quantity;
  final DateTime? createdAt;

  const CartItemModel({
    required this.id,
    required this.productId,
    this.product,
    required this.quantity,
    this.createdAt,
  });

  /// Get item total price
  double get totalPrice {
    if (product == null) return 0;
    return product!.displayPrice * quantity;
  }

  /// Get item original total price (before discount)
  double get originalTotalPrice {
    if (product == null) return 0;
    return product!.price * quantity;
  }

  /// Get savings amount
  double get savings {
    if (product == null || !product!.hasDiscount) return 0;
    return (product!.price - product!.discountPrice!) * quantity;
  }

  /// Create CartItemModel from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      product:
          json['product'] != null
              ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
              : null,
      quantity: json['quantity'] as int,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
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
    };
  }

  /// Create a copy with updated values
  CartItemModel copyWith({
    int? id,
    int? productId,
    ProductModel? product,
    int? quantity,
    DateTime? createdAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, productId, product, quantity, createdAt];
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
    return CartModel(
      items:
          (json['items'] as List)
              .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
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
