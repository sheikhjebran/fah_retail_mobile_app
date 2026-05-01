import 'package:equatable/equatable.dart';

/// Banner model for home screen slider
class BannerModel extends Equatable {
  final int id;
  final String imageUrl;
  final String? title;
  final String? description;
  final String? link;
  final String? discountText;
  final int? discountPercent;
  final String? buttonText;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
    this.link,
    this.discountText,
    this.discountPercent,
    this.buttonText,
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      link: json['link'] as String?,
      discountText: json['discount_text'] as String?,
      discountPercent: json['discount_percent'] as int?,
      buttonText: json['button_text'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'description': description,
      'link': link,
      'discount_text': discountText,
      'discount_percent': discountPercent,
      'button_text': buttonText,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  BannerModel copyWith({
    int? id,
    String? imageUrl,
    String? title,
    String? description,
    String? link,
    String? discountText,
    int? discountPercent,
    String? buttonText,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      discountText: discountText ?? this.discountText,
      discountPercent: discountPercent ?? this.discountPercent,
      buttonText: buttonText ?? this.buttonText,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    title,
    description,
    link,
    discountText,
    discountPercent,
    buttonText,
    sortOrder,
    isActive,
  ];
}

/// Admin dashboard stats model
class DashboardStatsModel extends Equatable {
  final double todaySales;
  final int totalOrders;
  final int pendingOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final int totalProducts;
  final int lowStockProducts;
  final List<TopSellingProduct>? topSellingProducts;
  final List<WeeklySalesData>? weeklySales;
  final List<CategorySalesData>? categorySales;

  const DashboardStatsModel({
    required this.todaySales,
    required this.totalOrders,
    required this.pendingOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalProducts,
    required this.lowStockProducts,
    this.topSellingProducts,
    this.weeklySales,
    this.categorySales,
  });

  /// Convenience getters for admin dashboard
  double get totalRevenue => todaySales;
  int get totalCustomers => totalOrders;
  Map<String, double> get revenueByMonth => {};
  Map<String, int> get ordersByStatus => {
    'pending': pendingOrders,
    'delivered': deliveredOrders,
    'cancelled': cancelledOrders,
  };
  List<dynamic> get recentOrders => [];

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    // Parse orders_by_status map
    final ordersByStatus = json['orders_by_status'] as Map<String, dynamic>?;

    // Helper to safely parse number
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return 0;
    }

    return DashboardStatsModel(
      todaySales: parseDouble(json['today_sales'] ?? json['total_revenue']),
      totalOrders: parseInt(json['total_orders']),
      pendingOrders: parseInt(
        json['pending_orders'] ?? ordersByStatus?['pending'],
      ),
      deliveredOrders: parseInt(
        json['delivered_orders'] ?? ordersByStatus?['delivered'],
      ),
      cancelledOrders: parseInt(
        json['cancelled_orders'] ?? ordersByStatus?['cancelled'],
      ),
      totalProducts: parseInt(json['total_products']),
      lowStockProducts: parseInt(json['low_stock_products']),
      topSellingProducts:
          json['top_selling_products'] != null
              ? (json['top_selling_products'] as List)
                  .map(
                    (e) =>
                        TopSellingProduct.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      weeklySales:
          json['weekly_sales'] != null
              ? (json['weekly_sales'] as List)
                  .map(
                    (e) => WeeklySalesData.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      categorySales:
          json['category_sales'] != null
              ? (json['category_sales'] as List)
                  .map(
                    (e) =>
                        CategorySalesData.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
    );
  }

  @override
  List<Object?> get props => [
    todaySales,
    totalOrders,
    pendingOrders,
    deliveredOrders,
    cancelledOrders,
    totalProducts,
    lowStockProducts,
    topSellingProducts,
    weeklySales,
    categorySales,
  ];
}

/// Top selling product data
class TopSellingProduct extends Equatable {
  final int productId;
  final String productName;
  final String? productImage;
  final int totalSold;
  final double totalRevenue;

  const TopSellingProduct({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.totalSold,
    required this.totalRevenue,
  });

  factory TopSellingProduct.fromJson(Map<String, dynamic> json) {
    return TopSellingProduct(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      totalSold: json['total_sold'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    productImage,
    totalSold,
    totalRevenue,
  ];
}

/// Weekly sales data for chart
class WeeklySalesData extends Equatable {
  final String day;
  final double sales;
  final int orders;

  const WeeklySalesData({
    required this.day,
    required this.sales,
    required this.orders,
  });

  factory WeeklySalesData.fromJson(Map<String, dynamic> json) {
    return WeeklySalesData(
      day: json['day'] as String,
      sales: (json['sales'] as num).toDouble(),
      orders: json['orders'] as int,
    );
  }

  @override
  List<Object?> get props => [day, sales, orders];
}

/// Category sales data for chart
class CategorySalesData extends Equatable {
  final String categoryName;
  final double sales;
  final double percentage;

  const CategorySalesData({
    required this.categoryName,
    required this.sales,
    required this.percentage,
  });

  factory CategorySalesData.fromJson(Map<String, dynamic> json) {
    return CategorySalesData(
      categoryName: json['category_name'] as String,
      sales: (json['sales'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [categoryName, sales, percentage];
}

/// Pagination response wrapper
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      items:
          (json['items'] as List)
              .map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      totalPages: json['total_pages'] as int,
    );
  }
}
