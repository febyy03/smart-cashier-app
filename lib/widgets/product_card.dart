import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';

// Map of icon names to Material Design Icons
final Map<String, IconData> _productIcons = {
  'restaurant_menu': Icons.restaurant_menu,
  'fastfood': Icons.fastfood,
  'restaurant': Icons.restaurant,
  'lunch_dining': Icons.lunch_dining,
  'local_dining': Icons.local_dining,
  'dinner_dining': Icons.dinner_dining,
  'ramen_dining': Icons.ramen_dining,
  'rice_bowl': Icons.rice_bowl,
  'set_meal': Icons.set_meal,
  'bakery_dining': Icons.bakery_dining,
  'cake': Icons.cake,
  'icecream': Icons.icecream,
  'local_cafe': Icons.local_cafe,
  'coffee': Icons.coffee,
  'coffee_maker': Icons.coffee_maker,
  'emoji_food_beverage': Icons.emoji_food_beverage,
  'liquor': Icons.liquor,
  'local_bar': Icons.local_bar,
  'wine_bar': Icons.wine_bar,
  'sports_bar': Icons.sports_bar,
  'free_breakfast': Icons.free_breakfast,
  'brunch_dining': Icons.brunch_dining,
  'tapas': Icons.tap_and_play, // Using tap_and_play as tapas alternative
  'outdoor_grill': Icons.outdoor_grill,
  'takeout_dining': Icons.takeout_dining,
  'delivery_dining': Icons.delivery_dining,
  'pest_control_rodent': Icons.pest_control_rodent, // For satay
  'grass': Icons.grass, // For traditional items
  'park': Icons.park, // For traditional items
  'ac_unit': Icons.ac_unit, // For cold drinks
  'whatshot': Icons.whatshot, // For hot drinks
  'local_florist': Icons.local_florist, // For tea
  'spa': Icons.spa, // For beverages
  'local_shipping': Icons.local_shipping, // For delivery items
};

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image/Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: product.imageUrl.isNotEmpty
                    ? _productIcons.containsKey(product.imageUrl)
                        ? Icon(
                            _productIcons[product.imageUrl],
                            color: theme.colorScheme.primary,
                            size: 30,
                          )
                        : product.imageUrl.startsWith('http')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.inventory_2,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : product.imageUrl.startsWith('assets/')
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.inventory_2,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.inventory_2,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 30,
                                  )
                    : Icon(
                        Icons.inventory_2,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 30,
                      ),
              ),

              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Price
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Category and Stock
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.categoryName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.inventory,
                          size: 16,
                          color: product.stock <= 10
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.stock} pcs',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: product.stock <= 10
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    // Barcode if available
                    if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.barcode!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}