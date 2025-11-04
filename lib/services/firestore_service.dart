// lib/services/firestore_service.dart
// Complete Firestore CRUD operations with optimized queries

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/loan_model.dart';
import '../models/investment_model.dart';
import '../models/bill_split_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== EXPENSE OPERATIONS ====================

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(expense.userId)
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toFirestore());
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(expense.userId)
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toFirestore());
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  Stream<List<ExpenseModel>> getExpensesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<ExpenseModel>> getExpensesByCategory(
      String userId, String category,
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('category', isEqualTo: category)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();
      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  // ==================== LOAN OPERATIONS ====================

  Future<void> addLoan(LoanModel loan) async {
    try {
      await _firestore
          .collection('users')
          .doc(loan.userId)
          .collection('loans')
          .doc(loan.id)
          .set(loan.toFirestore());
    } catch (e) {
      throw Exception('Failed to add loan: $e');
    }
  }

  Stream<List<LoanModel>> getLoansStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('loans')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LoanModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateEMIPayment(
      String userId, String loanId, EMIPayment payment) async {
    try {
      final loan = await _firestore
          .collection('users')
          .doc(userId)
          .collection('loans')
          .doc(loanId)
          .get();

      if (!loan.exists) throw Exception('Loan not found');

      final loanData = LoanModel.fromFirestore(loan.data()!, loanId);
      final updatedHistory = [...loanData.emiHistory, payment];

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('loans')
          .doc(loanId)
          .update({
        'emi_history': updatedHistory.map((e) => e.toMap()).toList(),
        'paid_emis': FieldValue.increment(1),
        'pending_emis': FieldValue.increment(-1),
        'next_emi_date':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      });
    } catch (e) {
      throw Exception('Failed to update EMI: $e');
    }
  }

  // ==================== INVESTMENT OPERATIONS ====================

  Future<void> addInvestment(InvestmentModel investment) async {
    try {
      await _firestore
          .collection('users')
          .doc(investment.userId)
          .collection('investments')
          .doc(investment.id)
          .set(investment.toFirestore());
    } catch (e) {
      throw Exception('Failed to add investment: $e');
    }
  }

  Stream<List<InvestmentModel>> getInvestmentsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('investments')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InvestmentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateInvestmentPrice(String userId, String investmentId,
      double newPrice, PriceDataPoint dataPoint) async {
    try {
      final investment = await _firestore
          .collection('users')
          .doc(userId)
          .collection('investments')
          .doc(investmentId)
          .get();

      if (!investment.exists) throw Exception('Investment not found');

      final invData =
          InvestmentModel.fromFirestore(investment.data()!, investmentId);
      final updatedHistory = [...invData.priceHistory, dataPoint];
      final newCurrentValue = invData.quantity * newPrice;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('investments')
          .doc(investmentId)
          .update({
        'current_price': newPrice,
        'current_value': newCurrentValue,
        'price_history': updatedHistory.map((e) => e.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update investment price: $e');
    }
  }

  // ==================== BILL SPLIT OPERATIONS ====================

  Future<void> createBillSplit(BillSplitModel bill) async {
    try {
      await _firestore
          .collection('bill_splits')
          .doc(bill.id)
          .set(bill.toFirestore());

      // Add to each participant's bills
      for (var participant in bill.participants) {
        await _firestore
            .collection('users')
            .doc(participant.userId)
            .collection('bill_splits')
            .doc(bill.id)
            .set({
          'bill_id': bill.id,
          'creator_id': bill.creatorId,
          'status': bill.status.name,
          'share_amount': participant.shareAmount,
          'created_at': Timestamp.fromDate(bill.createdAt),
        });
      }
    } catch (e) {
      throw Exception('Failed to create bill split: $e');
    }
  }

  Future<void> updateBillSplitStatus(
      String billId, String participantId, String status) async {
    try {
      await _firestore.collection('bill_splits').doc(billId).update({
        'participants': FieldValue.arrayUnion([
          {'userId': participantId, 'status': status}
        ])
      });
    } catch (e) {
      throw Exception('Failed to update bill status: $e');
    }
  }

  Stream<List<BillSplitModel>> getUserBillsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bill_splits')
        .snapshots()
        .asyncMap((snapshot) async {
      final billIds =
          snapshot.docs.map((doc) => doc['bill_id'] as String).toList();

      if (billIds.isEmpty) return [];

      final bills = await Future.wait(
        billIds.map((id) async {
          final billDoc =
              await _firestore.collection('bill_splits').doc(id).get();
          if (billDoc.exists) {
            return BillSplitModel.fromFirestore(billDoc.data()!, id);
          }
          return null;
        }),
      );

      return bills.whereType<BillSplitModel>().toList();
    });
  }

  Future<void> addBillMessage(
      String billId, String userId, String message) async {
    try {
      await _firestore
          .collection('bill_splits')
          .doc(billId)
          .collection('chat')
          .add({
        'user_id': userId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add message: $e');
    }
  }

  // ==================== BUDGET OPERATIONS ====================

  Future<void> setBudget(
      String userId, String categoryName, double budgetLimit) async {
    try {
      final budgetId =
          '${categoryName}_${DateTime.now().year}_${DateTime.now().month}';
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .set({
        'category_name': categoryName,
        'budget_limit': budgetLimit,
        'spent': 0,
        'period': 'monthly',
        'start_date': Timestamp.fromDate(
            DateTime(DateTime.now().year, DateTime.now().month)),
        'end_date': Timestamp.fromDate(
            DateTime(DateTime.now().year, DateTime.now().month + 1)),
      });
    } catch (e) {
      throw Exception('Failed to set budget: $e');
    }
  }

  Stream<List<CategoryBudget>> getBudgetsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryBudget.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<double> getCategorySpent(
      String userId, String category, int days) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('category', isEqualTo: category)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final expense = ExpenseModel.fromFirestore(doc.data(), doc.id);
        total += expense.amount;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  // ==================== TRANSACTION HISTORY ====================

  Stream<QuerySnapshot> getTransactionHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots();
  }
}
