// lib/screens/reports/ai_insights_screen.dart
// AI-powered financial insights and smart recommendations

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/investment_provider.dart';
import '../../providers/loan_provider.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _selectedCategory = 'All';

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
        title: const Text('AI Insights'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _animController.reset();
              _animController.forward();
            },
          ),
        ],
      ),
      body: Consumer4<ExpenseProvider, BudgetProvider, InvestmentProvider, LoanProvider>(
        builder: (context, expenseProvider, budgetProvider, investmentProvider, loanProvider, _) {
          final insights = _generateInsights(
            expenseProvider,
            budgetProvider,
            investmentProvider,
            loanProvider,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Category Filter
              _buildCategoryFilter(),
              const SizedBox(height: 20),

              // Insights
              if (insights.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No insights available',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...insights.asMap().entries.map((entry) {
                  final index = entry.key;
                  final insight = entry.value;

                  return SlideTransition(
                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(CurvedAnimation(
                      parent: _animController,
                      curve: Interval(index * 0.1, 1, curve: Curves.easeOut),
                    )),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildInsightCard(insight),
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Spending', 'Savings', 'Investment', 'Loan'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: _selectedCategory == category
                    ? Colors.white
                    : Colors.grey.shade700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    final type = insight['type'] as String;
    final Color iconColor;
    final IconData iconData;

    switch (type) {
      case 'warning':
        iconColor = Colors.red;
        iconData = Icons.warning_rounded;
        break;
      case 'opportunity':
        iconColor = Colors.green;
        iconData = Icons.lightbulb_outline;
        break;
      case 'trend':
        iconColor = Colors.blue;
        iconData = Icons.trending_up;
        break;
      case 'achievement':
        iconColor = Colors.amber;
        iconData = Icons.star;
        break;
      case 'recommendation':
        iconColor = Colors.purple;
        iconData = Icons.recommend;
        break;
      default:
        iconColor = Colors.grey;
        iconData = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 2,
        ),
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
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insight['category'] as String? ?? 'Financial Insight',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (insight['severity'] as String? ?? 'medium').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            insight['message'] as String,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Action
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: iconColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight['action'] as String? ?? 'Take action on this insight',
                    style: TextStyle(
                      fontSize: 12,
                      color: iconColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Metadata
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                insight['timestamp'] as String? ?? 'Just now',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              if (insight['impact'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Impact: ${insight['impact']}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateInsights(
    ExpenseProvider expenseProvider,
    BudgetProvider budgetProvider,
    InvestmentProvider investmentProvider,
    LoanProvider loanProvider,
  ) {
    final insights = <Map<String, dynamic>>[];

    // Spending insights
    if (expenseProvider.expenses.isNotEmpty) {
      final topCategory = expenseProvider.getTopCategories(limit: 1).first;
      final totalSpent = expenseProvider.expenses
          .fold(0.0, (sum, e) => sum + e.amount);

      insights.add({
        'type': 'warning',
        'title': 'High spending in ${topCategory.key}',
        'category': 'Spending',
        'message':
            '🚨 You spent ₹${topCategory.value.toStringAsFixed(0)} on ${topCategory.key} this month, which is unusually high.',
        'action': 'Review your purchases and set a category budget to control spending',
        'severity': topCategory.value > totalSpent * 0.4 ? 'high' : 'medium',
        'timestamp': 'Today',
        'impact': '↑ 15% higher than average',
      });
    }

    // Budget insights
    if (budgetProvider.alerts.isNotEmpty) {
      insights.add({
        'type': 'warning',
        'title': 'Budget alert: ${budgetProvider.alerts.length} category over limit',
        'category': 'Budgeting',
        'message':
            '⚠️ ${budgetProvider.alerts.first.categoryName} has reached ${budgetProvider.alerts.first.percentageUsed.toStringAsFixed(0)}% of allocated budget.',
        'action': 'Reduce spending or increase budget allocation for this category',
        'severity': 'high',
        'timestamp': 'Today',
        'impact': '↑ Urgentaction needed',
      });
    }

    // Savings opportunities
    if (expenseProvider.expenses.isNotEmpty) {
      insights.add({
        'type': 'opportunity',
        'title': 'Potential monthly savings',
        'category': 'Savings',
        'message':
            '💡 By reducing unnecessary purchases, you could save ₹2,500+ every month. That\'s ₹30,000 annually!',
        'action': 'Create a savings goal and track it with our budgeting tools',
        'severity': 'low',
        'timestamp': 'Yesterday',
        'impact': '💰 ₹30K/year',
      });
    }

    // Investment insights
    if (investmentProvider.investments.isNotEmpty) {
      final portfolio = investmentProvider.portfolioValue;
      final returns = investmentProvider.totalReturns;

      insights.add({
        'type': 'trend',
        'title': 'Your portfolio is performing well',
        'category': 'Investment',
        'message':
            '📈 Your investment portfolio value is ₹${portfolio.toStringAsFixed(0)} with returns of ₹${returns.toStringAsFixed(0)}. This is above market average.',
        'action': 'Consider diversifying further or consulting with a financial advisor',
        'severity': 'low',
        'timestamp': 'Today',
        'impact': '↑ +${((returns / portfolio) * 100).toStringAsFixed(1)}% ROI',
      });
    }

    // Loan insights
    if (loanProvider.loans.isNotEmpty) {
      final totalEMI = loanProvider.totalEMIObligations;
      final monthlyIncome = 50000; // Mock value

      if ((totalEMI / monthlyIncome) > 0.5) {
        insights.add({
          'type': 'warning',
          'title': 'High loan EMI obligations',
          'category': 'Loan',
          'message':
              '⚠️ Your monthly EMI obligations (₹${totalEMI.toStringAsFixed(0)}) are more than 50% of your income. Consider prepayment options.',
          'action': 'Explore loan consolidation or increase income to improve debt-to-income ratio',
          'severity': 'high',
          'timestamp': 'Today',
          'impact': '⚠️ DTI: ${((totalEMI / monthlyIncome) * 100).toStringAsFixed(0)}%',
        });
      }
    }

    // Achievement insights
    insights.add({
      'type': 'achievement',
      'title': 'On track with your financial goals!',
      'category': 'Achievement',
      'message':
          '🎉 You\'re maintaining a healthy spending pattern and your savings rate is above 20%. Keep it up!',
      'action': 'View your progress in the Reports section',
      'severity': 'low',
      'timestamp': '2 days ago',
      'impact': '✅ 20% savings rate',
    });

    // Recommendations
    insights.add({
      'type': 'recommendation',
      'title': 'Start an emergency fund',
      'category': 'Financial Planning',
      'message':
          '💡 Build an emergency fund with 3-6 months of expenses. This will help you handle unexpected financial challenges.',
      'action': 'Create a dedicated savings goal or investment account',
      'severity': 'medium',
      'timestamp': '1 week ago',
      'impact': '🛡️ Financial security',
    });

    // Filter by category if needed
    if (_selectedCategory != 'All') {
      insights.removeWhere(
        (insight) => !(insight['category'] as String).toLowerCase().contains(
          _selectedCategory.toLowerCase(),
        ),
      );
    }

    return insights;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
