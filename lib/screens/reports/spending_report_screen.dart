// lib/screens/reports/spending_report_screen.dart
// Advanced spending analysis with charts and comparisons

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';
import '../../providers/expense_provider.dart';
import '../../utils/formatters.dart';

class SpendingReportScreen extends StatefulWidget {
  const SpendingReportScreen({super.key});

  @override
  State<SpendingReportScreen> createState() => _SpendingReportScreenState();
}

class _SpendingReportScreenState extends State<SpendingReportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _selectedPeriod = 'month';

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
        title: const Text('Spending Report'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        ),
        child: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Period Selector
                _buildPeriodSelector(),
                const SizedBox(height: 20),

                // Key Metrics
                _buildMetricsCards(expenseProvider),
                const SizedBox(height: 20),

                // Category Breakdown Chart
                _buildChart(
                  title: 'Category Breakdown',
                  child: _buildCategoryPieChart(expenseProvider),
                ),
                const SizedBox(height: 20),

                // Monthly Trend Chart
                _buildChart(
                  title: 'Monthly Trend',
                  child: _buildMonthlyTrendChart(expenseProvider),
                ),
                const SizedBox(height: 20),

                // Weekly Comparison Chart
                _buildChart(
                  title: 'Weekly Comparison',
                  child: _buildWeeklyComparisonChart(expenseProvider),
                ),
                const SizedBox(height: 20),

                // Top Categories
                _buildTopCategoriesCard(expenseProvider),
                const SizedBox(height: 20),

                // Comparison & Insights
                _buildComparisonCard(expenseProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      {'label': 'Month', 'value': 'month'},
      {'label': 'Quarter', 'value': 'quarter'},
      {'label': 'Year', 'value': 'year'},
    ];

    return Wrap(
      spacing: 8,
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period['value'];
        return ChoiceChip(
          label: Text(period['label']!),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedPeriod = period['value']!),
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsCards(ExpenseProvider expenseProvider) {
    final totalSpent =
        expenseProvider.expenses.fold(0.0, (sum, e) => sum + e.amount);
    final avgTransaction = totalSpent / max(expenseProvider.expenses.length, 1);

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Spent',
            value: Formatters.formatCurrencyShort(totalSpent),
            color: Colors.red,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Average',
            value: Formatters.formatCurrencyShort(avgTransaction),
            color: Colors.blue,
            icon: Icons.show_chart,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart({required String title, required Widget child}) {
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
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(ExpenseProvider expenseProvider) {
    final topCategories = expenseProvider.getTopCategories(limit: 5);

    return PieChart(
      PieChartData(
        sections: topCategories.asMap().entries.map((entry) {
          final category = entry.value.key;
          final amount = entry.value.value;
          final total =
              expenseProvider.expenses.fold(0.0, (sum, e) => sum + e.amount);
          final percent = (amount / total) * 100;

          return PieChartSectionData(
            value: amount,
            title: '${percent.toStringAsFixed(0)}%',
            color: _getCategoryColor(category),
            radius: 60,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyTrendChart(ExpenseProvider expenseProvider) {
    // Generate mock monthly data
    final monthlyData = _generateMonthlyData(expenseProvider);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() < months.length) {
                  return Text(months[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: monthlyData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparisonChart(ExpenseProvider expenseProvider) {
    // Generate mock weekly data
    final weeklyData = _generateWeeklyData(expenseProvider);

    return BarChart(
      BarChartData(
        barGroups: weeklyData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: AppTheme.primaryColor,
                width: 12,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() < days.length) {
                  return Text(days[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCategoriesCard(ExpenseProvider expenseProvider) {
    final topCategories = expenseProvider.getTopCategories(limit: 5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Categories',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...topCategories.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final category = entry.value.key;
            final amount = entry.value.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(amount),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(ExpenseProvider expenseProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Month Comparison',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatCurrencyShort(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Last Month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹25,000',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.65,
            minHeight: 6,
            backgroundColor: Colors.blue.shade100,
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            '+10% compared to last month',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<double> _generateMonthlyData(ExpenseProvider expenseProvider) {
    return [15000, 18000, 16500, 20000, 19000, 22000];
  }

  List<double> _generateWeeklyData(ExpenseProvider expenseProvider) {
    return [3000, 2500, 3200, 2800, 3500, 2900, 3100];
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'shopping':
        return Colors.pink;
      case 'entertainment':
        return Colors.purple;
      case 'healthcare':
        return Colors.red;
      case 'bills & utilities':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  int max(int a, int b) => a > b ? a : b;

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
