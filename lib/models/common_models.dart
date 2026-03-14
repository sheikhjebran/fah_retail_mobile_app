import 'package:equatable/equatable.dart';

/// Banner model for home screen slider
class BannerModel extends Equatable {
  final int id;
  final String imageUrl;
  final String? title;
  final String? link;
  final int order;
  final bool isActive;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.link,
    this.order = 0,
    this.isActive = true,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      title: json['title'] as String?,
      link: json['link'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'link': link,
      'order': order,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, imageUrl, title, link, order, isActive];
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

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      todaySales: (json['today_sales'] as num).toDouble(),
      totalOrders: json['total_orders'] as int,
      pendingOrders: json['pending_orders'] as int,
      deliveredOrders: json['delivered_orders'] as int,
      cancelledOrders: json['cancelled_orders'] as int,
      totalProducts: json['total_products'] as int,
      lowStockProducts: json['low_stock_products'] as int,
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
