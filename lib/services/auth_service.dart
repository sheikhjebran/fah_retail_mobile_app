import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

/// Authentication service for FAH Retail App
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  /// Send OTP to phone number
  Future<OtpResponse> sendOtp(String phone) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.sendOtp,
        data: {'phone': phone},
      );

      if (response.statusCode == 200) {
        return OtpResponse.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Failed to send OTP');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to send OTP: $e');
    }
  }

  /// Verify OTP
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
    String? sessionId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
          if (sessionId != null) 'session_id': sessionId,
        },
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Invalid OTP');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to verify OTP: $e');
    }
  }

  /// Sign up new user
  Future<AuthResponse> signup({
    required String name,
    required String phone,
    required String email,
    String? address,
    String? city,
    String? pincode,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.signup,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          if (address != null) 'address': address,
          if (city != null) 'city': city,
          if (pincode != null) 'pincode': pincode,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Failed to sign up');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to sign up: $e');
    }
  }

  /// Login with phone and OTP
  Future<AuthResponse> login({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'phone': phone, 'otp': otp},
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Login failed');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login failed: $e');
    }
  }

  /// Get current user profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }

      throw ApiException(response.data['message'] ?? 'Failed to get profile');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get profile: $e');
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? address,
    String? city,
    String? pincode,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
          if (city != null) 'city': city,
          if (pincode != null) 'pincode': pincode,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }

      throw ApiException(
        response.data['message'] ?? 'Failed to update profile',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update profile: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      // Ignore logout errors - user will be logged out locally anyway
    }
  }

  /// Refresh auth token
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return response.data['token'] as String;
      }

      throw UnauthorizedException('Session expired');
    } catch (e) {
      throw UnauthorizedException('Session expired');
    }
  }
}
