import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final String merchantUrl;
  final bool isValid;
  final double? discountPercentage;
  final double? discountAmount;
  final double? minPurchaseAmount;
  final double? maxDiscountAmount;
  final String? description;
  final DateTime? expiryDate;
  final DateTime checkedAt;
  final String? userId;
  final String platform;

  CouponModel({
    required this.id,
    required this.code,
    required this.merchantUrl,
    required this.isValid,
    this.discountPercentage,
    this.discountAmount,
    this.minPurchaseAmount,
    this.maxDiscountAmount,
    this.description,
    this.expiryDate,
    required this.checkedAt,
    this.userId,
    required this.platform,
  });

  factory CouponModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CouponModel(
      id: id,
      code: data['code'] ?? '',
      merchantUrl: data['merchant_url'] ?? '',
      isValid: data['is_valid'] ?? false,
      discountPercentage: data['discount_percentage']?.toDouble(),
      discountAmount: data['discount_amount']?.toDouble(),
      minPurchaseAmount: data['min_purchase_amount']?.toDouble(),
      maxDiscountAmount: data['max_discount_amount']?.toDouble(),
      description: data['description'],
      expiryDate: (data['expiry_date'] as Timestamp?)?.toDate(),
      checkedAt: (data['checked_at'] as Timestamp).toDate(),
      userId: data['user_id'],
      platform: data['platform'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'merchant_url': merchantUrl,
      'is_valid': isValid,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'min_purchase_amount': minPurchaseAmount,
      'max_discount_amount': maxDiscountAmount,
      'description': description,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'checked_at': Timestamp.fromDate(checkedAt),
      'user_id': userId,
      'platform': platform,
    };
  }

  String get discountText {
    if (discountPercentage != null) {
      return '${discountPercentage!.toStringAsFixed(0)}% OFF';
    } else if (discountAmount != null) {
      return '₹${discountAmount!.toStringAsFixed(0)} OFF';
    }
    return 'Discount Available';
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
}
