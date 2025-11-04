// lib/widgets/investment_card.dart
// Reusable investment card with real-time price updates and quick actions

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/investment_model.dart';
import '../utils/formatters.dart';

class InvestmentCard extends StatefulWidget {
  final InvestmentModel investment;
  final VoidCallback? onTap;
  final VoidCallback? onSell;
  final VoidCallback? onAddMore;
  final AnimationController? animationController;

  const InvestmentCard({
    super.key,
    required this.investment,
    this.onTap,
    this.onSell,
    this.onAddMore,
    this.animationController,
  });

  @override
  State<InvestmentCard> createState() => _InvestmentCardState();
}

class _InvestmentCardState extends State<InvestmentCard> {
  @override
  Widget build(BuildContext context) {
    final gainLoss = widget.investment.currentValue - widget.investment.investedAmount;
    final gainLossPercent = (gainLoss / widget.investment.investedAmount) * 100;
    final isPositive = gainLoss >= 0;

    return ScaleTransition(
      scale: widget.animationController != null
          ? Tween<double>(begin: 0.9, end: 1).animate(
              CurvedAnimation(
                parent: widget.animationController!,
                curve: Curves.easeOut,
              ),
            )
          : AlwaysStoppedAnimation(1),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isPositive
                  ? Colors.green.shade200
                  : Colors.red.shade200,
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.investment.assetName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.investment.symbol.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(widget.investment.investmentType)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatType(widget.investment.investmentType),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getTypeColor(widget.investment.investmentType),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Amount Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.investment.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Price',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${widget.investment.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Value',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(
                                widget.investment.currentValue),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Gain/Loss Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invested',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Formatters.formatCurrency(
                                  widget.investment.investedAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gain/Loss',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  isPositive
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 12,
                                  color: isPositive
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${isPositive ? '+' : ''}${gainLossPercent.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isPositive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (widget.onSell != null || widget.onAddMore != null)
                          Row(
                            children: [
                              if (widget.onAddMore != null)
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  iconSize: 20,
                                  color: AppTheme.primaryColor,
                                  onPressed: widget.onAddMore,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              if (widget.onSell != null)
                                IconButton(
                                  icon: const Icon(Icons.sell_outlined),
                                  iconSize: 20,
                                  color: Colors.red,
                                  onPressed: widget.onSell,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'stocks':
        return Colors.blue;
      case 'crypto':
        return Colors.orange;
      case 'mutual_funds':
        return Colors.purple;
      case 'bonds':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatType(String type) {
    return type.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
