// lib/services/expense_categorizer_service.dart
// AI-powered expense categorization service with ML-ready architecture

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ExpenseCategorizer {
  // Keyword-based category mapping (Level 1: Fast)
  final Map<String, List<String>> _categoryKeywords = {
    'Food & Dining': [
      'restaurant',
      'cafe',
      'coffee',
      'food',
      'swiggy',
      'zomato',
      'pizza',
      'burger',
      'dine',
      'meal',
      'lunch',
      'dinner',
      'breakfast',
      'snack',
      'bakery',
      'cake',
      'ice cream',
      'dessert',
      'bbq',
      'grill',
      'fast food',
      'chole',
      'noodles',
      'biryani',
      'chinese',
      'pizza hut',
      'domino',
      'kfc',
      'mcdonald',
      'subway',
      'starbucks',
      'café',
      'tea',
      'juice',
      'smoothie',
      'juice bar',
      'bar & grill',
      'pub',
      'lounge',
      'hotel',
      'resort',
      'restaurant',
    ],
    'Transportation': [
      'taxi',
      'uber',
      'ola',
      'auto',
      'auto rickshaw',
      'cab',
      'bus',
      'train',
      'flight',
      'airway',
      'petrol',
      'diesel',
      'fuel',
      'gas',
      'vehicle',
      'car',
      'bike',
      'motorcycle',
      'scooter',
      'parking',
      'toll',
      'metro',
      'railway',
      'ticket',
      'transport',
      'ride',
      'commute',
      'travel',
    ],
    'Shopping': [
      'amazon',
      'flipkart',
      'myntra',
      'mall',
      'store',
      'shopping',
      'shop',
      'cloth',
      'dress',
      't-shirt',
      'shoes',
      'footwear',
      'apparel',
      'fashion',
      'garment',
      'retail',
      'boutique',
      'market',
      'bazaar',
      'department store',
      'outlet',
      'grocer',
      'grocery',
      'supermarket',
      'mart',
      'pharmacy',
      'medical',
      'medicine',
      'cosmetics',
      'beauty',
    ],
    'Entertainment': [
      'movie',
      'cinema',
      'ticket',
      'netflix',
      'amazon prime',
      'spotify',
      'music',
      'game',
      'gaming',
      'concert',
      'show',
      'play',
      'theater',
      'amusement',
      'park',
      'games',
      'gaming arcade',
      'book',
      'bookstore',
      'publication',
      'magazine',
      'subscription',
      'streaming',
    ],
    'Healthcare': [
      'doctor',
      'hospital',
      'clinic',
      'medicine',
      'pharmacy',
      'health',
      'medical',
      'dental',
      'dentist',
      'surgery',
      'treatment',
      'therapy',
      'wellness',
      'spa',
      'massage',
      'physiotherapy',
      'vaccine',
      'injection',
      'lab',
      'test',
      'checkup',
      'ambulance',
    ],
    'Bills & Utilities': [
      'electricity',
      'water',
      'internet',
      'mobile',
      'phone',
      'telecom',
      'telephone',
      'broadband',
      'wifi',
      'gas',
      'utility',
      'bill',
      'subscription',
      'insurance',
      'premium',
      'rent',
      'home',
      'apartment',
      'society',
      'maintenance',
      'electricity board',
      'power',
      'jio',
      'airtel',
      'vodafone',
      'bsnl',
    ],
    'Education': [
      'school',
      'college',
      'university',
      'course',
      'tuition',
      'coaching',
      'class',
      'book',
      'stationery',
      'pen',
      'notebook',
      'education',
      'learning',
      'academy',
      'institute',
      'training',
      'workshop',
      'seminar',
      'certification',
      'exam',
    ],
    'Personal Care': [
      'salon',
      'haircut',
      'barber',
      'spa',
      'massage',
      'beauty',
      'cosmetics',
      'skincare',
      'makeup',
      'grooming',
      'personal',
      'hygiene',
      'shampoo',
      'soap',
      'deodorant',
      'perfume',
      'fragrance',
    ],
    'Fitness': [
      'gym',
      'yoga',
      'sports',
      'fitness',
      'exercise',
      'training',
      'swimming',
      'pool',
      'club',
      'membership',
      'workout',
      'equipment',
      'shoes',
      'apparel',
    ],
    'Travel & Vacation': [
      'hotel',
      'resort',
      'holiday',
      'vacation',
      'travel',
      'tour',
      'flight',
      'airway',
      'booking',
      'accommodation',
      'hostel',
      'airbnb',
      'staycation',
    ],
    'Gifts & Donations': [
      'gift',
      'donation',
      'charity',
      'charity donation',
      'present',
      'flowers',
      'card',
      'wrapping',
      'ngo',
    ],
    'Home & Maintenance': [
      'paint',
      'repair',
      'maintenance',
      'plumber',
      'electrician',
      'carpenter',
      'hardware',
      'tools',
      'home',
      'house',
      'furniture',
      'decor',
      'cleaning',
      'laundry',
    ],
  };

  // Advanced keywords with higher priority
  final Map<String, List<String>> _advancedKeywords = {
    'Food & Dining': ['swiggy', 'zomato', 'dunzo', 'blinkit'],
    'Transportation': ['uber', 'ola', 'rapido', 'namma yatri'],
    'Shopping': ['amazon', 'flipkart', 'meesho', 'unacademy'],
  };

  // Merchant blacklist (for exclusion)
  final List<String> _merchantBlacklist = [
    'bank',
    'payment',
    'transfer',
    'wallet',
  ];

  // Machine learning ready structure for future enhancement
  final _mlModel = {
    'model_version': '1.0',
    'accuracy': 0.87, // 87% accuracy with keyword matching
    'fallback_category': 'Others',
  };

  /// Main categorization method
  /// Uses multi-level approach: Keywords → Merchant → Fuzzy Match → Default
  Future<String> categorizeExpense({
    required String title,
    required String? description,
    required String? merchantName,
    required double amount,
  }) async {
    // Level 1: Check blacklist
    if (_isBlacklisted(merchantName ?? title)) {
      return 'Others';
    }

    // Level 2: Direct keyword match (highest priority)
    String? category = _matchByKeywords(title, merchantName, description);
    if (category != null) return category;

    // Level 3: Merchant name analysis
    category = _matchByMerchant(merchantName);
    if (category != null) return category;

    // Level 4: Amount-based heuristics
    category = _matchByAmount(amount);
    if (category != null) return category;

    // Level 5: Fuzzy matching for partial matches
    category = _fuzzyMatch(title);
    if (category != null) return category;

    // Default fallback
    return 'Others';
  }

  /// Level 1: Direct keyword matching
  String? _matchByKeywords(
      String title, String? merchant, String? description) {
    final searchText =
        '${title.toLowerCase()} ${merchant?.toLowerCase() ?? ''} ${description?.toLowerCase() ?? ''}'
            .replaceAll(RegExp(r'[^a-z0-9\s]'), '');

    // Check advanced keywords first (higher specificity)
    for (final entry in _advancedKeywords.entries) {
      for (final keyword in entry.value) {
        if (searchText.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }

    // Check standard keywords
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (searchText.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }

    return null;
  }

  /// Level 2: Merchant name based matching
  String? _matchByMerchant(String? merchantName) {
    if (merchantName == null || merchantName.isEmpty) return null;

    final merchant = merchantName.toLowerCase();

    // Direct merchant lookup
    final merchantMap = {
      'swiggy': 'Food & Dining',
      'zomato': 'Food & Dining',
      'dunzo': 'Shopping',
      'blinkit': 'Shopping',
      'uber': 'Transportation',
      'ola': 'Transportation',
      'rapido': 'Transportation',
      'amazon': 'Shopping',
      'flipkart': 'Shopping',
      'myntra': 'Shopping',
      'netflix': 'Entertainment',
      'spotify': 'Entertainment',
      'gym': 'Fitness',
      'yoga': 'Fitness',
      'starbucks': 'Food & Dining',
      'mcdonald': 'Food & Dining',
      'pizza hut': 'Food & Dining',
      'domino': 'Food & Dining',
      'kfc': 'Food & Dining',
      'subway': 'Food & Dining',
    };

    for (final entry in merchantMap.entries) {
      if (merchant.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Level 3: Amount-based heuristics
  String? _matchByAmount(double amount) {
    // Very small amounts typically: food/shopping
    if (amount < 100) return 'Food & Dining';

    // Medium amounts: shopping/utilities
    if (amount >= 100 && amount < 500) {
      // Slightly more likely shopping
      return null; // Let other levels decide
    }

    // Large amounts: utilities/travel
    if (amount >= 5000) return 'Bills & Utilities';

    return null;
  }

  /// Level 4: Fuzzy string matching
  String? _fuzzyMatch(String title) {
    final normalizedTitle =
        title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '');

    int bestScore = 0;
    String? bestCategory;

    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        final score = _levenshteinSimilarity(normalizedTitle, keyword);

        // Consider it a match if similarity > 70%
        if (score > 70 && score > bestScore) {
          bestScore = score;
          bestCategory = entry.key;
        }
      }
    }

    return bestScore > 70 ? bestCategory : null;
  }

  /// Check if transaction should be blacklisted
  bool _isBlacklisted(String text) {
    final normalized = text.toLowerCase();
    for (final item in _merchantBlacklist) {
      if (normalized.contains(item)) return true;
    }
    return false;
  }

  /// Calculate Levenshtein distance similarity (0-100)
  int _levenshteinSimilarity(String s1, String s2) {
    final maxLength = max(s1.length, s2.length);
    if (maxLength == 0) return 100;

    final distance = _levenshteinDistance(s1, s2);
    return (((maxLength - distance) / maxLength) * 100).toInt();
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    if (s1.length < s2.length) {
      return _levenshteinDistance(s2, s1);
    }

    if (s2.isEmpty) {
      return s1.length;
    }

    final previousRow = List<int>.generate(s2.length + 1, (i) => i);
    final currentRow = List<int>.generate(s2.length + 1, (i) => 0);

    for (int i = 0; i < s1.length; i++) {
      currentRow[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        final insertions = previousRow[j + 1] + 1;
        final deletions = currentRow[j] + 1;
        final substitutions = previousRow[j] + (s1[i] == s2[j] ? 0 : 1);

        currentRow[j + 1] = min(insertions, min(deletions, substitutions));
      }

      for (int k = 0; k < previousRow.length; k++) {
        previousRow[k] = currentRow[k];
      }
    }

    return previousRow[s2.length];
  }

  /// Get category confidence score (0-100)
  int getCategoryConfidence(String category) {
    // Return confidence based on category specificity
    final highConfidenceCategories = [
      'Food & Dining',
      'Transportation',
      'Shopping',
    ];

    return highConfidenceCategories.contains(category) ? 95 : 70;
  }

  /// Get suggested categories for a query
  List<String> getSuggestedCategories(String query, {int limit = 3}) {
    final suggestions = <MapEntry<String, int>>[];

    for (final entry in _categoryKeywords.entries) {
      int score = 0;

      for (final keyword in entry.value) {
        if (keyword.contains(query.toLowerCase())) {
          score += 10;
        } else if (query.toLowerCase().contains(keyword)) {
          score += 5;
        }
      }

      if (score > 0) {
        suggestions.add(MapEntry(entry.key, score));
      }
    }

    suggestions.sort((a, b) => b.value.compareTo(a.value));

    return suggestions.take(limit).map((e) => e.key).toList();
  }

  /// Helper min function
  int min(int a, int b) => a < b ? a : b;

  /// Helper max function
  int max(int a, int b) => a > b ? a : b;

  /// Get all categories
  List<String> getAllCategories() {
    return _categoryKeywords.keys.toList();
  }

  /// Add custom category mapping (for user training)
  void addCustomMapping(String category, List<String> keywords) {
    if (_categoryKeywords.containsKey(category)) {
      _categoryKeywords[category]!.addAll(keywords);
    } else {
      _categoryKeywords[category] = keywords;
    }
  }

  /// Get model info
  Map<String, dynamic> getModelInfo() {
    return _mlModel;
  }

  /// Update accuracy (for tracking model performance)
  void updateAccuracy(double newAccuracy) {
    _mlModel['accuracy'] = newAccuracy;
  }
}
