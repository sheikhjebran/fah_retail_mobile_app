import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/utils/helpers.dart';

/// View contract for Login screen
abstract class LoginView {
  void showLoading();
  void hideLoading();
  void showOtpSent(String message, String? sessionId);
  void showOtpVerified(UserModel user);
  void showError(String message);
  void navigateToSignup(String phone);
  void navigateToDashboard();
}

/// View contract for Signup screen
abstract class SignupView {
  void showLoading();
  void hideLoading();
  void showSignupSuccess(UserModel user);
  void showError(String message);
  void showValidationError(String field, String message);
  void navigateToDashboard();
}

/// View contract for OTP verification screen
abstract class OtpVerificationView {
  void showLoading();
  void hideLoading();
  void showOtpResent();
  void showVerificationSuccess(UserModel user);
  void showError(String message);
  void startResendTimer();
  void navigateToDashboard();
  void navigateToSignup();
}

/// Auth presenter for managing authentication flow
class AuthPresenter {
  final AuthService _authService;
  LoginView? _loginView;
  SignupView? _signupView;
  OtpVerificationView? _otpView;

  String? _currentPhone;
  String? _currentSessionId;
  bool _isNewUser = false;

  AuthPresenter({AuthService? authService})
    : _authService = authService ?? AuthService();

  /// Attach login view
  void attachLoginView(LoginView view) {
    _loginView = view;
  }

  /// Attach signup view
  void attachSignupView(SignupView view) {
    _signupView = view;
  }

  /// Attach OTP verification view
  void attachOtpView(OtpVerificationView view) {
    _otpView = view;
  }

  /// Detach views
  void detach() {
    _loginView = null;
    _signupView = null;
    _otpView = null;
  }

  /// Get current phone
  String? get currentPhone => _currentPhone;

  /// Check if user is new
  bool get isNewUser => _isNewUser;

  /// Send OTP to phone number
  Future<void> sendOtp(String phone) async {
    _loginView?.showLoading();
    _otpView?.showLoading();

    try {
      _currentPhone = phone;
      final response = await _authService.sendOtp(phone);

      _loginView?.hideLoading();
      _otpView?.hideLoading();

      // Check if user is new - redirect to signup
      if (response.isNewUser) {
        _isNewUser = true;
        _loginView?.showError(response.message);
        _loginView?.navigateToSignup(phone);
        return;
      }

      if (response.success) {
        _currentSessionId = response.sessionId;
        _loginView?.showOtpSent(response.message, response.sessionId);
        _otpView?.startResendTimer();
      } else {
        _loginView?.showError(response.message);
        _otpView?.showError(response.message);
      }
    } catch (e) {
      _loginView?.hideLoading();
      _otpView?.hideLoading();
      _loginView?.showError(e.toString());
      _otpView?.showError(e.toString());
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (_currentPhone == null) return;
    await sendOtp(_currentPhone!);
    _otpView?.showOtpResent();
  }

  /// Verify OTP
  Future<void> verifyOtp(String otp) async {
    if (_currentPhone == null) return;

    _loginView?.showLoading();
    _otpView?.showLoading();

    try {
      final response = await _authService.verifyOtp(
        phone: _currentPhone!,
        otp: otp,
        sessionId: _currentSessionId,
      );

      // Save auth data with user
      await Helpers.saveAuthToken(response.token, user: response.user);

      _loginView?.hideLoading();
      _otpView?.hideLoading();
      _loginView?.showOtpVerified(response.user);
      _otpView?.showVerificationSuccess(response.user);

      // Navigate based on user data completeness
      if (_isUserComplete(response.user)) {
        _loginView?.navigateToDashboard();
        _otpView?.navigateToDashboard();
      } else {
        _isNewUser = true;
        _loginView?.navigateToSignup(_currentPhone!);
        _otpView?.navigateToSignup();
      }
    } catch (e) {
      _loginView?.hideLoading();
      _otpView?.hideLoading();
      _loginView?.showError(e.toString());
      _otpView?.showError(e.toString());
    }
  }

  /// Complete signup
  Future<void> signup({
    required String name,
    required String email,
    String? address,
    String? city,
    String? pincode,
  }) async {
    if (_currentPhone == null) return;

    _signupView?.showLoading();

    try {
      final response = await _authService.signup(
        name: name,
        phone: _currentPhone!,
        email: email,
        address: address,
        city: city,
        pincode: pincode,
      );

      // Save auth data with user
      await Helpers.saveAuthToken(response.token, user: response.user);

      _signupView?.hideLoading();
      _signupView?.showSignupSuccess(response.user);
      _signupView?.navigateToDashboard();
    } catch (e) {
      _signupView?.hideLoading();
      _signupView?.showError(e.toString());
    }
  }

  /// Check if user profile is complete
  bool _isUserComplete(UserModel user) {
    return user.name.isNotEmpty && user.email.isNotEmpty;
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      await Helpers.clearAuthData();
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await Helpers.isLoggedIn();
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _authService.getProfile();
    } catch (e) {
      return null;
    }
  }
}
