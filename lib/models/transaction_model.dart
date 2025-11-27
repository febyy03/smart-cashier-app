import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      cashierId: data['cashierId'] ?? '',
      cashierName: data['cashierName'] ?? '',
      items: (data['items'] as List<dynamic>)
          .map((item) => TransactionItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] == 'cash'
          ? PaymentMethod.cash
          : PaymentMethod.digital,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      receiptNumber: data['receiptNumber'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cashierId': cashierId,
      'cashierName': cashierName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentMethod':
          paymentMethod == PaymentMethod.cash ? 'cash' : 'digital',
      'timestamp': Timestamp.fromDate(timestamp),
      'receiptNumber': receiptNumber,
    };
  }
}