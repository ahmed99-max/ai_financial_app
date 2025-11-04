// lib/services/payment_service.dart
// Razorpay payment integration for bill splits and EMI payments

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();
  late Function(String) onPaymentSuccess;
  late Function(String, String) onPaymentError;

  PaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void processPayment({
    required String orderId,
    required double amount,
    required String email,
    required String phone,
    required String description,
    required String paymentMethod,
  }) {
    final options = {
      'key': 'YOUR_RAZORPAY_KEY', // Load from Firebase Remote Config
      'amount': (amount * 100).toInt(), // Convert to paise
      'currency': 'INR',
      'name': 'AI Finance',
      'description': description,
      'order_id': orderId,
      'prefill': {
        'email': email,
        'contact': phone,
      },
      'notes': {
        'payment_method': paymentMethod,
        'timestamp': DateTime.now().toString(),
      },
      'theme': {
        'color': '#6C63FF',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      onPaymentError(orderId, e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onPaymentSuccess(response.paymentId ?? '');
    _recordTransaction(
      paymentId: response.paymentId,
      orderId: response.orderId,
      signature: response.signature,
      status: 'completed',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onPaymentError(response.code.toString(), response.message ?? 'Payment failed');
    _recordTransaction(
      orderId: response.code.toString(),
      status: 'failed',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  Future<void> _recordTransaction({
    required String status,
    String? paymentId,
    String? orderId,
    String? signature,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .add({
        'payment_id': paymentId,
        'order_id': orderId,
        'signature': signature,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to record transaction: $e');
    }
  }

  Future<String> createOrder({
    required double amount,
    required String description,
  }) async {
    try {
      // This would call your backend Cloud Function
      // which creates the Razorpay order
      final response = await FirebaseFirestore.instance
          .collection('orders')
          .add({
        'amount': amount,
        'description': description,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });
      return response.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
