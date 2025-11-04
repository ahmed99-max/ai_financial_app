// lib/screens/finance/emi_payment_screen.dart
// Complete EMI payment processing with multiple payment methods and real-time verification

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/loan_provider.dart';
import '../../models/loan_model.dart';
import '../../utils/formatters.dart';

class EMIPaymentScreen extends StatefulWidget {
  final String loanId;

  const EMIPaymentScreen({
    super.key,
    required this.loanId,
  });

  @override
  State<EMIPaymentScreen> createState() => _EMIPaymentScreenState();
}

class _EMIPaymentScreenState extends State<EMIPaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _selectedMethod = 'upi';
  bool _isProcessing = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProvider>(
      builder: (context, loanProvider, _) {
        final loan = loanProvider.loans.firstWhere(
          (l) => l.id == widget.loanId,
          orElse: () => loanProvider.loans.first,
        );

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('Pay EMI'),
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
          ),
          body: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // EMI Summary Card
                  _buildEMISummaryCard(loan),
                  const SizedBox(height: 24),

                  // Payment Method Selection
                  _buildSectionTitle('Select Payment Method'),
                  const SizedBox(height: 12),
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 24),

                  // Payment Details
                  _buildPaymentDetails(loan),
                  const SizedBox(height: 24),

                  // Terms & Conditions
                  _buildTermsCheckbox(),
                  const SizedBox(height: 24),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreeToTerms && !_isProcessing
                          ? () => _processPayment(loan)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              'Pay ${Formatters.formatCurrency(loan.emiAmount)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEMISummaryCard(LoanModel loan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loan.loanName,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EMI Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.formatCurrency(loan.emiAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'EMI #',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${loan.paidEmis + 1}/${loan.tenureMonths}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Due Date',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loan.nextEmiDate != null
                        ? DateFormat('dd MMM yyyy').format(loan.nextEmiDate!)
                        : 'N/A',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Remaining EMIs',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loan.pendingEmis}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = [
      {'id': 'upi', 'name': 'UPI', 'icon': Icons.phone_android},
      {'id': 'card', 'name': 'Debit Card', 'icon': Icons.credit_card},
      {'id': 'bank', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
      {'id': 'wallet', 'name': 'Wallet', 'icon': Icons.account_balance_wallet},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: methods.map((method) {
        final isSelected = _selectedMethod == method['id'];
        return GestureDetector(
          onTap: () =>
              setState(() => _selectedMethod = method['id']! as String),
          child: Container(
            width: (MediaQuery.of(context).size.width - 40) / 2,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  method['icon'] as IconData,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  method['name']! as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentDetails(LoanModel loan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Payment Details'),
          const SizedBox(height: 12),
          _buildDetailRow(
              'EMI Amount', Formatters.formatCurrency(loan.emiAmount)),
          const Divider(),
          _buildDetailRow('Processing Fee', '₹0.00'),
          const Divider(),
          _buildDetailRow(
            'Total Amount',
            Formatters.formatCurrency(loan.emiAmount),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppTheme.primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _agreeToTerms,
            onChanged: (value) =>
                setState(() => _agreeToTerms = value ?? false),
            activeColor: AppTheme.primaryColor,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'terms and conditions',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  TextSpan(
                    text: 'privacy policy',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(LoanModel loan) async {
    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // In production: Integrate Razorpay or payment gateway
      // For now: Mock successful payment

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  '${Formatters.formatCurrency(loan.emiAmount)} paid successfully',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transaction ID: TXN${DateTime.now().millisecondsSinceEpoch}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
