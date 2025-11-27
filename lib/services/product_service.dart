import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Product CRUD Operations
  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isArchived', isEqualTo: false)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.barcode?.contains(query) == true)
          .toList();

      return products;
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load products by category: $e');
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .where('isArchived', isEqualTo: false)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ProductModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load product by barcode: $e');
    }
  }

  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = _firestore.collection('products').doc();
      final productWithId = product.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(productWithId.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).update({
        ...product.toFirestore(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      // Soft delete by archiving
      await _firestore.collection('products').doc(id).update({
        'isArchived': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'stock': newStock,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  // Image Upload
  Future<String> uploadProductImage(String productId, File imageFile) async {
    try {
      final ref = _storage.ref().child('products/$productId.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteProductImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting images
      print('Failed to delete image: $e');
    }
  }

  // Category Operations
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<String> addCategory(CategoryModel category) async {
    try {
      final docRef = _firestore.collection('categories').doc();
      final categoryWithId = CategoryModel(
        id: docRef.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
      );

      await docRef.set(categoryWithId.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').doc(category.id).update(category.toFirestore());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      // Check if category is used by products
      final productsSnapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: id)
          .limit(1)
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        throw Exception('Cannot delete category that contains products');
      }

      await _firestore.collection('categories').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Low Stock Alerts
  Future<List<ProductModel>> getLowStockProducts({int threshold = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isArchived', isEqualTo: false)
          .where('stock', isLessThanOrEqualTo: threshold)
          .orderBy('stock')
          .get();

      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load low stock products: $e');
    }
  }

  // Stream for real-time updates
  Stream<List<ProductModel>> getProductsStream() {
    return _firestore
        .collection('products')
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }
}