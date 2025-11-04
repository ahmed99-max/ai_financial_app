// lib/screens/reports/reports_dashboard_screen.dart
// Central dashboard for all financial reports and analytics

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/investment_provider.dart';
import '../../providers/loan_provider.dart';
import '../../utils/formatters.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Financial Reports'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadReports,
          ),
        ],
      ),
      body: Consumer4<ExpenseProvider, BudgetProvider, InvestmentProvider,
          LoanProvider>(
        builder: (context, expenseProvider, budgetProvider, investmentProvider,
            loanProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overview Cards
              _buildOverviewCards(
                expenseProvider,
                investmentProvider,
                loanProvider,
              ),
              const SizedBox(height: 24),

              // Spending Overview
              _buildReportSection(
                title: 'Spending Overview',
                icon: Icons.trending_up,
                child: _buildSpendingOverview(expenseProvider),
              ),
              const SizedBox(height: 20),

              // Budget Status
              _buildReportSection(
                title: 'Budget Status',
                icon: Icons.tablet,
                child: _buildBudgetStatus(budgetProvider, expenseProvider),
              ),
              const SizedBox(height: 20),

              // Investment Summary
              _buildReportSection(
                title: 'Investment Summary',
                icon: Icons.trending_up,
                child: _buildInvestmentSummary(investmentProvider),
              ),
              const SizedBox(height: 20),

              // Loan Summary
              _buildReportSection(
                title: 'Loan Summary',
                icon: Icons.credit_card,
                child: _buildLoanSummary(loanProvider),
              ),
              const SizedBox(height: 20),

              // Financial Health Score
              _buildReportSection(
                title: 'Financial Health Score',
                icon: Icons.favorite,
                child: _buildFinancialHealthScore(
                  expenseProvider,
                  budgetProvider,
                  investmentProvider,
                  loanProvider,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(
    ExpenseProvider expenseProvider,
    InvestmentProvider investmentProvider,
    LoanProvider loanProvider,
  ) {
    final totalSpent =
        expenseProvider.expenses.fold(0.0, (sum, e) => sum + e.amount);
    final netWorth =
        investmentProvider.portfolioValue - loanProvider.totalLoanAmount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildOverviewCard(
            title: 'Total Spent',
            value: Formatters.formatCurrencyShort(totalSpent),
            icon: Icons.trending_up,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          _buildOverviewCard(
            title: 'Net Worth',
            value: Formatters.formatCurrencyShort(netWorth),
            icon: Icons.account_balance,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildOverviewCard(
            title: 'Investments',
            value: Formatters.formatCurrencyShort(
                investmentProvider.portfolioValue),
            icon: Icons.trending_up,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildOverviewCard(
            title: 'Debts',
            value: Formatters.formatCurrencyShort(loanProvider.totalLoanAmount),
            icon: Icons.credit_card,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSpendingOverview(ExpenseProvider expenseProvider) {
    final topCategories = expenseProvider.getTopCategories(limit: 3);

    return Column(
      children: [
        ...topCategories.map((entry) {
          final category = entry.key;
          final amount = entry.value;
          final total =
              expenseProvider.expenses.fold(0.0, (sum, e) => sum + e.amount);
          final percent = (amount / total) * 100;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      Formatters.formatCurrency(amount),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      _getCategoryColor(category),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBudgetStatus(
    BudgetProvider budgetProvider,
    ExpenseProvider expenseProvider,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Budget',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(
                      budgetProvider.getTotalMonthlyBudget()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Spent',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(
                    expenseProvider.expenses
                        .fold(0.0, (sum, e) => sum + e.amount),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.65,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Remaining: ₹3,500 (35%)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInvestmentSummary(InvestmentProvider investmentProvider) {
    final returns = investmentProvider.totalReturns;
    final isPositive = returns >= 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Value',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(investmentProvider.portfolioValue),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Returns',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(returns),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoanSummary(LoanProvider loanProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Loans',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(loanProvider.totalLoanAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Monthly EMI',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(
                      loanProvider.totalEMIObligations / 12),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialHealthScore(
    ExpenseProvider expenseProvider,
    BudgetProvider budgetProvider,
    InvestmentProvider investmentProvider,
    LoanProvider loanProvider,
  ) {
    // Calculate health score (0-100)
    int score = 50; // Base score

    // Savings rate (max 20 points)
    final savingsRate = (budgetProvider.getTotalMonthlyBudget() > 0)
        ? (budgetProvider.getTotalMonthlyBudget() -
                expenseProvider.expenses
                    .fold(0.0, (sum, e) => sum + e.amount)) /
            budgetProvider.getTotalMonthlyBudget() *
            100
        : 0;

    if (savingsRate > 30)
      score += 20;
    else if (savingsRate > 20)
      score += 15;
    else if (savingsRate > 10) score += 10;

    // Investment (max 20 points)
    if (investmentProvider.portfolioValue > 100000)
      score += 20;
    else if (investmentProvider.portfolioValue > 50000) score += 15;

    // Debt ratio (max 20 points)
    final debtRatio = loanProvider.totalLoanAmount > 0 ? 0.3 : 0;
    if (debtRatio < 0.3)
      score += 20;
    else if (debtRatio < 0.5) score += 10;

    // Budget adherence (max 20 points)
    final spent =
        expenseProvider.expenses.fold(0.0, (sum, e) => sum + e.amount);
    final budgetUsage = budgetProvider.getTotalMonthlyBudget() > 0
        ? spent / budgetProvider.getTotalMonthlyBudget()
        : 0;
    if (budgetUsage < 0.8)
      score += 20;
    else if (budgetUsage < 1.0) score += 10;

    final scoreText = score >= 80
        ? 'Excellent'
        : score >= 60
            ? 'Good'
            : score >= 40
                ? 'Fair'
                : 'Poor';

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  score >= 80
                      ? Colors.green
                      : score >= 60
                          ? Colors.blue
                          : score >= 40
                              ? Colors.orange
                              : Colors.red,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  scoreText,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'shopping':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void _downloadReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📥 Reports downloading...')),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
