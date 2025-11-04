// lib/screens/profile/notification_preferences_screen.dart
// Granular notification settings and alert configuration

import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // Notification settings
  bool _allNotifications = true;
  bool _expenseAlerts = true;
  bool _budgetAlerts = true;
  bool _loanReminders = true;
  bool _investmentUpdates = true;
  bool _billReminders = true;
  bool _promotionOffers = false;
  bool _weeklyReport = true;
  bool _monthlyReport = true;

  String _pushTime = '09:00';
  String _emailTime = '18:00';

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
        title: const Text('Notification Preferences'),
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
            // Master Switch
            _buildSection(
              'All Notifications',
              Icons.notifications,
              [
                _buildSwitchTile(
                  'Enable All',
                  'Turn all notifications on/off',
                  _allNotifications,
                  (value) => setState(() {
                    _allNotifications = value;
                    _expenseAlerts = value;
                    _budgetAlerts = value;
                    _loanReminders = value;
                    _investmentUpdates = value;
                    _billReminders = value;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Transaction Alerts
            _buildSection(
              'Transaction Alerts',
              Icons.compare_arrows,
              [
                _buildSwitchTile(
                  'Expense Alerts',
                  'Notify when expense is added',
                  _expenseAlerts,
                  (value) => setState(() => _expenseAlerts = value),
                ),
                _buildSwitchTile(
                  'Budget Alerts',
                  'Alert when approaching budget limit',
                  _budgetAlerts,
                  (value) => setState(() => _budgetAlerts = value),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Financial Reminders
            _buildSection(
              'Financial Reminders',
              Icons.alarm,
              [
                _buildSwitchTile(
                  'Loan EMI Reminders',
                  'Remind before EMI due date',
                  _loanReminders,
                  (value) => setState(() => _loanReminders = value),
                ),
                _buildSwitchTile(
                  'Investment Updates',
                  'Portfolio performance updates',
                  _investmentUpdates,
                  (value) => setState(() => _investmentUpdates = value),
                ),
                _buildSwitchTile(
                  'Bill Reminders',
                  'Remind about pending bill settlements',
                  _billReminders,
                  (value) => setState(() => _billReminders = value),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reports
            _buildSection(
              'Reports',
              Icons.assessment,
              [
                _buildSwitchTile(
                  'Weekly Report',
                  'Weekly spending summary',
                  _weeklyReport,
                  (value) => setState(() => _weeklyReport = value),
                ),
                _buildSwitchTile(
                  'Monthly Report',
                  'Monthly financial summary',
                  _monthlyReport,
                  (value) => setState(() => _monthlyReport = value),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Marketing
            _buildSection(
              'Marketing',
              Icons.local_offer,
              [
                _buildSwitchTile(
                  'Promotional Offers',
                  'Receive special offers and deals',
                  _promotionOffers,
                  (value) => setState(() => _promotionOffers = value),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notification Timing
            _buildSection(
              'Notification Timing',
              Icons.schedule,
              [
                _buildTimeTile(
                  'Push Notifications',
                  _pushTime,
                  () => _selectTime('push'),
                ),
                _buildTimeTile(
                  'Email Notifications',
                  _emailTime,
                  () => _selectTime('email'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Save Preferences',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            items.length,
            (index) => Column(
              children: [
                items[index],
                if (index < items.length - 1)
                  Divider(color: Colors.grey.shade200, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildTimeTile(String label, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: AppTheme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(String type) async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (timeOfDay != null) {
      final formattedTime =
          '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';

      setState(() {
        if (type == 'push') {
          _pushTime = formattedTime;
        } else {
          _emailTime = formattedTime;
        }
      });
    }
  }

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Preferences saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
