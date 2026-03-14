import 'package:equatable/equatable.dart';

/// Address model for FAH Retail App
class AddressModel extends Equatable {
  final int id;
  final int userId;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  /// Get formatted address
  String get formattedAddress {
    return '$address, $city, $state - $pincode';
  }

  /// Get short address
  String get shortAddress {
    return '$city, $state - $pincode';
  }

  /// Get full name (convenience getter)
  String get fullName => name;

  /// Get full address (convenience getter)
  String get fullAddress => formattedAddress;

  /// Get label (Home, Work, etc. - defaults to "Address")
  String get label => isDefault ? 'Default' : 'Address';

  /// Create AddressModel from JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  /// Convert AddressModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }

  /// Create a copy with updated values
  AddressModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    phone,
    address,
    city,
    state,
    pincode,
    isDefault,
  ];
}

/// Create address request model
class CreateAddressRequest {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  const CreateAddressRequest({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }
}
