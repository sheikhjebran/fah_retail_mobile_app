/// App-wide constants for FAH Retail App
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FAH Retail';
  static const String appVersion = '1.0.0';

  // Splash Screen
  static const int splashDuration = 2; // seconds

  // Pagination
  static const int pageSize = 20;

  // OTP
  static const int otpLength = 6;
  static const int otpResendTime = 30; // seconds

  // Image Upload
  static const int maxProductImages = 5;
  static const int imageQuality = 80;
  static const double maxImageSize = 5.0; // MB

  // Cart
  static const int maxQuantityPerItem = 10;
  static const int minQuantityPerItem = 1;

  // User Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // Order Statuses
  static const String statusPending = 'pending';
  static const String statusOrderPlaced = 'order_placed';
  static const String statusInTransit = 'in_transit';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  // Payment Statuses
  static const String paymentPending = 'pending';
  static const String paymentPaid = 'paid';
  static const String paymentFailed = 'failed';

  // Payment Methods
  static const String paymentUPI = 'upi';
  static const String paymentCard = 'card';
  static const String paymentNetBanking = 'netbanking';
  static const String paymentWallet = 'wallet';

  // Razorpay
  static const String razorpayKey = 'YOUR_RAZORPAY_KEY'; // Replace with actual key

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String cartBoxKey = 'cart_box';

  // Banner
  static const int maxBannerImages = 4;

  // Dashboard
  static const int maxTrendingProducts = 6;
  static const int maxDiscountedProducts = 6;
}

/// Order status for tracking timeline
class OrderStatusInfo {
  static const Map<String, int> statusOrder = {
    AppConstants.statusPending: 0,
    AppConstants.statusOrderPlaced: 1,
    AppConstants.statusInTransit: 2,
    AppConstants.statusDelivered: 3,
    AppConstants.statusCancelled: -1,
  };

  static const Map<String, String> statusLabels = {
    AppConstants.statusPending: 'Order Pending',
    AppConstants.statusOrderPlaced: 'Order Accepted',
    AppConstants.statusInTransit: 'In Transit',
    AppConstants.statusDelivered: 'Delivered',
    AppConstants.statusCancelled: 'Cancelled',
  };
}
