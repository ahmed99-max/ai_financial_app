// lib/providers/expense_provider.dart
// Complete expense management provider with real-time Firestore integration and AI categorization

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import '../services/expense_categorizer_service.dart';
import '../constants/app_constants.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ExpenseCategorizer _categorizer = ExpenseCategorizer();

  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> _filteredExpenses = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String? _userId;
  StreamSubscription? _expenseStreamSubscription;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  List<ExpenseModel> get filteredExpenses => _filteredExpenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  // Initialize with user ID
  void initializeWithUser(String userId) {
    _userId = userId;
    _subscribeToExpenses();
  }

  // Real-time subscription to Firestore
  void _subscribeToExpenses() {
    if (_userId == null) return;

    _expenseStreamSubscription?.cancel();
    _expenseStreamSubscription =
        _firestoreService.getExpensesStream(_userId!).listen(
      (expenses) {
        _expenses = expenses;
        _applyFilters();
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load expenses: $error';
        notifyListeners();
      },
    );
  }

  // Add expense with AI categorization
  Future<void> addExpense({
    required String title,
    required double amount,
    required String paymentMethod,
    required String? merchantName,
    String? description,
    String? category,
    String? receiptUrl,
  }) async {
    if (_userId == null) throw Exception('User not initialized');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Auto-categorize if not provided
      final finalCategory = category ??
          await _categorizer.categorizeExpense(
            title: title,
            description: description,
            merchantName: merchantName,
            amount: amount,
          );

      final expense = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        title: title,
        description: description ?? '',
        amount: amount,
        category: finalCategory,
        date: DateTime.now(),
        type: ExpenseType.expense,
        paymentMethod: paymentMethod,
        merchantName: merchantName,
        receiptUrl: receiptUrl,
        isRecurring: false,
      );

      await _firestoreService.addExpense(expense);

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add expense: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update expense
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _firestoreService.updateExpense(expense);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update expense: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    if (_userId == null) return;

    try {
      await _firestoreService.deleteExpense(_userId!, expenseId);
      _expenses.removeWhere((e) => e.id == expenseId);
      _applyFilters();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete expense: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Apply all active filters
  void _applyFilters() {
    if (_selectedCategory == 'All') {
      _filteredExpenses = List.from(_expenses);
    } else {
      _filteredExpenses =
          _expenses.where((e) => e.category == _selectedCategory).toList();
    }
  }

  // Get category-wise summary
  Map<String, double> getCategorySummary() {
    final summary = <String, double>{};
    for (var expense in _expenses) {
      summary[expense.category] =
          (summary[expense.category] ?? 0) + expense.amount;
    }
    return summary;
  }

  // Get total expenses for period
  double getTotalExpenses({required int days}) {
    final startDate = DateTime.now().subtract(Duration(days: days));
    return _expenses
        .where((e) => e.date.isAfter(startDate))
        .fold(0, (sum, e) => sum + e.amount);
  }

  // Get daily average
  double getDailyAverage({required int days}) {
    final total = getTotalExpenses(days: days);
    return days > 0 ? total / days : 0;
  }

  // Get expenses by date range
  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .toList();
  }

  // Get top spending categories
  List<MapEntry<String, double>> getTopCategories({int limit = 5}) {
    final summary = getCategorySummary();
    final entries = summary.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  // Mark as recurring
  Future<void> markAsRecurring(String expenseId, String frequency) async {
    if (_userId == null) return;

    try {
      final expense = _expenses.firstWhere((e) => e.id == expenseId);
      final updated = ExpenseModel(
        id: expense.id,
        userId: expense.userId,
        title: expense.title,
        description: expense.description,
        amount: expense.amount,
        category: expense.category,
        date: expense.date,
        type: expense.type,
        paymentMethod: expense.paymentMethod,
        merchantName: expense.merchantName,
        transactionId: expense.transactionId,
        receiptUrl: expense.receiptUrl,
        isRecurring: true,
        recurringFrequency: frequency,
      );
      await _firestoreService.updateExpense(updated);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark as recurring: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get spending trend (last 7 days)
  List<double> getSpendingTrend({int days = 7}) {
    final trend = <double>[];
    for (int i = days; i > 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final dayExpenses = _expenses
          .where((e) => e.date.isAfter(dayStart) && e.date.isBefore(dayEnd))
          .fold(0.0, (sum, e) => sum + e.amount);

      trend.add(dayExpenses);
    }
    return trend;
  }

  // Clear resources
  @override
  void dispose() {
    _expenseStreamSubscription?.cancel();
    super.dispose();
  }
}
