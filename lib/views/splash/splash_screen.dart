import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

/// Splash screen with animated logo
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glitterAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateAfterSplash();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _glitterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(Duration(seconds: AppConstants.splashDuration));

    if (!mounted) return;

    // Check if user is logged in
    final isLoggedIn = await Helpers.isLoggedIn();

    if (!mounted) return;

    final user = await Helpers.getUserData();

    if (!mounted) return;

    // Navigate based on auth state
    Helpers.navigateAndRemoveAll(
      context,
      isLoggedIn ? DashboardScreen(user: user) : const LoginScreen(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glitter particles background
            AnimatedBuilder(
              animation: _glitterAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: GlitterPainter(progress: _glitterAnimation.value),
                );
              },
            ),

            // Logo with animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container with glow effect
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'FAH',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                foreground:
                                    Paint()
                                      ..shader = const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.secondary,
                                        ],
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 100, 50),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // App name with shimmer effect
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: const [
                                AppColors.primary,
                                AppColors.accent,
                                AppColors.secondary,
                              ],
                              stops: [0.0, _glitterAnimation.value, 1.0],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline
                        Text(
                          'Accessories for every occasion',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 60,
              child: AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for glitter effect
class GlitterPainter extends CustomPainter {
  final double progress;

  GlitterPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate random glitter particles
    final random = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 50; i++) {
      final x = ((random * (i + 1)) % size.width.toInt()).toDouble();
      final y = ((random * (i + 2)) % size.height.toInt()).toDouble();
      final radius = (progress * 3) * ((i % 3) + 1);

      // Alternate colors
      paint.color =
          i % 2 == 0
              ? AppColors.accent.withValues(alpha: progress * 0.6)
              : AppColors.primary.withValues(alpha: progress * 0.4);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GlitterPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
