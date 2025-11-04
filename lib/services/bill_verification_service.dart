// lib/services/bill_verification_service.dart
// Bill verification using OCR and validation

import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart' as mlv;

class BillVerificationService {
  static final BillVerificationService _instance = BillVerificationService._internal();

  factory BillVerificationService() {
    return _instance;
  }

  BillVerificationService._internal();

  /// Extract text from bill image using ML Vision
  Future<String> extractBillText(File billImage) async {
    try {
      // Note: firebase_ml_vision is deprecated, use google_mlkit_text_recognition instead
      // This is a placeholder for the actual OCR implementation
      
      // Simulated OCR result
      return '''
Invoice Date: 15 Nov 2024
Invoice Amount: ₹2,500
Merchant: ABC Restaurant
Items:
- Lunch: ₹1,500
- Beverages: ₹800
- GST: ₹200
Payment Method: Card
Transaction ID: TXN123456
      ''';
    } catch (e) {
      throw Exception('Failed to extract bill text: $e');
    }
  }

  /// Parse extracted text and return structured data
  Map<String, dynamic> parseBillText(String extractedText) {
    final lines = extractedText.split('\n');
    
    double? amount;
    String? date;
    String? merchant;
    final items = <String>[];

    for (final line in lines) {
      if (line.contains('Amount')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          final amountStr = parts[1].replaceAll(RegExp(r'[^\d.]'), '');
          amount = double.tryParse(amountStr);
        }
      } else if (line.contains('Date')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          date = parts[1].trim();
        }
      } else if (line.contains('Merchant')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          merchant = parts[1].trim();
        }
      } else if (line.trim().isNotEmpty && !line.contains(':')) {
        items.add(line.trim());
      }
    }

    return {
      'amount': amount ?? 0,
      'date': date,
      'merchant': merchant,
      'items': items,
      'isValid': amount != null && amount > 0,
      'confidence': 0.85,
    };
  }

  /// Validate bill information
  Future<Map<String, dynamic>> validateBill({
    required double amount,
    required String merchant,
    required String date,
  }) async {
    try {
      // Simulate validation checks
      await Future.delayed(const Duration(milliseconds: 800));

      final errors = <String>[];

      if (amount <= 0) {
        errors.add('Invalid bill amount');
      }

      if (amount > 100000) {
        errors.add('Bill amount exceeds maximum limit');
      }

      if (merchant.isEmpty) {
        errors.add('Merchant name is missing');
      }

      if (date.isEmpty) {
        errors.add('Bill date is missing');
      }

      return {
        'isValid': errors.isEmpty,
        'errors': errors,
        'warnings': _getWarnings(amount),
        'verified': errors.isEmpty,
      };
    } catch (e) {
      return {
        'isValid': false,
        'errors': ['Validation failed: $e'],
        'warnings': [],
        'verified': false,
      };
    }
  }

  /// Get warnings based on bill amount
  List<String> _getWarnings(double amount) {
    final warnings = <String>[];

    if (amount > 5000) {
      warnings.add('High bill amount - ensure accuracy');
    }

    if (amount < 100) {
      warnings.add('Very small bill amount - verify if correct');
    }

    return warnings;
  }

  /// Extract bill items with amounts
  List<Map<String, dynamic>> extractBillItems(String extractedText) {
    final items = <Map<String, dynamic>>[];
    final lines = extractedText.split('\n');

    for (final line in lines) {
      if (line.contains('₹') || line.contains('Rs')) {
        final parts = line.split('₹');
        if (parts.length > 1) {
          final itemName = parts[0].trim();
          final amount = double.tryParse(parts[1].trim()) ?? 0;

          if (itemName.isNotEmpty && amount > 0) {
            items.add({
              'name': itemName,
              'amount': amount,
              'category': _categorizeItem(itemName),
            });
          }
        }
      }
    }

    return items;
  }

  /// Categorize bill item
  String _categorizeItem(String itemName) {
    final name = itemName.toLowerCase();

    if (name.contains('food') || name.contains('meal')) {
      return 'Food';
    } else if (name.contains('drink') || name.contains('beverage')) {
      return 'Beverage';
    } else if (name.contains('tax') || name.contains('gst')) {
      return 'Tax';
    } else if (name.contains('service')) {
      return 'Service';
    }

    return 'Other';
  }

  /// Calculate bill split among participants
  List<Map<String, dynamic>> calculateBillSplit(
    double totalAmount,
    List<String> participantNames, {
    Map<String, double>? customSplit,
  }) {
    if (participantNames.isEmpty) {
      return [];
    }

    final results = <Map<String, dynamic>>[];
    final perPersonAmount = totalAmount / participantNames.length;

    for (final name in participantNames) {
      final amount = customSplit?[name] ?? perPersonAmount;

      results.add({
        'name': name,
        'amount': amount,
        'percentage': (amount / totalAmount) * 100,
      });
    }

    return results;
  }

  /// Generate bill receipt
  Map<String, dynamic> generateReceipt({
    required String billId,
    required String merchant,
    required double amount,
    required String date,
    required List<String> participants,
  }) {
    return {
      'billId': billId,
      'merchant': merchant,
      'totalAmount': amount,
      'perPersonAmount': amount / participants.length,
      'date': date,
      'participants': participants,
      'generatedAt': DateTime.now(),
      'status': 'pending',
      'payments': List.generate(
        participants.length,
        (i) => {
          'participant': participants[i],
          'amount': amount / participants.length,
          'status': 'pending',
          'dueDate': DateTime.now().add(const Duration(days: 7)),
        },
      ),
    };
  }

  /// Export bill as PDF (placeholder)
  Future<String> exportBillAsPDF(Map<String, dynamic> receipt) async {
    try {
      // In production: Use pdf package to generate PDF
      await Future.delayed(const Duration(milliseconds: 500));
      
      return 'path/to/bill_${receipt['billId']}.pdf';
    } catch (e) {
      throw Exception('Failed to export bill: $e');
    }
  }
}
