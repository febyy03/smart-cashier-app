import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../widgets/category_chip.dart';
import '../../config/routes.dart';
import 'add_product_screen.dart';

// Map of icon names to Material Design Icons
final Map<String, IconData> _productIcons = {
  'restaurant_menu': Icons.restaurant_menu,
  'fastfood': Icons.fastfood,
  'restaurant': Icons.restaurant,
  'lunch_dining': Icons.lunch_dining,
  'local_dining': Icons.local_dining,
  'dinner_dining': Icons.dinner_dining,
  'ramen_dining': Icons.ramen_dining,
  'rice_bowl': Icons.rice_bowl,
  'set_meal': Icons.set_meal,
  'bakery_dining': Icons.bakery_dining,
  'cake': Icons.cake,
  'icecream': Icons.icecream,
  'local_cafe': Icons.local_cafe,
  'coffee': Icons.coffee,
  'coffee_maker': Icons.coffee_maker,
  'emoji_food_beverage': Icons.emoji_food_beverage,
  'liquor': Icons.liquor,
  'local_bar': Icons.local_bar,
  'wine_bar': Icons.wine_bar,
  'sports_bar': Icons.sports_bar,
  'free_breakfast': Icons.free_breakfast,
  'brunch_dining': Icons.brunch_dining,
  'tapas': Icons.tap_and_play, // Using tap_and_play as tapas alternative
  'outdoor_grill': Icons.outdoor_grill,
  'takeout_dining': Icons.takeout_dining,
  'delivery_dining': Icons.delivery_dining,
  'pest_control_rodent': Icons.pest_control_rodent, // For satay
  'grass': Icons.grass, // For traditional items
  'park': Icons.park, // For traditional items
  'ac_unit': Icons.ac_unit, // For cold drinks
  'whatshot': Icons.whatshot, // For hot drinks
  'local_florist': Icons.local_florist, // For tea
  'spa': Icons.spa, // For beverages
  'local_shipping': Icons.local_shipping, // For delivery items
};

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
    print('ProductsScreen: Starting to load data');
    final productProvider = context.read<ProductProvider>();

    // Clear any previous errors
    productProvider.clearError();

    await productProvider.loadAllData();
    print('ProductsScreen: Finished loading data');

    // Force a rebuild to show any changes
    if (mounted) {
      setState(() {});
    }
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
          // Cart icon with item count
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final itemCount = cartProvider.totalQuantity;
              return Badge(
                isLabelVisible: itemCount > 0,
                label: Text(itemCount.toString()),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => _navigateToCart(),
                  tooltip: 'View Cart',
                ),
              );
            },
          ),

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

          // Products Carousel
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading || provider.products.isEmpty) {
                return const SizedBox.shrink();
              }

              final carouselProducts = provider.products.take(5).toList(); // Show first 5 products

              return Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 180,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    enlargeCenterPage: true,
                    enableInfiniteScroll: carouselProducts.length > 1,
                  ),
                  items: carouselProducts.map((product) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () => _showProductDetails(product),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: theme.cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image/Icon
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      color: theme.colorScheme.surfaceContainerHighest,
                                    ),
                                    child: product.imageUrl.isNotEmpty
                                        ? _productIcons.containsKey(product.imageUrl)
                                            ? Icon(
                                                _productIcons[product.imageUrl],
                                                size: 48,
                                                color: theme.colorScheme.primary,
                                              )
                                            : product.imageUrl.startsWith('http')
                                                ? Image.network(
                                                    product.imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Icon(
                                                      Icons.inventory_2,
                                                      size: 40,
                                                      color: theme.colorScheme.onSurfaceVariant,
                                                    ),
                                                  )
                                                : product.imageUrl.startsWith('assets/')
                                                    ? Image.asset(
                                                        product.imageUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          print('Carousel error loading image: ${product.imageUrl}, error: $error');
                                                          return Icon(
                                                            Icons.broken_image,
                                                            size: 40,
                                                            color: theme.colorScheme.onSurfaceVariant,
                                                          );
                                                        },
                                                      )
                                                    : Icon(
                                                        Icons.inventory_2,
                                                        size: 40,
                                                        color: theme.colorScheme.onSurfaceVariant,
                                                      )
                                        : Icon(
                                            Icons.inventory_2,
                                            size: 40,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                  ),
                                ),

                                // Product Info
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          product.name,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Rp ${product.price.toStringAsFixed(0)}',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.inventory_2,
                                              size: 16,
                                              color: product.stock <= 10
                                                  ? theme.colorScheme.error
                                                  : theme.colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${product.stock} pcs',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: product.stock <= 10
                                                    ? theme.colorScheme.error
                                                    : theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // Categories Filter
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              print('ProductsScreen: Building categories section with ${provider.categories.length} categories');
              if (provider.categories.isEmpty) {
                print('ProductsScreen: No categories available, hiding categories section');
                return const SizedBox.shrink();
              }

              return Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // All categories chip
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        category: CategoryModel(
                          id: '',
                          name: 'Semua',
                          icon: 'category',
                          color: '#2196F3',
                        ),
                        isSelected: _selectedCategoryId.isEmpty,
                        onTap: () => _onCategorySelected(''),
                      ),
                    ),

                    // Category chips
                    ...provider.categories.map((category) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            category: category,
                            isSelected: category.id == _selectedCategoryId,
                            onTap: () => _onCategorySelected(category.id),
                            onEdit: isAdmin ? () => _editCategory(category) : null,
                            onDelete: isAdmin ? () => _deleteCategory(category) : null,
                          ),
                        )),
                  ],
                ),
              );
            },
          ),

          // Products Grid
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
                print('ProductsScreen: Displaying ${filteredProducts.length} filtered products from ${provider.products.length} total products');

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
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductGridItem(context, product, theme, isAdmin);
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
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: product.imageUrl.startsWith('assets/')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            print('Details error loading image: ${product.imageUrl}, error: $error');
                            return Icon(
                              Icons.broken_image,
                              size: 40,
                              color: theme.colorScheme.onSurfaceVariant,
                            );
                          },
                        ),
                      )
                    : product.imageUrl.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              errorBuilder: (context, error, stackTrace) {
                                print('Details network error loading image: ${product.imageUrl}, error: $error');
                                return Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: theme.colorScheme.onSurfaceVariant,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.inventory_2,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant,
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

  void _navigateToCart() {
    Navigator.pushNamed(context, AppRoutes.transaction);
  }

  Widget _buildProductGridItem(BuildContext context, ProductModel product, ThemeData theme, bool isAdmin) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: theme.colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Overlay
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    // Background Image
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? _productIcons.containsKey(product.imageUrl)
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        theme.colorScheme.primary.withOpacity(0.1),
                                        theme.colorScheme.primary.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    _productIcons[product.imageUrl],
                                    size: 64,
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : product.imageUrl.startsWith('http')
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                            color: theme.colorScheme.surfaceContainerHighest,
                                          ),
                                          child: Icon(
                                            Icons.inventory_2,
                                            size: 48,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    )
                                  : product.imageUrl.startsWith('assets/')
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                          child: Image.asset(
                                            product.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading image: ${product.imageUrl}, error: $error');
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                                  color: theme.colorScheme.surfaceContainerHighest,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.broken_image,
                                                      size: 32,
                                                      color: theme.colorScheme.onSurfaceVariant,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Image Error',
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: theme.colorScheme.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                            color: theme.colorScheme.surfaceContainerHighest,
                                          ),
                                          child: Icon(
                                            Icons.inventory_2,
                                            size: 48,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                color: theme.colorScheme.surfaceContainerHighest,
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),

                    // Price Overlay
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // Stock Indicator
                    if (product.stock <= 10)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Low Stock',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Stock Info
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 16,
                            color: product.stock <= 10
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.stock} tersedia',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: product.stock <= 10
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Spacer
                      const Spacer(),

                      // Add to Cart Button
                      Row(
                        children: [
                          // Add to Cart Button
                          Expanded(
                            child: Consumer<CartProvider>(
                              builder: (context, cartProvider, child) {
                                final isInCart = cartProvider.containsProduct(product.id);
                                final cartItem = cartProvider.getCartItem(product.id);

                                return ElevatedButton.icon(
                                  onPressed: () {
                                    try {
                                      cartProvider.addProduct(product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${product.name} ditambahkan ke keranjang'),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: theme.colorScheme.primary,
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          backgroundColor: theme.colorScheme.error,
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    isInCart ? Icons.add_shopping_cart : Icons.add,
                                    size: 18,
                                  ),
                                  label: Text(
                                    isInCart
                                        ? '${cartItem?.quantity ?? 0}'
                                        : 'Tambah',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Admin Actions
                          if (isAdmin) ...[
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _navigateToEditProduct(product);
                                    break;
                                  case 'delete':
                                    _confirmDeleteProduct(product);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                              icon: Icon(
                                Icons.more_vert,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
