// lib/screens/finance/bill_details_screen.dart
// Complete bill split details with participant tracking and settlement status

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/bill_split_provider.dart';
import '../../models/bill_split_model.dart';

class BillDetailsScreen extends StatefulWidget {
  final String billId;

  const BillDetailsScreen({
    super.key,
    required this.billId,
  });

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;

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
    return Consumer<BillSplitProvider>(
      builder: (context, billProvider, _) {
        final bill = billProvider.bills.isNotEmpty
            ? billProvider.bills.firstWhere(
                (b) => b.id == widget.billId,
                orElse: () => billProvider.bills.first,
              )
            : null;

        if (bill == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bill Details')),
            body: const Center(child: Text('Bill not found')),
          );
        }

        final splitAmount = bill.totalAmount / bill.participants.length;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('Bill Details'),
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreOptions(bill),
              ),
            ],
          ),
          body: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
            ),
            child: Column(
              children: [
                // Bill Header
                _buildBillHeader(bill),

                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: const [
                      Tab(text: 'Participants', icon: Icon(Icons.people)),
                      Tab(text: 'History', icon: Icon(Icons.history)),
                      Tab(text: 'Details', icon: Icon(Icons.info)),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildParticipantsTab(bill, splitAmount),
                      _buildHistoryTab(bill),
                      _buildDetailsTab(bill),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: bill.status != BillStatus.completed
              ? FloatingActionButton(
                  onPressed: () => _handleSettlePayment(bill),
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.payment),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBillHeader(BillSplitModel bill) {
    final isPaid = bill.status == BillStatus.completed;
    final isDisputed = bill.status == BillStatus.disputed;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPaid
            ? LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              )
            : isDisputed
                ? LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                  )
                : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                      bill.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${bill.totalAmount.toStringAsFixed(2)}',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'per person',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${(bill.totalAmount / bill.participants.length).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                    'Created',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(bill.createdAt),
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
                    'Status',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bill.status.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
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

  Widget _buildParticipantsTab(BillSplitModel bill, double splitAmount) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bill.participants.length,
      itemBuilder: (context, index) {
        final participant = bill.participants[index];
        final status = participant.status;
        final statusColor = status == ParticipantStatus.paid
            ? Colors.green
            : status == ParticipantStatus.pending
                ? Colors.orange
                : Colors.blue;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: statusColor.withValues(alpha: 0.05),
              border: Border.all(color: statusColor.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        participant.userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          participant.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          participant.userId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount & Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${splitAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BillSplitModel bill) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Timeline - Assuming chat messages can represent history
        ...bill.chatMessages.entries.map((entry) {
          final index = entry.key;
          final message = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline dot
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index != bill.chatMessages.keys.last)
                      Container(
                        width: 2,
                        height: 60,
                        color: Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Payment details
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "System", // Placeholder as participant name is not in chat message
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              message,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(DateTime
                              .now()), // Placeholder, timestamp not available
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                            "Update", // Placeholder
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDetailsTab(BillSplitModel bill) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard('Bill Information', [
          _buildDetailRow('Bill Title', bill.title),
          _buildDetailRow('Description', bill.description ?? 'N/A'),
          _buildDetailRow('Created By', bill.creatorName),
          _buildDetailRow(
            'Created At',
            DateFormat('dd MMM yyyy').format(bill.createdAt),
          ),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Financial Summary', [
          _buildDetailRow(
              // This was missing a comma
              'Total Amount',
              '₹${bill.totalAmount.toStringAsFixed(2)}'),
          _buildDetailRow(
            'Per Person',
            '₹${(bill.totalAmount / bill.participants.length).toStringAsFixed(2)}',
          ),
          _buildDetailRow('Participants', '${bill.participants.length}'),
          _buildDetailRow(
              'Split Type', (bill.splitType ?? 'Equal').toUpperCase()),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Settlement Status', [
          _buildDetailRow('Paid',
              '${bill.participants.where((p) => p.status == ParticipantStatus.paid).length}/${bill.participants.length}'),
          _buildDetailRow(
            'Pending',
            '${bill.participants.where((p) => p.status == ParticipantStatus.pending).length}/${bill.participants.length}',
          ),
          _buildDetailRow('Status', bill.status.name.toUpperCase()),
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
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _handleSettlePayment(BillSplitModel bill) {
    Navigator.pushNamed(context, '/bill_payment', arguments: bill.id);
  }

  void _showMoreOptions(BillSplitModel bill) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Bill'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Message Participants'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Bill'),
            onTap: () => Navigator.pop(context),
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
