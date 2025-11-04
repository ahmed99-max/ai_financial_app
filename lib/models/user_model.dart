import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? phone;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isPremium;
  final int aiUsageCount;
  final int aiUsageLimit;
  final Map<String, dynamic>? bankDetails;
  final List<String> linkedAccounts;

  UserModel({
    required this.uid,
    required this.email,
    this.phone,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLogin,
    this.isPremium = false,
    this.aiUsageCount = 0,
    this.aiUsageLimit = 10,
    this.bankDetails,
    this.linkedAccounts = const [],
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      phone: data['phone'],
      displayName: data['display_name'],
      photoUrl: data['photo_url'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['last_login'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['is_premium'] ?? false,
      aiUsageCount: data['ai_usage_count'] ?? 0,
      aiUsageLimit: data['ai_usage_limit'] ?? 10,
      bankDetails: data['bank_details'],
      linkedAccounts: List<String>.from(data['linked_accounts'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phone': phone,
      'display_name': displayName,
      'photo_url': photoUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'last_login': Timestamp.fromDate(lastLogin),
      'is_premium': isPremium,
      'ai_usage_count': aiUsageCount,
      'ai_usage_limit': aiUsageLimit,
      'bank_details': bankDetails,
      'linked_accounts': linkedAccounts,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? phone,
    bool? isPremium,
    int? aiUsageCount,
    Map<String, dynamic>? bankDetails,
    List<String>? linkedAccounts,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      lastLogin: DateTime.now(),
      isPremium: isPremium ?? this.isPremium,
      aiUsageCount: aiUsageCount ?? this.aiUsageCount,
      aiUsageLimit: aiUsageLimit ?? this.aiUsageLimit,
      bankDetails: bankDetails ?? this.bankDetails,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
    );
  }
}
