import 'package:equatable/equatable.dart';

/// Address model for FAH Retail App
class AddressModel extends Equatable {
  final int id;
  final int userId;
  final String name;
  final String phone;
  final String? buildingNumber;
  final String address;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final String? alternatePhone;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.buildingNumber,
    required this.address,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    this.alternatePhone,
    this.isDefault = false,
  });

  /// Get formatted address for display
  String get formattedAddress {
    final parts = <String>[];
    if (buildingNumber != null && buildingNumber!.isNotEmpty) {
      parts.add(buildingNumber!);
    }
    parts.add(address);
    if (landmark != null && landmark!.isNotEmpty) {
      parts.add(landmark!);
    }
    parts.add(city);
    parts.add('$state - $pincode');
    return parts.join(', ');
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
      buildingNumber: json['building_number'] as String?,
      address: json['address'] as String,
      landmark: json['landmark'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      alternatePhone: json['alternate_phone'] as String?,
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
      'building_number': buildingNumber,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'alternate_phone': alternatePhone,
      'is_default': isDefault,
    };
  }

  /// Create a copy with updated values
  AddressModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? phone,
    String? buildingNumber,
    String? address,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    String? alternatePhone,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    phone,
    buildingNumber,
    address,
    landmark,
    city,
    state,
    pincode,
    alternatePhone,
    isDefault,
  ];
}

/// Create address request model
class CreateAddressRequest {
  final String name;
  final String phone;
  final String? buildingNumber;
  final String address;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final String? alternatePhone;
  final bool isDefault;

  const CreateAddressRequest({
    required this.name,
    required this.phone,
    this.buildingNumber,
    required this.address,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    this.alternatePhone,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'building_number': buildingNumber,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'alternate_phone': alternatePhone,
      'is_default': isDefault,
    };
  }
}
