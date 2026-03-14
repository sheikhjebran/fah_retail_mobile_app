import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/common_models.dart';
import '../services/admin_service.dart';
import '../core/constants/app_constants.dart';

/// View contract for admin dashboard
abstract class AdminDashboardView {
  void showLoading();
  void hideLoading();
  void showStats(DashboardStatsModel stats);
  void showError(String message);
}

/// View contract for admin product list
abstract class AdminProductListView {
  void showLoading();
  void hideLoading();
  void showProducts(List<ProductModel> products, bool hasMore);
  void showLoadMoreLoading();
  void showError(String message);
  void showEmptyState();
  void showProductDeleted(int productId);
}

/// View contract for admin product form
abstract class AdminProductFormView {
  void showLoading();
  void hideLoading();
  void showProduct(ProductModel product);
  void showProductSaved(ProductModel product);
  void showImageUploading();
  void showImagesUploaded(List<ProductImageModel> images);
  void showError(String message);
  void showValidationError(String field, String message);
}

/// View contract for admin order list
abstract class AdminOrderListView {
  void showLoading();
  void hideLoading();
  void showOrders(List<OrderModel> orders, bool hasMore);
  void showLoadMoreLoading();
  void showError(String message);
  void showEmptyState();
}

/// View contract for admin order detail
abstract class AdminOrderDetailView {
  void showLoading();
  void hideLoading();
  void showOrder(OrderModel order);
  void showStatusUpdated(OrderModel order);
  void showError(String message);
}

/// Admin presenter for managing admin operations
class AdminPresenter {
  final AdminService _adminService;

  AdminDashboardView? _dashboardView;
  AdminProductListView? _productListView;
  AdminProductFormView? _productFormView;
  AdminOrderListView? _orderListView;
  AdminOrderDetailView? _orderDetailView;

