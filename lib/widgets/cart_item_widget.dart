import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: cartItem.product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        cartItem.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.inventory_2,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.inventory_2,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
            ),

            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    cartItem.product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Price per unit
                  Text(
                    'Rp ${cartItem.product.price.toStringAsFixed(0)} each',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Row(
              children: [
                IconButton(
                  onPressed: cartItem.quantity > 1
                      ? () => onQuantityChanged?.call(cartItem.quantity - 1)
                      : null,
                  icon: Icon(
                    Icons.remove,
                    size: 20,
                    color: cartItem.quantity > 1
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${cartItem.quantity}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: (cartItem.quantity < cartItem.product.stock)
                      ? () => onQuantityChanged?.call(cartItem.quantity + 1)
                      : null,
                  icon: Icon(
                    Icons.add,
                    size: 20,
                    color: (cartItem.quantity < cartItem.product.stock)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Subtotal and Remove
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Subtotal
                Text(
                  'Rp ${cartItem.subtotal.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Remove button
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: 'Remove from cart',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}