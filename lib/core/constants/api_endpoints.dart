/// API Endpoints for FAH Retail App
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Change this for production
  // Use your PC's local IP for physical device testing
  static const String baseUrl = 'http://192.168.1.16:8000/api';

  // Authentication
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User Profile
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';

  // Products
  static const String products = '/products';
  static const String trendingProducts = '/products/trending';
  static const String discountedProducts = '/products/discounted';
  static String productById(int id) => '/products/$id';
  static const String searchProducts = '/products/search';

  // Categories
  static const String categories = '/categories';
  static String categoryById(int id) => '/categories/$id';

  // Cart
  static const String cart = '/cart';
  static const String addToCart = '/cart';
  static const String updateCart = '/cart';
  static String removeFromCart(int id) => '/cart/$id';
  static const String clearCart = '/cart/clear';

  // Orders
  static const String orders = '/orders';
  static const String placeOrder = '/orders';
  static String orderById(int id) => '/orders/$id';
  static String orderByNumber(String orderNumber) =>
      '/orders/number/$orderNumber';

  // Addresses
  static const String addresses = '/addresses';
  static String addressById(int id) => '/addresses/$id';
  static String setDefaultAddress(int id) => '/addresses/$id/default';

  // Payment
  static const String createPaymentOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';

  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminAddProduct = '/admin/products';
  static String adminEditProduct(int id) => '/admin/products/$id';
  static String adminDeleteProduct(int id) => '/admin/products/$id';
  static const String adminOrders = '/admin/orders';
  static String adminOrderById(int id) => '/admin/order/$id';
  static String adminUpdateOrderStatus(int id) => '/admin/order/$id/status';

  // Banners
  static const String banners = '/banners';
}
