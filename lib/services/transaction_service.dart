import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../services/product_service.dart';

class TransactionService {
  final Dio _dio = Dio();
  final ProductService _productService = ProductService();
  final String baseUrl = kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';

  TransactionService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // Create new transaction
  Future<String> createTransaction({
    required String cashierId,
    required String cashierName,
    required List<TransactionItem> items,
    required double tax,
    required double discount,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      // Calculate totals
      final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
      final total = subtotal + tax - discount;

      final response = await _dio.post('/transactions', data: {
        'total': total,
        'items': items.map((item) => item.toMap()).toList(),
        'transaction_date': DateTime.now().toIso8601String(),
      });

      // Update product stock locally (since API may not handle it)
      await _updateProductStock(items);

      return response.data['id'].toString();
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Update product stock after transaction
  Future<void> _updateProductStock(List<TransactionItem> items) async {
    // For now, skip stock update as API may handle it
    // TODO: implement stock update via API
  }

  // Get transactions
  Future<List<TransactionModel>> getTransactions({
    String? cashierId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get('/transactions');
      final data = response.data as List;
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  // Get transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final response = await _dio.get('/transactions/$id');
      return TransactionModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Get daily sales summary
  Future<Map<String, dynamic>> getDailySalesSummary(DateTime date) async {
    try {
      // For now, return mock data
      return {
        'date': date,
        'totalSales': 0.0,
        'totalTransactions': 0,
        'cashTransactions': 0,
        'digitalTransactions': 0,
        'productSales': <String, int>{},
        'transactions': <TransactionModel>[],
      };
    } catch (e) {
      throw Exception('Failed to get daily sales summary: $e');
    }
  }

  // Get sales summary for date range
  Future<Map<String, dynamic>> getSalesSummary(DateTime startDate, DateTime endDate) async {
    try {
      // For now, return mock data
      return {
        'startDate': startDate,
        'endDate': endDate,
        'totalSales': 0.0,
        'totalTransactions': 0,
        'averageTransaction': 0.0,
        'paymentMethodSummary': <String, double>{},
        'topProducts': [],
        'transactions': <TransactionModel>[],
      };
    } catch (e) {
      throw Exception('Failed to get sales summary: $e');
    }
  }
}