import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../models/user_model.dart';
import '../../presenters/auth_presenter.dart';
import 'otp_verification_screen.dart';
import 'signup_screen.dart';

/// Login screen with phone number input
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements LoginView {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _presenter = AuthPresenter();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter.attachLoginView(this);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _presenter.detach();
    super.dispose();
  }

  void _handleSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim();
      _presenter.sendOtp(phone);
    }
  }

  void _navigateToSignup() {
    final phone = _phoneController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupScreen(phone: phone, presenter: _presenter),
      ),
    );
  }

  // LoginView implementation
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void showOtpSent(String message, String? sessionId) {
    Helpers.showSuccess(context, message);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => OtpVerificationScreen(
              phone: _phoneController.text.trim(),
              presenter: _presenter,
            ),
      ),
    );
  }

  @override
  void showOtpVerified(UserModel user) {
    // Handled in OTP screen
  }

  @override
  void showError(String message) {
    Helpers.showError(context, message);
  }

  @override
  void navigateToSignup(String phone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupScreen(phone: phone, presenter: _presenter),
      ),
    );
  }

  @override
  void navigateToDashboard() {
    // Handled in OTP screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Header
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome text
                Center(
                  child: Text(
                    'Welcome to FAH Retail',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Sign in to continue shopping',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Phone input label
                Text(
                  'Phone Number',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),

                // Phone input field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🇮🇳 +91',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 24,
                            color: AppColors.border,
                          ),
                        ],
                      ),
                    ),
                    counterText: '',
                  ),
                  validator: Validators.validatePhone,
                  onFieldSubmitted: (_) => _handleSendOtp(),
                ),
                const SizedBox(height: 32),

                // Send OTP button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendOtp,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Send OTP'),
                  ),
                ),
                const SizedBox(height: 24),

                // Signup link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToSignup(),
                        child: Text(
                          'Sign Up',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Terms text
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
