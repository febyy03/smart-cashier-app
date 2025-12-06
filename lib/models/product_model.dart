
class ProductModel {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String categoryId;
  final String categoryName;
  final String imageUrl;
  final String? barcode;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.categoryName,
    this.imageUrl = '',
    this.barcode,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: '', // Will be loaded separately or from relation
      imageUrl: json['image_url'] ?? '',
      barcode: json['barcode'],
      isArchived: false, // Assume not archived
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }


  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? categoryId,
    String? categoryName,
    String? imageUrl,
    String? barcode,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}