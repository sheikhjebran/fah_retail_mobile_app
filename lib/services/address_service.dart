import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../models/address_model.dart';

/// Address service for FAH Retail App
class AddressService {
  final ApiClient _apiClient;

  AddressService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  /// Get all user addresses
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.addresses);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data is List ? data : (data['items'] ?? []);
        return items
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Failed to load addresses');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load addresses: $e');
    }
  }

  /// Get address by ID
  Future<AddressModel> getAddressById(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.addressById(id));

      if (response.statusCode == 200) {
        return AddressModel.fromJson(response.data);
      }

      throw ApiException('Address not found');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load address: $e');
    }
  }

  /// Add new address
  Future<AddressModel> addAddress(CreateAddressRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.addresses,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddressModel.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Failed to add address');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to add address: $e');
    }
  }

  /// Update address
  Future<AddressModel> updateAddress(
    int id,
    CreateAddressRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.addressById(id),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AddressModel.fromJson(response.data);
      }

      throw ApiException(
        response.data['message'] ?? 'Failed to update address',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update address: $e');
    }
  }

  /// Delete address
  Future<void> deleteAddress(int id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.addressById(id));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          response.data['message'] ?? 'Failed to delete address',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete address: $e');
    }
  }

  /// Set address as default
  Future<AddressModel> setDefaultAddress(int id) async {
    try {
      final response = await _apiClient.put(ApiEndpoints.setDefaultAddress(id));

      if (response.statusCode == 200) {
        return AddressModel.fromJson(response.data);
      }

      throw ApiException(
        response.data['message'] ?? 'Failed to set default address',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to set default address: $e');
    }
  }

  /// Get default address
  Future<AddressModel?> getDefaultAddress() async {
    try {
      final addresses = await getAddresses();
      return addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse:
            () => addresses.isNotEmpty ? addresses.first : throw Exception(),
      );
    } catch (e) {
      return null;
    }
  }
}
