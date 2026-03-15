import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../models/cart_model.dart';

/// Cart service for FAH Retail App
class CartService {
  final ApiClient _apiClient;

  CartService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  /// Get user's cart
  Future<CartModel> getCart() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cart);

      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data);
      }

      throw ApiException('Failed to load cart');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load cart: $e');
    }
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
        return CartModel.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Failed to add to cart');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to add to cart: $e');
    }
  }

  /// Update cart item quantity
  Future<CartItemModel> updateCartItem(UpdateCartRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateCart,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return CartItemModel.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Failed to update cart');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update cart: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(int cartItemId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.removeFromCart(cartItemId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          response.data['message'] ?? 'Failed to remove from cart',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to remove from cart: $e');
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.clearCart);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(response.data['message'] ?? 'Failed to clear cart');
      }
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
