/// API Endpoints for FAH Retail App
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Change this for production
  static const String baseUrl = 'http://localhost:8000/api';

  // Authentication
  static const String sendOtp = '/send-otp';
  static const String verifyOtp = '/verify-otp';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh-token';

  // User Profile
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';

  // Products
  static const String products = '/products';
  static const String trendingProducts = '/products/trending';
  static const String discountedProducts = '/products/discount';
  static String productById(int id) => '/product/$id';
  static const String searchProducts = '/products/search';

  // Categories
  static const String categories = '/categories';
  static String categoryById(int id) => '/category/$id';

  // Cart
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String updateCart = '/cart/update';
  static String removeFromCart(int id) => '/cart/$id';
  static const String clearCart = '/cart/clear';

  // Orders
  static const String orders = '/orders';
  static const String placeOrder = '/order/place';
  static String orderById(int id) => '/order/$id';
  static String orderByNumber(String orderNumber) =>
      '/order/number/$orderNumber';

  // Addresses
  static const String addresses = '/addresses';
  static String addressById(int id) => '/addresses/$id';
  static String setDefaultAddress(int id) => '/addresses/$id/default';

  // Payment
  static const String createPaymentOrder = '/payment/create-order';
  static const String verifyPayment = '/payment/verify';

  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminAddProduct = '/admin/product';
  static String adminEditProduct(int id) => '/admin/product/$id';
  static String adminDeleteProduct(int id) => '/admin/product/$id';
  static const String adminOrders = '/admin/orders';
  static String adminOrderById(int id) => '/admin/order/$id';
  static String adminUpdateOrderStatus(int id) => '/admin/order/$id/status';

  // Banners
  static const String banners = '/banners';
}
