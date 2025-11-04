// lib/utils/error_handler.dart
// Comprehensive error handling and recovery system

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final String code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    required this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: [$code] $message';
}

class NetworkException extends AppException {
  NetworkException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'NETWORK_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

class AuthException extends AppException {
  AuthException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'AUTH_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

class FirestoreException extends AppException {
  FirestoreException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'FIRESTORE_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

class PaymentException extends AppException {
  PaymentException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'PAYMENT_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

class ValidationException extends AppException {
  ValidationException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'VALIDATION_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Global error handler for the application
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();

  factory ErrorHandler() {
    return _instance;
  }

  ErrorHandler._internal();

  /// Handle Firebase Authentication errors
  AppException handleAuthError(FirebaseAuthException e) {
    String message = 'Authentication error occurred';

    switch (e.code) {
      case 'weak-password':
        message = 'Password is too weak. Use uppercase, lowercase, numbers & symbols';
        break;
      case 'email-already-in-use':
        message = 'Email address is already registered';
        break;
      case 'invalid-email':
        message = 'Invalid email address format';
        break;
      case 'user-disabled':
        message = 'User account has been disabled';
        break;
      case 'user-not-found':
        message = 'User account not found';
        break;
      case 'wrong-password':
        message = 'Invalid password. Please try again';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Try again later';
        break;
      case 'invalid-verification-code':
        message = 'Invalid or expired verification code';
        break;
      case 'invalid-phone-number':
        message = 'Invalid phone number format';
        break;
      case 'session-expired':
        message = 'Session expired. Please login again';
        break;
      default:
        message = e.message ?? 'Authentication failed';
    }

    return AuthException(
      message: message,
      originalException: e,
      stackTrace: StackTrace.current,
    );
  }

  /// Handle Firestore errors
  AppException handleFirestoreError(FirebaseException e) {
    String message = 'Database error occurred';

    switch (e.code) {
      case 'permission-denied':
        message = 'You do not have permission to access this data';
        break;
      case 'not-found':
        message = 'Data not found';
        break;
      case 'already-exists':
        message = 'Data already exists';
        break;
      case 'resource-exhausted':
        message = 'Database quota exceeded. Please try again later';
        break;
      case 'failed-precondition':
        message = 'Operation precondition failed';
        break;
      case 'aborted':
        message = 'Operation was aborted. Please retry';
        break;
      case 'out-of-range':
        message = 'Data is out of valid range';
        break;
      case 'unimplemented':
        message = 'This feature is not implemented';
        break;
      case 'internal':
        message = 'Internal server error. Please try again';
        break;
      case 'unavailable':
        message = 'Service temporarily unavailable. Please try again';
        break;
      case 'data-loss':
        message = 'Unrecoverable data loss error';
        break;
      case 'unauthenticated':
        message = 'Authentication required';
        break;
      default:
        message = e.message ?? 'Database operation failed';
    }

    return FirestoreException(
      message: message,
      originalException: e,
      stackTrace: StackTrace.current,
    );
  }

  /// Handle network errors
  AppException handleNetworkError(DioException e) {
    String message = 'Network error occurred';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response timeout. Please try again';
        break;
      case DioExceptionType.badResponse:
        message = _handleHttpError(e.response?.statusCode ?? 0);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.unknown:
        message = 'Unknown network error. Check your connection';
        break;
      case DioExceptionType.badCertificate:
        message = 'SSL certificate verification failed';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network';
        break;
    }

    return NetworkException(
      message: message,
      originalException: e,
      stackTrace: StackTrace.current,
    );
  }

  /// Handle HTTP status codes
  String _handleHttpError(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input';
      case 401:
        return 'Unauthorized. Please login again';
      case 403:
        return 'Forbidden. You do not have access';
      case 404:
        return 'Resource not found';
      case 409:
        return 'Conflict. Data already exists';
      case 422:
        return 'Invalid data. Please check your input';
      case 429:
        return 'Too many requests. Please try again later';
      case 500:
        return 'Server error. Please try again later';
      case 502:
        return 'Bad gateway. Service temporarily unavailable';
      case 503:
        return 'Service unavailable. Please try again later';
      case 504:
        return 'Gateway timeout. Please try again';
      default:
        return 'HTTP Error: $statusCode';
    }
  }

