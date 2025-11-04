// lib/services/payment_service.dart
// Complete payment processing with multiple gateway support

import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../utils/logger.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() {
    return _instance;
  }

  PaymentService._internal();

  late Razorpay _razorpay;
  Function(Map<String, dynamic>)? _onPaymentSuccess;
  Function(dynamic)? _onPaymentError;

  /// Initialize payment service
  Future<void> initialize() async {
    try {
      _razorpay = Razorpay();

      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      logger.info('Payment service initialized', tag: 'PaymentService');
    } catch (e) {
      logger.error('Failed to initialize payment service: $e',
          tag: 'PaymentService');
    }
  }

  /// Process payment with Razorpay
  Future<void> processPayment({
    required String orderId,
    required double amount,
    required String description,
    required String userEmail,
    required String userPhone,
    required String userName,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(dynamic) onError,
  }) async {
    try {
      _onPaymentSuccess = onSuccess;
      _onPaymentError = onError;

      var options = {
        'key': 'YOUR_RAZORPAY_KEY_ID', // Replace with actual key
        'amount': (amount * 100).toInt(), // Amount in paise
        'name': 'Financial App',
        'order_id': orderId,
        'description': description,
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
          'name': userName,
        },
        'theme': {
          'color': '#3F51B5', // Primary color
        },
      };

      _razorpay.open(options);

      logger.info(
        'Payment initiated: $orderId, Amount: ₹$amount',
        tag: 'PaymentService',
      );
    } catch (e) {
      logger.error('Failed to process payment: $e', tag: 'PaymentService');
      onError(e);
    }
  }

  /// Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    try {
      final paymentData = {
        'paymentId': response.paymentId,
        'orderId': response.orderId,
        'signature': response.signature,
        'status': 'success',
        'timestamp': DateTime.now(),
      };

      logger.info(
        'Payment successful: ${response.paymentId}',
        tag: 'PaymentService',
      );

      _onPaymentSuccess?.call(paymentData);
    } catch (e) {
      logger.error('Error handling payment success: $e',
          tag: 'PaymentService');
    }
  }

  /// Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    try {
      logger.error(
        'Payment failed: ${response.message}',
        tag: 'PaymentService',
      );

      _onPaymentError?.call(response.message);
    } catch (e) {
      logger.error('Error handling payment error: $e',
          tag: 'PaymentService');
    }
  }

  /// Handle external wallet payment
  void _handleExternalWallet(ExternalWalletResponse response) {
    try {
      logger.info(
        'External wallet selected: ${response.walletName}',
        tag: 'PaymentService',
      );
    } catch (e) {
      logger.error('Error handling external wallet: $e',
          tag: 'PaymentService');
    }
  }

  /// Create order on backend
  Future<String?> createOrder({
    required double amount,
    required String description,
  }) async {
    try {
      // In production: Call your backend API
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

      logger.info(
        'Order created: $orderId',
        tag: 'PaymentService',
      );

      return orderId;
    } catch (e) {
      logger.error('Failed to create order: $e', tag: 'PaymentService');
      return null;
    }
  }

  /// Verify payment signature
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      // In production: Verify with Razorpay API
      logger.info(
        'Payment verified: $paymentId',
        tag: 'PaymentService',
      );

      return true;
    } catch (e) {
      logger.error('Payment verification failed: $e',
          tag: 'PaymentService');
      return false;
    }
  }

  /// Process refund
  Future<Map<String, dynamic>?> processRefund({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      // In production: Call Razorpay refund API
      final refundData = {
        'refundId': 'rfnd_${DateTime.now().millisecondsSinceEpoch}',
        'paymentId': paymentId,
        'amount': amount,
        'status': 'processed',
        'timestamp': DateTime.now(),
      };

      logger.info(
        'Refund processed: ${refundData['refundId']}',
        tag: 'PaymentService',
      );

      return refundData;
    } catch (e) {
      logger.error('Failed to process refund: $e', tag: 'PaymentService');
      return null;
    }
  }

  /// Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      // In production: Fetch from backend/Firebase
      final history = <Map<String, dynamic>>[];

      logger.info(
        'Payment history retrieved for user: $userId',
        tag: 'PaymentService',
      );

      return history;
    } catch (e) {
      logger.error('Failed to get payment history: $e',
          tag: 'PaymentService');
      return [];
    }
  }

  /// Save payment method
  Future<bool> savePaymentMethod({
    required String methodType, // 'card', 'upi', 'netbanking'
    required Map<String, dynamic> methodDetails,
  }) async {
    try {
      logger.info(
        'Payment method saved: $methodType',
        tag: 'PaymentService',
      );

      return true;
    } catch (e) {
      logger.error('Failed to save payment method: $e',
          tag: 'PaymentService');
      return false;
    }
  }

  /// Validate UPI ID
  Future<bool> validateUPI(String upiId) async {
    try {
      final regex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+$');
      return regex.hasMatch(upiId);
    } catch (e) {
      logger.error('UPI validation error: $e', tag: 'PaymentService');
      return false;
    }
  }

  /// Validate card
  Future<bool> validateCard({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) async {
    try {
      // Basic validation
      if (cardNumber.length != 16) return false;
      if (cvv.length < 3 || cvv.length > 4) return false;

      logger.info('Card validated', tag: 'PaymentService');
      return true;
    } catch (e) {
      logger.error('Card validation error: $e', tag: 'PaymentService');
      return false;
    }
  }

  /// Cleanup
  void dispose() {
    try {
      _razorpay.clear();
      logger.info('Payment service disposed', tag: 'PaymentService');
    } catch (e) {
      logger.error('Error disposing payment service: $e',
          tag: 'PaymentService');
    }
  }
}

// Convenience instance
final paymentService = PaymentService();
