
class TransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  TransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory TransactionItem.fromMap(Map<String, dynamic> data) {
    return TransactionItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

enum PaymentMethod { cash, digital }

class TransactionModel {
  final String id;
  final String cashierId;
  final String cashierName;
  final List<TransactionItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final PaymentMethod paymentMethod;
  final DateTime timestamp;
  final String receiptNumber;

  TransactionModel({
    required this.id,
    required this.cashierId,
    required this.cashierName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.timestamp,
    required this.receiptNumber,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      cashierId: json['user_id']?.toString() ?? '',
      cashierName: '', // Not in API response
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => TransactionItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: 0, // Calculate or from API
      tax: 0,
      discount: 0,
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.cash, // Default
      timestamp: DateTime.parse(json['transaction_date'] ?? DateTime.now().toIso8601String()),
      receiptNumber: '', // Generate or from API
    );
  }

}