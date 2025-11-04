// lib/providers/loan_provider.dart
// Complete loan management with EMI tracking, payment processing, and AI recommendations

import 'dart:async';
import 'dart:math';

import 'package:ai_finance/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_model.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';

class LoanOffer {
  final String id;
  final String bankName;
  final double interestRate;
  final int maxTenure;
  final double maxAmount;
  final double processingFee;
  final bool preApproved;
  final String eligibilityReason;

  LoanOffer({
    required this.id,
    required this.bankName,
    required this.interestRate,
    required this.maxTenure,
    required this.maxAmount,
    required this.processingFee,
    required this.preApproved,
    required this.eligibilityReason,
  });
}

class LoanReminder {
  final String loanId;
  final String loanName;
  final double emiAmount;
  final DateTime dueDate;
  final int daysUntilDue;
  final bool isOverdue;

  LoanReminder({
    required this.loanId,
    required this.loanName,
    required this.emiAmount,
    required this.dueDate,
    required this.daysUntilDue,
    required this.isOverdue,
  });
}

class LoanProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PaymentService _paymentService = PaymentService();

  List<LoanModel> _loans = [];
  List<LoanOffer> _preApprovedOffers = [];
  List<LoanReminder> _reminders = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  StreamSubscription? _loanStreamSubscription;

  // Getters
  List<LoanModel> get loans => _loans;
  List<LoanOffer> get preApprovedOffers => _preApprovedOffers;
  List<LoanReminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalLoanAmount =>
      _loans.fold(0, (sum, l) => sum + l.principalAmount);
  double get totalEMIObligations =>
      _loans.fold(0, (sum, l) => sum + (l.emiAmount * l.pendingEmis));

  void initializeWithUser(String userId) {
    _userId = userId;
    _subscribeToLoans();
    _generatePreApprovedOffers();
  }

  // Real-time subscription to loans
  void _subscribeToLoans() {
    if (_userId == null) return;

    _loanStreamSubscription?.cancel();
    _loanStreamSubscription = _firestore
        .collection('users')
        .doc(_userId!)
        .collection('loans')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen(
      (snapshot) {
        _loans = snapshot.docs
            .map((doc) => LoanModel.fromFirestore(doc.data(), doc.id))
            .toList();
        _generateReminders();
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load loans: $error';
        notifyListeners();
      },
    );
  }

  // Add new loan
  Future<void> addLoan({
    required String loanName,
    required String loanType,
    required double principalAmount,
    required double interestRate,
    required int tenureMonths,
    required String? bankName,
    required String? accountNumber,
    required DateTime startDate,
    required bool autoDebit,
  }) async {
    if (_userId == null) throw Exception('User not initialized');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate EMI using formula: EMI = [P × r × (1+r)^n] / [(1+r)^n - 1]
      final monthlyRate = interestRate / 100 / 12;
      final emiAmount =
          _calculateEMI(principalAmount, monthlyRate, tenureMonths);
      final totalPayable = emiAmount * tenureMonths;
      final totalInterest = totalPayable - principalAmount;

      final loan = LoanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        loanName: loanName,
        loanType: loanType,
        principalAmount: principalAmount,
        interestRate: interestRate,
        tenureMonths: tenureMonths,
        emiAmount: emiAmount,
        totalInterest: totalInterest,
        totalPayable: totalPayable,
        startDate: startDate,
        status: LoanStatus.active,
        bankName: bankName,
        accountNumber: accountNumber,
        paidEmis: 0,
        pendingEmis: tenureMonths,
        nextEmiDate: startDate.add(const Duration(days: 30)),
        autoDebit: autoDebit,
      );

      await _firestoreService.addLoan(loan);

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add loan: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Calculate EMI using standard formula
  double _calculateEMI(double principal, double monthlyRate, int months) {
    if (monthlyRate == 0) return principal / months;

    final numerator = principal * monthlyRate * pow((1 + monthlyRate), months);
    final denominator = pow((1 + monthlyRate), months) - 1;

    return numerator / denominator;
  }

  // Pay EMI with Razorpay
  Future<void> payEMI(
    String loanId,
    double emiAmount,
    String userEmail,
    String userPhone,
  ) async {
    if (_userId == null) return;

    try {
      final loan = _loans.firstWhere((l) => l.id == loanId);

      // Create Razorpay order
      final orderId = await _paymentService.createOrder(
        amount: emiAmount,
        description: 'EMI Payment for ${loan.loanName}',
      );

      // Process payment
      _paymentService.processPayment(
        orderId: orderId,
        amount: emiAmount,
        email: userEmail,
        phone: userPhone,
        description: 'EMI Payment for ${loan.loanName}',
        paymentMethod: 'credit_card',
      );

      // Listen for payment success
      _paymentService.onPaymentSuccess = (paymentId) async {
        await _recordEMIPayment(loanId, emiAmount, paymentId);
      };

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to process EMI payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Record EMI payment
  Future<void> _recordEMIPayment(
    String loanId,
    double amount,
    String paymentId,
  ) async {
    if (_userId == null) return;

    final loan = _loans.firstWhere((l) => l.id == loanId);

    try {
      final payment = EMIPayment(
        emiNumber: loan.paidEmis + 1,
        amount: amount,
        paidDate: DateTime.now(),
        dueDate: loan.nextEmiDate ?? DateTime.now(),
        transactionId: paymentId,
        paymentMode: 'online',
      );

      await _firestoreService.updateEMIPayment(_userId!, loanId, payment);

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to record payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get EMI schedule
  List<Map<String, dynamic>> getEMISchedule(String loanId) {
    final loan = _loans.firstWhere(
      (l) => l.id == loanId,
      orElse: () => LoanModel(
        id: '',
        userId: _userId ?? '',
        loanName: '',
        loanType: '',
        principalAmount: 0,
        interestRate: 0,
        tenureMonths: 0,
        emiAmount: 0,
        totalInterest: 0,
        totalPayable: 0,
        startDate: DateTime.now(),
      ),
    );

    if (loan.id.isEmpty) return [];

    final schedule = <Map<String, dynamic>>[];
    double balance = loan.principalAmount;

    for (int i = 1; i <= loan.tenureMonths; i++) {
      final dueDate = loan.startDate.add(Duration(days: i * 30));
      final interest = balance * (loan.interestRate / 100 / 12);
      final principal = loan.emiAmount - interest;
      balance -= principal;

      schedule.add({
        'month': i,
        'due_date': dueDate,
        'emi': loan.emiAmount,
        'principal': principal,
        'interest': interest,
        'balance': balance.clamp(0, double.infinity),
        'is_paid': i <= loan.paidEmis,
      });
    }

    return schedule;
  }

  // Generate pre-approved loan offers
  Future<void> _generatePreApprovedOffers() async {
    _preApprovedOffers = [];

    // Sample offers (would come from AI scoring in production)
    final offers = [
      LoanOffer(
        id: '1',
        bankName: 'ICICI Bank',
        interestRate: 9.5,
        maxTenure: 84,
        maxAmount: 500000,
        processingFee: 1000,
        preApproved: true,
        eligibilityReason: 'Excellent credit profile',
      ),
      LoanOffer(
        id: '2',
        bankName: 'HDFC Bank',
        interestRate: 10.0,
        maxTenure: 72,
        maxAmount: 400000,
        processingFee: 1500,
        preApproved: true,
        eligibilityReason: 'Good credit score',
      ),
      LoanOffer(
        id: '3',
        bankName: 'Axis Bank',
        interestRate: 11.0,
        maxTenure: 60,
        maxAmount: 300000,
        processingFee: 2000,
        preApproved: false,
        eligibilityReason: 'Eligible after income verification',
      ),
    ];

    _preApprovedOffers = offers.where((o) => o.preApproved).toList();
    notifyListeners();
  }

  // Check loan eligibility (AI scoring)
  Future<Map<String, dynamic>> checkEligibility() async {
    // Placeholder for AI eligibility checking
    // In production, would call Cloud Functions

    return {
      'eligible': true,
      'score': 750,
      'max_loan_amount': 500000,
      'recommended_rate': 9.5,
      'max_tenure': 84,
    };
  }

  // Generate reminders
  void _generateReminders() {
    _reminders = [];

    for (var loan in _loans) {
      if (loan.nextEmiDate != null) {
        final daysUntilDue =
            loan.nextEmiDate!.difference(DateTime.now()).inDays;
        final isOverdue = daysUntilDue < 0;

        _reminders.add(
          LoanReminder(
            loanId: loan.id,
            loanName: loan.loanName,
            emiAmount: loan.emiAmount,
            dueDate: loan.nextEmiDate!,
            daysUntilDue: daysUntilDue.abs(),
            isOverdue: isOverdue,
          ),
        );
      }
    }

    // Sort by due date
    _reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get loan details
  LoanModel? getLoanDetails(String loanId) {
    try {
      return _loans.firstWhere((l) => l.id == loanId);
    } catch (e) {
      return null;
    }
  }

  // Get remaining balance
  double getRemainingBalance(String loanId) {
    final loan = getLoanDetails(loanId);
    if (loan == null) return 0;

    final emisPaid = loan.paidEmis;
    final schedule = getEMISchedule(loanId);

    if (schedule.isEmpty) return loan.principalAmount;

    return schedule[emisPaid]['balance'] ?? 0;
  }

  // Get interest paid so far
  double getInterestPaidSoFar(String loanId) {
    final schedule = getEMISchedule(loanId);
    double totalInterest = 0;

    for (int i = 0;
        i < _loans.firstWhere((l) => l.id == loanId).paidEmis;
        i++) {
      totalInterest += schedule[i]['interest'] ?? 0;
    }

    return totalInterest;
  }

  // Get upcoming reminders
  List<LoanReminder> getUpcomingReminders({int daysAhead = 7}) {
    return _reminders
        .where((r) => r.daysUntilDue <= daysAhead && !r.isOverdue)
        .toList();
  }

  // Get overdue reminders
  List<LoanReminder> getOverdueReminders() {
    return _reminders.where((r) => r.isOverdue).toList();
  }

  @override
  void dispose() {
    _loanStreamSubscription?.cancel();
    _paymentService.dispose();
    super.dispose();
  }
}
