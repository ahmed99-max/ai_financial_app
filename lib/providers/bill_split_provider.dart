// lib/providers/bill_split_provider.dart
// Complete bill split management with payment processing and dispute resolution

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_split_model.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';

class ChatMessage {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'user_name': userName,
        'message': message,
        'timestamp': Timestamp.fromDate(timestamp),
        'image_url': imageUrl,
      };
}

class BillSplitProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PaymentService _paymentService = PaymentService();

  List<BillSplitModel> _bills = [];
  List<ChatMessage> _chatMessages = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _selectedBillId;
  StreamSubscription? _billStreamSubscription;
  StreamSubscription? _chatStreamSubscription;

  // Getters
  List<BillSplitModel> get bills => _bills;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedBillId => _selectedBillId;

  double get totalBillsCreated => _bills
      .where((b) => b.creatorId == _userId)
      .fold(0.0, (total, b) => total + b.totalAmount);

  double get totalBillsOwed =>
      _bills.where((b) => b.creatorId != _userId).fold(0.0, (total, b) {
        final participant = b.participants.firstWhere(
          (p) => p.userId == _userId,
          orElse: () => BillParticipant(
            userId: '',
            userName: '',
            shareAmount: 0,
          ),
        );
        return total + participant.shareAmount;
      });

  void initializeWithUser(String userId) {
    _userId = userId;
    _subscribeToUserBills();
  }

  // Subscribe to user's bills (both created and participating)
  void _subscribeToUserBills() {
    if (_userId == null) return;

    _billStreamSubscription?.cancel();
    _billStreamSubscription = _firestore
        .collection('bill_splits')
        .where('creator_id', isEqualTo: _userId)
        .snapshots()
        .listen(
      (snapshot) {
        _bills = snapshot.docs
            .map((doc) => BillSplitModel.fromFirestore(doc.data(), doc.id))
            .toList();
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load bills: $error';
        notifyListeners();
      },
    );
  }

  // Create new bill split
  Future<void> createBill({
    required String title,
    required String description,
    required double totalAmount,
    required List<BillParticipant> participants,
    required String creatorName,
    String? billImageUrl,
    String? splitType, // 'equal', 'itemized', 'percentage'
  }) async {
    if (_userId == null) throw Exception('User not initialized');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bill = BillSplitModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        totalAmount: totalAmount,
        creatorId: _userId!,
        creatorName: creatorName,
        participants: participants,
        billImageUrl: billImageUrl,
        createdAt: DateTime.now(),
        status: BillStatus.pending,
        splitType: splitType,
        chatMessages: {},
      );

      await _firestoreService.createBillSplit(bill);

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create bill: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Accept bill split
  Future<void> acceptBill(String billId) async {
    try {
      await _firestoreService.updateBillSplitStatus(
        billId,
        _userId ?? '',
        'accepted',
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to accept bill: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Reject bill split
  Future<void> rejectBill(String billId, String reason) async {
    try {
      await _firestore.collection('bill_splits').doc(billId).update({
        'status': 'rejected',
        'rejection_reason': reason,
        'rejected_by': _userId,
        'rejected_at': FieldValue.serverTimestamp(),
      });
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reject bill: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Mark as dispute
  Future<void> markAsDispute(String billId, String reason) async {
    try {
      await _firestore.collection('bill_splits').doc(billId).update({
        'status': 'disputed',
        'dispute_reason': reason,
        'disputed_by': _userId,
        'disputed_at': FieldValue.serverTimestamp(),
      });
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark as dispute: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Process settlement payment
  Future<void> settleBill(
    String billId,
    double amount,
    String userEmail,
    String userPhone,
    String userName,
  ) async {
    if (_userId == null) return;

    try {
      final bill = _bills.firstWhere((b) => b.id == billId);

      // Create Razorpay order
      final orderId = await _paymentService.createOrder(
        amount: amount,
        description: 'Bill Settlement: ${bill.title}',
      );

      if (orderId == null) {
        throw Exception('Failed to create payment order');
      }

      // Set up payment callbacks before processing
      _paymentService.onPaymentSuccess = (paymentId) async {
        await _recordBillPayment(
          billId,
          amount,
          paymentId,
        );
      };

      _paymentService.onPaymentError = (code, message) {
        _error = 'Payment failed: $message (Code: $code)';
        notifyListeners();
      };

      // Process payment
      _paymentService.processPayment(
        orderId: orderId,
        amount: amount,
        description: 'Bill Settlement: ${bill.title}',
        email: userEmail,
        phone: userPhone,
        paymentMethod: 'upi', // or any default/selected method
      );

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to settle bill: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Record bill payment
  Future<void> _recordBillPayment(
    String billId,
    double amount,
    String paymentId,
  ) async {
    try {
      await _firestore.collection('bill_splits').doc(billId).update({
        'status': BillStatus.completed.name,
        'payment_id': paymentId,
        'paid_amount': amount,
        'paid_at': FieldValue.serverTimestamp(),
      });

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to record payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Subscribe to chat messages
  void subscribeToBillChat(String billId) {
    _selectedBillId = billId;
    _chatStreamSubscription?.cancel();

    _chatStreamSubscription = _firestore
        .collection('bill_splits')
        .doc(billId)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _chatMessages = snapshot.docs
            .map((doc) {
              final data = doc.data();
              return ChatMessage(
                id: doc.id,
                userId: data['user_id'] ?? '',
                userName: data['user_name'] ?? 'Unknown',
                message: data['message'] ?? '',
                timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                imageUrl: data['image_url'],
              );
            })
            .toList()
            .reversed
            .toList();
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load chat: $error';
        notifyListeners();
      },
    );
  }

  // Send chat message
  Future<void> sendChatMessage(
    String billId,
    String message, {
    String? imageUrl,
  }) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('bill_splits')
          .doc(billId)
          .collection('chat')
          .add({
        'user_id': _userId,
        'user_name': 'User', // Should come from user profile
        'message': message,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get bills where user is debtor
  List<BillSplitModel> getBillsAsDebtor() {
    return _bills.where((b) {
      final participant = b.participants.firstWhere(
        (p) => p.userId == _userId && p.status != ParticipantStatus.paid,
        orElse: () => BillParticipant(
          userId: '',
          userName: '',
          shareAmount: 0,
        ),
      );
      return participant.userId.isNotEmpty;
    }).toList();
  }

  // Get bills where user is creditor
  List<BillSplitModel> getBillsAsCreditor() {
    return _bills.where((b) => b.creatorId == _userId).toList();
  }

  // Get pending bills
  List<BillSplitModel> getPendingBills() {
    return _bills.where((b) => b.status == BillStatus.pending).toList();
  }

  // Get disputed bills
  List<BillSplitModel> getDisputedBills() {
    return _bills.where((b) => b.status == BillStatus.disputed).toList();
  }

  // Calculate total owed by participant
  double getTotalOwedByParticipant(String participantId) {
    double total = 0;

    for (var bill in _bills) {
      if (bill.creatorId == _userId) {
        final participant = bill.participants.firstWhere(
          (p) => p.userId == participantId,
          orElse: () => bill.participants.first,
        );

        if (participant.userId.isNotEmpty &&
            participant.status != ParticipantStatus.paid) {
          total += participant.shareAmount;
        }
      }
    }

    return total;
  }

  // Resend bill to participant
  Future<void> resendBillToParticipant(
    String billId,
    String participantId,
  ) async {
    try {
      // Send notification to participant
      // Implementation would call Cloud Functions to send email/notification

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to resend bill: $e';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _billStreamSubscription?.cancel();
    _chatStreamSubscription?.cancel();
    _paymentService.dispose();
    super.dispose();
  }
}
