import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';

/// Payment response model
class PaymentOrderResponse {
  final String orderId;
  final int amount;
  final String currency;
  final String? receipt;

  const PaymentOrderResponse({
    required this.orderId,
    required this.amount,
    required this.currency,
    this.receipt,
  });

  factory PaymentOrderResponse.fromJson(Map<String, dynamic> json) {
    return PaymentOrderResponse(
      orderId: json['order_id'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      receipt: json['receipt'] as String?,
    );
  }
}

/// Payment verification response
class PaymentVerificationResponse {
  final bool verified;
  final String? message;

  const PaymentVerificationResponse({required this.verified, this.message});

  factory PaymentVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResponse(
      verified: json['verified'] as bool,
      message: json['message'] as String?,
    );
  }
}

/// Payment service for FAH Retail App
class PaymentService {
  final ApiClient _apiClient;
  late final Razorpay _razorpay;

  // Razorpay key - should be stored securely
  static const String _razorpayKey = 'YOUR_RAZORPAY_KEY';

  PaymentService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance {
    _razorpay = Razorpay();
  }

  /// Initialize Razorpay with callbacks
  void initRazorpay({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onFailure,
    required void Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  /// Dispose Razorpay
  void dispose() {
    _razorpay.clear();
  }

  /// Create payment order on server
  Future<PaymentOrderResponse> createPaymentOrder({
    required double amount,
    required String currency,
    String? receipt,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createPaymentOrder,
        data: {
          'amount': (amount * 100).toInt(), // Convert to paise
          'currency': currency,
          if (receipt != null) 'receipt': receipt,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentOrderResponse.fromJson(response.data);
      }

      throw ApiException(
        response.data['message'] ?? 'Failed to create payment order',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create payment order: $e');
    }
  }

  /// Open Razorpay payment sheet
  void openPaymentSheet({
    required String orderId,
    required int amount, // Amount in paise
    required String name,
    required String description,
    required String email,
    required String phone,
    String? prefillName,
  }) {
    final options = {
      'key': _razorpayKey,
      'amount': amount,
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {
        'contact': phone,
        'email': email,
        if (prefillName != null) 'name': prefillName,
      },
      'theme': {
        'color': '#E91E63', // Primary pink color
      },
      'external': {
        'wallets': ['paytm', 'phonepe', 'amazonpay'],
      },
    };

    _razorpay.open(options);
  }

  /// Verify payment on server
  Future<PaymentVerificationResponse> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyPayment,
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );

      if (response.statusCode == 200) {
        return PaymentVerificationResponse.fromJson(response.data);
      }

      throw ApiException(
        response.data['message'] ?? 'Payment verification failed',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Payment verification failed: $e');
    }
  }

  /// Get payment methods supported
  static List<PaymentMethod> getSupportedPaymentMethods() {
    return [
      const PaymentMethod(
        id: 'upi',
        name: 'UPI',
        description: 'Pay using UPI apps',
        icon: 'assets/icons/upi.png',
      ),
      const PaymentMethod(
        id: 'gpay',
        name: 'Google Pay',
        description: 'Pay using Google Pay',
        icon: 'assets/icons/gpay.png',
      ),
      const PaymentMethod(
        id: 'phonepe',
        name: 'PhonePe',
        description: 'Pay using PhonePe',
        icon: 'assets/icons/phonepe.png',
      ),
      const PaymentMethod(
        id: 'card',
        name: 'Debit/Credit Card',
        description: 'Pay using Card',
        icon: 'assets/icons/card.png',
      ),
      const PaymentMethod(
        id: 'netbanking',
        name: 'Net Banking',
        description: 'Pay using Net Banking',
        icon: 'assets/icons/netbanking.png',
      ),
    ];
  }
}

/// Payment method model
class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String icon;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}
