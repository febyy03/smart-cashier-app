import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final String baseUrl = kIsWeb ? 'http://127.0.0.1:8080/api' : 'http://10.0.2.2:8000/api';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Product CRUD Operations
  Future<List<ProductModel>> getProducts() async {
    try {
      // Use public headers for products endpoint (no auth required)
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      print('ProductService: Making request to $baseUrl/products');
      print('ProductService: Headers: $headers');

      final response = await http.get(Uri.parse('$baseUrl/products'), headers: headers);
      print('ProductService: Response status: ${response.statusCode}');
      print('ProductService: Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        print('ProductService: Parsed ${data.length} products');
        final products = data.map((json) => ProductModel.fromJson(json)).toList();
        print('ProductService: Successfully created ${products.length} ProductModel objects');
        return products;
      } else {
        print('ProductService: Failed with status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('ProductService: Exception occurred: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {'search': query});
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {'category_id': categoryId});
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products by category: $e');
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl/products/$id'), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> addProduct(ProductModel product) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: json.encode({
          'name': product.name,
          'price': product.price,
          'stock': product.stock,
          'unit': 'pcs', // Default
          'category_id': product.categoryId,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['id'].toString();
      } else {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      final headers = await _getHeaders();
      await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: headers,
        body: json.encode({
          'name': product.name,
          'price': product.price,
          'stock': product.stock,
          'unit': 'pcs',
          'category_id': product.categoryId,
        }),
      );
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'), headers: headers);

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Category Operations
  Future<List<CategoryModel>> getCategories() async {
    try {
      // Use public headers for categories endpoint (no auth required)
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      print('ProductService: Making request to $baseUrl/categories');

      final response = await http.get(Uri.parse('$baseUrl/categories'), headers: headers);
      print('ProductService: Categories response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        print('ProductService: Parsed ${data.length} categories');
        final categories = data.map((json) => CategoryModel.fromJson(json)).toList();
        print('ProductService: Successfully created ${categories.length} CategoryModel objects');
        return categories;
      } else {
        print('ProductService: Failed with status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('ProductService: Exception occurred: $e');
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