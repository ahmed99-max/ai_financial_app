// lib/screens/finance/loan_offers_screen.dart
// Pre-approved loan offers with personalized recommendations and quick apply

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loan_provider.dart';
import '../../utils/formatters.dart';

class LoanOffersScreen extends StatefulWidget {
  const LoanOffersScreen({super.key});

  @override
  State<LoanOffersScreen> createState() => _LoanOffersScreenState();
}

class _LoanOffersScreenState extends State<LoanOffersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _filterType = 'all';

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
    final offers = _generateOffers();
    final filteredOffers = _filterType == 'all'
        ? offers
        : offers.where((o) => o['type'] == _filterType).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Loan Offers'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Banner
            _buildHeaderBanner(),
            const SizedBox(height: 20),

            // Filter Chips
            _buildFilterChips(),
            const SizedBox(height: 20),

            // Offers List
            ...filteredOffers.asMap().entries.map((entry) {
              final index = entry.key;
              final offer = entry.value;

              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(
                  parent: _animController,
                  curve: Interval(index * 0.1, 1, curve: Curves.easeOut),
                )),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildOfferCard(offer),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pre-Approved Offers',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get instant approval on select loan offers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.verified_user, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Instant approval • No hidden charges',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Personal', 'value': 'personal'},
      {'label': 'Home', 'value': 'home'},
      {'label': 'Auto', 'value': 'auto'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _filterType == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (_) => setState(() => _filterType = filter['value']!),
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final isBestOffer = offer['badge'] == 'best';

    return Container(
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
      child: Stack(
        children: [
          Padding(
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
                            offer['lender'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getLoanTypeColor(offer['type'])
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              offer['type'].toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    _getLoanTypeColor(offer['type']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rate,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${offer['rating']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${offer['reviews']}+ reviews',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Loan Amount & Rate
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loan Amount',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrencyShort(offer['maxAmount']),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interest Rate',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${offer['rateMin']}% - ${offer['rateMax']}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tenure',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${offer['maxTenure']} months',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Features
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Benefits',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (offer['features'] as List<String>)
                          .map((feature) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.green.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check,
                                    size: 12,
                                    color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ))
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _applyForLoan(offer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Best Offer Badge
          if (isBestOffer)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    const Text(
                      'Best Offer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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

  List<Map<String, dynamic>> _generateOffers() {
    return [
      {
        'id': 1,
        'lender': 'HDFC Bank',
        'type': 'personal',
        'maxAmount': 500000,
        'rateMin': 7.5,
        'rateMax': 12,
        'maxTenure': 84,
        'rating': 4.8,
        'reviews': 15000,
        'badge': 'best',
        'features': ['Instant approval', 'No processing fee', '24/7 support'],
      },
      {
        'id': 2,
        'lender': 'ICICI Bank',
        'type': 'home',
        'maxAmount': 5000000,
        'rateMin': 6.5,
        'rateMax': 8.5,
        'maxTenure': 360,
        'rating': 4.7,
        'reviews': 12000,
        'badge': '',
        'features': ['Flexible EMI', 'Expert guidance', 'Low documentation'],
      },
      {
        'id': 3,
        'lender': 'Axis Bank',
        'type': 'auto',
        'maxAmount': 2000000,
        'rateMin': 6.5,
        'rateMax': 9,
        'maxTenure': 72,
        'rating': 4.6,
        'reviews': 8000,
        'badge': '',
        'features': ['Quick disbursement', 'Insurance included', 'Easy transfer'],
      },
      {
        'id': 4,
        'lender': 'SBI',
        'type': 'personal',
        'maxAmount': 750000,
        'rateMin': 8.0,
        'rateMax': 13,
        'maxTenure': 72,
        'rating': 4.5,
        'reviews': 20000,
        'badge': '',
        'features': ['Government bank', 'Reliable', 'Good customer service'],
      },
    ];
  }

  Color _getLoanTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'personal':
        return Colors.blue;
      case 'home':
        return Colors.green;
      case 'auto':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _applyForLoan(Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Loan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Apply with ${offer['lender']}?'),
            const SizedBox(height: 8),
            Text(
              'Loan Amount: ${Formatters.formatCurrencyShort(offer['maxAmount'])}',
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
                const SnackBar(
                  content: Text('✅ Application submitted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
