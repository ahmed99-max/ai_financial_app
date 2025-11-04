import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class BillSplitTab extends StatelessWidget {
  const BillSplitTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Bill Split',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Split bills with friends easily',
                      style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureCard(
                      Icons.add_circle,
                      'Create New Split',
                      'Split bills with image sharing',
                      () {},
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      Icons.inbox,
                      'Received Bills',
                      'Review and pay shared bills',
                      () {},
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      Icons.group,
                      'Find Friends',
                      'Search and add friends',
                      () {},
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      Icons.chat,
                      'Messages',
                      'Chat about bill disputes',
                      () {},
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Activity',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildEmptyState(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Split'),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.group, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No bills yet',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first bill split',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
