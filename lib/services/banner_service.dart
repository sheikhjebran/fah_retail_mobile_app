import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../models/common_models.dart';

/// Banner service for home screen
class BannerService {
  final ApiClient _apiClient;

  BannerService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  /// Get active banners
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.banners);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        return data
            .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Failed to load banners');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load banners: $e');
    }
  }
}
