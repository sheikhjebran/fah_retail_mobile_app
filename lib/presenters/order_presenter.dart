import '../models/order_model.dart';
import '../models/address_model.dart';
import '../services/order_service.dart';
import '../services/address_service.dart';
import '../services/payment_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// View contract for order list screen
abstract class OrderListView {
  void showLoading();
  void hideLoading();
  void showOrders(List<OrderModel> orders, bool hasMore);
  void showLoadMoreLoading();
  void showError(String message);
  void showEmptyState();
}

/// View contract for order detail screen
abstract class OrderDetailView {
  void showLoading();
  void hideLoading();
  void showOrder(OrderModel order);
  void showStatusHistory(List<OrderStatusHistoryModel> history);
  void showOrderCancelled();
  void showError(String message);
}

/// View contract for checkout screen
abstract class CheckoutView {
  void showLoading();
  void hideLoading();
  void showAddresses(List<AddressModel> addresses);
  void showPaymentMethods(List<PaymentMethod> methods);
  void showPaymentProcessing();
  void showOrderPlaced(OrderModel order);
  void showPaymentFailed(String message);
  void showError(String message);
}

/// Order presenter for managing order operations
class OrderPresenter {
  final OrderService _orderService;
  final AddressService _addressService;
  final PaymentService _paymentService;

  OrderListView? _listView;
  OrderDetailView? _detailView;
  CheckoutView? _checkoutView;

  List<OrderModel> _orders = [];
  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  String? _selectedPaymentMethod;

  int _currentPage = 1;
  bool _hasMoreOrders = true;
  bool _isLoading = false;

  String? _pendingRazorpayOrderId;

  OrderPresenter({
    OrderService? orderService,
    AddressService? addressService,
    PaymentService? paymentService,
  }) : _orderService = orderService ?? OrderService(),
       _addressService = addressService ?? AddressService(),
       _paymentService = paymentService ?? PaymentService();

  /// Attach list view
  void attachListView(OrderListView view) {
    _listView = view;
  }

  /// Attach detail view
  void attachDetailView(OrderDetailView view) {
    _detailView = view;
  }

  /// Attach checkout view
  void attachCheckoutView(CheckoutView view) {
    _checkoutView = view;
  }

  /// Detach views
  void detach() {
    _listView = null;
    _detailView = null;
    _checkoutView = null;
    _paymentService.dispose();
  }

  /// Get current orders
  List<OrderModel> get orders => _orders;

  /// Get addresses
  List<AddressModel> get addresses => _addresses;

  /// Get selected address
  AddressModel? get selectedAddress => _selectedAddress;

  /// Get selected payment method
  String? get selectedPaymentMethod => _selectedPaymentMethod;

