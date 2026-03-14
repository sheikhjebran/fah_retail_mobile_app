import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../models/user_model.dart';
import '../../presenters/auth_presenter.dart';
import '../dashboard/dashboard_screen.dart';

/// Signup screen for collecting user details
class SignupScreen extends StatefulWidget {
  final String phone;
  final AuthPresenter presenter;

  const SignupScreen({super.key, required this.phone, required this.presenter});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> implements SignupView {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _isLoading = false;
  final Map<String, String> _validationErrors = {};

  @override
  void initState() {
    super.initState();
    widget.presenter.attachSignupView(this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.presenter.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        address:
            _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
        city:
            _cityController.text.trim().isNotEmpty
                ? _cityController.text.trim()
                : null,
        pincode:
            _pincodeController.text.trim().isNotEmpty
                ? _pincodeController.text.trim()
                : null,
      );
    }
  }

  // SignupView implementation
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void showSignupSuccess(UserModel user) {
    Helpers.showSuccess(context, 'Welcome, ${user.name}!');
  }

  @override
  void showError(String message) {
    Helpers.showError(context, message);
  }

  @override
  void showValidationError(String field, String message) {
    setState(() {
      _validationErrors[field] = message;
    });
  }

  @override
  void navigateToDashboard() {
    Helpers.navigateAndRemoveAll(context, const DashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'Tell us about yourself',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Complete your profile to start shopping',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Phone (read-only)
                _buildLabel('Phone Number'),
                TextFormField(
                  initialValue: '+91 ${widget.phone}',
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_outlined),
                    fillColor: AppColors.background,
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                _buildLabel('Full Name *'),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),

                // Email
                _buildLabel('Email *'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                // Address (optional)
                _buildLabel('Address (Optional)'),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Enter your address',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // City and Pincode row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('City'),
                          TextFormField(
                            controller: _cityController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'City',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Pincode'),
                          TextFormField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              hintText: 'Pincode',
                              prefixIcon: Icon(Icons.pin_drop_outlined),
                              counterText: '',
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return Validators.validatePincode(value);
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
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
                            : const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
