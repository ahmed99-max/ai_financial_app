// lib/screens/finance/add_loan_screen.dart
// Complete loan creation with EMI calculation and auto-amortization schedule

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/loan_provider.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _loanNameController = TextEditingController();
  final _principalController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  String _loanType = 'personal';
  DateTime _selectedDate = DateTime.now();
  bool _autoDebit = false;
  bool _isSubmitting = false;

  // Calculated values
  double _calculatedEMI = 0;
  double _totalPayable = 0;
  double _totalInterest = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Add New Loan'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        ),
        child: Column(
          children: [
            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Loan Details', icon: Icon(Icons.description)),
                  Tab(text: 'Preview', icon: Icon(Icons.preview)),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildPreviewTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSubmitting ? null : _submitForm,
        backgroundColor: AppTheme.primaryColor,
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.check),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan Type Selector
            _buildSectionTitle('Loan Type'),
            const SizedBox(height: 12),
            _buildLoanTypeSelector(),
            const SizedBox(height: 24),

            // Loan Name
            _buildSectionTitle('Loan Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _loanNameController,
              validator: (value) => Validators.validateName(value),
              decoration: InputDecoration(
                hintText: 'e.g., Home Loan - HDFC',
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Principal Amount
            _buildSectionTitle('Principal Amount'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _principalController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validateAmount(value),
              onChanged: (_) => _calculateEMI(),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Interest Rate
            _buildSectionTitle('Interest Rate (p.a.)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _interestRateController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validateInterestRate(value),
              onChanged: (_) => _calculateEMI(),
              decoration: InputDecoration(
                hintText: '0.00',
                suffixIcon: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('%'),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Tenure
            _buildSectionTitle('Tenure (Months)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tenureController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validateTenure(value),
              onChanged: (_) => _calculateEMI(),
              decoration: InputDecoration(
                hintText: '60',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Start Date
            _buildSectionTitle('Loan Start Date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 14),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bank Details
            _buildSectionTitle('Bank Details'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bankNameController,
              decoration: InputDecoration(
                hintText: 'Bank Name',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _accountNumberController,
              validator: (value) => Validators.validateAccountNumber(value),
              decoration: InputDecoration(
                hintText: 'Account Number',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Auto Debit Toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enable Auto Debit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Automatic EMI payment from linked account',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _autoDebit,
                    onChanged: (value) => setState(() => _autoDebit = value),
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _loanNameController.text.isEmpty
                      ? 'Loan Summary'
                      : _loanNameController.text,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
                          Formatters.formatCurrency(double.tryParse(
                                  _principalController.text) ??
                              0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Principal',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.formatCurrency(_calculatedEMI),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Monthly EMI',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Loan Breakdown
          _buildPreviewCard('Loan Details', [
            _buildPreviewRow(
              'Loan Type',
              _loanType.toUpperCase(),
            ),
            _buildPreviewRow(
              'Interest Rate',
              '${_interestRateController.text}% p.a.',
            ),
            _buildPreviewRow(
              'Tenure',
              '${_tenureController.text} months (${Formatters.formatTenure(int.tryParse(_tenureController.text) ?? 0)})',
            ),
            _buildPreviewRow(
              'Start Date',
              DateFormat('dd MMM yyyy').format(_selectedDate),
            ),
          ]),
          const SizedBox(height: 16),

          // Financial Summary
          _buildPreviewCard('Financial Summary', [
            _buildPreviewRow(
              'Principal',
              Formatters.formatCurrency(
                  double.tryParse(_principalController.text) ?? 0),
            ),
            _buildPreviewRow(
              'Monthly EMI',
              Formatters.formatCurrency(_calculatedEMI),
            ),
            _buildPreviewRow(
              'Total Interest',
              Formatters.formatCurrency(_totalInterest),
            ),
            _buildPreviewRow(
              'Total Payable',
              Formatters.formatCurrency(_totalPayable),
            ),
          ]),
          const SizedBox(height: 16),

          // EMI Schedule Preview
          _buildPreviewCard('EMI Schedule (First 3 Months)', [
            ..._generateEMISchedule().take(3).toList().asMap().entries.map((e) {
              final month = e.key + 1;
              final emi = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Month $month'),
                    Text(
                      '₹${emi['emi']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ]),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(String title, List<Widget> children) {
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
            children.length,
            (index) => Column(
              children: [
                children[index],
                if (index < children.length - 1) const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildLoanTypeSelector() {
    final types = ['personal', 'home', 'auto', 'education'];

    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = _loanType == type;

        return ChoiceChip(
          label: Text(type.capitalize),
          selected: isSelected,
          onSelected: (selected) => setState(() => _loanType = type),
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        );
      }).toList(),
    );
  }

  void _calculateEMI() {
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = (double.tryParse(_interestRateController.text) ?? 0) / 100 / 12;
    final months = int.tryParse(_tenureController.text) ?? 0;

    if (principal > 0 && rate > 0 && months > 0) {
      final emi = (principal * rate * pow(1 + rate, months)) /
          (pow(1 + rate, months) - 1);

      setState(() {
        _calculatedEMI = emi.isNaN ? 0 : emi;
        _totalPayable = _calculatedEMI * months;
        _totalInterest = _totalPayable - principal;
      });
    }
  }

  List<Map<String, dynamic>> _generateEMISchedule() {
    final schedule = <Map<String, dynamic>>[];
    final principal = double.tryParse(_principalController.text) ?? 0;
    final rate = (double.tryParse(_interestRateController.text) ?? 0) / 100 / 12;
    final months = int.tryParse(_tenureController.text) ?? 0;

    double balance = principal;

    for (int i = 1; i <= months; i++) {
      final interest = balance * rate;
      final principalPay = _calculatedEMI - interest;
      balance -= principalPay;

      schedule.add({
        'month': i,
        'emi': _calculatedEMI.toStringAsFixed(2),
        'principal': principalPay.toStringAsFixed(2),
        'interest': interest.toStringAsFixed(2),
        'balance': balance.toStringAsFixed(2),
      });
    }

    return schedule;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final loanProvider = context.read<LoanProvider>();

      // Create amortization schedule
      final schedule = _generateEMISchedule();

      // Add to provider
      await loanProvider.addLoan(
        loanName: _loanNameController.text,
        loanType: _loanType,
        principalAmount: double.parse(_principalController.text),
        interestRate: double.parse(_interestRateController.text),
        tenureMonths: int.parse(_tenureController.text),
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        startDate: _selectedDate,
        autoDebit: _autoDebit,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Loan added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  double pow(double x, int n) => x * x;

  @override
  void dispose() {
    _loanNameController.dispose();
    _principalController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }
}

extension on String {
  String get capitalize => this[0].toUpperCase() + substring(1);
}
