import 'package:cloud_firestore/cloud_firestore.dart';

class InvestmentModel {
  final String id;
  final String userId;
  final String investmentType;
  final String assetName;
  final String symbol;
  final double investedAmount;
  final double currentValue;
  final double quantity;
  final double buyPrice;
  final double currentPrice;
  final DateTime purchaseDate;
  final InvestmentStatus status;
  final List<PriceDataPoint> priceHistory;
  final AIRecommendation? aiRecommendation;

  InvestmentModel({
    required this.id,
    required this.userId,
    required this.investmentType,
    required this.assetName,
    required this.symbol,
    required this.investedAmount,
    required this.currentValue,
    required this.quantity,
    required this.buyPrice,
    required this.currentPrice,
    required this.purchaseDate,
    this.status = InvestmentStatus.active,
    this.priceHistory = const [],
    this.aiRecommendation,
  });

  factory InvestmentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return InvestmentModel(
      id: id,
      userId: data['user_id'] ?? '',
      investmentType: data['investment_type'] ?? '',
      assetName: data['asset_name'] ?? '',
      symbol: data['symbol'] ?? '',
      investedAmount: (data['invested_amount'] ?? 0).toDouble(),
      currentValue: (data['current_value'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toDouble(),
      buyPrice: (data['buy_price'] ?? 0).toDouble(),
      currentPrice: (data['current_price'] ?? 0).toDouble(),
      purchaseDate: (data['purchase_date'] as Timestamp).toDate(),
      status: InvestmentStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => InvestmentStatus.active,
      ),
      priceHistory: (data['price_history'] as List<dynamic>?)
              ?.map((e) => PriceDataPoint.fromMap(e))
              .toList() ??
          [],
      aiRecommendation: data['ai_recommendation'] != null
          ? AIRecommendation.fromMap(data['ai_recommendation'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'investment_type': investmentType,
      'asset_name': assetName,
      'symbol': symbol,
      'invested_amount': investedAmount,
      'current_value': currentValue,
      'quantity': quantity,
      'buy_price': buyPrice,
      'current_price': currentPrice,
      'purchase_date': Timestamp.fromDate(purchaseDate),
      'status': status.name,
      'price_history': priceHistory.map((e) => e.toMap()).toList(),
      'ai_recommendation': aiRecommendation?.toMap(),
    };
  }

  double get profitLoss => currentValue - investedAmount;

  double get profitLossPercentage => ((currentValue - investedAmount) / investedAmount) * 100;

  bool get isProfitable => profitLoss > 0;

  String get returnColor => isProfitable ? 'green' : 'red';
}

class PriceDataPoint {
  final DateTime timestamp;
  final double price;
  final double volume;

  PriceDataPoint({
    required this.timestamp,
    required this.price,
    this.volume = 0,
  });

  factory PriceDataPoint.fromMap(Map<String, dynamic> data) {
    return PriceDataPoint(
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      price: (data['price'] ?? 0).toDouble(),
      volume: (data['volume'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'price': price,
      'volume': volume,
    };
  }
}

class AIRecommendation {
  final String action;
  final double confidence;
  final String reason;
  final double targetPrice;
  final double stopLoss;
  final DateTime generatedAt;
  final List<String> factors;

  AIRecommendation({
    required this.action,
    required this.confidence,
    required this.reason,
    required this.targetPrice,
    required this.stopLoss,
    required this.generatedAt,
    this.factors = const [],
  });

  factory AIRecommendation.fromMap(Map<String, dynamic> data) {
    return AIRecommendation(
      action: data['action'] ?? '',
      confidence: (data['confidence'] ?? 0).toDouble(),
      reason: data['reason'] ?? '',
      targetPrice: (data['target_price'] ?? 0).toDouble(),
      stopLoss: (data['stop_loss'] ?? 0).toDouble(),
      generatedAt: (data['generated_at'] as Timestamp).toDate(),
      factors: List<String>.from(data['factors'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'confidence': confidence,
      'reason': reason,
      'target_price': targetPrice,
      'stop_loss': stopLoss,
      'generated_at': Timestamp.fromDate(generatedAt),
      'factors': factors,
    };
  }

  bool get isBuyRecommendation => action.toLowerCase() == 'buy';

  bool get isSellRecommendation => action.toLowerCase() == 'sell';

  bool get isHoldRecommendation => action.toLowerCase() == 'hold';
}

enum InvestmentStatus { active, sold, matured }
