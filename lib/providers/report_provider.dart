import 'package:flutter/foundation.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class ReportProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  Map<String, dynamic>? _dailySalesSummary;
  Map<String, dynamic>? _salesSummary;
  List<Map<String, dynamic>>? _topProducts;
  List<Map<String, dynamic>>? _trendingProducts;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get dailySalesSummary => _dailySalesSummary;
  Map<String, dynamic>? get salesSummary => _salesSummary;
  List<Map<String, dynamic>>? get topProducts => _topProducts;
  List<Map<String, dynamic>>? get trendingProducts => _trendingProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load daily sales summary
  Future<void> loadDailySalesSummary({DateTime? date}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final targetDate = date ?? DateTime.now();
      _dailySalesSummary = await _transactionService.getDailySalesSummary(targetDate);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load sales summary for date range
  Future<void> loadSalesSummary(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salesSummary = await _transactionService.getSalesSummary(startDate, endDate);
      _topProducts = _salesSummary?['topProducts'] as List<Map<String, dynamic>>?;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load trending products
  Future<void> loadTrendingProducts({int days = 7}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Import recommendation service dynamically to avoid circular dependency
      final recommendationService = await _getRecommendationService();
      _trendingProducts = await recommendationService.getTrendingProducts(days: days);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get recommendation service
  Future<dynamic> _getRecommendationService() async {
    // This is a workaround to avoid circular imports
    // In a real app, you'd restructure the services
    final recommendationService = await _importRecommendationService();
    return recommendationService;
  }

  Future<dynamic> _importRecommendationService() async {
    // Dynamic import to avoid circular dependency
    // For now, return a mock service
    return MockRecommendationService();
  }

  // Get chart data for sales over time
  List<Map<String, dynamic>> getSalesChartData() {
    if (_salesSummary == null) return [];

    final transactions = _salesSummary!['transactions'] as List<TransactionModel>;
    final dailyData = <String, Map<String, dynamic>>{};

    for (final transaction in transactions) {
      final dateKey = transaction.timestamp.toString().split(' ')[0]; // YYYY-MM-DD
      if (dailyData.containsKey(dateKey)) {
        dailyData[dateKey]!['sales'] += transaction.total;
        dailyData[dateKey]!['transactions'] += 1;
      } else {
        dailyData[dateKey] = {
          'date': dateKey,
          'sales': transaction.total,
          'transactions': 1,
        };
      }
    }

    return dailyData.values.toList()
      ..sort((a, b) => a['date'].compareTo(b['date']));
  }

  // Get payment method distribution
  Map<String, double> getPaymentMethodData() {
    if (_salesSummary == null) return {};

    return _salesSummary!['paymentMethodSummary'] as Map<String, double>? ?? {};
  }

  // Get top products data for charts
  List<Map<String, dynamic>> getTopProductsChartData() {
    return _topProducts ?? [];
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    await Future.wait([
      loadDailySalesSummary(date: now),
      loadSalesSummary(thirtyDaysAgo, now),
      loadTrendingProducts(),
    ]);
  }
}

// Mock service to avoid circular imports
class MockRecommendationService {
  Future<List<Map<String, dynamic>>> getTrendingProducts({int days = 7}) async {
    // Return mock data
    return [
      {
        'productId': '1',
        'currentRevenue': 150000.0,
        'previousRevenue': 100000.0,
        'growthRate': 50.0,
      },
      {
        'productId': '2',
        'currentRevenue': 200000.0,
        'previousRevenue': 180000.0,
        'growthRate': 11.11,
      },
    ];
  }
}