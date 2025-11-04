// lib/screens/finance/bill_payment_screen.dart
// Bill settlement payment processing with participant tracking

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/bill_split_provider.dart';
import '../../utils/formatters.dart';

class BillPaymentScreen extends StatefulWidget {
  final String billId;

  const BillPaymentScreen({super.key, required this.billId});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _selectedMethod = 'upi';
  bool _isProcessing = false;
  Set<String> _selectedParticipants = {};

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
    return Consumer<BillSplitProvider>(
      builder: (context, billProvider, _) {
        final bill = billProvider.bills.firstWhere(
          (b) => b.id == widget.billId,
          orElse: () => billProvider.bills.first,
        );

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('Settle Bill'),
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
                  // Bill Header
                  _buildBillHeader(bill),
                  const SizedBox(height: 24),

                  // Select Participants
                  _buildSectionTitle('Select Who to Pay'),
                  const SizedBox(height: 12),
                  _buildParticipantSelector(bill),
                  const SizedBox(height: 24),

                  // Payment Method
                  _buildSectionTitle('Payment Method'),
                  const SizedBox(height: 12),
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 24),

                  // Payment Summary
                  _buildPaymentSummary(bill),
                  const SizedBox(height: 24),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedParticipants.isNotEmpty && !_isProcessing
                          ? () => _processPayment(bill)
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
                          : const Text('Process Payment'),
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

  Widget _buildBillHeader(dynamic bill) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bill.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ${Formatters.formatCurrency(bill.totalAmount)}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
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

  Widget _buildParticipantSelector(dynamic bill) {
    final splitAmount = bill.totalAmount / bill.participants.length;

    return Column(
      children: bill.participants.map<Widget>((participant) {
        final isSelected = _selectedParticipants.contains(participant.userId);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedParticipants.remove(participant.userId);
              } else {
                _selectedParticipants.add(participant.userId);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) {
                    setState(() {
                      if (isSelected) {
                        _selectedParticipants.remove(participant.userId);
                      } else {
                        _selectedParticipants.add(participant.userId);
                      }
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        participant.userEmail,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.formatCurrency(splitAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = ['upi', 'card', 'bank', 'wallet'];

    return Wrap(
      spacing: 8,
      children: methods.map((method) {
        final isSelected = _selectedMethod == method;

        return ChoiceChip(
          label: Text(method.toUpperCase()),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedMethod = method),
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentSummary(dynamic bill) {
    final splitAmount = bill.totalAmount / bill.participants.length;
    final totalToPay = splitAmount * _selectedParticipants.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Payment Summary'),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Per Person Share',
            Formatters.formatCurrency(splitAmount),
          ),
          const Divider(),
          _buildSummaryRow(
            'Participants Selected',
            '${_selectedParticipants.length}',
          ),
          const Divider(),
          _buildSummaryRow(
            'Total Amount',
            Formatters.formatCurrency(totalToPay),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
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

  Future<void> _processPayment(dynamic bill) async {
    setState(() => _isProcessing = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Bill settled successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
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
          SnackBar(content: Text('Error: $e')),
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
