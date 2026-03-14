import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/cart_model.dart';
import '../../presenters/cart_presenter.dart';
import '../order/checkout_screen.dart';

/// Cart screen with items and checkout
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> implements CartView {
  final _presenter = CartPresenter();

  CartModel? _cart;
  bool _isLoading = true;
  final Map<String, bool> _updatingItems = {};

  @override
  void initState() {
    super.initState();
    _presenter.attach(this);
    _loadCart();
  }

  @override
  void dispose() {
    _presenter.detach();
    super.dispose();
  }

  Future<void> _loadCart() async {
    await _presenter.loadCart();
  }

  void _updateQuantity(CartItemModel item, int newQuantity) async {
    if (newQuantity < 1) {
      _removeItem(item);
      return;
    }

    setState(() => _updatingItems[item.id] = true);
    await _presenter.updateCartItem(item.id, newQuantity);
    setState(() => _updatingItems.remove(item.id));
  }

  void _removeItem(CartItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Item'),
            content: Text(
              'Are you sure you want to remove ${item.productName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _updatingItems[item.id] = true);
      await _presenter.removeFromCart(item.id);
      setState(() => _updatingItems.remove(item.id));
    }
  }

  void _proceedToCheckout() {
    if (_cart == null || _cart!.items.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutScreen(cart: _cart!)),
    );
  }

  // CartView implementation
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void showCart(CartModel cart) {
    setState(() => _cart = cart);
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void showItemAdded(String productName) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$productName added to cart')));
  }

  @override
  void showItemRemoved(String productName) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$productName removed from cart')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (_cart != null && _cart!.items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Clear Cart'),
                        content: const Text(
                          'Are you sure you want to clear all items?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                );
                if (confirmed == true) {
                  await _presenter.clearCart();
                }
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _cart == null || _cart!.items.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadCart,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: _cart!.items.length,
                  itemBuilder: (context, index) {
                    final item = _cart!.items[index];
                    return _CartItemCard(
                      item: item,
                      isUpdating: _updatingItems[item.id] ?? false,
                      onQuantityChanged: (qty) => _updateQuantity(item, qty),
                      onRemove: () => _removeItem(item),
                    );
                  },
                ),
              ),
      bottomNavigationBar:
          _cart != null && _cart!.items.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to your cart',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to products
            },
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${_cart!.totalItems} items)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  Formatters.formatPriceInt(_cart!.totalAmount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToCheckout,
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cart item card widget
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool isUpdating;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.isUpdating,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child:
                  item.productImage != null
                      ? CachedNetworkImage(
                        imageUrl: item.productImage!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                Container(color: AppColors.shimmerBase),
                        errorWidget:
                            (context, url, error) => _buildPlaceholderImage(),
                      )
                      : _buildPlaceholderImage(),
            ),
          ),
          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatPriceInt(item.price),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Quantity controls
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onPressed:
                          isUpdating
                              ? null
                              : () => onQuantityChanged(item.quantity - 1),
                    ),
                    if (isUpdating)
                      const SizedBox(
                        width: 40,
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    _QuantityButton(
                      icon: Icons.add,
                      onPressed:
                          isUpdating
                              ? null
                              : () => onQuantityChanged(item.quantity + 1),
                    ),
                    const Spacer(),
                    Text(
                      Formatters.formatPriceInt(item.subtotal),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onRemove,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed == null ? AppColors.textDisabled : null,
        ),
      ),
    );
  }
}
