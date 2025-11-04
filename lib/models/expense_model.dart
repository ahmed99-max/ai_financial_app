import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final ExpenseType type;
  final String paymentMethod;
  final String? merchantName;
  final String? merchantUpiId;
  final String? transactionId;
  final String? receiptUrl;
  final bool isRecurring;
  final String? recurringFrequency;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.amount,
    required this.category,
    required this.date,
    this.type = ExpenseType.expense,
    this.paymentMethod = 'UPI',
    this.merchantName,
    this.merchantUpiId,
    this.transactionId,
    this.receiptUrl,
    this.isRecurring = false,
    this.recurringFrequency,
  });

  factory ExpenseModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ExpenseModel(
      id: id,
      userId: data['user_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      type: ExpenseType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ExpenseType.expense,
      ),
      paymentMethod: data['payment_method'] ?? 'UPI',
      merchantName: data['merchant_name'],
      merchantUpiId: data['merchant_upi_id'],
      transactionId: data['transaction_id'],
      receiptUrl: data['receipt_url'],
      isRecurring: data['is_recurring'] ?? false,
      recurringFrequency: data['recurring_frequency'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'type': type.name,
      'payment_method': paymentMethod,
      'merchant_name': merchantName,
      'merchant_upi_id': merchantUpiId,
      'transaction_id': transactionId,
      'receipt_url': receiptUrl,
      'is_recurring': isRecurring,
      'recurring_frequency': recurringFrequency,
    };
  }
}

class CategoryBudget {
  final String id;
  final String userId;
  final String categoryName;
  final double budgetLimit;
  final double spent;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final String? iconName;
  final String? color;

  CategoryBudget({
    required this.id,
    required this.userId,
    required this.categoryName,
    required this.budgetLimit,
    this.spent = 0,
    this.period = 'monthly',
    required this.startDate,
    required this.endDate,
    this.iconName,
    this.color,
  });

  factory CategoryBudget.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryBudget(
      id: id,
      userId: data['user_id'] ?? '',
      categoryName: data['category_name'] ?? '',
      budgetLimit: (data['budget_limit'] ?? 0).toDouble(),
      spent: (data['spent'] ?? 0).toDouble(),
      period: data['period'] ?? 'monthly',
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),
      iconName: data['icon_name'],
      color: data['color'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'category_name': categoryName,
      'budget_limit': budgetLimit,
      'spent': spent,
      'period': period,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'icon_name': iconName,
      'color': color,
    };
  }

  double get remainingBudget => budgetLimit - spent;

  double get percentageUsed => (spent / budgetLimit) * 100;

  bool get isOverBudget => spent > budgetLimit;

  bool get isNearLimit => percentageUsed >= 80;
}

enum ExpenseType {
  expense,
  income,
  investment,
  loan,
  billSplit,
  transfer
}
