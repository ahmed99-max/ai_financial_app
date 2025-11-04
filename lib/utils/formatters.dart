// lib/utils/formatters.dart
// Comprehensive formatting utilities for currencies, dates, numbers

import 'package:intl/intl.dart';

class Formatters {
  // Format currency (INR)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format currency without decimals
  static String formatCurrencyShort(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  // Format percentage
  static String formatPercentage(double value, [int decimals = 2]) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  // Format profit/loss with color indicator
  static String formatProfitLoss(double value, [int decimals = 2]) {
    final sign = value >= 0 ? '+' : '';
    return '$sign₹${value.toStringAsFixed(decimals)}';
  }

  // Format date - Full format
  static String formatDateFull(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy, EEEE');
    return formatter.format(date);
  }

  // Format date - Medium format
  static String formatDateMedium(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  // Format date - Short format
  static String formatDateShort(DateTime date) {
    final formatter = DateFormat('dd/MM/yy');
    return formatter.format(date);
  }

  // Format date - With time
  static String formatDateWithTime(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');
    return formatter.format(date);
  }

  // Format time only
  static String formatTimeOnly(DateTime date) {
    final formatter = DateFormat('hh:mm a');
    return formatter.format(date);
  }

  // Format date for API (ISO format)
  static String formatDateISO(DateTime date) {
    return date.toIso8601String();
  }

  // Format relative time (e.g., "2 days ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  // Format number with thousand separator
  static String formatNumber(num value, [int decimals = 0]) {
    final formatter = NumberFormat('#,##0' + (decimals > 0 ? '.${'0' * decimals}' : ''));
    return formatter.format(value);
  }

  // Format EMI schedule
  static String formatEMI(double amount, int months) {
    return '₹${amount.toStringAsFixed(0)} × $months months';
  }

  // Format loan tenure
  static String formatTenure(int months) {
    if (months % 12 == 0) {
      return '${months ~/ 12} year${months ~/ 12 > 1 ? 's' : ''}';
    } else if (months >= 12) {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      return '$years year${years > 1 ? 's' : ''} $remainingMonths month${remainingMonths > 1 ? 's' : ''}';
    } else {
      return '$months month${months > 1 ? 's' : ''}';
    }
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.length != 10) return phone;
    return '${phone.substring(0, 5)} ${phone.substring(5)}';
  }

  // Format Indian phone with country code
  static String formatPhoneInternational(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '+91 ${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return phone;
  }

  // Mask account number (show last 4 digits)
  static String maskAccountNumber(String account) {
    if (account.length <= 4) return '****${account.substring(account.length - 1)}';
    return '*' * (account.length - 4) + account.substring(account.length - 4);
  }

  // Mask email
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '*@$domain';
    }

    return name[0] + '*' * (name.length - 2) + name[name.length - 1] + '@$domain';
  }

  // Format address
  static String formatAddress(String address) {
    return address.length > 50 ? '${address.substring(0, 50)}...' : address;
  }

  // Format large numbers (K, L, Cr)
  static String formatLargeNumber(num number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)}Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  // Format investment quantity
  static String formatQuantity(double quantity) {
    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(2);
  }

  // Format price with rupee symbol
  static String formatPrice(double price) {
    if (price >= 1000000) {
      return '₹${(price / 1000000).toStringAsFixed(2)}M';
    } else if (price >= 1000) {
      return '₹${(price / 1000).toStringAsFixed(2)}K';
    } else {
      return '₹${price.toStringAsFixed(2)}';
    }
  }

  // Format discount percentage
  static String formatDiscount(double discount) {
    return '-${discount.toStringAsFixed(0)}%';
  }

  // Format tax
  static String formatTax(double tax) {
    return '+₹${tax.toStringAsFixed(2)}';
  }

  // Format transaction reference
  static String formatTransactionReference(String ref) {
    return ref.toUpperCase();
  }

  // Format order ID
  static String formatOrderID(String id) {
    return '#${id.toUpperCase()}';
  }

  // Format category name (Title Case)
  static String formatCategoryName(String category) {
    return category.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Format status (Title Case)
  static String formatStatus(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Format boolean as readable text
  static String formatBoolean(bool value) {
    return value ? 'Yes' : 'No';
  }

  // Format IP address
  static String formatIP(String ip) {
    final parts = ip.split('.');
    if (parts.length == 4) {
      return parts.map((part) => part.padLeft(3, '0')).join('.');
    }
    return ip;
  }

  // Format UUID (shorten)
  static String formatUUID(String uuid) {
    if (uuid.length >= 8) {
      return '${uuid.substring(0, 8)}...';
    }
    return uuid;
  }

  // Format credit card number
  static String formatCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 4) {
      return '**** **** **** ${cleaned.substring(cleaned.length - 4)}';
    }
    return cardNumber;
  }

  // Format CVV (mask)
  static String formatCVV(String cvv) {
    return '*' * cvv.length;
  }

  // Format expiry date
  static String formatExpiryDate(String month, String year) {
    return '$month/$year';
  }

  // Format bytes to readable size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
  }

  // Format percentage change with arrow
  static String formatPercentageChange(double value) {
    if (value > 0) return '↑ ${value.toStringAsFixed(2)}%';
    if (value < 0) return '↓ ${value.abs().toStringAsFixed(2)}%';
    return '→ 0%';
  }

  // Format ROI
  static String formatROI(double roi) {
    return '${roi.toStringAsFixed(2)}% ROI';
  }

  // Format timeframe
  static String formatTimeframe(String timeframe) {
    switch (timeframe.toLowerCase()) {
      case '1d':
        return '1 Day';
      case '1w':
        return '1 Week';
      case '1m':
        return '1 Month';
      case '3m':
        return '3 Months';
      case '1y':
        return '1 Year';
      case 'all':
        return 'All Time';
      default:
        return timeframe;
    }
  }

  // Format bill amount with tax
  static String formatBillAmount(double amount, double tax) {
    final total = amount + tax;
    return '₹${amount.toStringAsFixed(2)} + ₹${tax.toStringAsFixed(2)} (Tax) = ₹${total.toStringAsFixed(2)}';
  }

  // Format coupon discount
  static String formatCouponDiscount(double amount) {
    return '-₹${amount.toStringAsFixed(2)}';
  }

  // Format notification timestamp
  static String formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM').format(dateTime);
    }
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Title case
  static String titleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
