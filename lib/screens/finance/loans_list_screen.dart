// lib/screens/finance/loans_list_screen.dart
// Complete loans management screen with real-time data and EMI tracking

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/loan_provider.dart';
import '../../models/loan_model.dart';

class LoansListScreen extends StatefulWidget {
  const LoansListScreen({super.key});

  @override
  State<LoansListScreen> createState() => _LoansListScreenState();
}

class _LoansListScreenState extends State<LoansListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _sortBy = 'dueDate';
  String _searchQuery = '';

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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Loans'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Consumer<LoanProvider>(
        builder: (context, loanProvider, _) {
          final loans = loanProvider.loans;
          final filteredLoans = _filterAndSortLoans(loans);

          if (loans.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Summary Card
              _buildSummaryCard(loanProvider),

              // Search Bar
              _buildSearchBar(),

              // Loans List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLoans.length,
                  itemBuilder: (context, index) {
                    final loan = filteredLoans[index];
                    return _buildLoanCard(loan, index);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLoanDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(LoanProvider provider) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Total Loan',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${provider.totalLoanAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white24,
          ),
          Column(
            children: [
              Text(
                'EMI/Month',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${(provider.totalEMIObligations / 12).toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white24,
          ),
          Column(
            children: [
              Text(
                'Active Loans',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.loans.length}',
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search loans...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLoanCard(LoanModel loan, int index) {
    final remainingBalance =
        context.read<LoanProvider>().getRemainingBalance(loan.id);
    final isPaid = loan.pendingEmis == 0;
    final isOverdue =
        loan.nextEmiDate != null && loan.nextEmiDate!.isBefore(DateTime.now());

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(index * 0.1, 1, curve: Curves.easeOut),
      )),
      child: GestureDetector(
        onTap: () => _navigateToDetails(loan),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getLoanTypeColor(loan.loanType),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    loan.loanType.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (loan.bankName != null)
                                  Text(
                                    loan.bankName!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Interest Rate Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${loan.interestRate}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              'p.a.',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${loan.principalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EMI',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${loan.emiAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remaining',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${remainingBalance.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${loan.paidEmis}/${loan.tenureMonths} EMIs',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: loan.paidEmis / loan.tenureMonths,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(
                            AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bottom Row - Next EMI & Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next EMI',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (loan.nextEmiDate != null)
                            Row(
                              children: [
                                Icon(
                                  isOverdue
                                      ? Icons.error_outline
                                      : Icons.calendar_today,
                                  size: 14,
                                  color: isOverdue
                                      ? Colors.red
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd MMM yyyy')
                                      .format(loan.nextEmiDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isOverdue
                                        ? Colors.red
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'No due EMI',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                      // Pay EMI Button
                      if (!isPaid && !isOverdue)
                        ElevatedButton.icon(
                          onPressed: () => _handlePayEMI(loan),
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text('Pay EMI'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        )
                      else if (isOverdue)
                        ElevatedButton.icon(
                          onPressed: () => _handlePayEMI(loan),
                          icon: const Icon(Icons.warning, size: 16),
                          label: const Text('Pay Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No loans yet',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first loan to start tracking',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  List<LoanModel> _filterAndSortLoans(List<LoanModel> loans) {
    var filtered = loans.where((loan) {
      return loan.loanName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              loan.bankName!
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
          false;
    }).toList();

    switch (_sortBy) {
      case 'amount':
        filtered.sort((a, b) => b.principalAmount.compareTo(a.principalAmount));
        break;
      case 'interest':
        filtered.sort((a, b) => b.interestRate.compareTo(a.interestRate));
        break;
      case 'dueDate':
      default:
        filtered.sort((a, b) {
          if (a.nextEmiDate == null) return 1;
          if (b.nextEmiDate == null) return -1;
          return a.nextEmiDate!.compareTo(b.nextEmiDate!);
        });
    }

    return filtered;
  }

  Color _getLoanTypeColor(String loanType) {
    switch (loanType.toLowerCase()) {
      case 'personal':
        return Colors.blue;
      case 'home':
        return Colors.green;
      case 'auto':
        return Colors.orange;
      case 'education':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: _sortBy == 'dueDate' ? AppTheme.primaryColor : Colors.grey,
            ),
            title: const Text('Due Date'),
            onTap: () {
              setState(() => _sortBy = 'dueDate');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.attach_money,
              color: _sortBy == 'amount' ? AppTheme.primaryColor : Colors.grey,
            ),
            title: const Text('Amount'),
            onTap: () {
              setState(() => _sortBy = 'amount');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.percent,
              color:
                  _sortBy == 'interest' ? AppTheme.primaryColor : Colors.grey,
            ),
            title: const Text('Interest Rate'),
            onTap: () {
              setState(() => _sortBy = 'interest');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(LoanModel loan) {
    // Navigate to loan details screen
  }

  void _handlePayEMI(LoanModel loan) {
    // Navigate to EMI payment screen
  }

  void _showAddLoanDialog() {
    // Show add loan dialog
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
