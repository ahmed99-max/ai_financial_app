import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'AI Finance';
  static const String appVersion = '1.0.0';

  // Free User Limits
  static const int freeAiUsageLimit = 10;
  static const int premiumAiUsageLimit = 1000;

  // Default Categories
  static const List<String> defaultCategories = [
    'Food & Dining',
    'Shopping',
    'Transportation',
    'Entertainment',
    'Healthcare',
    'Utilities',
    'Education',
    'Investment',
    'Loan Payment',
    'Bill Split',
    'Others',
  ];

  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'Food & Dining': Icons.restaurant,
    'Shopping': Icons.shopping_bag,
    'Transportation': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Healthcare': Icons.local_hospital,
    'Utilities': Icons.lightbulb,
    'Education': Icons.school,
    'Investment': Icons.trending_up,
    'Loan Payment': Icons.payment,
    'Bill Split': Icons.group,
    'Others': Icons.more_horiz,
  };

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Food & Dining': Color(0xFFFF6B6B),
    'Shopping': Color(0xFF4ECDC4),
    'Transportation': Color(0xFF45B7D1),
    'Entertainment': Color(0xFFFFA07A),
    'Healthcare': Color(0xFF98D8C8),
    'Utilities': Color(0xFFFED766),
    'Education': Color(0xFF6C5CE7),
    'Investment': Color(0xFF00B894),
    'Loan Payment': Color(0xFFE17055),
    'Bill Split': Color(0xFF74B9FF),
    'Others': Color(0xFF95A5A6),
  };

  // Investment Types
  static const List<String> investmentTypes = [
    'Stocks',
    'Mutual Funds',
    'Crypto',
    'Gold',
    'Fixed Deposit',
    'Real Estate',
    'Bonds',
  ];

  // Loan Types
  static const List<String> loanTypes = [
    'Home Loan',
    'Personal Loan',
    'Car Loan',
    'Education Loan',
    'Business Loan',
    'Credit Card',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'UPI',
    'Credit Card',
    'Debit Card',
    'Net Banking',
    'Cash',
    'Wallet',
  ];

  // Shopping Platforms
  static const List<String> shoppingPlatforms = [
    'Amazon',
    'Flipkart',
    'Myntra',
    'Ajio',
    'Meesho',
    'Snapdeal',
    'Others',
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // API Endpoints (Mock - Replace with real endpoints)
  static const String productSearchApi = 'https://api.example.com/search';
  static const String priceTrackerApi = 'https://api.example.com/price';
  static const String couponCheckerApi = 'https://api.example.com/coupon';
  static const String bankApiEndpoint = 'https://api.example.com/bank';
}

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF00D4FF);
  static const Color accentColor = Color(0xFFFF6584);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF2D3436);
  static const Color textSecondaryColor = Color(0xFF636E72);
  static const Color successColor = Color(0xFF00B894);
  static const Color errorColor = Color(0xFFFF7675);
  static const Color warningColor = Color(0xFFFDAF42);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: const CardThemeData(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimaryColor,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );

  // Gradient Decorations
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFFF7675), Color(0xFFFF9FF3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
