import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/user_model.dart';
import '../../presenters/auth_presenter.dart';
import '../dashboard/dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'signup_screen.dart';

/// OTP verification screen
class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final AuthPresenter presenter;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.presenter,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    implements OtpVerificationView {
  final _otpController = TextEditingController();

  bool _isLoading = false;
  int _resendTimer = AppConstants.otpResendTime;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    widget.presenter.attachOtpView(this);
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = AppConstants.otpResendTime;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _handleVerifyOtp() {
    if (_isLoading) return; // Prevent double submission
    if (_otpController.text.length == AppConstants.otpLength) {
      widget.presenter.verifyOtp(_otpController.text);
    }
  }

  void _handleResendOtp() {
    if (_canResend) {
      widget.presenter.resendOtp();
    }
  }

  // OtpVerificationView implementation
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void showOtpResent() {
    Helpers.showSuccess(context, 'OTP sent again');
    _startResendTimer();
  }

  UserModel? _verifiedUser;

  @override
  void showVerificationSuccess(UserModel user) {
    _verifiedUser = user;
    Helpers.showSuccess(context, 'Verified successfully');
  }

  @override
  void showError(String message) {
    Helpers.showError(context, message);
    _otpController.clear();
  }

  @override
  void startResendTimer() {
    _startResendTimer();
  }

  @override
  void navigateToDashboard() {
    if (_verifiedUser?.isAdmin == true) {
      Helpers.navigateAndRemoveAll(context, const AdminDashboardScreen());
    } else {
      Helpers.navigateAndRemoveAll(context, const DashboardScreen());
    }
  }

  @override
  void navigateToSignup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                SignupScreen(phone: widget.phone, presenter: widget.presenter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

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
                    Icons.lock_outline,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Center(
                child: Text(
                  'Enter Verification Code',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Center(
                child: Text(
                  'We sent a verification code to\n+91 ${widget.phone}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // OTP input
              PinCodeTextField(
                appContext: context,
                controller: _otpController,
                length: AppConstants.otpLength,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: AppColors.surface,
                  inactiveFillColor: AppColors.surface,
                  selectedFillColor: AppColors.primaryLight,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  selectedColor: AppColors.primary,
                ),
                enableActiveFill: true,
                onCompleted: (_) => _handleVerifyOtp(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 24),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyOtp,
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
                          : const Text('Verify'),
                ),
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Center(
                child:
                    _canResend
                        ? TextButton(
                          onPressed: _handleResendOtp,
                          child: const Text('Resend OTP'),
                        )
                        : Text(
                          'Resend OTP in $_resendTimer seconds',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
              ),

              const SizedBox(height: 16),

              // Change number
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Change Phone Number'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
