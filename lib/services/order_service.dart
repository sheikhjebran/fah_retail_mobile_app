import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../models/order_model.dart';
import '../models/common_models.dart';

/// Order service for FAH Retail App
class OrderService {
  final ApiClient _apiClient;

  OrderService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  /// Place a new order
  Future<OrderModel> placeOrder(PlaceOrderRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.placeOrder,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrderModel.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Failed to place order');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to place order: $e');
    }
  }

  /// Get user's orders with pagination
  Future<PaginatedResponse<OrderModel>> getOrders({
    int page = 1,
    int pageSize = AppConstants.pageSize,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        ApiEndpoints.orders,
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
      final response = await _apiClient.get(ApiEndpoints.orderById(id));

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      }

      throw ApiException('Order not found');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load order: $e');
    }
  }

  /// Get order by order number
  Future<OrderModel> getOrderByNumber(String orderNumber) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.orderByNumber(orderNumber),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      }

      throw ApiException('Order not found');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load order: $e');
    }
  }

  /// Cancel order
  Future<OrderModel> cancelOrder(int orderId) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.orderById(orderId)}/cancel',
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Failed to cancel order');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to cancel order: $e');
    }
  }

  /// Get order status history
  Future<List<OrderStatusHistoryModel>> getOrderStatusHistory(
    int orderId,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.orderById(orderId)}/status-history',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map(
              (e) =>
                  OrderStatusHistoryModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }

      throw ApiException('Failed to load status history');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load status history: $e');
    }
  }
}