  /// Handle payment errors
  AppException handlePaymentError(dynamic error) {
    String message = 'Payment failed';

    if (error is Exception) {
      message = error.toString();
    }

    // Razorpay specific errors
    if (message.contains('invalid_vpa')) {
      message = 'Invalid UPI ID. Please check and try again';
    } else if (message.contains('gateway_error')) {
      message = 'Payment gateway error. Please retry';
    } else if (message.contains('otp_expired')) {
      message = 'OTP expired. Please retry';
    } else if (message.contains('declined')) {
      message = 'Payment declined by bank. Try another method';
    } else if (message.contains('insufficient_funds')) {
      message = 'Insufficient funds in account';
    }

    return PaymentException(
      message: message,
      originalException: error,
      stackTrace: StackTrace.current,
    );
  }

  /// Handle validation errors
  AppException handleValidationError(String fieldName, String message) {
    return ValidationException(
      message: '$fieldName: $message',
      originalException: null,
      stackTrace: StackTrace.current,
    );
  }

  /// Generic error handler
  AppException handleError(dynamic error, {String? context}) {
    String message = 'An error occurred';

    if (error is FirebaseException) {
      return handleFirestoreError(error);
    } else if (error is FirebaseAuthException) {
      return handleAuthError(error);
    } else if (error is DioException) {
      return handleNetworkError(error);
    } else if (error is AppException) {
      return error;
    } else if (error is Exception) {
      message = error.toString();
    } else if (error is String) {
      message = error;
    }

    return AppException(
      message: message,
      code: 'UNKNOWN_ERROR',
      originalException: error,
      stackTrace: StackTrace.current,
    );
  }

  /// Log error for debugging
  void logError(AppException exception) {
    print('╔════════════════════════════════════════╗');
    print('║  ERROR: ${exception.code}');
    print('╠════════════════════════════════════════╣');
    print('║ Message: ${exception.message}');
    print('║ Original: ${exception.originalException}');
    print('╚════════════════════════════════════════╝');

    if (exception.stackTrace != null) {
      print('Stack Trace:\n${exception.stackTrace}');
    }
  }

  /// Show error snackbar in UI
  void showErrorSnackBar(
    BuildContext context,
    AppException exception, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exception.message),
        backgroundColor: Colors.red.shade600,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show error dialog
  Future<void> showErrorDialog(
    BuildContext context,
    AppException exception, {
    String title = 'Error',
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(exception.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }

  /// Retry logic with exponential backoff
  Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxAttempts) {
          rethrow;
        }

        // Exponential backoff: 1s, 2s, 4s
        final delay = initialDelay * (1 << (attempt - 1));
        await Future.delayed(delay);
      }
    }

    throw Exception('Max retry attempts exceeded');
  }

  /// Safe operation wrapper
  Future<T?> safeOperation<T>(
    Future<T> Function() operation, {
    VoidCallback? onError,
    bool showDialog = false,
    required BuildContext? context,
  }) async {
    try {
      return await operation();
    } catch (e) {
      final exception = handleError(e);
      logError(exception);

      onError?.call();

      if (showDialog && context != null) {
        await showErrorDialog(context, exception);
      }

      return null;
    }
  }

  /// Validate required field
  void validateRequired(dynamic value, String fieldName) {
    if (value == null || (value is String && value.isEmpty)) {
      throw handleValidationError(fieldName, 'is required');
    }
  }

  /// Validate email format
  void validateEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!regex.hasMatch(email)) {
      throw handleValidationError('Email', 'is invalid');
    }
  }

  /// Validate phone format
  void validatePhone(String phone) {
    final regex = RegExp(r'^[6-9]\d{9}$');

    if (!regex.hasMatch(phone)) {
      throw handleValidationError('Phone', 'is invalid (10 digits)');
    }
  }

  /// Validate amount
  void validateAmount(double amount, {double minAmount = 0}) {
    if (amount <= minAmount) {
      throw handleValidationError('Amount', 'must be greater than $minAmount');
    }
  }
}