  DashboardStatsModel? _stats;
  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];

  int _productPage = 1;
  int _orderPage = 1;
  bool _hasMoreProducts = true;
  bool _hasMoreOrders = true;
  bool _isLoading = false;

  AdminPresenter({AdminService? adminService})
    : _adminService = adminService ?? AdminService();

  /// Attach dashboard view
  void attachDashboardView(AdminDashboardView view) {
    _dashboardView = view;
  }

  /// Attach product list view
  void attachProductListView(AdminProductListView view) {
    _productListView = view;
  }

  /// Attach product form view
  void attachProductFormView(AdminProductFormView view) {
    _productFormView = view;
  }

  /// Attach order list view
  void attachOrderListView(AdminOrderListView view) {
    _orderListView = view;
  }

  /// Attach order detail view
  void attachOrderDetailView(AdminOrderDetailView view) {
    _orderDetailView = view;
  }

  /// Detach views
  void detach() {
    _dashboardView = null;
    _productListView = null;
    _productFormView = null;
    _orderListView = null;
    _orderDetailView = null;
  }

  // ==================== Dashboard ====================

  /// Load dashboard stats
  Future<void> loadDashboard() async {
    _dashboardView?.showLoading();

    try {
      _stats = await _adminService.getDashboardStats();
      _dashboardView?.hideLoading();
      _dashboardView?.showStats(_stats!);
    } catch (e) {
      _dashboardView?.hideLoading();
      _dashboardView?.showError(e.toString());
    }
  }

  /// Get dashboard stats
  DashboardStatsModel? get stats => _stats;

  // ==================== Product Management ====================

  /// Load products
  Future<void> loadProducts({
    bool refresh = false,
    int? categoryId,
    String? search,
    bool? lowStock,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    if (refresh) {
      _productPage = 1;
      _products = [];
      _hasMoreProducts = true;
    }

    _productListView?.showLoading();

    try {
      final response = await _adminService.getProducts(
        page: _productPage,
        categoryId: categoryId,
        search: search,
        lowStock: lowStock,
      );

      _products = response.items;
      _hasMoreProducts = response.hasNextPage;
      _productPage++;

      _productListView?.hideLoading();

      if (_products.isEmpty) {
        _productListView?.showEmptyState();
      } else {
        _productListView?.showProducts(_products, _hasMoreProducts);
      }
    } catch (e) {
      _productListView?.hideLoading();
      _productListView?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Load more products
  Future<void> loadMoreProducts() async {
    if (_isLoading || !_hasMoreProducts) return;
    _isLoading = true;

    _productListView?.showLoadMoreLoading();

    try {
      final response = await _adminService.getProducts(page: _productPage);

      _products.addAll(response.items);
      _hasMoreProducts = response.hasNextPage;
      _productPage++;

      _productListView?.showProducts(_products, _hasMoreProducts);
    } catch (e) {
      _productListView?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Add product
  Future<void> addProduct({
    required String name,
    required String description,
    required int categoryId,
    required double price,
    double? discountPrice,
    required int qty,
    List<String>? shades,
    bool isTrending = false,
  }) async {
    _productFormView?.showLoading();

    try {
      final product = await _adminService.addProduct(
        name: name,
        description: description,
        categoryId: categoryId,
        price: price,
        discountPrice: discountPrice,
        qty: qty,
        shades: shades,
        isTrending: isTrending,
      );

      _productFormView?.hideLoading();
      _productFormView?.showProductSaved(product);
    } catch (e) {
      _productFormView?.hideLoading();
      _productFormView?.showError(e.toString());
    }
  }

  /// Update product
  Future<void> updateProduct(
    int id, {
    String? name,
    String? description,
    int? categoryId,
    double? price,
    double? discountPrice,
    int? qty,
    List<String>? shades,
    bool? isTrending,
  }) async {
    _productFormView?.showLoading();

    try {
      final product = await _adminService.updateProduct(
        id,
        name: name,
        description: description,
        categoryId: categoryId,
        price: price,
        discountPrice: discountPrice,
        qty: qty,
        shades: shades,
        isTrending: isTrending,
      );

      _productFormView?.hideLoading();
      _productFormView?.showProductSaved(product);
    } catch (e) {
      _productFormView?.hideLoading();
      _productFormView?.showError(e.toString());
    }
  }

  /// Delete product
  Future<void> deleteProduct(int id) async {
    _productListView?.showLoading();

    try {
      await _adminService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _productListView?.hideLoading();
      _productListView?.showProductDeleted(id);
      _productListView?.showProducts(_products, _hasMoreProducts);
    } catch (e) {
      _productListView?.hideLoading();
      _productListView?.showError(e.toString());
    }
  }

  /// Upload product images
  Future<void> uploadProductImages(
    int productId,
    List<String> imagePaths, {
    int? primaryIndex,
  }) async {
    _productFormView?.showImageUploading();

    try {
      final images = await _adminService.uploadProductImages(
        productId,
        imagePaths,
        primaryIndex: primaryIndex,
      );

      _productFormView?.showImagesUploaded(images);
    } catch (e) {
      _productFormView?.showError(e.toString());
    }
  }

  /// Set trending status
  Future<void> setTrendingStatus(int productId, bool isTrending) async {
    try {
      await _adminService.updateProduct(productId, isTrending: isTrending);

      // Update local list
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(isTrending: isTrending);
        _productListView?.showProducts(_products, _hasMoreProducts);
      }
    } catch (e) {
      _productListView?.showError(e.toString());
    }
  }

  // ==================== Order Management ====================

  /// Load orders
  Future<void> loadOrders({
    bool refresh = false,
    String? status,
    String? search,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    if (refresh) {
      _orderPage = 1;
      _orders = [];
      _hasMoreOrders = true;
    }

    _orderListView?.showLoading();

    try {
      final response = await _adminService.getOrders(
        page: _orderPage,
        status: status,
        search: search,
      );

      _orders = response.items;
      _hasMoreOrders = response.hasNextPage;
      _orderPage++;

      _orderListView?.hideLoading();

      if (_orders.isEmpty) {
        _orderListView?.showEmptyState();
      } else {
        _orderListView?.showOrders(_orders, _hasMoreOrders);
      }
    } catch (e) {
      _orderListView?.hideLoading();
      _orderListView?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Load more orders
  Future<void> loadMoreOrders() async {
    if (_isLoading || !_hasMoreOrders) return;
    _isLoading = true;

    _orderListView?.showLoadMoreLoading();

    try {
      final response = await _adminService.getOrders(page: _orderPage);

      _orders.addAll(response.items);
      _hasMoreOrders = response.hasNextPage;
      _orderPage++;

      _orderListView?.showOrders(_orders, _hasMoreOrders);
    } catch (e) {
      _orderListView?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Load order detail
  Future<void> loadOrderDetail(int orderId) async {
    _orderDetailView?.showLoading();

    try {
      final order = await _adminService.getOrderById(orderId);
      _orderDetailView?.hideLoading();
      _orderDetailView?.showOrder(order);
    } catch (e) {
      _orderDetailView?.hideLoading();
      _orderDetailView?.showError(e.toString());
    }
  }

  /// Accept order
  Future<void> acceptOrder(int orderId) async {
    _orderDetailView?.showLoading();

    try {
      final order = await _adminService.acceptOrder(orderId);
      _orderDetailView?.hideLoading();
      _orderDetailView?.showStatusUpdated(order);
    } catch (e) {
      _orderDetailView?.hideLoading();
      _orderDetailView?.showError(e.toString());
    }
  }

  /// Dispatch order
  Future<void> dispatchOrder(int orderId) async {
    _orderDetailView?.showLoading();

    try {
      final order = await _adminService.dispatchOrder(orderId);
      _orderDetailView?.hideLoading();
      _orderDetailView?.showStatusUpdated(order);
    } catch (e) {
      _orderDetailView?.hideLoading();
      _orderDetailView?.showError(e.toString());
    }
  }

  /// Mark as delivered
  Future<void> markDelivered(int orderId) async {
    _orderDetailView?.showLoading();

    try {
      final order = await _adminService.markDelivered(orderId);
      _orderDetailView?.hideLoading();
      _orderDetailView?.showStatusUpdated(order);
    } catch (e) {
      _orderDetailView?.hideLoading();
      _orderDetailView?.showError(e.toString());
    }
  }

  /// Cancel order
  Future<void> cancelOrder(int orderId, {String? reason}) async {
    _orderDetailView?.showLoading();

    try {
      final order = await _adminService.cancelOrder(orderId, reason: reason);
      _orderDetailView?.hideLoading();
      _orderDetailView?.showStatusUpdated(order);
    } catch (e) {
      _orderDetailView?.hideLoading();
      _orderDetailView?.showError(e.toString());
    }
  }
}
