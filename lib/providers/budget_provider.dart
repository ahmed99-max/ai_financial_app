// lib/providers/budget_provider.dart
// Budget management provider with real-time tracking and smart alerts

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String categoryName;
  final double budgetLimit;
  final String period; // 'monthly', 'weekly', 'yearly'
  final DateTime startDate;
  final DateTime endDate;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.categoryName,
    required this.budgetLimit,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() => {
        'category_name': categoryName,
        'budget_limit': budgetLimit,
        'period': period,
        'start_date': Timestamp.fromDate(startDate),
        'end_date': Timestamp.fromDate(endDate),
      };

  factory BudgetModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BudgetModel(
      id: id,
      userId: data['user_id'] ?? '',
      categoryName: data['category_name'] ?? '',
      budgetLimit: (data['budget_limit'] ?? 0).toDouble(),
      period: data['period'] ?? 'monthly',
      startDate: (data['start_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['end_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class BudgetAlert {
  final String id;
  final String categoryName;
  final double spent;
  final double limit;
  final double percentageUsed;
  final DateTime timestamp;

  BudgetAlert({
    required this.id,
    required this.categoryName,
    required this.spent,
    required this.limit,
    required this.percentageUsed,
    required this.timestamp,
  });
}

class BudgetProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BudgetModel> _budgets = [];
  List<BudgetAlert> _alerts = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  StreamSubscription? _budgetStreamSubscription;

  // Getters
  List<BudgetModel> get budgets => _budgets;
  List<BudgetAlert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initializeWithUser(String userId) {
    _userId = userId;
    _subscribeToBudgets();
  }

  void _subscribeToBudgets() {
    if (_userId == null) return;

    _budgetStreamSubscription?.cancel();
    _budgetStreamSubscription = _firestore
        .collection('users')
        .doc(_userId!)
        .collection('budgets')
        .snapshots()
        .listen(
      (snapshot) async {
        _budgets = snapshot.docs
            .map((doc) => BudgetModel.fromFirestore(doc.data(), doc.id))
            .toList();
        await _checkBudgetAlerts();
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load budgets: $error';
        notifyListeners();
      },
    );
  }

  // Set budget for category
  Future<void> setBudget({
    required String categoryName,
    required double budgetLimit,
    required String period,
  }) async {
    if (_userId == null) throw Exception('User not initialized');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      DateTime startDate, endDate;

      if (period == 'monthly') {
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
      } else if (period == 'weekly') {
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 7));
      } else {
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
      }

      final budgetId = '${categoryName}_${now.year}_${now.month}';

      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('budgets')
          .doc(budgetId)
          .set({
        'category_name': categoryName,
        'budget_limit': budgetLimit,
        'period': period,
        'start_date': Timestamp.fromDate(startDate),
        'end_date': Timestamp.fromDate(endDate),
        'created_at': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to set budget: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update budget
  Future<void> updateBudget(String budgetId, double newLimit) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('budgets')
          .doc(budgetId)
          .update({'budget_limit': newLimit});

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update budget: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Delete budget
  Future<void> deleteBudget(String budgetId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('budgets')
          .doc(budgetId)
          .delete();

      _budgets.removeWhere((b) => b.id == budgetId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete budget: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Check and generate budget alerts
  Future<void> _checkBudgetAlerts() async {
    if (_userId == null) return;

    final newAlerts = <BudgetAlert>[];

    for (var budget in _budgets) {
      final spent = await _firestoreService.getCategorySpent(
        _userId!,
        budget.categoryName,
        (budget.endDate.difference(budget.startDate).inDays),
      );

      final percentageUsed = (spent / budget.budgetLimit) * 100;

      if (percentageUsed >= 80) {
        newAlerts.add(
          BudgetAlert(
            id: '${budget.id}_${DateTime.now().millisecondsSinceEpoch}',
            categoryName: budget.categoryName,
            spent: spent,
            limit: budget.budgetLimit,
            percentageUsed: percentageUsed,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    _alerts = newAlerts;
  }

  // Get budget progress for category
  Future<double> getCategoryBudgetProgress(String categoryName) async {
    if (_userId == null) return 0;

    final budget = _budgets.firstWhere(
      (b) => b.categoryName == categoryName,
      orElse: () => BudgetModel(
        id: '',
        userId: _userId!,
        categoryName: categoryName,
        budgetLimit: 0,
        period: 'monthly',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
    );

    if (budget.budgetLimit == 0) return 0;

    final spent = await _firestoreService.getCategorySpent(
      _userId!,
      categoryName,
      (budget.endDate.difference(budget.startDate).inDays),
    );

    return (spent / budget.budgetLimit).clamp(0, 1);
  }

  // Get total budget for current month
  double getTotalMonthlyBudget() {
    return _budgets
        .where((b) => b.period == 'monthly')
        .fold(0, (sum, b) => sum + b.budgetLimit);
  }

  // Get category budget
  double getCategoryBudget(String categoryName) {
    final budget = _budgets.firstWhere(
      (b) => b.categoryName == categoryName,
      orElse: () => BudgetModel(
        id: '',
        userId: _userId ?? '',
        categoryName: categoryName,
        budgetLimit: 0,
        period: 'monthly',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
    );
    return budget.budgetLimit;
  }

  // Get AI-suggested budget (based on historical spending)
  Future<Map<String, double>> getAISuggestedBudgets() async {
    if (_userId == null) return {};

    // Get last 3 months of spending
    final suggestions = <String, double>{};

    for (var category in AppConstants.defaultCategories) {
      double totalSpent = 0;
      for (int i = 0; i < 3; i++) {
        final spent = await _firestoreService.getCategorySpent(
          _userId!,
          category,
          30,
        );
        totalSpent += spent;
      }

      // Add 10% buffer to average
      final suggested = (totalSpent / 3) * 1.1;
      if (suggested > 0) {
        suggestions[category] = suggested;
      }
    }

    return suggestions;
  }

  // Get remaining budget for category
  Future<double> getRemainingBudget(String categoryName) async {
    final budget = getCategoryBudget(categoryName);
    if (budget == 0) return 0;

    final spent = await _firestoreService.getCategorySpent(
      _userId!,
      categoryName,
      30,
    );

    return (budget - spent).clamp(0, budget);
  }

  @override
  void dispose() {
    _budgetStreamSubscription?.cancel();
    super.dispose();
  }
}
