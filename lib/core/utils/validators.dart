/// Input validators for FAH Retail App
class Validators {
  Validators._();

  /// Validate phone number (Indian format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any spaces or dashes
    final phone = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Check if it's a valid Indian phone number
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validate address
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 10) {
      return 'Please enter a complete address';
    }

    if (value.length > 200) {
      return 'Address must be less than 200 characters';
    }

    return null;
  }

  /// Validate city
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }

    if (value.length < 2) {
      return 'Enter a valid city name';
    }

    return null;
  }

  /// Validate state
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }

    if (value.length < 2) {
      return 'Enter a valid state name';
    }

    return null;
  }

  /// Validate pincode (Indian format - 6 digits)
  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }

    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value)) {
      return 'Enter a valid 6-digit pincode';
    }

    return null;
  }

  /// Validate OTP
  static String? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != length) {
      return 'Enter a valid $length-digit OTP';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate price
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Enter a valid price';
    }

    if (price < 0) {
      return 'Price cannot be negative';
    }

    if (price > 1000000) {
      return 'Price is too high';
    }

    return null;
  }

  /// Validate quantity
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }

    final qty = int.tryParse(value);
    if (qty == null) {
      return 'Enter a valid quantity';
    }

    if (qty < 0) {
      return 'Quantity cannot be negative';
    }

    if (qty > 10000) {
      return 'Quantity is too high';
    }

    return null;
  }

  /// Validate product description
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    if (value.length < 20) {
      return 'Description must be at least 20 characters';
    }

    if (value.length > 1000) {
      return 'Description must be less than 1000 characters';
    }

    return null;
  }
}
