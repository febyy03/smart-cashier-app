import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered products
  List<ProductModel> get activeProducts =>
      _products.where((product) => !product.isArchived).toList();

  List<ProductModel> get lowStockProducts =>
      _products.where((product) => product.stock <= 10 && !product.isArchived).toList();

  // Load data
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('ProductProvider: Starting to load products');
      _products = await _productService.getProducts();
      print('ProductProvider: Successfully loaded ${_products.length} products');
    } catch (e) {
      print('ProductProvider: Error loading products: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('ProductProvider: Finished loading products. isLoading: $_isLoading, error: $_error');
    }
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('ProductProvider: Starting to load categories');
      _categories = await _productService.getCategories();
      print('ProductProvider: Successfully loaded ${_categories.length} categories');
    } catch (e) {
      print('ProductProvider: Error loading categories: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('ProductProvider: Finished loading categories. isLoading: $_isLoading, error: $_error');
    }
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadProducts(),
      loadCategories(),
    ]);
  }

  // Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await loadProducts();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.searchProducts(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter by category
  Future<void> filterByCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (categoryId.isEmpty) {
        _products = await _productService.getProducts();
      } else {
        _products = await _productService.getProductsByCategory(categoryId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Product CRUD
  Future<bool> addProduct(ProductModel product) async {
    try {
      final productId = await _productService.addProduct(product);
      await loadProducts(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _productService.updateProduct(product);
      await loadProducts(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      await loadProducts(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    try {
      await _productService.updateStock(productId, newStock);
      await loadProducts(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Category CRUD
  Future<bool> addCategory(CategoryModel category) async {
    try {
      await _productService.addCategory(category);
      await loadCategories(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _productService.updateCategory(category);
      await loadCategories(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _productService.deleteCategory(categoryId);
      await loadCategories(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get product by ID
  ProductModel? getProductById(String id) {
    return _products.cast<ProductModel?>().firstWhere(
          (product) => product?.id == id,
          orElse: () => null,
        );
  }

  // Get category by ID
  CategoryModel? getCategoryById(String id) {
    return _categories.cast<CategoryModel?>().firstWhere(
          (category) => category?.id == id,
          orElse: () => null,
        );
  }

  // Get product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    return await _productService.getProductByBarcode(barcode);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Streams for real-time updates
  Stream<List<ProductModel>> get productsStream => _productService.getProductsStream();
  Stream<List<CategoryModel>> get categoriesStream => _productService.getCategoriesStream();
}