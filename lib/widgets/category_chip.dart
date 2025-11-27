import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Material(
        color: isSelected
            ? category.getColor()
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Icon
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : category.getColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    size: 12,
                    color: isSelected ? Colors.white : category.getColor(),
                  ),
                ),

                const SizedBox(width: 6),

                // Category Name
                Text(
                  category.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),

                // Action buttons for admin
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
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
                              Icon(Icons.edit, size: 18),
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
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'food':
      case 'restaurant':
        return Icons.restaurant;
      case 'drink':
      case 'beverage':
        return Icons.local_drink;
      case 'snack':
        return Icons.cookie;
      case 'grocery':
        return Icons.shopping_cart;
      case 'electronics':
        return Icons.devices;
      case 'clothing':
        return Icons.checkroom;
      case 'book':
      case 'books':
        return Icons.book;
      case 'toy':
      case 'toys':
        return Icons.toys;
      case 'beauty':
      case 'cosmetics':
        return Icons.face;
      case 'health':
      case 'medical':
        return Icons.medical_services;
      case 'home':
      case 'household':
        return Icons.home;
      case 'sports':
        return Icons.sports_soccer;
      case 'automotive':
        return Icons.directions_car;
      case 'pet':
      case 'pets':
        return Icons.pets;
      case 'garden':
        return Icons.grass;
      case 'office':
        return Icons.business;
      case 'music':
        return Icons.music_note;
      case 'movie':
      case 'film':
        return Icons.movie;
      case 'game':
      case 'gaming':
        return Icons.games;
      default:
        return Icons.category;
    }
  }
}