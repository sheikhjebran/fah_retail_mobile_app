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
            'images',
            await MultipartFile.fromFile(
              imagePaths[i],
              filename: 'image_$i.jpg',
            ),
          ),
        );
      }

      if (primaryIndex != null) {
        formData.fields.add(MapEntry('primary_index', primaryIndex.toString()));
      }

      final response = await _apiClient.uploadFile(
        '${ApiEndpoints.adminEditProduct(productId)}/images',
        formData: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data
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
}
