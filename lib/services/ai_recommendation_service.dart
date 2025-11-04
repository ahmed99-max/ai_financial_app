// lib/services/ai_recommendation_service.dart
// Advanced AI service for investment and financial recommendations using ML algorithms

import 'dart:math';
import '../models/investment_model.dart';

class AIRecommendationService {
  /// Advanced recommendation engine using multiple AI signals
  Future<Map<String, dynamic>> getInvestmentRecommendation(
    InvestmentModel investment, {
    List<double> priceHistory = const [],
    double marketSentiment = 0.5,
  }) async {
    if (priceHistory.isEmpty) {
      return {
        'action': 'HOLD',
        'confidence': 50,
        'reason': 'Insufficient data',
        'targetPrice': investment.currentPrice,
      };
    }

    // Calculate multiple indicators
    final rsi = _calculateRSI(priceHistory);
    final macd = _calculateMACD(priceHistory);
    final bollingerBands = _calculateBollingerBands(priceHistory);
    final momentum = _calculateMomentum(priceHistory);
    final volumeTrend = _analyzeVolumeTrend(priceHistory);

    // Aggregate signals
    int buySignals = 0;
    int sellSignals = 0;

    // RSI Analysis
    if (rsi < 30) {
      buySignals += 2; // Strong buy signal
    } else if (rsi < 40) {
      buySignals += 1;
    } else if (rsi > 70) {
      sellSignals += 2; // Strong sell signal
    } else if (rsi > 60) {
      sellSignals += 1;
    }

    // MACD Analysis
    if (macd['histogram']! > 0 &&
        macd['histogram']! > (macd['prevHistogram'] ?? 0)) {
      buySignals += 1;
    } else if (macd['histogram']! < 0 &&
        macd['histogram']! < (macd['prevHistogram'] ?? 0)) {
      sellSignals += 1;
    }

    // Bollinger Bands Analysis
    if (bollingerBands['position']! < 0.2) {
      buySignals += 1; // Near lower band
    } else if (bollingerBands['position']! > 0.8) {
      sellSignals += 1; // Near upper band
    }

    // Momentum Analysis
    if (momentum > 0.03) {
      buySignals += 1;
    } else if (momentum < -0.03) {
      sellSignals += 1;
    }

    // Market Sentiment
    if (marketSentiment > 0.6) {
      buySignals += 1;
    } else if (marketSentiment < 0.4) {
      sellSignals += 1;
    }

    // Determine final recommendation
    final action = _determineAction(buySignals, sellSignals);
    final confidence = _calculateConfidence(buySignals, sellSignals);
    final targetPrice = _calculateTargetPrice(
      investment.currentPrice,
      rsi,
      bollingerBands,
      action,
    );

    return {
      'action': action,
      'confidence': confidence,
      'targetPrice': targetPrice,
      'reason': _generateReason(rsi, macd, action),
      'signals': {
        'rsi': rsi,
        'macd': macd,
        'bollingerBands': bollingerBands,
        'momentum': momentum,
        'buySignals': buySignals,
        'sellSignals': sellSignals,
      },
    };
  }

