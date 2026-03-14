import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/cart_model.dart';
import '../../models/address_model.dart';
import '../../models/order_model.dart';
import '../../presenters/order_presenter.dart';
import '../../services/address_service.dart';
import '../../services/payment_service.dart';
import 'order_confirmation_screen.dart';

/// Checkout screen with address selection and payment
class CheckoutScreen extends StatefulWidget {
  final CartModel cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    implements CheckoutView {
  final _orderPresenter = OrderPresenter();
  final _addressService = AddressService();
  final _paymentService = PaymentService();

  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  bool _isLoadingAddresses = true;
  bool _isPlacingOrder = false;

  // Pricing
  int get _subtotal => widget.cart.totalAmount;
  int get _deliveryFee => _subtotal >= 499 ? 0 : 49;
  int get _total => _subtotal + _deliveryFee;

  @override
  void initState() {
    super.initState();
    _orderPresenter.attachCheckoutView(this);
    _loadAddresses();
    _initPayment();
  }

  @override
  void dispose() {
    _orderPresenter.detach();
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    try {
      _addresses = await _addressService.getAddresses();
      if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => _addresses.first,
        );
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddresses = false);
      }
    }
  }

  void _initPayment() {
    _paymentService.init(
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentFailure,
      onWalletResponse: _onPaymentWallet,
    );
  }

  void _onPaymentSuccess(String paymentId, String orderId, String signature) {
    // Verify payment and complete order
    _completeOrder(paymentId);
  }

  void _onPaymentFailure(int code, String message) {
    setState(() => _isPlacingOrder = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Payment failed: $message')));
  }

  void _onPaymentWallet(Map<dynamic, dynamic> response) {
    // Handle wallet response
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      // Create Razorpay order
      final razorpayOrder = await _paymentService.createPaymentOrder(_total);

      // Open payment gateway
      _paymentService.openPaymentGateway(
        orderId: razorpayOrder['id'],
        amount: _total,
        name: 'FAH Retail',
        description: 'Order payment',
      );
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _completeOrder(String paymentId) async {
    final request = PlaceOrderRequest(
      addressId: _selectedAddress!.id,
      paymentId: paymentId,
      items:
          widget.cart.items
              .map(
                (item) => OrderItemModel(
                  id: '',
                  productId: item.productId,
                  productName: item.productName,
                  productImage: item.productImage,
                  quantity: item.quantity,
                  price: item.price,
                  subtotal: item.subtotal,
                ),
              )
              .toList(),
    );

    await _orderPresenter.placeOrder(request);
  }

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => _AddressBottomSheet(
            addresses: _addresses,
            selectedAddress: _selectedAddress,
            onSelected: (address) {
              setState(() => _selectedAddress = address);
              Navigator.pop(context);
            },
            onAddNew: () {
              Navigator.pop(context);
              // TODO: Navigate to add address screen
            },
          ),
    );
  }

  // CheckoutView implementation
  @override
  void showLoading() {
    setState(() => _isPlacingOrder = true);
  }

  @override
  void hideLoading() {
    setState(() => _isPlacingOrder = false);
  }

  @override
  void showOrderPlaced(OrderModel order) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderConfirmationScreen(order: order)),
    );
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body:
          _isLoadingAddresses
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery address section
                    _buildSectionHeader('Delivery Address'),
                    const SizedBox(height: 12),
                    _buildAddressCard(),

                    const SizedBox(height: 24),

                    // Order items section
                    _buildSectionHeader(
                      'Order Items (${widget.cart.totalItems})',
                    ),
                    const SizedBox(height: 12),
                    _buildOrderItems(),

                    const SizedBox(height: 24),

                    // Price breakdown
                    _buildSectionHeader('Price Details'),
                    const SizedBox(height: 12),
                    _buildPriceBreakdown(),

                    const SizedBox(height: 100), // Space for bottom bar
                  ],
                ),
              ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddressCard() {
    if (_selectedAddress == null) {
      return InkWell(
        onTap: _showAddressBottomSheet,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Add Delivery Address',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: _showAddressBottomSheet,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _selectedAddress!.label,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedAddress!.fullName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedAddress!.fullAddress,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Phone: ${_selectedAddress!.phone}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children:
            widget.cart.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      Formatters.formatPriceInt(item.subtotal),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', _subtotal),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Delivery Fee',
            _deliveryFee,
            note: _deliveryFee == 0 ? 'FREE' : null,
          ),
          const Divider(height: 24),
          _buildPriceRow('Total', _total, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    int amount, {
    bool isBold = false,
    String? note,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
        if (note != null)
          Text(
            note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            Formatters.formatPriceInt(amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  Formatters.formatPriceInt(_total),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                child:
                    _isPlacingOrder
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Address selection bottom sheet
class _AddressBottomSheet extends StatelessWidget {
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final Function(AddressModel) onSelected;
  final VoidCallback onAddNew;

  const _AddressBottomSheet({
    required this.addresses,
    this.selectedAddress,
    required this.onSelected,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Address',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...addresses.map((address) => _buildAddressOption(context, address)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddNew,
              icon: const Icon(Icons.add),
              label: const Text('Add New Address'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressOption(BuildContext context, AddressModel address) {
    final isSelected = selectedAddress?.id == address.id;

    return InkWell(
      onTap: () => onSelected(address),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.fullName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          address.label,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
