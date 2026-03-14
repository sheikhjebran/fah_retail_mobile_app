import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/common_models.dart';

/// Product service for FAH Retail App
class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  /// Get all products with pagination and filters
  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    int pageSize = AppConstants.pageSize,
    ProductFilter? filter,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (filter != null) {
        queryParams.addAll(filter.toQueryParams());
      }

      final response = await _apiClient.get(
        ApiEndpoints.products,
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

  /// Get trending products
  Future<List<ProductModel>> getTrendingProducts({
    int limit = AppConstants.maxTrendingProducts,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.trendingProducts,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        return data
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Failed to load trending products');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load trending products: $e');
    }
  }

  /// Get discounted products
  Future<List<ProductModel>> getDiscountedProducts({
    int limit = AppConstants.maxDiscountedProducts,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.discountedProducts,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        return data
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Failed to load discounted products');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load discounted products: $e');
    }
  }

  /// Get product by ID
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.productById(id));

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      }

      throw ApiException('Product not found');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load product: $e');
    }
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.searchProducts,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        return data
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Failed to search products');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to search products: $e');
    }
  }

  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.categories);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        return data
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Failed to load categories');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load categories: $e');
    }
  }

  /// Get category by ID
  Future<CategoryModel> getCategoryById(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.categoryById(id));

      if (response.statusCode == 200) {
        return CategoryModel.fromJson(response.data);
      }

      throw ApiException('Category not found');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load category: $e');
    }
  }

  /// Get products by category
  Future<PaginatedResponse<ProductModel>> getProductsByCategory(
    int categoryId, {
    int page = 1,
    int pageSize = AppConstants.pageSize,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.products,
        queryParameters: {
          'category_id': categoryId,
          'page': page,
          'page_size': pageSize,
        },
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
}
