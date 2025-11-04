// lib/screens/finance/investment_details_screen.dart
// Complete investment details with price charts, recommendations, and performance analytics

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/investment_provider.dart';
import '../../models/investment_model.dart';

class InvestmentDetailsScreen extends StatefulWidget {
  final String investmentId;

  const InvestmentDetailsScreen({
    super.key,
    required this.investmentId,
  });

  @override
  State<InvestmentDetailsScreen> createState() => _InvestmentDetailsScreenState();
}

class _InvestmentDetailsScreenState extends State<InvestmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  String _selectedTimeframe = '1M';

  final timeframes = ['1W', '1M', '3M', '1Y', 'All'];

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
    return Consumer<InvestmentProvider>(
      builder: (context, investmentProvider, _) {
        final investment = investmentProvider.investments
            .firstWhere((inv) => inv.id == widget.investmentId);
        final gainLoss = investment.currentValue - investment.investedAmount;
        final gainLossPercent = (gainLoss / investment.investedAmount) * 100;
        final isPositive = gainLoss >= 0;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(investment.assetName),
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreOptions(investment),
              ),
            ],
          ),
          body: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
            ),
            child: Column(
              children: [
                // Price Header
                _buildPriceHeader(investment, gainLoss, gainLossPercent, isPositive),

                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: const [
                      Tab(text: 'Chart', icon: Icon(Icons.show_chart)),
                      Tab(text: 'AI Analysis', icon: Icon(Icons.lightbulb)),
                      Tab(text: 'Details', icon: Icon(Icons.info)),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChartTab(investment),
                      _buildAIAnalysisTab(investment),
                      _buildDetailsTab(investment),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showSellDialog(investment),
            backgroundColor: Colors.red,
            child: const Icon(Icons.sell_outlined),
          ),
        );
      },
    );
  }

  Widget _buildPriceHeader(
    InvestmentModel investment,
    double gainLoss,
    double gainLossPercent,
    bool isPositive,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? Colors.green : Colors.red)
                .withValues(alpha: 0.3),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Price',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${investment.currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                    ),
                    Text(
                      '${gainLossPercent.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
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
                  Text(
                    'Buy Price',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${investment.buyPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gain/Loss',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}₹${gainLoss.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantity',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${investment.quantity}',
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

  Widget _buildChartTab(InvestmentModel investment) {
    // Generate mock price history data
    final priceHistory = _generatePriceHistory(investment);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Timeframe selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: timeframes.map((timeframe) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(timeframe),
                  selected: _selectedTimeframe == timeframe,
                  onSelected: (selected) {
                    setState(() => _selectedTimeframe = timeframe);
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: _selectedTimeframe == timeframe
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Price chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price History',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() % 5 == 0) {
                              return Text(
                                'Day ${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: priceHistory
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                              e.key.toDouble(),
                              e.value,
                            ))
                            .toList(),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIAnalysisTab(InvestmentModel investment) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // AI Recommendation
        _buildAIRecommendationCard(),
        const SizedBox(height: 16),

        // Technical Indicators
        _buildTechnicalIndicatorsCard(investment),
        const SizedBox(height: 16),

        // Performance Metrics
        _buildPerformanceMetricsCard(investment),
      ],
    );
  }

  Widget _buildAIRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              const Text(
                'AI Recommendation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'BUY',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecommendationRow('Confidence', '85%'),
              const SizedBox(height: 8),
              _buildRecommendationRow('Target Price', '₹150.00'),
              const SizedBox(height: 8),
              _buildRecommendationRow('Timeframe', '3-6 months'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Strong technical momentum with RSI below 30 suggests oversold condition. Moving average crossover indicates potential uptrend.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTechnicalIndicatorsCard(InvestmentModel investment) {
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
            'Technical Indicators',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildIndicatorRow('RSI (14)', '28', Colors.red),
          const SizedBox(height: 12),
          _buildIndicatorRow('MACD', 'Bullish', Colors.green),
          const SizedBox(height: 12),
          _buildIndicatorRow('Moving Average (20)', 'Above', Colors.blue),
          const SizedBox(height: 12),
          _buildIndicatorRow('Support', '₹${investment.currentPrice - 10}', Colors.orange),
          const SizedBox(height: 12),
          _buildIndicatorRow('Resistance', '₹${investment.currentPrice + 15}', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetricsCard(InvestmentModel investment) {
    final gainLoss = investment.currentValue - investment.investedAmount;
    final gainLossPercent = (gainLoss / investment.investedAmount) * 100;

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
            'Performance Metrics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Current Value', '₹${investment.currentValue.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildMetricRow('Invested Amount', '₹${investment.investedAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildMetricRow(
            'Gain/Loss',
            '${gainLossPercent > 0 ? '+' : ''}₹${gainLoss.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            'Return %',
            '${gainLossPercent > 0 ? '+' : ''}${gainLossPercent.toStringAsFixed(2)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(InvestmentModel investment) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard('Investment Information', [
          _buildDetailRow('Asset Name', investment.assetName),
          _buildDetailRow('Symbol', investment.symbol),
          _buildDetailRow('Type', investment.investmentType.toUpperCase()),
          _buildDetailRow('Status', 'Active'),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Purchase Details', [
          _buildDetailRow('Quantity', '${investment.quantity}'),
          _buildDetailRow(
            'Buy Price',
            '₹${investment.buyPrice.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Purchase Date',
            DateFormat('dd MMM yyyy').format(investment.purchaseDate),
          ),
          _buildDetailRow(
            'Invested Amount',
            '₹${investment.investedAmount.toStringAsFixed(2)}',
          ),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Current Details', [
          _buildDetailRow(
            'Current Price',
            '₹${investment.currentPrice.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Current Value',
            '₹${investment.currentValue.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Gain/Loss',
            '₹${(investment.currentValue - investment.investedAmount).toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Return %',
            '${(((investment.currentValue - investment.investedAmount) / investment.investedAmount) * 100).toStringAsFixed(2)}%',
          ),
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
                if (index < rows.length - 1) const Divider(),
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
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  List<double> _generatePriceHistory(InvestmentModel investment) {
    // Generate mock historical prices
    final random = DateTime.now().microsecond.toDouble() % 10;
    return List.generate(
      30,
      (i) => investment.buyPrice + (i * random) + (DateTime.now().microsecond % 5),
    );
  }

  void _showSellDialog(InvestmentModel investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sell Investment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sell ${investment.quantity} shares of ${investment.assetName}?'),
            const SizedBox(height: 16),
            Text(
              'Current Value: ₹${investment.currentValue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sell order placed')),
              );
            },
            child: const Text('Confirm Sell'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(InvestmentModel investment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
            },
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
