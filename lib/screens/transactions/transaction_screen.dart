import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/transaction_service.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../widgets/cart_item_widget.dart';
import '../../widgets/recommendation_card.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/product_card.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TransactionService _transactionService = TransactionService();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isProcessing = false;
  bool _showScanner = false;
  final RecommendationService _recommendationService = RecommendationService();
  List<Map<String, dynamic>> _recommendations = [];
  bool _loadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final productProvider = context.read<ProductProvider>();
    await productProvider.loadAllData();
    await _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _loadingRecommendations = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;

      if (userId != null) {
        _recommendations = await _recommendationService.getPersonalizedRecommendations(userId);
      } else {
        _recommendations = await _recommendationService.getPopularProducts(limit: 5);
      }
    } catch (e) {
      print('Error loading recommendations: $e');
      _recommendations = [];
    } finally {
      if (mounted) {
        setState(() => _loadingRecommendations = false);
      }
    }
  }

  void _addProductToCart(ProductModel product) {
    final cartProvider = context.read<CartProvider>();
    try {
      cartProvider.addProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first.rawValue;
      if (barcode != null) {
        final productProvider = context.read<ProductProvider>();
        final product = await productProvider.getProductByBarcode(barcode);

        if (product != null && mounted) {
          _addProductToCart(product);
          setState(() => _showScanner = false);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product not found')),
          );
        }
      }
    }
  }

  void _searchProducts(String query) {
    final productProvider = context.read<ProductProvider>();
    if (query.isEmpty) {
      productProvider.loadProducts();
    } else {
      productProvider.searchProducts(query);
    }
  }

  Future<void> _processPayment() async {
    final cartProvider = context.read<CartProvider>();
    final authProvider = context.read<AuthProvider>();

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Validate cart
      cartProvider.validateCart();

      // Create transaction
      final transactionId = await _transactionService.createTransaction(
        cashierId: authProvider.currentUser!.id,
        cashierName: authProvider.currentUser!.name,
        items: cartProvider.toTransactionItems(),
        tax: cartProvider.tax,
        discount: cartProvider.discount,
        paymentMethod: _selectedPaymentMethod,
      );

      // Clear cart
      cartProvider.clearCart();

      // Show success dialog
      if (mounted) {
        _showOrderCompletionDialog(transactionId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
        actions: [
          // Barcode scanner
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => setState(() => _showScanner = !_showScanner),
            tooltip: 'Scan barcode',
          ),

          // Clear cart
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return cart.items.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear Cart'),
                            content: const Text('Are you sure you want to clear the cart?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  cart.clearCart();
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                ),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                      tooltip: 'Clear cart',
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Product Search Section
          if (!_showScanner)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                ),
              ),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchProducts('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _searchProducts,
                  ),

                  const SizedBox(height: 12),

                  // Quick Add Products
                  Consumer<ProductProvider>(
                    builder: (context, provider, child) {
                      final recentProducts = provider.activeProducts.take(6).toList();
                      if (recentProducts.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Add',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recentProducts.length,
                              itemBuilder: (context, index) {
                                final product = recentProducts[index];
                                return Container(
                                  width: 70,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () => _addProductToCart(product),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: theme.colorScheme.surfaceContainerHighest,
                                          ),
                                          child: product.imageUrl.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    product.imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        Icon(Icons.inventory_2, color: theme.colorScheme.onSurfaceVariant),
                                                  ),
                                                )
                                              : Icon(Icons.inventory_2, color: theme.colorScheme.onSurfaceVariant),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.name,
                                          style: theme.textTheme.bodySmall,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // AI Recommendations
                  if (_loadingRecommendations)
                    const Center(child: CircularProgressIndicator())
                  else if (_recommendations.isNotEmpty)
                    RecommendationSection(
                      title: 'Recommended for You',
                      recommendations: _recommendations,
                      onAddToCart: (recommendation) async {
                        // Find the actual product
                        final productProvider = context.read<ProductProvider>();
                        final product = productProvider.activeProducts.firstWhere(
                          (p) => p.id == recommendation['productId'],
                          orElse: () => throw Exception('Product not found'),
                        );
                        _addProductToCart(product);
                      },
                    ),
                ],
              ),
            ),

          // Barcode Scanner
          if (_showScanner)
            Container(
              height: 300,
              color: Colors.black,
              child: MobileScanner(
                onDetect: _onBarcodeDetected,
              ),
            ),

          // Cart Items and Summary
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cart is empty',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add products to get started',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Cart Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final cartItem = cart.items[index];
                          return CartItemWidget(
                            cartItem: cartItem,
                            onQuantityChanged: (quantity) {
                              cart.updateQuantity(cartItem.product.id, quantity);
                            },
                            onRemove: () {
                              cart.removeProduct(cartItem.product.id);
                            },
                          );
                        },
                      ),
                    ),

                    // Order Summary and Checkout
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(
                          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Discount Input
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _discountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Discount (Rp)',
                                    hintText: '0',
                                    prefixIcon: Icon(Icons.discount),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final discount = double.tryParse(value) ?? 0;
                                    cart.discount = discount;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  _discountController.clear();
                                  cart.removeDiscount();
                                },
                                icon: const Icon(Icons.clear),
                                tooltip: 'Remove discount',
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Order Summary
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow('Subtotal', 'Rp ${cart.subtotal.toStringAsFixed(0)}'),
                                _buildSummaryRow('Tax (10%)', 'Rp ${cart.tax.toStringAsFixed(0)}'),
                                if (cart.discount > 0)
                                  _buildSummaryRow('Discount', '-Rp ${cart.discount.toStringAsFixed(0)}'),
                                const Divider(),
                                _buildSummaryRow(
                                  'Total',
                                  'Rp ${cart.total.toStringAsFixed(0)}',
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Payment Method
                          Row(
                            children: [
                              Text(
                                'Payment Method',
                                style: theme.textTheme.titleMedium,
                              ),
                              const Spacer(),
                              SegmentedButton<PaymentMethod>(
                                segments: const [
                                  ButtonSegment(
                                    value: PaymentMethod.cash,
                                    label: Text('Cash'),
                                    icon: Icon(Icons.money),
                                  ),
                                  ButtonSegment(
                                    value: PaymentMethod.digital,
                                    label: Text('Digital'),
                                    icon: Icon(Icons.credit_card),
                                  ),
                                ],
                                selected: {_selectedPaymentMethod},
                                onSelectionChanged: (selection) {
                                  setState(() {
                                    _selectedPaymentMethod = selection.first;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Checkout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _processPayment,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                              child: _isProcessing
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      'Complete Transaction - Rp ${cart.total.toStringAsFixed(0)}',
                                      style: theme.textTheme.titleMedium,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderCompletionDialog(String transactionId) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 24),

              // Success Title
              Text(
                'Pesanan Selesai!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Success Message
              Text(
                'Terima kasih atas pesanan Anda.\nTransaksi telah berhasil diproses.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Transaction ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID Transaksi: $transactionId',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        // Navigate to transaction history
                        Navigator.pushNamed(context, '/transaction-history');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: theme.colorScheme.outline),
                      ),
                      child: const Text('Lihat Riwayat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        // Navigate back to products for new transaction
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/products',
                          (route) => false, // Remove all previous routes
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: const Text('Pesan Lagi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}