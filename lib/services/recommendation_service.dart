import '../models/product_model.dart';
import '../models/transaction_model.dart';
import 'product_service.dart';
import 'transaction_service.dart';

class RecommendationService {
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();

  // Get frequently bought together products
  Future<List<Map<String, dynamic>>> getFrequentlyBoughtTogether(String productId) async {
    try {
      // Get all transactions containing the product
      final transactions = await _transactionService.getTransactions(limit: 1000);

      final productTransactions = transactions.where((transaction) =>
          transaction.items.any((item) => item.productId == productId)
      ).toList();

      // Count co-occurrences
      final coOccurrences = <String, int>{};
      for (final transaction in productTransactions) {
        final otherItems = transaction.items.where((item) => item.productId != productId);
        for (final item in otherItems) {
          coOccurrences[item.productId] = (coOccurrences[item.productId] ?? 0) + 1;
        }
      }

      // Sort by frequency and return top recommendations
      final sorted = coOccurrences.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(5).map((entry) {
        final product = _findProductInTransactions(productTransactions, entry.key);
        return {
          'productId': entry.key,
          'productName': product?.productName ?? 'Unknown Product',
          'frequency': entry.value,
          'confidence': entry.value / productTransactions.length,
        };
      }).toList();
    } catch (e) {
      print('Error getting frequently bought together: $e');
      return [];
    }
  }

  TransactionItem? _findProductInTransactions(List<TransactionModel> transactions, String productId) {
    for (final transaction in transactions) {
      final item = transaction.items.firstWhere(
        (item) => item.productId == productId,
        orElse: () => TransactionItem(productId: '', productName: '', quantity: 0, price: 0, subtotal: 0),
      );
      if (item.productId.isNotEmpty) return item;
    }
    return null;
  }

  // Get popular products based on recent sales
  Future<List<Map<String, dynamic>>> getPopularProducts({
    int days = 30,
    int limit = 10,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final transactions = await _transactionService.getTransactions(
        startDate: startDate,
        endDate: endDate,
        limit: 500,
      );

      final productSales = <String, Map<String, dynamic>>{};

      for (final transaction in transactions) {
        for (final item in transaction.items) {
          if (productSales.containsKey(item.productId)) {
            productSales[item.productId]!['quantity'] += item.quantity;
            productSales[item.productId]!['revenue'] += item.subtotal;
            productSales[item.productId]!['transactions'] += 1;
          } else {
            productSales[item.productId] = {
              'productId': item.productId,
              'productName': item.productName,
              'quantity': item.quantity,
              'revenue': item.subtotal,
              'transactions': 1,
            };
          }
        }
      }

      // Sort by revenue
      final sorted = productSales.values.toList()
        ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

      return sorted.take(limit).toList();
    } catch (e) {
      print('Error getting popular products: $e');
      return [];
    }
  }

  // Get high-stock products for promotion
  Future<List<ProductModel>> getHighStockRecommendations({
    int minStock = 50,
    int limit = 10,
  }) async {
    try {
      final products = await _productService.getProducts();
      return products.where((p) => p.stock >= minStock).take(limit).toList();
    } catch (e) {
      print('Error getting high stock recommendations: $e');
      return [];
    }
  }

  // Get personalized recommendations based on purchase history
  Future<List<Map<String, dynamic>>> getPersonalizedRecommendations(String userId) async {
    try {
      // Get user's transaction history
      final userTransactions = await _transactionService.getTransactions(
        cashierId: userId,
        limit: 100,
      );

      if (userTransactions.isEmpty) {
        return await getPopularProducts(limit: 5);
      }

      // Analyze user's purchase patterns
      final userProductCounts = <String, int>{};
      final userCategories = <String, int>{};

      for (final transaction in userTransactions) {
        for (final item in transaction.items) {
          userProductCounts[item.productId] = (userProductCounts[item.productId] ?? 0) + item.quantity;
          // Note: We'd need category info here, but for now we'll skip category analysis
        }
      }

      // Get recommendations based on frequently bought products
      final recommendations = <Map<String, dynamic>>[];
      final processedProducts = <String>{};

      for (final productId in userProductCounts.keys) {
        if (processedProducts.contains(productId)) continue;

        final relatedProducts = await getFrequentlyBoughtTogether(productId);
        for (final related in relatedProducts) {
          if (!processedProducts.contains(related['productId'])) {
            recommendations.add(related);
            processedProducts.add(related['productId'] as String);
          }
        }
      }

      // If not enough recommendations, add popular products
      if (recommendations.length < 5) {
        final popularProducts = await getPopularProducts(limit: 10);
        for (final popular in popularProducts) {
          if (!processedProducts.contains(popular['productId'])) {
            recommendations.add({
              ...popular,
              'reason': 'Popular product',
            });
            processedProducts.add(popular['productId'] as String);
            if (recommendations.length >= 5) break;
          }
        }
      }

      return recommendations.take(5).toList();
    } catch (e) {
      print('Error getting personalized recommendations: $e');
      return [];
    }
  }

