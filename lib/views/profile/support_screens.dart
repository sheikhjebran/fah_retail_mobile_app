import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Help center screen with FAQs
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Categories
            Text(
              'Frequently Asked Questions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildFaqTile(
              context,
              'How do I place an order?',
              'Browse products, add items to your cart, and proceed to checkout. '
                  'Enter your delivery address and payment details to complete the order.',
            ),
            _buildFaqTile(
              context,
              'What payment methods are accepted?',
              'We accept Credit Cards, Debit Cards, UPI, Net Banking, and Cash on Delivery.',
            ),
            _buildFaqTile(
              context,
              'How can I track my order?',
              'Go to "Orders" in the app to see the status of your orders. '
                  'You will also receive updates via SMS.',
            ),
            _buildFaqTile(
              context,
              'What is the return policy?',
              'You can return most items within 7 days of delivery. '
                  'Items must be unused and in original packaging.',
            ),
            _buildFaqTile(
              context,
              'How do I cancel an order?',
              'You can cancel an order before it is shipped. '
                  'Go to Orders, select the order, and tap "Cancel Order".',
            ),
            _buildFaqTile(
              context,
              'How do I change my delivery address?',
              'You can manage your addresses in Profile > Manage Addresses. '
                  'Select a different address during checkout.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contact us screen
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We\'re here to help!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reach out to us through any of the channels below',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact options
            _buildContactTile(
              context,
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: 'support@fahretail.com',
              onTap: () {
                // TODO: Open email
              },
            ),
            _buildContactTile(
              context,
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: '+91 98765 43210',
              onTap: () {
                // TODO: Open phone
              },
            ),
            _buildContactTile(
              context,
              icon: Icons.chat_outlined,
              title: 'WhatsApp',
              subtitle: '+91 98765 43210',
              onTap: () {
                // TODO: Open WhatsApp
              },
            ),
            _buildContactTile(
              context,
              icon: Icons.access_time,
              title: 'Business Hours',
              subtitle: 'Mon - Sat, 9:00 AM - 6:00 PM',
              onTap: null,
            ),

            const SizedBox(height: 24),

            // Address
            Text(
              'Our Address',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'FAH Retail\n123 Main Street\nBangalore, Karnataka 560001',
                      style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing:
            onTap != null
                ? const Icon(Icons.arrow_forward_ios, size: 16)
                : null,
        onTap: onTap,
      ),
    );
  }
}

/// Terms and conditions screen
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: March 2026',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing and using the FAH Retail mobile application, you accept '
                  'and agree to be bound by the terms and conditions of this agreement.',
            ),
            _buildSection(
              context,
              '2. Use of Service',
              'You agree to use this service only for lawful purposes and in accordance '
                  'with these Terms. You agree not to use the service in any way that '
                  'violates any applicable laws or regulations.',
            ),
            _buildSection(
              context,
              '3. Account Registration',
              'To use certain features of the app, you must register for an account. '
                  'You are responsible for maintaining the confidentiality of your account '
                  'and password.',
            ),
            _buildSection(
              context,
              '4. Products and Pricing',
              'All product descriptions, pricing, and availability are subject to change '
                  'without notice. We reserve the right to limit quantities and refuse orders.',
            ),
            _buildSection(
              context,
              '5. Orders and Payment',
              'By placing an order, you agree to pay the full amount shown at checkout. '
                  'We accept various payment methods as displayed in the app.',
            ),
            _buildSection(
              context,
              '6. Shipping and Delivery',
              'We will make reasonable efforts to deliver products within the estimated '
                  'timeframe. Delivery times are not guaranteed and may vary.',
            ),
            _buildSection(
              context,
              '7. Returns and Refunds',
              'Please refer to our Return Policy for details on returns, exchanges, '
                  'and refunds. Items must be returned in original condition.',
            ),
            _buildSection(
              context,
              '8. Limitation of Liability',
              'FAH Retail shall not be liable for any indirect, incidental, special, '
                  'or consequential damages arising from the use of this service.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Privacy policy screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: March 2026',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              'Information We Collect',
              'We collect information you provide directly, such as your name, '
                  'email address, phone number, and shipping address when you create '
                  'an account or place an order.',
            ),
            _buildSection(
              context,
              'How We Use Your Information',
              'We use your information to process orders, communicate with you, '
                  'improve our services, and send promotional offers (with your consent).',
            ),
            _buildSection(
              context,
              'Information Sharing',
              'We do not sell your personal information. We share information only '
                  'with service providers who assist in order fulfillment and delivery.',
            ),
            _buildSection(
              context,
              'Data Security',
              'We implement appropriate security measures to protect your personal '
                  'information from unauthorized access, alteration, or destruction.',
            ),
            _buildSection(
              context,
              'Your Rights',
              'You have the right to access, correct, or delete your personal '
                  'information. Contact us to exercise these rights.',
            ),
            _buildSection(
              context,
              'Cookies and Tracking',
              'We use cookies and similar technologies to enhance your experience '
                  'and analyze app usage patterns.',
            ),
            _buildSection(
              context,
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us '
                  'at privacy@fahretail.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
