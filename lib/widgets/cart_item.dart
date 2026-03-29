import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/cart_model.dart';
import 'quantity_selector.dart';

/// Cart item widget for cart screen
class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove;
  final bool isLoading;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onQuantityChanged,
    this.onRemove,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            child: CachedNetworkImage(
              imageUrl: item.productImageUrl ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 80,
                height: 80,
                color: AppColors.surface,
                child: const Icon(Icons.image, color: AppColors.textSecondary),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: AppColors.surface,
                child: const Icon(Icons.image, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productNameValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Price
                Row(
                  children: [
                    Text(
                      Formatters.formatPriceInt(item.displayPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    if (item.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        Formatters.formatPriceInt(
                          item.productOriginalPrice ?? item.price ?? 0,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Discount badge
                if (item.hasDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Save ${Formatters.formatPriceInt((item.productOriginalPrice ?? item.price ?? 0) - item.displayPrice)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Quantity selector and remove button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuantitySelector(
                      quantity: item.quantity,
                      onChanged: onQuantityChanged ?? (_) {},
                      isLoading: isLoading,
                    ),
                    if (onRemove != null)
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
