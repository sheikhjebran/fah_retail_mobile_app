import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/order_model.dart';

/// Order status timeline widget showing order progress
class OrderStatusTimeline extends StatelessWidget {
  final List<OrderStatusHistoryModel> statusHistory;
  final String currentStatus;

  const OrderStatusTimeline({
    super.key,
    required this.statusHistory,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = ['pending', 'order_placed', 'in_transit', 'delivered'];
    final currentIndex = statuses.indexOf(currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ...statuses.asMap().entries.map((entry) {
          final index = entry.key;
          final status = entry.value;
          final isCompleted = index <= currentIndex;
          final isCurrent = index == currentIndex;
          final isCancelled = currentStatus == 'cancelled';

          return _TimelineItem(
            status: status,
            isCompleted: isCancelled ? false : isCompleted,
            isCurrent: isCurrent,
            isCancelled: isCancelled && index == currentIndex,
            timestamp: _getTimestampForStatus(status),
          );
        }),
        if (currentStatus == 'cancelled')
          _TimelineItem(
            status: 'cancelled',
            isCompleted: true,
            isCurrent: true,
            isCancelled: true,
            timestamp: _getTimestampForStatus('cancelled'),
          ),
      ],
    );
  }

  DateTime? _getTimestampForStatus(String status) {
    try {
      return statusHistory
          .firstWhere((h) => h.status == status)
          .timestamp;
    } catch (_) {
      return null;
    }
  }
}

class _TimelineItem extends StatelessWidget {
  final String status;
  final bool isCompleted;
  final bool isCurrent;
  final bool isCancelled;
  final DateTime? timestamp;

  const _TimelineItem({
    required this.status,
    required this.isCompleted,
    required this.isCurrent,
    required this.isCancelled,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (isCancelled) return AppColors.error;
      if (isCompleted) return AppColors.success;
      if (isCurrent) return AppColors.primary;
      return AppColors.textSecondary;
    }

    IconData getIcon() {
      switch (status) {
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

    String getLabel() {
      switch (status) {
        case 'pending':
          return 'Order Pending';
        case 'order_placed':
          return 'Order Accepted';
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

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: getColor().withValues(alpha: isCompleted || isCurrent ? 1 : 0.3),
          ),
          child: Icon(
            getIcon(),
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getLabel(),
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted || isCurrent
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              if (timestamp != null)
                Text(
                  _formatDateTime(timestamp!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
