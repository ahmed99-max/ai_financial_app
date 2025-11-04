import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String id;
  final String userId;
  final String loanName;
  final String loanType;
  final double principalAmount;
  final double interestRate;
  final int tenureMonths;
  final double emiAmount;
  final double totalInterest;
  final double totalPayable;
  final DateTime startDate;
  final DateTime? endDate;
  final LoanStatus status;
  final String? bankName;
  final String? accountNumber;
  final List<EMIPayment> emiHistory;
  final int paidEmis;
  final int pendingEmis;
  final DateTime? nextEmiDate;
  final bool autoDebit;

  LoanModel({
    required this.id,
    required this.userId,
    required this.loanName,
    required this.loanType,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiAmount,
    required this.totalInterest,
    required this.totalPayable,
    required this.startDate,
    this.endDate,
    this.status = LoanStatus.active,
    this.bankName,
    this.accountNumber,
    this.emiHistory = const [],
    this.paidEmis = 0,
    this.pendingEmis = 0,
    this.nextEmiDate,
    this.autoDebit = false,
  });

  factory LoanModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LoanModel(
      id: id,
      userId: data['user_id'] ?? '',
      loanName: data['loan_name'] ?? '',
      loanType: data['loan_type'] ?? '',
      principalAmount: (data['principal_amount'] ?? 0).toDouble(),
      interestRate: (data['interest_rate'] ?? 0).toDouble(),
      tenureMonths: data['tenure_months'] ?? 0,
      emiAmount: (data['emi_amount'] ?? 0).toDouble(),
      totalInterest: (data['total_interest'] ?? 0).toDouble(),
      totalPayable: (data['total_payable'] ?? 0).toDouble(),
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp?)?.toDate(),
      status: LoanStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => LoanStatus.active,
      ),
      bankName: data['bank_name'],
      accountNumber: data['account_number'],
      emiHistory: (data['emi_history'] as List<dynamic>?)
              ?.map((e) => EMIPayment.fromMap(e))
              .toList() ??
          [],
      paidEmis: data['paid_emis'] ?? 0,
      pendingEmis: data['pending_emis'] ?? 0,
      nextEmiDate: (data['next_emi_date'] as Timestamp?)?.toDate(),
      autoDebit: data['auto_debit'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'loan_name': loanName,
      'loan_type': loanType,
      'principal_amount': principalAmount,
      'interest_rate': interestRate,
      'tenure_months': tenureMonths,
      'emi_amount': emiAmount,
      'total_interest': totalInterest,
      'total_payable': totalPayable,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status.name,
      'bank_name': bankName,
      'account_number': accountNumber,
      'emi_history': emiHistory.map((e) => e.toMap()).toList(),
      'paid_emis': paidEmis,
      'pending_emis': pendingEmis,
      'next_emi_date': nextEmiDate != null ? Timestamp.fromDate(nextEmiDate!) : null,
      'auto_debit': autoDebit,
    };
  }

  double get remainingAmount => totalPayable - (paidEmis * emiAmount);

  double get paymentProgress => (paidEmis / tenureMonths) * 100;

  bool get isOverdue {
    if (nextEmiDate == null) return false;
    return DateTime.now().isAfter(nextEmiDate!);
  }

  int get daysUntilNextEmi {
    if (nextEmiDate == null) return 0;
    return nextEmiDate!.difference(DateTime.now()).inDays;
  }
}

class EMIPayment {
  final int emiNumber;
  final double amount;
  final DateTime paidDate;
  final DateTime dueDate;
  final String? transactionId;
  final String paymentMode;
  final bool isLate;

  EMIPayment({
    required this.emiNumber,
    required this.amount,
    required this.paidDate,
    required this.dueDate,
    this.transactionId,
    required this.paymentMode,
    this.isLate = false,
  });

  factory EMIPayment.fromMap(Map<String, dynamic> data) {
    return EMIPayment(
      emiNumber: data['emi_number'] ?? 0,
      amount: (data['amount'] ?? 0).toDouble(),
      paidDate: (data['paid_date'] as Timestamp).toDate(),
      dueDate: (data['due_date'] as Timestamp).toDate(),
      transactionId: data['transaction_id'],
      paymentMode: data['payment_mode'] ?? '',
      isLate: data['is_late'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emi_number': emiNumber,
      'amount': amount,
      'paid_date': Timestamp.fromDate(paidDate),
      'due_date': Timestamp.fromDate(dueDate),
      'transaction_id': transactionId,
      'payment_mode': paymentMode,
      'is_late': isLate,
    };
  }
}

enum LoanStatus { active, completed, closed, defaulted }
