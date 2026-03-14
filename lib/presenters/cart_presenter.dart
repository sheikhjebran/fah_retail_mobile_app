import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../core/constants/app_constants.dart';

/// View contract for cart screen
abstract class CartView {
  void showLoading();
  void hideLoading();
  void showCart(CartModel cart);
  void showItemAdded(CartItemModel item);
  void showItemUpdated(CartItemModel item);
  void showItemRemoved(int cartItemId);
  void showCartCleared();
  void showError(String message);
  void showEmptyCart();
  void updateCartBadge(int count);
}

/// Cart presenter for managing cart operations
class CartPresenter {
  final CartService _cartService;
  CartView? _view;

  CartModel _cart = const CartModel();
  bool _isLoading = false;

  CartPresenter({CartService? cartService})
    : _cartService = cartService ?? CartService();

  /// Attach view
  void attachView(CartView view) {
    _view = view;
  }

  /// Detach view
  void detach() {
    _view = null;
  }

  /// Get current cart
  CartModel get cart => _cart;

  /// Get cart item count
  int get itemCount => _cart.itemCount;

  /// Get cart subtotal
  double get subtotal => _cart.subtotal;

  /// Get total savings
  double get savings => _cart.totalSavings;

  /// Check if cart is empty
  bool get isEmpty => _cart.isEmpty;

  /// Load cart
  Future<void> loadCart() async {
    if (_isLoading) return;
    _isLoading = true;

    _view?.showLoading();

    try {
      _cart = await _cartService.getCart();
      _view?.hideLoading();

      if (_cart.isEmpty) {
        _view?.showEmptyCart();
      } else {
        _view?.showCart(_cart);
      }

      _view?.updateCartBadge(_cart.itemCount);
    } catch (e) {
      _view?.hideLoading();
      _view?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Add product to cart
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      // Check if product is in stock
      if (!product.inStock) {
        _view?.showError('Product is out of stock');
        return;
      }

      // Check if already in cart
      final existingItem = _cart.getItemByProductId(product.id);
      if (existingItem != null) {
        // Update quantity instead
        await updateQuantity(existingItem.id, existingItem.quantity + quantity);
        return;
      }

      final request = AddToCartRequest(
        productId: product.id,
        quantity: quantity,
      );

      final item = await _cartService.addToCart(request);

      // Update local cart
      final updatedItems = List<CartItemModel>.from(_cart.items)..add(item);
      _cart = _cart.copyWith(items: updatedItems);

      _view?.showItemAdded(item);
      _view?.showCart(_cart);
      _view?.updateCartBadge(_cart.itemCount);
    } catch (e) {
      _view?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Update cart item quantity
  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (_isLoading) return;

    // Validate quantity
    if (quantity < AppConstants.minQuantityPerItem) {
      await removeFromCart(cartItemId);
      return;
    }

    if (quantity > AppConstants.maxQuantityPerItem) {
      _view?.showError(
        'Maximum ${AppConstants.maxQuantityPerItem} items allowed',
      );
      return;
    }

    _isLoading = true;

    try {
      final request = UpdateCartRequest(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      final item = await _cartService.updateCartItem(request);

      // Update local cart
      final updatedItems =
          _cart.items.map((i) {
            return i.id == cartItemId ? item : i;
          }).toList();
      _cart = _cart.copyWith(items: updatedItems);

      _view?.showItemUpdated(item);
      _view?.showCart(_cart);
      _view?.updateCartBadge(_cart.itemCount);
    } catch (e) {
      _view?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Increment item quantity
  Future<void> incrementQuantity(int cartItemId) async {
    final item = _cart.items.firstWhere(
      (i) => i.id == cartItemId,
      orElse: () => throw Exception('Item not found'),
    );
    await updateQuantity(cartItemId, item.quantity + 1);
  }

  /// Decrement item quantity
  Future<void> decrementQuantity(int cartItemId) async {
    final item = _cart.items.firstWhere(
      (i) => i.id == cartItemId,
      orElse: () => throw Exception('Item not found'),
    );
    await updateQuantity(cartItemId, item.quantity - 1);
  }

  /// Remove item from cart
  Future<void> removeFromCart(int cartItemId) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      await _cartService.removeFromCart(cartItemId);

      // Update local cart
      final updatedItems =
          _cart.items.where((i) => i.id != cartItemId).toList();
      _cart = _cart.copyWith(items: updatedItems);

      _view?.showItemRemoved(cartItemId);

      if (_cart.isEmpty) {
        _view?.showEmptyCart();
      } else {
        _view?.showCart(_cart);
      }

      _view?.updateCartBadge(_cart.itemCount);
    } catch (e) {
      _view?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      await _cartService.clearCart();

      _cart = const CartModel();

      _view?.showCartCleared();
      _view?.showEmptyCart();
      _view?.updateCartBadge(0);
    } catch (e) {
      _view?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Check if product is in cart
  bool isInCart(int productId) {
    return _cart.containsProduct(productId);
  }

  /// Get quantity of product in cart
  int getQuantityInCart(int productId) {
    final item = _cart.getItemByProductId(productId);
    return item?.quantity ?? 0;
  }
}
