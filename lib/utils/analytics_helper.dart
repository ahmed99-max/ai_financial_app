// lib/utils/analytics_helper.dart
// Comprehensive analytics and tracking for financial events

import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/logger.dart';

class AnalyticsHelper {
  static final AnalyticsHelper _instance = AnalyticsHelper._internal();

  factory AnalyticsHelper() {
    return _instance;
  }

  AnalyticsHelper._internal();

  final _analytics = FirebaseAnalytics.instance;

  // Financial Events

  /// Log when user adds a new loan
  Future<void> logLoanCreated({
    required String loanType,
    required double amount,
    required int tenure,
    required double interestRate,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'loan_created',
        parameters: {
          'loan_type': loanType,
          'amount': amount,
          'tenure_months': tenure,
          'interest_rate': interestRate,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      logger.info(
        'Loan created: $loanType, Amount: $amount',
        tag: 'Analytics',
      );
    } catch (e) {
      logger.error('Failed to log loan creation: $e', tag: 'Analytics');
    }
  }

  /// Log EMI payment
  Future<void> logEMIPayment({
    required String loanId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'emi_payment',
        parameters: {
          'loan_id': loanId,
          'amount': amount,
          'payment_method': paymentMethod,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      logger.info(
        'EMI payment logged: $amount via $paymentMethod',
        tag: 'Analytics',
      );
    } catch (e) {
      logger.error('Failed to log EMI payment: $e', tag: 'Analytics');
    }
  }

  /// Log investment purchase
  Future<void> logInvestmentPurchase({
    required String assetType,
    required String symbol,
    required double amount,
    required double quantity,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'investment_purchased',
        parameters: {
          'asset_type': assetType,
          'symbol': symbol,
          'amount': amount,
          'quantity': quantity,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      logger.info(
        'Investment purchased: $symbol ($assetType)',
        tag: 'Analytics',
      );
    } catch (e) {
      logger.error('Failed to log investment purchase: $e', tag: 'Analytics');
    }
  }

  /// Log expense added
  Future<void> logExpenseAdded({
    required String category,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'expense_added',
        parameters: {
          'category': category,
          'amount': amount,
          'payment_method': paymentMethod,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      logger.info(
        'Expense added: $category, $amount',
        tag: 'Analytics',
      );
    } catch (e) {
      logger.error('Failed to log expense: $e', tag: 'Analytics');
    }
  }

  /// Log bill created
  Future<void> logBillCreated({
    required double amount,
    required int participantCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'bill_created',
        parameters: {
          'amount': amount,
          'participant_count': participantCount,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      logger.info(
        'Bill created: $amount with $participantCount participants',
        tag: 'Analytics',
      );
    } catch (e) {
      logger.error('Failed to log bill creation: $e', tag: 'Analytics');
    }
  }

  /// Log AI recommendation viewed
  Future<void> logAIRecommendationViewed({
    required String recommendationType,
    required String action,
    required int confidence,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'ai_recommendation_viewed',
        parameters: {
          'recommendation_type': recommendationType,
          'action': action,
          'confidence': confidence,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      logger.info(
        'AI recommendation viewed: $action ($confidence%)',
        tag: 'Analytics',
      );
    } catch (e) {
      logger.error('Failed to log AI recommendation: $e', tag: 'Analytics');
    }
  }

  /// Log user engagement
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );

      logger.info('Screen viewed: $screenName', tag: 'Analytics');
    } catch (e) {
      logger.error('Failed to log screen view: $e', tag: 'Analytics');
    }
  }

  /// Log feature usage
  Future<void> logFeatureUsage({required String featureName}) async {
    try {
      await _analytics.logEvent(
        name: 'feature_used',
        parameters: {
          'feature_name': featureName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      logger.info('Feature used: $featureName', tag: 'Analytics');
    } catch (e) {
      logger.error('Failed to log feature usage: $e', tag: 'Analytics');
    }
  }

  /// Log error event
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screenName,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          'screen_name': screenName ?? 'Unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      logger.error(
        'Analytics error logged: $errorType - $errorMessage',
        tag: 'Analytics',
      );
    } catch (e) {
      logger.error('Failed to log error to analytics: $e', tag: 'Analytics');
    }
  }

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    required String currency,
    required String language,
    String? userSegment,
  }) async {
    try {
      await _analytics.setUserId(id: userId);

      await _analytics.setUserProperty(name: 'currency', value: currency);
      await _analytics.setUserProperty(name: 'language', value: language);

      if (userSegment != null) {
        await _analytics.setUserProperty(
            name: 'user_segment', value: userSegment);
      }

      logger.info(
        'User properties set: $userId',
        tag: 'Analytics',
      );
    } catch (e) {
      logger.error('Failed to set user properties: $e', tag: 'Analytics');
    }
  }

  /// Get analytics data summary
  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    return {
      'timestamp': DateTime.now(),
      'userId': await _analytics.appInstanceId,
      'eventsLogged': 'See Firebase Console',
      'status': 'Connected',
    };
  }
}

// Convenience instance
final analytics = AnalyticsHelper();
