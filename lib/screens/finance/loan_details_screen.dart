// lib/screens/finance/loan_details_screen.dart
// Complete loan details screen with EMI schedule, charts, and payment history

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/loan_provider.dart';
import '../../models/loan_model.dart';

class LoanDetailsScreen extends StatefulWidget {
  final String loanId;

  const LoanDetailsScreen({
    super.key,
    required this.loanId,
  });

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  bool _expandedSchedule = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        final loan = loanProvider.getLoanDetails(widget.loanId);

        if (loan == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loan Details')),
            body: const Center(
              child: Text('Loan not found'),
            ),
          );
        }

        final remainingBalance = loanProvider.getRemainingBalance(widget.loanId);
        final emiSchedule = loanProvider.getEMISchedule(widget.loanId);
        final interestPaid = loanProvider.getInterestPaidSoFar(widget.loanId);

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('Loan Details'),
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(loan),
              ),
            ],
          ),
          body: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
            ),
            child: Column(
              children: [
                // Loan Summary Card
                _buildSummaryCard(loan, remainingBalance, interestPaid),

                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: const [
                      Tab(text: 'Schedule', icon: Icon(Icons.calendar_today)),
                      Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
                      Tab(text: 'Details', icon: Icon(Icons.info)),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildScheduleTab(emiSchedule, loan),
                      _buildAnalyticsTab(loan, emiSchedule),
                      _buildDetailsTab(loan),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: loan.pendingEmis > 0
              ? FloatingActionButton(
                  onPressed: () => _handlePayEMI(loan),
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.payment),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSummaryCard(LoanModel loan, double remainingBalance, double interestPaid) {
    final loanProgress = (loan.paidEmis / loan.tenureMonths);
    final totalInterest = loan.totalInterest;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.loanName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${loan.principalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${loan.interestRate}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'p.a.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${(loanProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: loanProgress,
                  minHeight: 12,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Paid EMIs',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loan.paidEmis}/${loan.tenureMonths}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Column(
                children: [
                  Text(
                    'Remaining',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${remainingBalance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Column(
                children: [
                  Text(
                    'Interest Paid',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${interestPaid.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(
    List<Map<String, dynamic>> schedule,
    LoanModel loan,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        final emi = schedule[index];
        final isPaid = emi['is_paid'];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isPaid ? Colors.green.shade50 : Colors.white,
            ),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Month ${emi['month']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(emi['due_date']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${emi['emi'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPaid ? 'Paid' : 'Pending',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Principal'),
                          Text('₹${emi['principal'].toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Interest'),
                          Text('₹${emi['interest'].toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Remaining Balance'),
                          Text(
                            '₹${emi['balance'].toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(
    LoanModel loan,
    List<Map<String, dynamic>> schedule,
  ) {
    final totalInterest = loan.totalInterest;
    final principal = loan.principalAmount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Principal vs Interest breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Principal vs Interest',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: principal,
                        title: 'Principal\n₹${principal.toStringAsFixed(0)}',
                        color: Colors.blue,
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        value: totalInterest,
                        title: 'Interest\n₹${totalInterest.toStringAsFixed(0)}',
                        color: Colors.orange,
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // EMI breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EMI Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAnalyticsRow(
                'Monthly EMI',
                '₹${loan.emiAmount.toStringAsFixed(0)}',
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildAnalyticsRow(
                'Total EMIs',
                '${loan.tenureMonths}',
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildAnalyticsRow(
                'Total Amount Payable',
                '₹${loan.totalPayable.toStringAsFixed(0)}',
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildAnalyticsRow(
                'Total Interest',
                '₹${totalInterest.toStringAsFixed(0)}',
                Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(LoanModel loan) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard('Loan Information', [
          _buildDetailRow('Loan Name', loan.loanName),
          _buildDetailRow('Loan Type', loan.loanType.toUpperCase()),
          _buildDetailRow('Bank', loan.bankName ?? 'N/A'),
          _buildDetailRow('Principal Amount', '₹${loan.principalAmount}'),
          _buildDetailRow('Interest Rate', '${loan.interestRate}% p.a.'),
          _buildDetailRow('Tenure', '${loan.tenureMonths} months'),
        ]),
        const SizedBox(height: 12),
        _buildDetailCard('Payment Details', [
          _buildDetailRow('Monthly EMI', '₹${loan.emiAmount.toStringAsFixed(0)}'),
          _buildDetailRow('Total Amount Payable', '₹${loan.totalPayable.toStringAsFixed(0)}'),
          _buildDetailRow('Total Interest', '₹${loan.totalInterest.toStringAsFixed(0)}'),
          _buildDetailRow('EMIs Paid', '${loan.paidEmis}/${loan.tenureMonths}'),
          _buildDetailRow(
            'Next EMI Date',
            loan.nextEmiDate != null
                ? DateFormat('dd MMM yyyy').format(loan.nextEmiDate!)
                : 'N/A',
          ),
        ]),
        const SizedBox(height: 12),
        _buildDetailCard('Account Information', [
          _buildDetailRow('Account Number', _maskAccount(loan.accountNumber ?? 'N/A')),
          _buildDetailRow('Auto Debit', loan.autoDebit ? 'Enabled' : 'Disabled'),
          _buildDetailRow('Created', DateFormat('dd MMM yyyy').format(loan.startDate)),
        ]),
      ],
    );
  }

  Widget _buildDetailCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            rows.length,
            (index) => Column(
              children: [
                rows[index],
                if (index < rows.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Colors.grey.shade200),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String _maskAccount(String account) {
    if (account.length <= 4) return account;
    return '*' * (account.length - 4) + account.substring(account.length - 4);
  }

  void _handlePayEMI(LoanModel loan) {
    // Navigate to EMI payment screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pay EMI feature coming soon')),
    );
  }

  void _showEditDialog(LoanModel loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Loan'),
        content: const Text('Edit loan details'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }
}
