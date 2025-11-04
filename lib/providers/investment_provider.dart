// lib/providers/investment_provider.dart
// Complete investment portfolio management with AI recommendations and real-time market data

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investment_model.dart';
import '../services/firestore_service.dart';

class InvestmentRecommendation {
  final String investmentId;
  final String symbol;
  final String assetName;
  final String action; // 'BUY', 'SELL', 'HOLD'
  final double targetPrice;
  final double currentPrice;
  final double confidence; // 0-100
  final String reason;
  final DateTime generatedAt;

  InvestmentRecommendation({
    required this.investmentId,
    required this.symbol,
    required this.assetName,
    required this.action,
    required this.targetPrice,
    required this.currentPrice,
    required this.confidence,
    required this.reason,
    required this.generatedAt,
  });
}

class InvestmentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<InvestmentModel> _investments = [];
  List<InvestmentRecommendation> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  StreamSubscription? _investmentStreamSubscription;
  double _portfolioValue = 0;
  double _totalInvested = 0;
  double _totalReturns = 0;

  // Getters
  List<InvestmentModel> get investments => _investments;
  List<InvestmentRecommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get portfolioValue => _portfolioValue;
  double get totalInvested => _totalInvested;
  double get totalReturns => _totalReturns;
  double get returnPercentage =>
      _totalInvested > 0 ? (_totalReturns / _totalInvested) * 100 : 0;

  void initializeWithUser(String userId) {
    _userId = userId;
    _subscribeToInvestments();
  }

  // Real-time subscription to investments
  void _subscribeToInvestments() {
    if (_userId == null) return;

    _investmentStreamSubscription?.cancel();
    _investmentStreamSubscription = _firestore
        .collection('users')
        .doc(_userId!)
        .collection('investments')
        .snapshots()
        .listen(
      (snapshot) {
        _investments = snapshot.docs
            .map((doc) => InvestmentModel.fromFirestore(doc.data(), doc.id))
            .toList();
        _calculatePortfolioMetrics();
        _generateAIRecommendations();
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load investments: $error';
        notifyListeners();
      },
    );
  }

  // Add new investment
  Future<void> addInvestment({
    required String
        investmentType, // 'stocks', 'crypto', 'mutual_funds', 'bonds'
    required String assetName,
    required String symbol,
    required double investedAmount,
    required double quantity,
    required double buyPrice,
    required double currentPrice,
    required DateTime purchaseDate,
    String? notes,
  }) async {
    if (_userId == null) throw Exception('User not initialized');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final investment = InvestmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        investmentType: investmentType,
        assetName: assetName,
        symbol: symbol,
        investedAmount: investedAmount,
        currentValue: investedAmount,
        quantity: quantity,
        buyPrice: buyPrice,
        currentPrice: currentPrice,
        purchaseDate: purchaseDate,
        status: InvestmentStatus.active,
        priceHistory: [
          PriceDataPoint(
            price: buyPrice,
            timestamp: purchaseDate,
          ),
        ],
      );

      await _firestoreService.addInvestment(investment);

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add investment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update investment price
  Future<void> updatePrice(
    String investmentId,
    double newPrice,
  ) async {
    if (_userId == null) return;

    try {
      final dataPoint = PriceDataPoint(
        price: newPrice,
        timestamp: DateTime.now(),
      );

      await _firestoreService.updateInvestmentPrice(
        _userId!,
        investmentId,
        newPrice,
        dataPoint,
      );

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update price: $e';
      notifyListeners();
    }
  }

  // Calculate portfolio metrics
  void _calculatePortfolioMetrics() {
    _portfolioValue = 0;
    _totalInvested = 0;
    _totalReturns = 0;

    for (var investment in _investments) {
      if (investment.status == InvestmentStatus.active) {
        _portfolioValue += investment.currentValue;
        _totalInvested += investment.investedAmount;
        _totalReturns += (investment.currentValue - investment.investedAmount);
      }
    }
  }

  // Generate AI recommendations based on market data and technical analysis
  void _generateAIRecommendations() {
    _recommendations = [];

    for (var investment in _investments) {
      if (investment.status != InvestmentStatus.active) continue;

      // Calculate technical indicators
      final rsi = _calculateRSI(investment);
      final priceChange = ((investment.currentPrice - investment.buyPrice) /
              investment.buyPrice) *
          100;
      final movingAverage = _calculateMovingAverage(investment);

      String action = 'HOLD';
      double confidence = 50;
      String reason = 'Neutral market conditions';
      double targetPrice = investment.currentPrice;

      // Simple technical analysis logic
      if (rsi < 30) {
        action = 'BUY';
        confidence = 75;
        reason = 'Oversold condition - potential reversal';
        targetPrice = investment.currentPrice * 1.15; // 15% upside
      } else if (rsi > 70) {
        action = 'SELL';
        confidence = 70;
        reason = 'Overbought condition - potential pullback';
        targetPrice = investment.currentPrice * 0.85; // 15% downside
      } else if (priceChange > 10 && investment.currentPrice > movingAverage) {
        action = 'HOLD';
        confidence = 60;
        reason = 'Strong uptrend - maintain position';
        targetPrice = investment.currentPrice * 1.10;
      } else if (priceChange < -10 && investment.currentPrice < movingAverage) {
        action = 'SELL';
        confidence = 65;
        reason = 'Downtrend - consider exit';
        targetPrice = investment.currentPrice * 0.90;
      }

      _recommendations.add(
        InvestmentRecommendation(
          investmentId: investment.id,
          symbol: investment.symbol,
          assetName: investment.assetName,
          action: action,
          targetPrice: targetPrice,
          currentPrice: investment.currentPrice,
          confidence: confidence,
          reason: reason,
          generatedAt: DateTime.now(),
        ),
      );
    }
  }

  // Calculate RSI (Relative Strength Index)
  double _calculateRSI(InvestmentModel investment, {int period = 14}) {
    if (investment.priceHistory.length < period + 1) {
      return 50; // Neutral if insufficient data
    }

    double gains = 0;
    double losses = 0;

    for (int i = 0; i < period; i++) {
      final change = investment.priceHistory[i + 1].price -
          investment.priceHistory[i].price;
      if (change > 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }

    final avgGain = gains / period;
    final avgLoss = losses / period;

    if (avgLoss == 0) return 100;

    final rs = avgGain / avgLoss;
    final rsi = 100 - (100 / (1 + rs));

    return rsi;
  }

  // Calculate Simple Moving Average
  double _calculateMovingAverage(InvestmentModel investment,
      {int period = 20}) {
    if (investment.priceHistory.length < period) {
      return investment.currentPrice;
    }

    final recentPrices = investment.priceHistory.take(period);
    final average =
        recentPrices.fold<double>(0, (total, p) => total + p.price) / period;

    return average;
  }

  // Get investment by type
  List<InvestmentModel> getByType(String type) {
    return _investments
        .where((i) =>
            i.investmentType == type && i.status == InvestmentStatus.active)
        .toList();
  }

  // Get portfolio allocation
  Map<String, double> getPortfolioAllocation() {
    final allocation = <String, double>{};

    for (var investment in _investments) {
      if (investment.status != InvestmentStatus.active) continue;

      final percentage = (_portfolioValue > 0)
          ? (investment.currentValue / _portfolioValue) * 100
          : 0;

      allocation[investment.assetName] = percentage as double;
    }

    return allocation;
  }

  // Get top performers
  List<InvestmentModel> getTopPerformers({int limit = 5}) {
    final sorted = List<InvestmentModel>.from(_investments)
      ..sort((a, b) {
        final double returnA =
            ((a.currentValue - a.investedAmount) / a.investedAmount) * 100;
        final double returnB =
            ((b.currentValue - b.investedAmount) / b.investedAmount) * 100;
        return returnB.compareTo(returnA);
      });

    return sorted.take(limit).toList();
  }

  // Get investment performance for period
  double getPerformanceForPeriod(String investmentId, {int days = 30}) {
    final investment = _investments.firstWhere(
      (i) => i.id == investmentId,
      orElse: () => InvestmentModel(
        id: '',
        userId: _userId ?? '',
        investmentType: '',
        assetName: '',
        symbol: '',
        investedAmount: 0,
        currentValue: 0,
        quantity: 0,
        buyPrice: 0,
        currentPrice: 0,
        purchaseDate: DateTime.now(),
      ),
    );

    if (investment.id.isEmpty) return 0;

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final oldestPrice = investment.priceHistory
        .where((p) => p.timestamp.isBefore(cutoffDate))
        .fold<double?>(null, (prev, p) => prev ?? p.price);

    if (oldestPrice == null) return 0;

    return ((investment.currentPrice - oldestPrice) / oldestPrice) * 100;
  }

  // Sell investment (move to inactive)
  Future<void> sellInvestment(String investmentId, double sellPrice) async {
    if (_userId == null) return;

    try {
      final investment = _investments.firstWhere((i) => i.id == investmentId);

      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('investments')
          .doc(investmentId)
          .update({
        'status': 'closed',
        'current_price': sellPrice,
        'current_value': investment.quantity * sellPrice,
      });

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sell investment: $e';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _investmentStreamSubscription?.cancel();
    super.dispose();
  }
}
