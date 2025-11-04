import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double currentPrice;
  final String currency;
  final String? imageUrl;
  final String productUrl;
  final String platform;
  final String category;
  final List<PriceHistory> priceHistory;
  final DateTime? lastUpdated;
  final bool isTracking;
  final String? userId;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.currentPrice,
    this.currency = 'INR',
    this.imageUrl,
    required this.productUrl,
    required this.platform,
    required this.category,
    this.priceHistory = const [],
    this.lastUpdated,
    this.isTracking = false,
    this.userId,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      currentPrice: (data['current_price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'INR',
      imageUrl: data['image_url'],
      productUrl: data['product_url'] ?? '',
      platform: data['platform'] ?? '',
      category: data['category'] ?? '',
      priceHistory: (data['price_history'] as List<dynamic>?)
              ?.map((e) => PriceHistory.fromMap(e))
              .toList() ??
          [],
      lastUpdated: (data['last_updated'] as Timestamp?)?.toDate(),
      isTracking: data['is_tracking'] ?? false,
      userId: data['user_id'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'current_price': currentPrice,
      'currency': currency,
      'image_url': imageUrl,
      'product_url': productUrl,
      'platform': platform,
      'category': category,
      'price_history': priceHistory.map((e) => e.toMap()).toList(),
      'last_updated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(),
      'is_tracking': isTracking,
      'user_id': userId,
    };
  }

  double get lowestPrice {
    if (priceHistory.isEmpty) return currentPrice;
    return priceHistory.map((e) => e.price).reduce((a, b) => a < b ? a : b);
  }

  double get highestPrice {
    if (priceHistory.isEmpty) return currentPrice;
    return priceHistory.map((e) => e.price).reduce((a, b) => a > b ? a : b);
  }

  double get priceDropPercentage {
    if (priceHistory.isEmpty) return 0;
    final firstPrice = priceHistory.first.price;
    return ((firstPrice - currentPrice) / firstPrice * 100);
  }
}

class PriceHistory {
  final double price;
  final DateTime timestamp;

  PriceHistory({required this.price, required this.timestamp});

  factory PriceHistory.fromMap(Map<String, dynamic> data) {
    return PriceHistory(
      price: (data['price'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
