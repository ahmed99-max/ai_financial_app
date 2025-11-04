// lib/utils/validators.dart
// Comprehensive form validation utilities for all input fields

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[6-9]\d{9}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain special character';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Name must not exceed 50 characters';
    }

    if (!RegExp(r"^[a-zA-Z\s'-]*$").hasMatch(value)) {
      return 'Name contains invalid characters';
    }

    return null;
  }

  // Amount validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);

    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount > 10000000) {
      return 'Amount exceeds maximum limit';
    }

    return null;
  }

  // Percentage validation
  static String? validatePercentage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Percentage is required';
    }

    final percentage = double.tryParse(value);

    if (percentage == null) {
      return 'Please enter a valid percentage';
    }

    if (percentage < 0 || percentage > 100) {
      return 'Percentage must be between 0 and 100';
    }

    return null;
  }

  // Interest rate validation
  static String? validateInterestRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Interest rate is required';
    }

    final rate = double.tryParse(value);

    if (rate == null) {
      return 'Please enter a valid interest rate';
    }

    if (rate < 0 || rate > 50) {
      return 'Interest rate must be between 0 and 50%';
    }

    return null;
  }

  // Tenure validation (in months)
  static String? validateTenure(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tenure is required';
    }

    final months = int.tryParse(value);

    if (months == null) {
      return 'Please enter a valid number of months';
    }

    if (months < 1 || months > 600) {
      return 'Tenure must be between 1 and 600 months';
    }

    return null;
  }

  // Account number validation
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }

    if (value.length < 9 || value.length > 18) {
      return 'Account number must be 9-18 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Account number must contain only digits';
    }

    return null;
  }

  // IFSC code validation
  static String? validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return 'IFSC code is required';
    }

    if (value.length != 11) {
      return 'IFSC code must be 11 characters';
    }

    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) {
      return 'Invalid IFSC code format';
    }

    return null;
  }

  // UPI ID validation
  static String? validateUPI(String? value) {
    if (value == null || value.isEmpty) {
      return 'UPI ID is required';
    }

    if (!RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]{3,}$').hasMatch(value)) {
      return 'Please enter a valid UPI ID';
    }

    return null;
  }

  // URL validation
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
        r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Coupon code validation
  static String? validateCouponCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Coupon code is required';
    }

    if (value.length < 3 || value.length > 20) {
      return 'Coupon code must be 3-20 characters';
    }

    if (!RegExp(r'^[A-Z0-9_-]+$').hasMatch(value)) {
      return 'Coupon code contains invalid characters';
    }

    return null;
  }

  // Not empty validation
  static String? validateNotEmpty(String? value,
      [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }

    return null;
  }

  // Min length validation
  static String? validateMinLength(String? value, int minLength,
      [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  // Max length validation
  static String? validateMaxLength(String? value, int maxLength,
      [String fieldName = 'Field']) {
    if (value == null) {
      return null;
    }

    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  // Match field validation (for password confirm)
  static String? validateMatch(String? value, String? compareValue,
      [String fieldName = 'Field']) {
    if (value == null || compareValue == null) {
      return null;
    }

    if (value != compareValue) {
      return '$fieldName does not match';
    }

    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'Date cannot be in the future';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // PIN code validation
  static String? validatePIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN code is required';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'PIN code must be 6 digits';
    }

    return null;
  }

  // Aadhar validation
  static String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhar number is required';
    }

    if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
      return 'Aadhar number must be 12 digits';
    }

    return null;
  }

  // PAN validation
  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN is required';
    }

    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) {
      return 'Invalid PAN format';
    }

    return null;
  }

  // GST validation
  static String? validateGST(String? value) {
    if (value == null || value.isEmpty) {
      return 'GST is required';
    }

    if (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9]{1}$')
        .hasMatch(value)) {
      return 'Invalid GST format';
    }

    return null;
  }

  // Investment quantity validation
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }

    final qty = double.tryParse(value);

    if (qty == null) {
      return 'Please enter a valid quantity';
    }

    if (qty <= 0) {
      return 'Quantity must be greater than 0';
    }

    if (qty > 100000) {
      return 'Quantity exceeds maximum limit';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);

    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price <= 0) {
      return 'Price must be greater than 0';
    }

    if (price > 1000000000) {
      return 'Price exceeds maximum limit';
    }

    return null;
  }

  // Stock symbol validation
  static String? validateSymbol(String? value) {
    if (value == null || value.isEmpty) {
      return 'Symbol is required';
    }

    if (value.length > 10) {
      return 'Symbol must not exceed 10 characters';
    }

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
      return 'Symbol must contain uppercase letters and numbers';
    }

    return null;
  }

  // Cryptocurrency address validation
  static String? validateCryptoAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 26 || value.length > 35) {
      return 'Invalid cryptocurrency address';
    }

    return null;
  }

  // Bill description validation
  static String? validateBillDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bill description is required';
    }

    if (value.length < 3 || value.length > 500) {
      return 'Description must be 3-500 characters';
    }

    return null;
  }

  // Merchant name validation
  static String? validateMerchant(String? value) {
    if (value == null || value.isEmpty) {
      return 'Merchant name is required';
    }

    if (value.length < 2 || value.length > 100) {
      return 'Merchant name must be 2-100 characters';
    }

    return null;
  }
}
