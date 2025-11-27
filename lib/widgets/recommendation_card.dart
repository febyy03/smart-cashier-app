import 'package:flutter/material.dart';
import '../models/product_model.dart';

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;
  final VoidCallback? onAddToCart;
  final String? reason;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onAddToCart,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onAddToCart,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Icon/Placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      recommendation['productName'] ?? 'Unknown Product',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Reason or additional info
                    Row(
                      children: [
                        if (reason != null) ...[
                          Icon(
                            Icons.lightbulb_outline,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reason!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else if (recommendation.containsKey('frequency')) ...[
                          Icon(
                            Icons.trending_up,
                            size: 14,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Bought together ${recommendation['frequency']} times',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ] else if (recommendation.containsKey('growthRate')) ...[
                          Icon(
                            Icons.trending_up,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendation['growthRate'] == double.infinity
                                ? 'New trending product'
                                : '${recommendation['growthRate'].toStringAsFixed(1)}% growth',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Price if available
                    if (recommendation.containsKey('price')) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${recommendation['price'].toStringAsFixed(0)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Add Button
              if (onAddToCart != null)
                IconButton(
                  onPressed: onAddToCart,
                  icon: Icon(
                    Icons.add_shopping_cart,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Add to cart',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecommendationSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> recommendations;
  final Function(Map<String, dynamic>)? onAddToCart;
  final String? emptyMessage;

  const RecommendationSection({
    super.key,
    required this.title,
    required this.recommendations,
    this.onAddToCart,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.recommend,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Recommendations List
        if (recommendations.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emptyMessage ?? 'No recommendations available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return SizedBox(
                  width: 280,
                  child: RecommendationCard(
                    recommendation: recommendation,
                    onAddToCart: onAddToCart != null
                        ? () => onAddToCart!(recommendation)
                        : null,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}