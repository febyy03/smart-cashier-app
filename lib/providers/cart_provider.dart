import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  double _taxRate = 0.1; // 10% tax
  double _discount = 0.0;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get tax => subtotal * _taxRate;
  double get discount => _discount;
  double get total => subtotal + tax - discount;

  double get taxRate => _taxRate;
  set taxRate(double rate) {
    _taxRate = rate;
    notifyListeners();
  }

  set discount(double value) {
    _discount = value;
    notifyListeners();
  }

  // Add product to cart
  void addProduct(ProductModel product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Product already in cart, increase quantity
      final currentQuantity = _items[existingIndex].quantity;
      final newQuantity = currentQuantity + quantity;

      // Check stock limit
      if (newQuantity > product.stock) {
        throw Exception('Insufficient stock. Available: ${product.stock}');
      }

      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: newQuantity,
      );
    } else {
      // New product
      if (quantity > product.stock) {
        throw Exception('Insufficient stock. Available: ${product.stock}');
      }

      _items.add(CartItem(
        product: product,
        quantity: quantity,
      ));
    }

    notifyListeners();
  }

  // Update quantity of product in cart
  void updateQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        // Check stock limit
        if (newQuantity > _items[index].product.stock) {
          throw Exception('Insufficient stock. Available: ${_items[index].product.stock}');
        }

        _items[index] = _items[index].copyWith(quantity: newQuantity);
      }
      notifyListeners();
    }
  }

  // Remove product from cart
  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _discount = 0.0;
    notifyListeners();
  }

  // Check if product is in cart
  bool containsProduct(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get cart item by product id
  CartItem? getCartItem(String productId) {
    return _items.cast<CartItem?>().firstWhere(
          (item) => item?.product.id == productId,
          orElse: () => null,
        );
  }

  // Convert cart to transaction items
  List<TransactionItem> toTransactionItems() {
    return _items.map((cartItem) {
      return TransactionItem(
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        quantity: cartItem.quantity,
        price: cartItem.product.price,
        subtotal: cartItem.subtotal,
      );
    }).toList();
  }

  // Apply discount percentage
  void applyDiscountPercentage(double percentage) {
    if (percentage < 0 || percentage > 100) {
      throw Exception('Invalid discount percentage');
    }
    _discount = subtotal * (percentage / 100);
    notifyListeners();
  }

  // Apply fixed discount amount
  void applyDiscountAmount(double amount) {
    if (amount < 0 || amount > subtotal) {
      throw Exception('Invalid discount amount');
    }
    _discount = amount;
    notifyListeners();
  }

  // Remove discount
  void removeDiscount() {
    _discount = 0.0;
    notifyListeners();
  }

  // Validate cart before checkout
  bool validateCart() {
    if (_items.isEmpty) {
      throw Exception('Cart is empty');
    }

    for (final item in _items) {
      if (item.quantity > item.product.stock) {
        throw Exception('Insufficient stock for ${item.product.name}');
      }
    }

    return true;
  }

  // Get cart summary
  Map<String, dynamic> getSummary() {
    return {
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
    };
  }
}