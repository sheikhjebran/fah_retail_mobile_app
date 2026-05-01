import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../presenters/admin_presenter.dart';
import '../../widgets/order_status_timeline.dart';

/// Admin order detail screen
class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen>
    implements AdminOrderDetailView {
  final _presenter = AdminPresenter();
  OrderModel? _order;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _presenter.attachOrderDetailView(this);
    _presenter.loadOrderDetail(widget.orderId);
  }

  @override
  void dispose() {
    _presenter.detach();
    super.dispose();
  }

  void _updateOrderStatus() async {
    final status = await showDialog<String>(
      context: context,
      builder: (context) => _StatusUpdateDialog(currentStatus: _order!.status),
    );

    if (status != null && status != _order!.status) {
      await _presenter.updateOrderStatus(widget.orderId, status);
    }
  }

  // AdminOrderDetailView implementation
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void showOrderDetail(OrderModel order) {
    setState(() => _order = order);
  }

  @override
  void showUpdateStatusSuccess() {
    setState(() => _isUpdating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order status updated successfully')),
    );
    _presenter.loadOrderDetail(widget.orderId);
  }

  @override
  void showUpdateStatusLoading() {
    setState(() => _isUpdating = true);
  }

  @override
  void showError(String message) {
    setState(() => _isUpdating = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _order != null ? 'Order #${_order!.orderNumber}' : 'Order Details',
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _order == null
              ? const Center(child: Text('Order not found'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order status card
                    _buildStatusCard(),
                    const SizedBox(height: 16),

                    // Customer details
                    _buildCustomerCard(),
                    const SizedBox(height: 16),

                    // Delivery address
                    if (_order!.address != null) ...[
                      _buildAddressCard(),
                      const SizedBox(height: 16),
                    ],

                    // Order items
                    _buildItemsCard(),
                    const SizedBox(height: 16),

                    // Order timeline
                    if (_order!.statusHistory != null &&
                        _order!.statusHistory!.isNotEmpty) ...[
                      _buildTimelineCard(),
                      const SizedBox(height: 16),
                    ],

                    // Price summary
                    _buildPriceSummary(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      bottomNavigationBar:
          _order != null &&
                  _order!.status != 'delivered' &&
                  _order!.status != 'cancelled'
              ? _buildBottomBar()
              : null,
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(_order!.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(_order!.status).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(_order!.status),
            color: _getStatusColor(_order!.status),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(_order!.status),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getStatusColor(_order!.status),
                  ),
                ),
                if (_order!.createdAt != null)
                  Text(
                    'Placed on ${Formatters.formatDateTime(_order!.createdAt!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  _order!.isPaid
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _order!.isPaid ? 'PAID' : 'PENDING',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _order!.isPaid ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(_order!.address?.fullName ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(_order!.address?.phone ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Text('Email not available'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Address',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(_order!.address!.fullAddress),
          const SizedBox(height: 4),
          Text(
            '${_order!.address!.city}, ${_order!.address!.state} - ${_order!.address!.pincode}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            'Phone: ${_order!.address!.phone}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items (${_order!.items?.length ?? 0})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_order!.items ?? []).map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        item.productImage != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.productImage!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, _, _) => const Icon(
                                      Icons.image,
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            )
                            : const Icon(
                              Icons.image,
                              color: AppColors.textSecondary,
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.quantity} x ${Formatters.formatPriceInt(item.price)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Formatters.formatPriceInt(item.subtotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: OrderStatusTimeline(
        statusHistory: _order!.statusHistory!,
        currentStatus: _order!.status,
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', _order!.subtotal),
          const SizedBox(height: 8),
          _buildPriceRow('Delivery Fee', _order!.deliveryFee),
          if (_order!.discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Discount', -_order!.discount),
          ],
          const Divider(height: 24),
          _buildPriceRow('Total', _order!.totalAmount, isBold: true),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Payment Method',
            0,
            label: _order!.paymentMethod.toUpperCase(),
            isBold: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isBold = false,
    String? label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          label ?? Formatters.formatPriceInt(amount),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: amount < 0 ? AppColors.success : null,
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
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isUpdating ? null : _updateOrderStatus,
          child:
              _isUpdating
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Update Status'),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'order_placed':
        return AppColors.info;
      case 'in_transit':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'order_placed':
        return Icons.check_circle_outline;
      case 'in_transit':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'order_placed':
        return 'Order Placed';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

/// Status update dialog
class _StatusUpdateDialog extends StatefulWidget {
  final String currentStatus;

  const _StatusUpdateDialog({required this.currentStatus});

  @override
  State<_StatusUpdateDialog> createState() => _StatusUpdateDialogState();
}

class _StatusUpdateDialogState extends State<_StatusUpdateDialog> {
  late String _selectedStatus;

  final List<String> _statuses = [
    'pending',
    'order_placed',
    'in_transit',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Order Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            _statuses.map((status) {
              return ListTile(
                title: Text(_getStatusLabel(status)),
                leading: Radio<String>(
                  value: status,
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () {
                  setState(() => _selectedStatus = status);
                },
              );
            }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedStatus),
          child: const Text('Update'),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'order_placed':
        return 'Order Placed';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
