import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final Dio _dio = Dio();
  final String baseUrl = kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';

  ProductService() {
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

  // Product CRUD Operations
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      final data = response.data as List;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _dio.get('/products', queryParameters: {'search': query});
      final data = response.data as List;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _dio.get('/products', queryParameters: {'category_id': categoryId});
      final data = response.data as List;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products by category: $e');
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return ProductModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<String> addProduct(ProductModel product) async {
    try {
      final response = await _dio.post('/products', data: {
        'name': product.name,
        'price': product.price,
        'stock': product.stock,
        'unit': 'pcs', // Default
        'category_id': product.categoryId,
      });
      return response.data['id'].toString();
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _dio.put('/products/${product.id}', data: {
        'name': product.name,
        'price': product.price,
        'stock': product.stock,
        'unit': 'pcs',
        'category_id': product.categoryId,
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/products/$id');
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Category Operations
  Future<List<CategoryModel>> getCategories() async {
    try {
      // For now, return static categories since API may not have separate endpoint
      return [
        CategoryModel(id: '1', name: 'Food', icon: '🍔', color: '#FF6B6B'),
        CategoryModel(id: '2', name: 'Drinks', icon: '🥤', color: '#4ECDC4'),
        CategoryModel(id: '3', name: 'Snacks', icon: '🍿', color: '#45B7D1'),
      ];
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  // Simplified methods
  Future<List<ProductModel>> getLowStockProducts({int threshold = 10}) async {
    try {
      final products = await getProducts();
      return products.where((p) => p.stock <= threshold).toList();
    } catch (e) {
      throw Exception('Failed to load low stock products: $e');
    }
  }

  // Stub methods for compatibility
  Future<void> updateStock(String productId, int newStock) async {
    // TODO: implement via API
  }

  Future<String> addCategory(CategoryModel category) async {
    // TODO: implement via API
    return '1';
  }

  Future<void> updateCategory(CategoryModel category) async {
    // TODO: implement via API
  }

  Future<void> deleteCategory(String id) async {
    // TODO: implement via API
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    // TODO: implement via API
    return null;
  }

  Stream<List<ProductModel>> getProductsStream() {
    // TODO: implement stream via API
    return Stream.value([]);
  }

  Stream<List<CategoryModel>> getCategoriesStream() {
    // TODO: implement stream via API
    return Stream.value([]);
  }
}