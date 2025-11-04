import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/coupon_model.dart';

class AIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  // AI Product Search
  Future<List<ProductModel>> searchProducts(String query, {String? platform}) async {
    try {
      // Simulate AI-powered search with delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock product data - In production, this would call real AI API
      final mockProducts = _generateMockProducts(query, platform);

      // Store search results in Firestore
      for (var product in mockProducts) {
        await _firestore.collection('products').doc(product.id).set(product.toFirestore());
      }

      return mockProducts;
    } catch (e) {
      throw Exception('Product search failed: $e');
    }
  }

  // AI Price Tracker
  Future<ProductModel> trackPrice(String productUrl, String userId) async {
    try {
      // Simulate AI extraction of product details from URL
      await Future.delayed(const Duration(seconds: 2));

      final product = _extractProductFromUrl(productUrl, userId);

      // Save to Firestore
      await _firestore.collection('products').doc(product.id).set(product.toFirestore());

      // Create price tracking entry
      await _firestore.collection('price_tracking').doc(product.id).set({
        'product_id': product.id,
        'user_id': userId,
        'is_tracking': true,
        'alert_on_drop': true,
        'alert_threshold': 5.0,
        'created_at': FieldValue.serverTimestamp(),
      });

      return product;
    } catch (e) {
      throw Exception('Price tracking failed: $e');
    }
  }

  // Update Price History
  Future<void> updatePriceHistory(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) return;

      final product = ProductModel.fromFirestore(doc.data()!, productId);

      // Simulate price fluctuation
      final newPrice = product.currentPrice * (0.95 + _random.nextDouble() * 0.1);
      final priceHistory = List<PriceHistory>.from(product.priceHistory);
      priceHistory.add(PriceHistory(price: newPrice, timestamp: DateTime.now()));

      await _firestore.collection('products').doc(productId).update({
        'current_price': newPrice,
        'price_history': priceHistory.map((e) => e.toMap()).toList(),
        'last_updated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update price history: $e');
    }
  }

  // AI Coupon Checker
  Future<CouponModel> checkCoupon(String couponCode, String merchantUrl, String userId) async {
    try {
      // Simulate AI checking coupon validity
      await Future.delayed(const Duration(seconds: 2));

      final coupon = _validateCoupon(couponCode, merchantUrl, userId);

      // Save to Firestore
      await _firestore.collection('coupons').add(coupon.toFirestore());

      return coupon;
    } catch (e) {
      throw Exception('Coupon check failed: $e');
    }
  }

  // Get Price History for Chart
  Future<List<PriceHistory>> getPriceHistory(String productId, {int days = 30}) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) return [];

      final product = ProductModel.fromFirestore(doc.data()!, productId);
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      return product.priceHistory.where((h) => h.timestamp.isAfter(cutoffDate)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get Investment Recommendation
  Future<Map<String, dynamic>> getInvestmentRecommendation(String symbol) async {
    try {
      // Simulate AI analysis
      await Future.delayed(const Duration(seconds: 2));

      final actions = ['BUY', 'SELL', 'HOLD'];
      final action = actions[_random.nextInt(actions.length)];
      final confidence = 60 + _random.nextDouble() * 35;

      return {
        'action': action,
        'confidence': confidence,
        'reason': _generateRecommendationReason(action, confidence),
        'target_price': 1000 + _random.nextDouble() * 500,
        'stop_loss': 800 + _random.nextDouble() * 200,
        'factors': _generateFactors(action),
      };
    } catch (e) {
      throw Exception('Failed to get recommendation: $e');
    }
  }

  // Private Helper Methods

  List<ProductModel> _generateMockProducts(String query, String? platform) {
    final products = <ProductModel>[];
    final platforms = platform != null ? [platform] : ['Amazon', 'Flipkart', 'Myntra'];

    for (int i = 0; i < 10; i++) {
      final price = 500 + _random.nextDouble() * 5000;
      products.add(ProductModel(
        id: 'prod_${DateTime.now().millisecondsSinceEpoch}_$i',
        name: '$query - Model ${i + 1}',
        description: 'High quality $query with advanced features and excellent performance',
        currentPrice: price,
        productUrl: 'https://example.com/product/${i + 1}',
        platform: platforms[i % platforms.length],
        category: _getCategoryForQuery(query),
        priceHistory: [PriceHistory(price: price, timestamp: DateTime.now())],
        lastUpdated: DateTime.now(),
        imageUrl: 'https://via.placeholder.com/300',
      ));
    }

    return products;
  }

  ProductModel _extractProductFromUrl(String url, String userId) {
    final price = 1000 + _random.nextDouble() * 9000;
    return ProductModel(
      id: 'tracked_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Product from URL',
      description: 'AI-extracted product from $url',
      currentPrice: price,
      productUrl: url,
      platform: _extractPlatformFromUrl(url),
      category: 'Electronics',
      priceHistory: [PriceHistory(price: price, timestamp: DateTime.now())],
      lastUpdated: DateTime.now(),
      isTracking: true,
      userId: userId,
    );
  }

  CouponModel _validateCoupon(String code, String url, String userId) {
    final isValid = _random.nextDouble() > 0.3;
    final discountType = _random.nextBool();

    return CouponModel(
      id: 'coupon_${DateTime.now().millisecondsSinceEpoch}',
      code: code,
      merchantUrl: url,
      isValid: isValid,
      discountPercentage: discountType ? (10 + _random.nextDouble() * 40) : null,
      discountAmount: !discountType ? (100 + _random.nextDouble() * 400) : null,
      minPurchaseAmount: isValid ? (500 + _random.nextDouble() * 1500) : null,
      maxDiscountAmount: isValid && discountType ? (200 + _random.nextDouble() * 800) : null,
      description: isValid
          ? 'Coupon is valid and active'
          : 'Coupon is invalid or expired',
      expiryDate: isValid ? DateTime.now().add(Duration(days: 30)) : null,
      checkedAt: DateTime.now(),
      userId: userId,
      platform: _extractPlatformFromUrl(url),
    );
  }

  String _getCategoryForQuery(String query) {
    final categories = {
      'phone': 'Electronics',
      'laptop': 'Electronics',
      'shirt': 'Fashion',
      'shoes': 'Fashion',
      'book': 'Books',
      'toy': 'Toys',
    };

    for (var key in categories.keys) {
      if (query.toLowerCase().contains(key)) {
        return categories[key]!;
      }
    }

    return 'Others';
  }

  String _extractPlatformFromUrl(String url) {
    if (url.contains('amazon')) return 'Amazon';
    if (url.contains('flipkart')) return 'Flipkart';
    if (url.contains('myntra')) return 'Myntra';
    return 'Others';
  }

  String _generateRecommendationReason(String action, double confidence) {
    if (action == 'BUY') {
      return 'Strong upward momentum detected with ${confidence.toStringAsFixed(1)}% confidence. Technical indicators suggest potential growth.';
    } else if (action == 'SELL') {
      return 'Bearish signals detected with ${confidence.toStringAsFixed(1)}% confidence. Market conditions suggest profit booking.';
    } else {
      return 'Market consolidation phase with ${confidence.toStringAsFixed(1)}% confidence. Wait for clearer signals.';
    }
  }

  List<String> _generateFactors(String action) {
    if (action == 'BUY') {
      return ['Positive market sentiment', 'Strong technical indicators', 'Good fundamentals'];
    } else if (action == 'SELL') {
      return ['Overbought conditions', 'Negative market trends', 'Resistance levels reached'];
    } else {
      return ['Mixed signals', 'Market uncertainty', 'Wait for breakout'];
    }
  }
}
