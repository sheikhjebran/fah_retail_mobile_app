import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/common_models.dart';

/// Admin service for FAH Retail App
class AdminService {
  final ApiClient _apiClient;

  AdminService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  // ==================== Dashboard ====================

  /// Get admin dashboard stats
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.adminDashboard);

      if (response.statusCode == 200) {
        return DashboardStatsModel.fromJson(response.data);
      }

      throw ApiException('Failed to load dashboard');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load dashboard: $e');
    }
  }

  // ==================== Product Management ====================

  /// Get all products for admin
  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    int pageSize = AppConstants.pageSize,
    int? categoryId,
    String? search,
    bool? lowStock,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null) queryParams['search'] = search;
      if (lowStock != null) queryParams['low_stock'] = lowStock;

      final response = await _apiClient.get(
        ApiEndpoints.adminProducts,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedResponse.fromJson(response.data, ProductModel.fromJson);
      }

      throw ApiException('Failed to load products');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load products: $e');
    }
  }

  /// Add new product
  Future<ProductModel> addProduct({
    required String name,
    required String description,
    required int categoryId,
    required double price,
    double? discountPrice,
    required int qty,
    List<String>? shades,
    bool isTrending = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminAddProduct,
        data: {
          'name': name,
          'description': description,
          'category_id': categoryId,
          'price': price,
          if (discountPrice != null) 'discount_price': discountPrice,
          'qty': qty,
          if (shades != null) 'shades': shades,
          'is_trending': isTrending,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductModel.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Failed to add product');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to add product: $e');
    }
  }

  /// Update product
  Future<ProductModel> updateProduct(
    int id, {
    String? name,
    String? description,
    int? categoryId,
    double? price,
    double? discountPrice,
    int? qty,
    List<String>? shades,
    bool? isTrending,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (categoryId != null) data['category_id'] = categoryId;
      if (price != null) data['price'] = price;
      if (discountPrice != null) data['discount_price'] = discountPrice;
      if (qty != null) data['qty'] = qty;
      if (shades != null) data['shades'] = shades;
      if (isTrending != null) data['is_trending'] = isTrending;

      final response = await _apiClient.put(
        ApiEndpoints.adminEditProduct(id),
        data: data,
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      }

      throw ApiException(
        response.data['message'] ?? 'Failed to update product',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update product: $e');
    }
  }

  /// Delete product
  Future<void> deleteProduct(int id) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.adminDeleteProduct(id),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          response.data['message'] ?? 'Failed to delete product',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete product: $e');
    }
  }

  /// Upload product images
  Future<List<ProductImageModel>> uploadProductImages(
    int productId,
    List<String> imagePaths, {
    int? primaryIndex,
  }) async {
    try {
      final formData = FormData();

      for (int i = 0; i < imagePaths.length; i++) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              imagePaths[i],
              filename: 'image_$i.jpg',
            ),
          ),
        );
      }

      final response = await _apiClient.uploadFile(
        '${ApiEndpoints.adminEditProduct(productId)}/upload-images',
        formData: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> images = response.data['images'] ?? [];
        return images
            .map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(response.data['message'] ?? 'Failed to upload images');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to upload images: $e');
    }
  }

  /// Delete product image
  Future<void> deleteProductImage(int productId, int imageId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.adminEditProduct(productId)}/images/$imageId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          response.data['message'] ?? 'Failed to delete image',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete image: $e');
    }
  }

  /// Set primary image
  Future<void> setPrimaryImage(int productId, int imageId) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.adminEditProduct(productId)}/images/$imageId/primary',
      );

      if (response.statusCode != 200) {
        throw ApiException(
          response.data['message'] ?? 'Failed to set primary image',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to set primary image: $e');
    }
  }

  // ==================== Order Management ====================

  /// Get all orders for admin
  Future<PaginatedResponse<OrderModel>> getOrders({
    int page = 1,
    int pageSize = AppConstants.pageSize,
    String? status,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        ApiEndpoints.adminOrders,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedResponse.fromJson(response.data, OrderModel.fromJson);
      }

      throw ApiException('Failed to load orders');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load orders: $e');
    }
  }

  /// Get order by ID
  Future<OrderModel> getOrderById(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.adminOrderById(id));

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      }

      throw ApiException('Order not found');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load order: $e');
    }
  }

  /// Update order status
  Future<OrderModel> updateOrderStatus(
    int orderId,
    UpdateOrderStatusRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.adminUpdateOrderStatus(orderId),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      }

      throw ApiException(
        response.data['message'] ?? 'Failed to update order status',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update order status: $e');
    }
  }

  /// Accept order
  Future<OrderModel> acceptOrder(int orderId) async {
    return updateOrderStatus(
      orderId,
      const UpdateOrderStatusRequest(status: AppConstants.statusOrderPlaced),
    );
  }

  /// Dispatch order
  Future<OrderModel> dispatchOrder(int orderId) async {
    return updateOrderStatus(
      orderId,
      const UpdateOrderStatusRequest(status: AppConstants.statusInTransit),
    );
  }

  /// Mark order as delivered
  Future<OrderModel> markDelivered(int orderId) async {
    return updateOrderStatus(
      orderId,
      const UpdateOrderStatusRequest(status: AppConstants.statusDelivered),
    );
  }

  /// Cancel order
  Future<OrderModel> cancelOrder(int orderId, {String? reason}) async {
    return updateOrderStatus(
      orderId,
      UpdateOrderStatusRequest(
        status: AppConstants.statusCancelled,
        note: reason,
      ),
    );
  }

  // ==================== Banner Management ====================

  /// Get all banners for admin
  Future<List<BannerModel>> getBanners({bool includeInactive = true}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.adminBanners,
        queryParameters: {'include_inactive': includeInactive},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data is List ? data : (data['items'] ?? []);
        return items
            .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Failed to load banners');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load banners: $e');
    }
  }

  /// Get banner by ID
  Future<BannerModel> getBanner(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.adminBannerById(id));

      if (response.statusCode == 200) {
        return BannerModel.fromJson(response.data);
      }

      throw ApiException('Banner not found');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load banner: $e');
    }
  }

  /// Create new banner
  Future<BannerModel> createBanner({
    required String imageUrl,
    String? title,
    String? description,
    String? link,
    String? discountText,
    int? discountPercent,
    String? buttonText,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminBanners,
        data: {
          'image_url': imageUrl,
          'title': title,
          'description': description,
          'link': link,
          'discount_text': discountText,
          'discount_percent': discountPercent,
          'button_text': buttonText ?? 'Shop Now',
          'sort_order': sortOrder,
          'is_active': isActive,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BannerModel.fromJson(response.data);
      }

      throw ApiException('Failed to create banner');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create banner: $e');
    }
  }

  /// Update banner
  Future<BannerModel> updateBanner(
    int id, {
    String? imageUrl,
    String? title,
    String? description,
    String? link,
    String? discountText,
    int? discountPercent,
    String? buttonText,
    int? sortOrder,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (link != null) data['link'] = link;
      if (discountText != null) data['discount_text'] = discountText;
      if (discountPercent != null) data['discount_percent'] = discountPercent;
      if (buttonText != null) data['button_text'] = buttonText;
      if (sortOrder != null) data['sort_order'] = sortOrder;
      if (isActive != null) data['is_active'] = isActive;

      final response = await _apiClient.put(
        ApiEndpoints.adminBannerById(id),
        data: data,
      );

      if (response.statusCode == 200) {
        return BannerModel.fromJson(response.data);
      }

      throw ApiException('Failed to update banner');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update banner: $e');
    }
  }

  /// Delete banner (soft delete)
  Future<void> deleteBanner(int id) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.adminBannerById(id),
      );

      if (response.statusCode == 200) {
        return;
      }

      throw ApiException('Failed to delete banner');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete banner: $e');
    }
  }

  /// Upload banner image
  Future<String> uploadBannerImage(String filePath, {int? bannerId}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final endpoint =
          bannerId != null
              ? ApiEndpoints.adminBannerUploadImage(bannerId)
              : ApiEndpoints.adminBannerUploadNewImage;

      final response = await _apiClient.post(endpoint, data: formData);

      if (response.statusCode == 200) {
        return response.data['image_url'] as String;
      }

      throw ApiException('Failed to upload image');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to upload image: $e');
    }
  }
}
