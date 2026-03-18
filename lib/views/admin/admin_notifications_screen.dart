import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Admin notifications settings screen
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  bool _orderNotifications = true;
  bool _productNotifications = true;
  bool _systemNotifications = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Notifications Section
            _buildSectionHeader('Order & Sales'),
            _buildNotificationTile(
              title: 'New Order Notifications',
              description: 'Get notified when a new order is placed',
              value: _orderNotifications,
              onChanged: (value) {
                setState(() => _orderNotifications = value);
              },
            ),
            const SizedBox(height: 16),

            // Product Notifications Section
            _buildSectionHeader('Product Management'),
            _buildNotificationTile(
              title: 'Low Stock Alerts',
              description: 'Get notified when product stock is low',
              value: _productNotifications,
              onChanged: (value) {
                setState(() => _productNotifications = value);
              },
            ),
            const SizedBox(height: 16),

            // System Notifications Section
            _buildSectionHeader('System & Security'),
            _buildNotificationTile(
              title: 'System Updates',
              description: 'Get notified about important system updates',
              value: _systemNotifications,
              onChanged: (value) {
                setState(() => _systemNotifications = value);
              },
            ),
            const SizedBox(height: 16),

            // Notification Channels Section
            _buildSectionHeader('Notification Channels'),
            _buildNotificationTile(
              title: 'Email Notifications',
              description: 'Receive notifications via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
              },
            ),
            const SizedBox(height: 12),
            _buildNotificationTile(
              title: 'Push Notifications',
              description: 'Receive in-app notifications',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
              },
            ),
            const SizedBox(height: 12),
            _buildNotificationTile(
              title: 'SMS Notifications',
              description: 'Receive notifications via SMS',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() => _smsNotifications = value);
              },
            ),
            const SizedBox(height: 24),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Changes are saved automatically. Critical alerts cannot be disabled.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
