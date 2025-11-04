// lib/screens/expense/expense_history_screen.dart
// Transaction history with filtering, search, and beautiful card animations

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense_model.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedPeriod = 'All';
  bool _isSearching = false;
  List<ExpenseModel> _filteredExpenses = [];

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _filterExpenses(List<ExpenseModel> expenses) {
    List<ExpenseModel> filtered = expenses;

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((e) =>
              e.title
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()) ||
                  e.merchantName!
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()) ??
              false)
          .toList();
    }

    // Filter by period
    final now = DateTime.now();
    if (_selectedPeriod != 'All') {
      DateTime startDate;
      if (_selectedPeriod == 'Today') {
        startDate = DateTime(now.year, now.month, now.day);
      } else if (_selectedPeriod == 'Week') {
        startDate = now.subtract(Duration(days: now.weekday - 1));
      } else if (_selectedPeriod == 'Month') {
        startDate = DateTime(now.year, now.month, 1);
      } else {
        startDate = DateTime(now.year - 1);
      }

      filtered = filtered.where((e) => e.date.isAfter(startDate)).toList();
    }

    setState(() => _filteredExpenses = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Expense History'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          _filterExpenses(provider.expenses);

          return Column(
            children: [
              // Search and Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                child: Column(
                  children: [
                    // Search Field
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => _filterExpenses(provider.expenses),
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterExpenses(provider.expenses);
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Period Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Today', 'Week', 'Month', 'Year']
                            .map((period) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(period),
                              selected: _selectedPeriod == period,
                              onSelected: (_) {
                                setState(() => _selectedPeriod = period);
                                _filterExpenses(provider.expenses);
                              },
                              selectedColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color: _selectedPeriod == period
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: const [
                    Tab(text: 'List View', icon: Icon(Icons.list)),
                    Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // List View
                    _buildListView(provider),

                    // Analytics View
                    _buildAnalyticsView(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListView(ExpenseProvider provider) {
    if (_filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = _filteredExpenses[index];
        return _buildExpenseCard(expense, index);
      },
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense, int index) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(index * 0.1, 1, curve: Curves.easeOut),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
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
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppConstants.categoryColors[expense.category] ??
                        AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      AppConstants.categoryIcons[expense.category] ??
                          Icons.receipt,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              expense.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '₹${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            expense.merchantName ?? 'Cash',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM, hh:mm a').format(expense.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              AppConstants.categoryColors[expense.category] ??
                                  AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          expense.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsView(ExpenseProvider provider) {
    final categorySummary = provider.getCategorySummary();
    final topCategories = provider.getTopCategories(limit: 5);
    final weeklyTrend = provider.getSpendingTrend(days: 7);
    final totalExpenses = weeklyTrend.fold(0.0, (sum, e) => sum + e);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Spending Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Spending (Last 7 Days)',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Average: ₹${(totalExpenses / 7).toStringAsFixed(2)}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    if (provider.expenses.length > 1)
                      Text(
                        '${provider.expenses.length} transactions',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Weekly Chart
          const Text(
            'Spending Trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTrendChart(weeklyTrend),
          const SizedBox(height: 24),

          // Category Breakdown
          const Text(
            'Category Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCategoryChart(topCategories),
          const SizedBox(height: 24),

          // Top Categories List
          const Text(
            'Top Spending Categories',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...topCategories.map((entry) {
            final percentage = (entry.value / totalExpenses * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 13)),
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        AppConstants.categoryColors[entry.key] ??
                            AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<double> trend) {
    final maxValue =
        trend.isEmpty ? 1.0 : trend.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ];
                  if (value.toInt() < days.length) {
                    return Text(days[value.toInt()],
                        style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  '₹${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                trend.length,
                (index) => FlSpot(index.toDouble(), trend[index]),
              ),
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
          ],
          minY: 0,
          maxY: maxValue * 1.2,
        ),
      ),
    );
  }

  Widget _buildCategoryChart(List<MapEntry<String, double>> categories) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: categories.asMap().entries.map((e) {
            final color = AppConstants.categoryColors[e.value.key] ??
                AppTheme.primaryColor;
            return PieChartSectionData(
              value: e.value.value,
              title:
                  '${(e.value.value / categories.fold<double>(0, (sum, c) => sum + c.value) * 100).toStringAsFixed(0)}%',
              color: color,
              radius: 60,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }
}
