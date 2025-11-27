import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_chip.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = '';
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final productProvider = context.read<ProductProvider>();
    await productProvider.loadAllData();
  }

  void _onSearchChanged(String query) {
    final productProvider = context.read<ProductProvider>();
    if (query.isEmpty && _selectedCategoryId.isEmpty) {
      productProvider.loadProducts();
    } else {
      productProvider.searchProducts(query);
    }
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId == _selectedCategoryId ? '' : categoryId;
    });

    final productProvider = context.read<ProductProvider>();
    productProvider.filterByCategory(_selectedCategoryId);
  }

  void _toggleLowStockFilter() {
    setState(() {
      _showLowStockOnly = !_showLowStockOnly;
    });
  }

  List<ProductModel> _getFilteredProducts(ProductProvider provider) {
    List<ProductModel> products = _selectedCategoryId.isEmpty
        ? provider.activeProducts
        : provider.products.where((p) => p.categoryId == _selectedCategoryId).toList();

    if (_showLowStockOnly) {
      products = products.where((p) => p.stock <= 10).toList();
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Low stock filter toggle
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              final lowStockCount = provider.lowStockProducts.length;
              return Badge(
                isLabelVisible: lowStockCount > 0,
                label: Text(lowStockCount.toString()),
                child: IconButton(
                  icon: Icon(
                    _showLowStockOnly ? Icons.warning : Icons.warning_outlined,
                    color: _showLowStockOnly ? theme.colorScheme.error : null,
                  ),
                  onPressed: _toggleLowStockFilter,
                  tooltip: 'Show low stock items',
                ),
              );
            },
          ),

          // Add product button (admin only)
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToAddProduct(),
              tooltip: 'Add Product',
            ),
        ],
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Categories Filter
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // All categories chip
                    CategoryChip(
                      category: CategoryModel(
                        id: '',
                        name: 'All',
                        icon: 'category',
                        color: '#2196F3',
                      ),
                      isSelected: _selectedCategoryId.isEmpty,
                      onTap: () => _onCategorySelected(''),
                    ),

                    // Category chips
                    ...provider.categories.map((category) => CategoryChip(
                          category: category,
                          isSelected: category.id == _selectedCategoryId,
                          onTap: () => _onCategorySelected(category.id),
                          onEdit: isAdmin ? () => _editCategory(category) : null,
                          onDelete: isAdmin ? () => _deleteCategory(category) : null,
                        )),
                  ],
                ),
              );
            },
          ),

          // Products List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading products',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredProducts = _getFilteredProducts(provider);

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getEmptyStateMessage(),
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (isAdmin)
                          ElevatedButton.icon(
                            onPressed: _navigateToAddProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Product'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _showProductDetails(product),
                        onEdit: isAdmin ? () => _navigateToEditProduct(product) : null,
                        onDelete: isAdmin ? () => _confirmDeleteProduct(product) : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    if (_searchController.text.isNotEmpty) {
      return 'No products found for "${_searchController.text}"';
    }
    if (_selectedCategoryId.isNotEmpty) {
      return 'No products in this category';
    }
    if (_showLowStockOnly) {
      return 'No low stock items';
    }
    return 'No products available';
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  void _navigateToEditProduct(ProductModel product) {
    // TODO: Implement edit product screen with product parameter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit product coming soon')),
    );
  }

  void _showProductDetails(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _buildProductDetailsSheet(context, product, scrollController),
      ),
    );
  }

  Widget _buildProductDetailsSheet(BuildContext context, ProductModel product, ScrollController scrollController) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Product Image
          if (product.imageUrl.isNotEmpty)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Product Details
          _buildDetailRow('Price', 'Rp ${product.price.toStringAsFixed(0)}'),
          _buildDetailRow('Stock', '${product.stock} pieces'),
          _buildDetailRow('Category', product.categoryName),

          if (product.barcode != null && product.barcode!.isNotEmpty)
            _buildDetailRow('Barcode', product.barcode!),

          _buildDetailRow(
            'Created',
            '${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}',
          ),

          _buildDetailRow(
            'Last Updated',
            '${product.updatedAt.day}/${product.updatedAt.month}/${product.updatedAt.year}',
          ),

          const SizedBox(height: 24),

          // Stock Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: product.stock <= 10
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              product.stock <= 10 ? 'Low Stock' : 'In Stock',
              style: TextStyle(
                color: product.stock <= 10
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(ProductModel product) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(product);
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final theme = Theme.of(context);
    final provider = context.read<ProductProvider>();
    final success = await provider.deleteProduct(product.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Product deleted successfully' : 'Failed to delete product',
          ),
          backgroundColor: success ? theme.colorScheme.primary : theme.colorScheme.error,
        ),
      );
    }
  }

  void _editCategory(CategoryModel category) {
    // TODO: Implement category editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category editing coming soon')),
    );
  }

  void _deleteCategory(CategoryModel category) {
    // TODO: Implement category deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category deletion coming soon')),
    );
  }
}
