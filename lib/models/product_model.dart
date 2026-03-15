import 'package:equatable/equatable.dart';
import 'category_model.dart';

/// Product model for FAH Retail App
class ProductModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final double price;
  final double? discountPrice;
  final int qty;
  final List<String>? shades;
  final String? primaryImage;
  final List<ProductImageModel>? images;
  final bool isTrending;
  final CategoryModel? category;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    this.discountPrice,
    required this.qty,
    this.shades,
    this.primaryImage,
    this.images,
    this.isTrending = false,
    this.category,
    this.createdAt,
  });

  /// Check if product has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// Get discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price * 100);
  }

  /// Get display price (discounted or original)
  double get displayPrice => discountPrice ?? price;

  /// Check if product is in stock
  bool get inStock => qty > 0;

  /// Get stock count (alias for qty)
  int get stock => qty;

  /// Get category name (convenience getter)
  String? get categoryName => category?.name;

  /// Get display image (fallback to first image from images array if primary is null)
  String? get displayImage {
    if (primaryImage != null) return primaryImage;
    if (images != null && images!.isNotEmpty) {
      // Find primary image first
      final primary = images!.where((img) => img.isPrimary).firstOrNull;
      if (primary != null) return primary.imageUrl;
      // Otherwise return first image
      return images!.first.imageUrl;
    }
    return null;
  }

  /// Check if product has multiple images
  bool get hasMultipleImages => images != null && images!.length > 1;

  /// Get all image URLs
  List<String> get allImageUrls {
    if (images == null || images!.isEmpty) {
      return primaryImage != null ? [primaryImage!] : [];
    }
    return images!.map((img) => img.imageUrl).toList();
  }

  /// Create ProductModel from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      categoryId: json['category_id'] as int,
      price: (json['price'] as num).toDouble(),
      discountPrice:
          json['discount_price'] != null
              ? (json['discount_price'] as num).toDouble()
              : null,
      qty: json['qty'] as int,
      shades:
          json['shades'] != null
              ? List<String>.from(json['shades'] as List)
              : null,
      primaryImage: json['primary_image'] as String?,
      images:
          json['images'] != null
              ? (json['images'] as List)
                  .map(
                    (e) =>
                        ProductImageModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      isTrending: json['is_trending'] as bool? ?? false,
      category:
          json['category'] != null
              ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  /// Convert ProductModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'price': price,
      'discount_price': discountPrice,
      'qty': qty,
      'shades': shades,
      'primary_image': primaryImage,
      'images': images?.map((e) => e.toJson()).toList(),
      'is_trending': isTrending,
      'category': category?.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    int? categoryId,
    double? price,
    double? discountPrice,
    int? qty,
    List<String>? shades,
    String? primaryImage,
    List<ProductImageModel>? images,
    bool? isTrending,
    CategoryModel? category,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      qty: qty ?? this.qty,
      shades: shades ?? this.shades,
      primaryImage: primaryImage ?? this.primaryImage,
      images: images ?? this.images,
      isTrending: isTrending ?? this.isTrending,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    categoryId,
    price,
    discountPrice,
    qty,
    shades,
    primaryImage,
    images,
    isTrending,
    category,
    createdAt,
  ];
}

/// Product image model
class ProductImageModel extends Equatable {
  final int id;
  final int? productId;
  final String imageUrl;
  final bool isPrimary;

  const ProductImageModel({
    required this.id,
    this.productId,
    required this.imageUrl,
    this.isPrimary = false,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as int,
      productId: json['product_id'] as int?,
      imageUrl: json['image_url'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (productId != null) 'product_id': productId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
    };
  }

  @override
  List<Object?> get props => [id, productId, imageUrl, isPrimary];
}

/// Product filter model
class ProductFilter {
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String? searchQuery;
  final ProductSortOption sortOption;
  final bool? isTrending;
  final bool? hasDiscount;

  const ProductFilter({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
    this.sortOption = ProductSortOption.newest,
    this.isTrending,
    this.hasDiscount,
  });

  ProductFilter copyWith({
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    ProductSortOption? sortOption,
    bool? isTrending,
    bool? hasDiscount,
  }) {
    return ProductFilter(
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      isTrending: isTrending ?? this.isTrending,
      hasDiscount: hasDiscount ?? this.hasDiscount,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (categoryId != null) params['category_id'] = categoryId;
    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }
    params['sort'] = sortOption.value;
    if (isTrending != null) params['is_trending'] = isTrending;
    if (hasDiscount != null) params['has_discount'] = hasDiscount;
    return params;
  }
}

/// Product sort options
enum ProductSortOption {
  newest('newest', 'Newest'),
  priceLowToHigh('price_asc', 'Price: Low to High'),
  priceHighToLow('price_desc', 'Price: High to Low'),
  popular('popular', 'Popular');

  final String value;
  final String label;

  const ProductSortOption(this.value, this.label);
}
