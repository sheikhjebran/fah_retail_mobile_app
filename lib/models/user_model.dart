import 'package:equatable/equatable.dart';

/// User model for FAH Retail App
class UserModel extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String? address;
  final String? city;
  final String? pincode;
  final String role;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.address,
    this.city,
    this.pincode,
    this.role = 'user',
    this.createdAt,
  });

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      pincode: json['pincode'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'pincode': pincode,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? pincode,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    address,
    city,
    pincode,
    role,
    createdAt,
  ];
}

/// Auth response model
class AuthResponse {
  final String token;
  final String? refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// OTP response model
class OtpResponse {
  final bool success;
  final String message;
  final String? sessionId;
  final bool isNewUser;

  const OtpResponse({
    required this.success,
    required this.message,
    this.sessionId,
    this.isNewUser = false,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      sessionId: json['session_id'] as String?,
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }
}
