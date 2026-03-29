import 'package:hive/hive.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../models/cart_model.dart';

/// Cart service for FAH Retail App with Hive caching
class CartService {
  final ApiClient _apiClient;
  static const String _cartBoxName = 'cart';

  CartService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  /// Get the cart box
  Box<CartModel> get _cartBox => Hive.box<CartModel>(_cartBoxName);

  /// Get user's cart (with Hive caching for offline support)
  Future<CartModel> getCart({bool forceRefresh = false}) async {
    // Return cached cart if available and not forcing refresh
    if (!forceRefresh && _cartBox.isNotEmpty) {
      final cached = _cartBox.get('current');
      if (cached != null) {
        return cached;
      }
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.cart);

      if (response.statusCode == 200) {
        final cart = CartModel.fromJson(response.data);
        await _cacheCart(cart);
        return cart;
      }

      throw ApiException('Failed to load cart');
    } catch (e) {
      if (e is ApiException) rethrow;
      // Return cached cart on network error
      final cached = _cartBox.get('current');
      if (cached != null) return cached;
      throw ApiException('Failed to load cart: $e');
    }
  }

  /// Cache cart locally
  Future<void> _cacheCart(CartModel cart) async {
    await _cartBox.put('current', cart);
  }

  /// Clear cached cart
  Future<void> clearCache() async {
    await _cartBox.delete('current');
  }

  /// Add item to cart
  /// Returns the full cart after adding the item
  Future<CartModel> addToCart(AddToCartRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.addToCart,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend returns full cart response
        final cart = CartModel.fromJson(response.data);
        await _cacheCart(cart);
        return cart;
      }

      throw ApiException(response.data['message'] ?? 'Failed to add to cart');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to add to cart: $e');
    }
  }

  /// Update cart item quantity
  Future<CartModel> updateCartItem(UpdateCartRequest request) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.cart}/${request.cartItemId}',
        data: {'quantity': request.quantity},
      );

      if (response.statusCode == 200) {
        final cart = CartModel.fromJson(response.data);
        await _cacheCart(cart);
        return cart;
      }

      throw ApiException(response.data['message'] ?? 'Failed to update cart');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update cart: $e');
    }
  }

  /// Remove item from cart
  Future<CartModel> removeFromCart(int cartItemId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.removeFromCart(cartItemId),
      );

      if (response.statusCode == 200) {
        final cart = CartModel.fromJson(response.data);
        await _cacheCart(cart);
        return cart;
      }

      throw ApiException(
        response.data['message'] ?? 'Failed to remove from cart',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to remove from cart: $e');
    }
  }

  /// Clear entire cart
  Future<CartModel> clearCart() async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.clearCart);

      if (response.statusCode == 200) {
        final cart = CartModel.fromJson(response.data);
        await _cacheCart(cart);
        return cart;
      }

      throw ApiException(response.data['message'] ?? 'Failed to clear cart');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to clear cart: $e');
    }
  }

  /// Increment cart item quantity
  Future<CartItemModel> incrementQuantity(int cartItemId) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.cart}/$cartItemId/increment',
      );

      if (response.statusCode == 200) {
        return CartItemModel.fromJson(response.data);
      }

      throw ApiException(
        response.data['message'] ?? 'Failed to update quantity',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update quantity: $e');
    }
  }

  /// Decrement cart item quantity
  Future<CartItemModel?> decrementQuantity(int cartItemId) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.cart}/$cartItemId/decrement',
      );

      if (response.statusCode == 200) {
        return CartItemModel.fromJson(response.data);
      }

      // If quantity becomes 0, item is removed
      if (response.statusCode == 204) {
        return null;
      }

      throw ApiException(
        response.data['message'] ?? 'Failed to update quantity',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update quantity: $e');
    }
  }
}
