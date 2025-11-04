import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'home/home_tab.dart';
import 'bill_split/bill_split_tab.dart';
import 'finance/finance_tab.dart';
import 'expense/expense_tab.dart';
import 'profile/profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  final List<Widget> _tabs = const [
    HomeTab(),
    BillSplitTab(),
    FinanceTab(),
    ExpenseTab(),
    ProfileTab(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group),
      label: 'Bill Split',
    ),
    NavigationDestination(
      icon: Icon(Icons.trending_up_outlined),
      selectedIcon: Icon(Icons.trending_up),
      label: 'Finance',
    ),
    NavigationDestination(
      icon: Icon(Icons.wallet_outlined),
      selectedIcon: Icon(Icons.wallet),
      label: 'Expenses',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppConstants.mediumAnimation,
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
        animationDuration: AppConstants.mediumAnimation,
        backgroundColor: Colors.white,
        elevation: 8,
        height: 70,
      ),
    );
  }
}