  /// Load orders
  Future<void> loadOrders({bool refresh = false, String? status}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (refresh) {
      _currentPage = 1;
      _orders = [];
      _hasMoreOrders = true;
    }

    _listView?.showLoading();

    try {
      final response = await _orderService.getOrders(
        page: _currentPage,
        status: status,
      );

      _orders = response.items;
      _hasMoreOrders = response.hasNextPage;
      _currentPage++;

      _listView?.hideLoading();

      if (_orders.isEmpty) {
        _listView?.showEmptyState();
      } else {
        _listView?.showOrders(_orders, _hasMoreOrders);
      }
    } catch (e) {
      _listView?.hideLoading();
      _listView?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Load more orders
  Future<void> loadMoreOrders() async {
    if (_isLoading || !_hasMoreOrders) return;
    _isLoading = true;

    _listView?.showLoadMoreLoading();

    try {
      final response = await _orderService.getOrders(page: _currentPage);

      _orders.addAll(response.items);
      _hasMoreOrders = response.hasNextPage;
      _currentPage++;

      _listView?.showOrders(_orders, _hasMoreOrders);
    } catch (e) {
      _listView?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Load order detail
  Future<void> loadOrderDetail(int orderId) async {
    _detailView?.showLoading();

    try {
      final order = await _orderService.getOrderById(orderId);
      _detailView?.hideLoading();
      _detailView?.showOrder(order);

      // Load status history
      if (order.statusHistory != null) {
        _detailView?.showStatusHistory(order.statusHistory!);
      }
    } catch (e) {
      _detailView?.hideLoading();
      _detailView?.showError(e.toString());
    }
  }

  /// Cancel order
  Future<void> cancelOrder(int orderId) async {
    _detailView?.showLoading();

    try {
      await _orderService.cancelOrder(orderId);
      _detailView?.hideLoading();
      _detailView?.showOrderCancelled();

      // Refresh order detail
      await loadOrderDetail(orderId);
    } catch (e) {
      _detailView?.hideLoading();
      _detailView?.showError(e.toString());
    }
  }

  /// Initialize checkout
  Future<void> initCheckout() async {
    _checkoutView?.showLoading();

    try {
      // Load addresses
      _addresses = await _addressService.getAddresses();

      // Set default address
      _selectedAddress = _addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse:
            () =>
                _addresses.isNotEmpty
                    ? _addresses.first
                    : throw Exception('No addresses'),
      );

      _checkoutView?.hideLoading();
      _checkoutView?.showAddresses(_addresses);
      _checkoutView?.showPaymentMethods(
        PaymentService.getSupportedPaymentMethods(),
      );

      // Initialize Razorpay
      _paymentService.initRazorpay(
        onSuccess: _onPaymentSuccess,
        onFailure: _onPaymentFailure,
        onExternalWallet: _onExternalWallet,
      );
    } catch (e) {
      _checkoutView?.hideLoading();
      _checkoutView?.showError(e.toString());
    }
  }

  /// Select address
  void selectAddress(AddressModel address) {
    _selectedAddress = address;
  }

  /// Select payment method
  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
  }

  /// Place order
  Future<void> placeOrder({
    required double amount,
    required String email,
    required String phone,
    required String name,
  }) async {
    if (_selectedAddress == null) {
      _checkoutView?.showError('Please select a delivery address');
      return;
    }

    if (_selectedPaymentMethod == null) {
      _checkoutView?.showError('Please select a payment method');
      return;
    }

    _checkoutView?.showPaymentProcessing();

    try {
      // Create payment order
      final paymentOrder = await _paymentService.createPaymentOrder(
        amount: amount,
        currency: 'INR',
      );

      _pendingRazorpayOrderId = paymentOrder.orderId;

      // Open Razorpay payment sheet
      _paymentService.openPaymentSheet(
        orderId: paymentOrder.orderId,
        amount: paymentOrder.amount,
        name: 'FAH Retail',
        description: 'Order Payment',
        email: email,
        phone: phone,
        prefillName: name,
      );
    } catch (e) {
      _checkoutView?.showPaymentFailed(e.toString());
    }
  }

  /// Handle payment success
  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Verify payment
      final verification = await _paymentService.verifyPayment(
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      );

      if (verification.verified) {
        // Place order
        final request = PlaceOrderRequest(
          addressId: _selectedAddress!.id,
          paymentMethod: _selectedPaymentMethod!,
          razorpayOrderId: response.orderId,
          razorpayPaymentId: response.paymentId,
          razorpaySignature: response.signature,
        );

        final order = await _orderService.placeOrder(request);
        _checkoutView?.showOrderPlaced(order);
      } else {
        _checkoutView?.showPaymentFailed('Payment verification failed');
      }
    } catch (e) {
      _checkoutView?.showPaymentFailed(e.toString());
    }
  }

  /// Handle payment failure
  void _onPaymentFailure(PaymentFailureResponse response) {
    _checkoutView?.showPaymentFailed(response.message ?? 'Payment failed');
  }

  /// Handle external wallet
  void _onExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
  }

  /// Add new address
  Future<void> addAddress(CreateAddressRequest request) async {
    _checkoutView?.showLoading();

    try {
      final address = await _addressService.addAddress(request);
      _addresses.add(address);
      _selectedAddress = address;

      _checkoutView?.hideLoading();
      _checkoutView?.showAddresses(_addresses);
    } catch (e) {
      _checkoutView?.hideLoading();
      _checkoutView?.showError(e.toString());
    }
  }
}