  // Get trending products (products with increasing sales)
  Future<List<Map<String, dynamic>>> getTrendingProducts({int days = 7}) async {
    try {
      final now = DateTime.now();
      final currentPeriodEnd = now;
      final currentPeriodStart = now.subtract(Duration(days: days));
      final previousPeriodEnd = currentPeriodStart;
      final previousPeriodStart = previousPeriodEnd.subtract(Duration(days: days));

      // Get current period sales
      final currentTransactions = await _transactionService.getTransactions(
        startDate: currentPeriodStart,
        endDate: currentPeriodEnd,
        limit: 500,
      );

      // Get previous period sales
      final previousTransactions = await _transactionService.getTransactions(
        startDate: previousPeriodStart,
        endDate: previousPeriodEnd,
        limit: 500,
      );

      final currentSales = <String, double>{};
      final previousSales = <String, double>{};

      for (final transaction in currentTransactions) {
        for (final item in transaction.items) {
          currentSales[item.productId] = (currentSales[item.productId] ?? 0) + item.subtotal;
        }
      }

      for (final transaction in previousTransactions) {
        for (final item in transaction.items) {
          previousSales[item.productId] = (previousSales[item.productId] ?? 0) + item.subtotal;
        }
      }

      // Calculate growth rate
      final trendingProducts = <Map<String, dynamic>>[];

      for (final productId in currentSales.keys) {
        final currentRevenue = currentSales[productId]!;
        final previousRevenue = previousSales[productId] ?? 0;

        if (previousRevenue > 0) {
          final growthRate = ((currentRevenue - previousRevenue) / previousRevenue) * 100;
          if (growthRate > 10) { // More than 10% growth
            trendingProducts.add({
              'productId': productId,
              'currentRevenue': currentRevenue,
              'previousRevenue': previousRevenue,
              'growthRate': growthRate,
            });
          }
        } else if (currentRevenue > 0) {
          // New product
          trendingProducts.add({
            'productId': productId,
            'currentRevenue': currentRevenue,
            'previousRevenue': 0,
            'growthRate': double.infinity,
          });
        }
      }

      // Sort by growth rate
      trendingProducts.sort((a, b) => (b['growthRate'] as double).compareTo(a['growthRate'] as double));

      return trendingProducts.take(10).toList();
    } catch (e) {
      print('Error getting trending products: $e');
      return [];
    }
  }

  // Get products that are running low (for restocking recommendations)
  Future<List<ProductModel>> getRestockRecommendations({
    int threshold = 20,
    int limit = 20,
  }) async {
    try {
      final products = await _productService.getProducts();
      return products.where((p) => p.stock <= threshold).take(limit).toList();
    } catch (e) {
      print('Error getting restock recommendations: $e');
      return [];
    }
  }

  // Get seasonal recommendations (basic implementation)
  Future<List<Map<String, dynamic>>> getSeasonalRecommendations() async {
    try {
      final now = DateTime.now();
      final currentMonth = now.month;

      // Simple seasonal logic - you can expand this
      final seasonalProducts = <String>[];

      if (currentMonth >= 6 && currentMonth <= 8) { // Summer
        seasonalProducts.addAll(['ice cream', 'soda', 'beach items']);
      } else if (currentMonth >= 12 || currentMonth <= 2) { // Winter
        seasonalProducts.addAll(['hot drinks', 'warm food', 'winter items']);
      }

      // For now, return popular products as seasonal
      return await getPopularProducts(limit: 5);
    } catch (e) {
      print('Error getting seasonal recommendations: $e');
      return [];
    }
  }

  // Get complementary products (upselling)
  Future<List<Map<String, dynamic>>> getComplementaryProducts(String productId) async {
    try {
      // For now, use frequently bought together
      return await getFrequentlyBoughtTogether(productId);
    } catch (e) {
      print('Error getting complementary products: $e');
      return [];
    }
  }
}