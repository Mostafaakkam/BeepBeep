import 'product_image_model.dart';
import 'product_variant_model.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final int storeId;
  final String storeName;
  final String? storeLogo;
  final String? storeAddress;
  final int? categoryId;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double averageRating;
  final int reviewCount;
  // Store Owner Dashboard: only present on the owner's own product list
  // (GET /api/stores/:storeId/products -- see
  // productRepository.findByStoreIdForOwner) which deliberately includes
  // deactivated products so an owner can still see/reactivate them. The
  // public product endpoints (findAll/findById) already filter is_active = 1
  // server-side and never send this field, so it defaults to true there --
  // every existing customer-facing call site that never reads it is
  // unaffected.
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.storeId,
    required this.storeName,
    this.storeLogo,
    this.storeAddress,
    this.categoryId,
    required this.images,
    required this.variants,
    required this.createdAt,
    required this.updatedAt,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List<dynamic>? ?? [];
    final variantsList = json['variants'] as List<dynamic>? ?? [];

    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      storeId: json['store_id'] as int,
      storeName: json['store_name'] as String,
      storeLogo: json['store_logo'] as String?,
      storeAddress: json['store_address'] as String?,
      categoryId: json['category_id'] as int?,
      images: imagesList.map((img) => ProductImage.fromJson(img as Map<String, dynamic>)).toList(),
      variants: variantsList.map((variant) => ProductVariant.fromJson(variant as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == null ? true : json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'store_id': storeId,
      'store_name': storeName,
      'store_logo': storeLogo,
      'store_address': storeAddress,
      'category_id': categoryId,
      'images': images.map((img) => img.toJson()).toList(),
      'variants': variants.map((variant) => variant.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'average_rating': averageRating,
      'review_count': reviewCount,
      'is_active': isActive,
    };
  }

  // Get the lowest price from variants, or 0 if no variants
  double get lowestPrice {
    if (variants.isEmpty) return 0.0;
    return variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  // Get the highest price from variants, or 0 if no variants
  double get highestPrice {
    if (variants.isEmpty) return 0.0;
    return variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  // Check if product has price range
  bool get hasPriceRange => lowestPrice != highestPrice;
}
