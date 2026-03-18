import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Admin help center screen
class AdminHelpCenterScreen extends StatefulWidget {
  const AdminHelpCenterScreen({super.key});

  @override
  State<AdminHelpCenterScreen> createState() => _AdminHelpCenterScreenState();
}

class _AdminHelpCenterScreenState extends State<AdminHelpCenterScreen> {
  final _searchController = TextEditingController();
  List<HelpItem> _filteredItems = [];

  final List<HelpItem> _helpItems = [
    HelpItem(
      category: 'Store Management',
      title: 'How to add new products?',
      content:
          'Navigate to Products > Add New Product. Fill in the product details, upload images, set prices and click Save.',
    ),
    HelpItem(
      category: 'Store Management',
      title: 'How to manage inventory?',
      content:
          'Go to Products > Inventory to view and update stock levels. You can also set low stock alerts.',
    ),
    HelpItem(
      category: 'Store Management',
      title: 'How to create product categories?',
      content:
          'Navigate to Categories > Add Category. Enter category name and upload an image. You can also create subcategories.',
    ),
    HelpItem(
      category: 'Orders',
      title: 'How to manage orders?',
      content:
          'All orders are displayed in the Orders section. You can view details, update status, and process payments.',
    ),
    HelpItem(
      category: 'Orders',
      title: 'What are the different order statuses?',
      content:
          'Orders go through: Pending > Order Placed > In Transit > Delivered. You can also cancel orders if needed.',
    ),
    HelpItem(
      category: 'Orders',
      title: 'How to track shipments?',
      content:
          'You can track shipments through the Orders section. Integration with logistics partners is coming soon.',
    ),
    HelpItem(
      category: 'Payments',
      title: 'How are payments processed?',
      content:
          'We use Razorpay for secure payment processing. Payments are verified and funds are transferred automatically.',
    ),
    HelpItem(
      category: 'Payments',
      title: 'How to view payment history?',
      content:
          'Go to Dashboard > Revenue to view payment history, refunds, and financial reports.',
    ),
    HelpItem(
      category: 'Reports',
      title: 'How to generate sales reports?',
      content:
          'Navigate to Dashboard > Reports. You can filter by date range, product, or category to get detailed insights.',
    ),
    HelpItem(
      category: 'Reports',
      title: 'How to export data?',
      content:
          'Most reports can be exported as CSV or PDF. Click the Export button on the report page.',
    ),
    HelpItem(
      category: 'Account',
      title: 'How to change my password?',
      content:
          'Go to Profile > Security > Change Password. Enter your current password and new password.',
    ),
    HelpItem(
      category: 'Account',
      title: 'How to enable two-factor authentication?',
      content:
          'Navigate to Profile > Security > Two-Factor Authentication. Follow the setup instructions.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = _helpItems;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _helpItems;
      } else {
        _filteredItems =
            _helpItems
                .where(
                  (item) =>
                      item.title.toLowerCase().contains(query.toLowerCase()) ||
                      item.content.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
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
            // Search box
            TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Search help articles...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Links
            if (_filteredItems.length == _helpItems.length) ...[
              const Text(
                'Quick Links',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildQuickLink(
                icon: Icons.shopping_bag_outlined,
                title: 'Getting Started',
                subtitle: 'Learn the basics of store management',
              ),
              const SizedBox(height: 12),
              _buildQuickLink(
                icon: Icons.settings_outlined,
                title: 'Store Settings',
                subtitle: 'Configure your store preferences',
              ),
              const SizedBox(height: 12),
              _buildQuickLink(
                icon: Icons.help_outline,
                title: 'Common Issues',
                subtitle: 'Troubleshoot common problems',
              ),
              const SizedBox(height: 24),
            ],

            // Articles by Category
            const Text(
              'Articles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_filteredItems.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No articles found',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return _buildHelpCard(item);
                },
              ),
            const SizedBox(height: 24),

            // Contact Support
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.mail_outline,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Still need help?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Contact our support team',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement contact support
                      },
                      child: const Text('Contact Us'),
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

  Widget _buildQuickLink({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
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
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildHelpCard(HelpItem item) {
    return GestureDetector(
      onTap: () {
        _showArticleDetail(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              item.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArticleDetail(HelpItem item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(item.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.content,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class HelpItem {
  final String category;
  final String title;
  final String content;

  HelpItem({
    required this.category,
    required this.title,
    required this.content,
  });
}
