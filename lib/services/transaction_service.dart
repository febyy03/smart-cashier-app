import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/product_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  final Uuid _uuid = const Uuid();

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

      // Generate receipt number
      final receiptNumber = _generateReceiptNumber();

      final transaction = TransactionModel(
        id: '', // Will be set by Firestore
        cashierId: cashierId,
        cashierName: cashierName,
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        total: total,
        paymentMethod: paymentMethod,
        timestamp: DateTime.now(),
        receiptNumber: receiptNumber,
      );

      // Save to Firestore
      final docRef = await _firestore.collection('transactions').add(transaction.toFirestore());

      // Update product stock
      await _updateProductStock(items);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Update product stock after transaction
  Future<void> _updateProductStock(List<TransactionItem> items) async {
    for (final item in items) {
      final currentStock = await _getCurrentStock(item.productId);
      final newStock = currentStock - item.quantity;

      if (newStock < 0) {
        throw Exception('Insufficient stock for ${item.productName}');
      }

      await _productService.updateStock(item.productId, newStock);
    }
  }

  // Get current stock for a product
  Future<int> _getCurrentStock(String productId) async {
    final product = await _productService.getProductById(productId);
    return product?.stock ?? 0;
  }

  // Generate unique receipt number
  String _generateReceiptNumber() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final randomStr = _uuid.v4().substring(0, 4).toUpperCase();
    return 'RCP$dateStr$timeStr$randomStr';
  }

  // Get transactions with filters
  Future<List<TransactionModel>> getTransactions({
    String? cashierId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore.collection('transactions');

      if (cashierId != null) {
        query = query.where('cashierId', isEqualTo: cashierId);
      }

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('timestamp', descending: true).limit(limit);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  // Get transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final doc = await _firestore.collection('transactions').doc(id).get();
      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load transaction: $e');
    }
  }

  // Get transaction by receipt number
  Future<TransactionModel?> getTransactionByReceipt(String receiptNumber) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('receiptNumber', isEqualTo: receiptNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return TransactionModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load transaction: $e');
    }
  }

  // Get daily sales summary
  Future<Map<String, dynamic>> getDailySalesSummary(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('transactions')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final transactions = snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();

      final totalSales = transactions.fold(0.0, (sum, t) => sum + t.total);
      final totalTransactions = transactions.length;
      final cashTransactions = transactions.where((t) => t.paymentMethod == PaymentMethod.cash).length;
      final digitalTransactions = transactions.where((t) => t.paymentMethod == PaymentMethod.digital).length;

      // Calculate product sales
      final productSales = <String, int>{};
      for (final transaction in transactions) {
        for (final item in transaction.items) {
          productSales[item.productName] = (productSales[item.productName] ?? 0) + item.quantity;
        }
      }

      return {
        'date': date,
        'totalSales': totalSales,
        'totalTransactions': totalTransactions,
        'cashTransactions': cashTransactions,
        'digitalTransactions': digitalTransactions,
        'productSales': productSales,
        'transactions': transactions,
      };
    } catch (e) {
      throw Exception('Failed to get daily sales summary: $e');
    }
  }

  // Get sales summary for date range
  Future<Map<String, dynamic>> getSalesSummary(DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final transactions = snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();

      final totalSales = transactions.fold(0.0, (sum, t) => sum + t.total);
      final totalTransactions = transactions.length;
      final averageTransaction = totalTransactions > 0 ? totalSales / totalTransactions : 0.0;

      // Group by payment method
      final paymentMethodSummary = <String, double>{};
      for (final transaction in transactions) {
        final method = transaction.paymentMethod == PaymentMethod.cash ? 'cash' : 'digital';
        paymentMethodSummary[method] = (paymentMethodSummary[method] ?? 0) + transaction.total;
      }

      // Top selling products
      final productSales = <String, Map<String, dynamic>>{};
      for (final transaction in transactions) {
        for (final item in transaction.items) {
          if (productSales.containsKey(item.productId)) {
            productSales[item.productId]!['quantity'] += item.quantity;
            productSales[item.productId]!['revenue'] += item.subtotal;
          } else {
            productSales[item.productId] = {
              'name': item.productName,
              'quantity': item.quantity,
              'revenue': item.subtotal,
            };
          }
        }
      }

      final topProducts = productSales.values.toList()
        ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

      return {
        'startDate': startDate,
        'endDate': endDate,
        'totalSales': totalSales,
        'totalTransactions': totalTransactions,
        'averageTransaction': averageTransaction,
        'paymentMethodSummary': paymentMethodSummary,
        'topProducts': topProducts.take(10).toList(),
        'transactions': transactions,
      };
    } catch (e) {
      throw Exception('Failed to get sales summary: $e');
    }
  }

  // Stream for real-time transaction updates
  Stream<List<TransactionModel>> getTransactionsStream({
    String? cashierId,
    int limit = 20,
  }) {
    Query query = _firestore.collection('transactions');

    if (cashierId != null) {
      query = query.where('cashierId', isEqualTo: cashierId);
    }

    return query
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList());
  }

  // Cancel transaction (refund)
  Future<void> cancelTransaction(String transactionId) async {
    try {
      final transaction = await getTransactionById(transactionId);
      if (transaction == null) {
        throw Exception('Transaction not found');
      }

      // Restore product stock
      for (final item in transaction.items) {
        final currentStock = await _getCurrentStock(item.productId);
        final newStock = currentStock + item.quantity;
        await _productService.updateStock(item.productId, newStock);
      }

      // Mark transaction as cancelled (you might want to add a status field)
      await _firestore.collection('transactions').doc(transactionId).update({
        'cancelled': true,
        'cancelledAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to cancel transaction: $e');
    }
  }
}