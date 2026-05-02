import 'package:intl/intl.dart';

/// Formatters for FAH Retail App
class Formatters {
  Formatters._();

  // Currency formatter for Indian Rupees
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format price in Indian Rupees
  static String formatPrice(double price) {
    return _currencyFormat.format(price);
  }

  /// Format price without decimals
  static String formatPriceInt(double price) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(price);
  }

  /// Format date (converts UTC to local)
  static String formatDate(DateTime date) {
    final localDate = date.isUtc ? date.toLocal() : date;
    return DateFormat('dd MMM yyyy').format(localDate);
  }

  /// Format date with time (converts UTC to local)
  static String formatDateTime(DateTime date) {
    final localDate = date.isUtc ? date.toLocal() : date;
    return DateFormat('dd MMM yyyy, hh:mm a').format(localDate);
  }

  /// Format time (converts UTC to local)
  static String formatTime(DateTime date) {
    final localDate = date.isUtc ? date.toLocal() : date;
    return DateFormat('hh:mm a').format(localDate);
  }

  /// Format date for API (ISO 8601)
  static String formatDateForApi(DateTime date) {
    return date.toIso8601String();
  }

  /// Parse date from API (treats as UTC since backend uses utcnow)
  static DateTime? parseDateFromApi(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      final parsed = DateTime.parse(dateString);
      // If no timezone info, treat as UTC (backend uses datetime.utcnow())
      if (!dateString.contains('Z') && !dateString.contains('+')) {
        return DateTime.utc(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
          parsed.millisecond,
          parsed.microsecond,
        );
      }
      return parsed;
    } catch (e) {
      return null;
    }
  }

  /// Format phone number with country code
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  /// Format order number
  static String formatOrderNumber(String orderNumber) {
    return '#$orderNumber';
  }

  /// Format quantity with unit
  static String formatQuantity(int quantity, {String unit = 'items'}) {
    if (quantity == 1) {
      return '1 ${unit.replaceAll('s', '')}';
    }
    return '$quantity $unit';
  }

  /// Format percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(0)}%';
  }

  /// Calculate discount percentage
  static String calculateDiscountPercentage(
    double original,
    double discounted,
  ) {
    if (original <= 0) return '0%';
    final discount = ((original - discounted) / original * 100);
    return '${discount.toStringAsFixed(0)}% OFF';
  }

  /// Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}