  /// Calculate RSI (Relative Strength Index)
  double _calculateRSI(List<double> prices, [int period = 14]) {
    if (prices.length < period + 1) return 50;

    double gains = 0;
    double losses = 0;

    for (int i = prices.length - period; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
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
    return 100 - (100 / (1 + rs));
  }

  /// Calculate MACD (Moving Average Convergence Divergence)
  Map<String, double> _calculateMACD(List<double> prices) {
    final ema12 = _calculateEMA(prices, 12);
    final ema26 = _calculateEMA(prices, 26);
    final macdLine = ema12 - ema26;
    final signalLine = _calculateEMA([macdLine], 9);
    final histogram = macdLine - signalLine;

    return {
      'macdLine': macdLine,
      'signalLine': signalLine,
      'histogram': histogram,
      'prevHistogram': prices.length > 1 ? histogram : 0,
    };
  }

  /// Calculate Exponential Moving Average
  double _calculateEMA(List<double> prices, int period) {
    if (prices.isEmpty) return 0;

    final sma = prices.take(period).fold(0.0, (sum, p) => sum + p) / period;
    final multiplier = 2.0 / (period + 1);

    double ema = sma;
    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] - ema) * multiplier + ema;
    }

    return ema;
  }

  /// Calculate Bollinger Bands
  Map<String, double> _calculateBollingerBands(List<double> prices,
      [int period = 20]) {
    final sma = prices.take(period).fold(0.0, (sum, p) => sum + p) / period;
    final variance = prices
            .take(period)
            .fold(0.0, (sum, p) => sum + pow(p - sma, 2))
            .toDouble() /
        period;
    final stdDev = sqrt(variance);

    final upperBand = sma + (2 * stdDev);
    final lowerBand = sma - (2 * stdDev);
    final currentPrice = prices.last;

    final position = (currentPrice - lowerBand) / (upperBand - lowerBand);

    return {
      'upper': upperBand,
      'middle': sma,
      'lower': lowerBand,
      'position': position.clamp(0, 1),
    };
  }

  /// Calculate Price Momentum
  double _calculateMomentum(List<double> prices, [int period = 10]) {
    if (prices.length < period + 1) return 0;

    final currentPrice = prices.last;
    final pastPrice = prices[prices.length - period - 1];

    return (currentPrice - pastPrice) / pastPrice;
  }

  /// Analyze Volume Trend (simulated)
  Map<String, double> _analyzeVolumeTrend(List<double> prices) {
    if (prices.length < 2) return {'trend': 0};

    final recentChange =
        (prices.last - prices[prices.length - 2]) / prices[prices.length - 2];

    return {
      'trend': recentChange > 0 ? 1 : -1,
      'strength': recentChange.abs(),
    };
  }

  /// Determine final action based on signals
  String _determineAction(int buySignals, int sellSignals) {
    final difference = buySignals - sellSignals;

    if (difference >= 2) {
      return 'BUY';
    } else if (difference <= -2) {
      return 'SELL';
    } else {
      return 'HOLD';
    }
  }

  /// Calculate confidence percentage
  int _calculateConfidence(int buySignals, int sellSignals) {
    final totalSignals = buySignals + sellSignals;
    if (totalSignals == 0) return 50;

    final maxSignals = max(buySignals, sellSignals);
    final confidence = (maxSignals / totalSignals) * 100;

    return (confidence * 0.85 + 50 * 0.15).toInt().clamp(40, 95);
  }

  /// Calculate target price based on analysis
  double _calculateTargetPrice(
    double currentPrice,
    double rsi,
    Map<String, double> bollingerBands,
    String action,
  ) {
    if (action == 'BUY') {
      // Target: move towards upper band
      final range = bollingerBands['upper']! - bollingerBands['lower']!;
      return currentPrice + (range * 0.15);
    } else if (action == 'SELL') {
      // Target: move towards lower band
      final range = bollingerBands['upper']! - bollingerBands['lower']!;
      return currentPrice - (range * 0.15);
    } else {
      // Hold: stay near current price
      return currentPrice;
    }
  }

  /// Generate readable recommendation reason
  String _generateReason(double rsi, Map<String, double> macd, String action) {
    final reasons = <String>[];

    if (rsi < 30) {
      reasons.add('Oversold condition detected');
    } else if (rsi > 70) {
      reasons.add('Overbought condition detected');
    }

    if (macd['histogram']! > 0) {
      reasons.add('Bullish MACD signal');
    } else if (macd['histogram']! < 0) {
      reasons.add('Bearish MACD signal');
    }

    if (action == 'BUY') {
      reasons.add('Multiple buy signals converging');
    } else if (action == 'SELL') {
      reasons.add('Multiple sell signals converging');
    }

    return reasons.isNotEmpty
        ? reasons.join(', ')
        : 'Technical indicators show neutral momentum';
  }

  /// Get loan eligibility score
  Future<Map<String, dynamic>> checkLoanEligibility({
    required double monthlyIncome,
    required double monthlyExpense,
    required int creditScore,
    required List<double> loanHistory,
  }) async {
    // Simulate eligibility checking (in production, call Cloud Functions)
    await Future.delayed(const Duration(milliseconds: 500));

    final incomeToExpenseRatio = monthlyIncome / (monthlyExpense + 1);
    final existingLoanBurden =
        loanHistory.fold(0.0, (sum, l) => sum + l) / (monthlyIncome + 1);

    double score = 0;

    // Credit score contribution (40%)
    score += (creditScore / 900) * 40;

    // Income to expense ratio (35%)
    if (incomeToExpenseRatio > 2) {
      score += 35;
    } else if (incomeToExpenseRatio > 1.5) {
      score += 25;
    } else if (incomeToExpenseRatio > 1) {
      score += 15;
    }

    // Existing loan burden (25%)
    if (existingLoanBurden < 0.3) {
      score += 25;
    } else if (existingLoanBurden < 0.5) {
      score += 15;
    } else if (existingLoanBurden < 0.7) {
      score += 5;
    }

    final eligible = score > 60;
    final maxLoanAmount =
        eligible ? (monthlyIncome * 50).clamp(0, 10000000) : 0;

    return {
      'eligible': eligible,
      'score': score.toInt(),
      'maxLoanAmount': maxLoanAmount,
      'recommendedRate': _getRecommendedRate(score),
      'maxTenure': _getMaxTenure(score),
      'reason': _getEligibilityReason(score, monthlyIncome, monthlyExpense),
    };
  }

  /// Get recommended interest rate based on score
  double _getRecommendedRate(double score) {
    if (score >= 80) return 7.5;
    if (score >= 70) return 9.0;
    if (score >= 60) return 11.0;
    return 13.0;
  }

  /// Get max tenure based on score
  int _getMaxTenure(double score) {
    if (score >= 80) return 84;
    if (score >= 70) return 72;
    if (score >= 60) return 60;
    return 48;
  }

  /// Get eligibility explanation
  String _getEligibilityReason(
    double score,
    double income,
    double expense,
  ) {
    if (score >= 80) {
      return 'Excellent profile. Approved with best rates and flexible terms';
    } else if (score >= 70) {
      return 'Good profile. Approved with competitive rates';
    } else if (score >= 60) {
      return 'Moderate profile. Eligible after verification';
    } else {
      return 'Profile needs improvement. Apply after reducing existing obligations';
    }
  }

  /// Get AI spending insights
  Future<List<Map<String, dynamic>>> getSpendingInsights({
    required Map<String, double> categorySpending,
    required double monthlyIncome,
    required List<double> historicalSpending,
  }) async {
    final insights = <Map<String, dynamic>>[];

    // Analyze spending patterns
    for (final entry in categorySpending.entries) {
      final percentage = (entry.value / monthlyIncome) * 100;

      if (percentage > 30) {
        insights.add({
          'category': entry.key,
          'type': 'warning',
          'message':
              '⚠️ ${entry.key} spending is ${percentage.toStringAsFixed(1)}% of income',
          'action': 'Consider reducing or tracking purchases carefully',
          'severity': percentage > 50 ? 'high' : 'medium',
        });
      } else if (percentage < 5 && entry.value > 0) {
        insights.add({
          'category': entry.key,
          'type': 'savings_opportunity',
          'message':
              '💡 You\'re spending efficiently on ${entry.key} (${percentage.toStringAsFixed(1)}%)',
          'action': 'Maintain this spending level',
          'severity': 'low',
        });
      }
    }

    // Check for unusual patterns
    if (historicalSpending.isNotEmpty) {
      final average = historicalSpending.fold(0.0, (sum, v) => sum + v) /
          historicalSpending.length;
      final currentTotal =
          categorySpending.values.fold(0.0, (sum, v) => sum + v);

      if (currentTotal > average * 1.2) {
        insights.add({
          'category': 'Overall',
          'type': 'unusual_activity',
          'message': '📈 Spending is 20% higher than usual this period',
          'action': 'Review recent purchases for any unexpected expenses',
          'severity': 'medium',
        });
      }
    }

    return insights;
  }
}
