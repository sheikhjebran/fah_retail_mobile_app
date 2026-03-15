import 'package:equatable/equatable.dart';

/// Category model for FAH Retail App
class CategoryModel extends Equatable {
  final int id;
  final String name;
  final int? parentId;
  final String? image;
  final List<CategoryModel>? subcategories;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.image,
    this.subcategories,
  });

  /// Check if this is a parent category
  bool get isParent => parentId == null;

  /// Check if this category has subcategories
  bool get hasSubcategories =>
      subcategories != null && subcategories!.isNotEmpty;

  /// Create CategoryModel from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse int from int or String
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return CategoryModel(
      id: parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      parentId: parseInt(json['parent_id']),
      image: (json['image_url'] ?? json['image'])?.toString(),
      subcategories:
          json['subcategories'] != null
              ? (json['subcategories'] as List)
                  .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  /// Convert CategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'image': image,
      'subcategories': subcategories?.map((e) => e.toJson()).toList(),
    };
  }

  /// Create a copy with updated values
  CategoryModel copyWith({
    int? id,
    String? name,
    int? parentId,
    String? image,
    List<CategoryModel>? subcategories,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      image: image ?? this.image,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  @override
  List<Object?> get props => [id, name, parentId, image, subcategories];
}

/// Predefined categories for accessories store
class AppCategories {
  AppCategories._();

  static const List<String> mainCategories = [
    'Hair band',
    'Hair pins',
    'Saree pins',
    'Clips',
    'Necklace',
    'Bracelet',
    'Rings',
    'Watches',
    'Fancy mirror',
    'Earrings',
  ];

  static const List<String> earringSubcategories = [
    'Crystal earrings',
    'Long earrings',
    'Short earrings',
    'Round earrings',
    'Rose gold earrings',
    'Silver plated earrings',
    'Gold plated earrings',
  ];
}
