import 'package:flutter/material.dart';

/// App color palette for FAH Retail App
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(
    0xFFE91E63,
  ); // Pink - Perfect for accessories
  static const Color primaryLight = Color(0xFFF8BBD9);
  static const Color primaryDark = Color(0xFFC2185B);

  // Secondary Colors
  static const Color secondary = Color(0xFF9C27B0); // Purple
  static const Color secondaryLight = Color(0xFFE1BEE7);
  static const Color secondaryDark = Color(0xFF7B1FA2);

  // Accent Colors
  static const Color accent = Color(0xFFFFD700); // Gold
  static const Color accentLight = Color(0xFFFFF8E1);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Order Status Colors
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusOrderPlaced = Color(0xFF2196F3);
  static const Color statusInTransit = Color(0xFF9C27B0);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);

  // Other Colors
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Discount Badge
  static const Color discountBadge = Color(0xFFFF5722);
  static const Color trendingBadge = Color(0xFFE91E63);

  // Rating
  static const Color starFilled = Color(0xFFFFD700);
  static const Color starEmpty = Color(0xFFE0E0E0);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [primaryLight, secondaryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
