// lib/screens/expense/add_expense_screen.dart
// Complete expense creation with AI categorization, real-time validation, and animations

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedCategory;
  String _selectedPaymentMethod = 'UPI';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _recurringFrequency = 'monthly';
  XFile? _receiptImage;
  bool _isSubmitting = false;
  String? _aiCategory;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  Future<void> _pickReceiptImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() => _receiptImage = image);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt image captured')),
      );
    }
  }

  Future<void> _aiCategorizeExpense() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and amount')),
      );
      return;
    }

    // Simulate AI categorization with delay
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    // Simple AI logic - in production use Cloud Functions
    final keywords = {
      'Food & Dining': [
        'food',
        'restaurant',
        'cafe',
        'pizza',
        'burger',
        'swiggy',
        'zomato',
        'meal'
      ],
      'Shopping': [
        'shop',
        'mall',
        'store',
        'amazon',
        'flipkart',
        'cloth',
        'dress'
      ],
      'Transportation': [
        'taxi',
        'uber',
        'ola',
        'bus',
        'train',
        'gas',
        'petrol',
        'auto'
      ],
      'Entertainment': [
        'movie',
        'cinema',
        'game',
        'netflix',
        'spotify',
        'concert'
      ],
      'Healthcare': ['doctor', 'hospital', 'medicine', 'pharmacy', 'clinic'],
    };

    String category = 'Others';
    final searchText =
        '${_titleController.text} ${_merchantController.text}'.toLowerCase();

    for (final entry in keywords.entries) {
      if (entry.value.any((kw) => searchText.contains(kw))) {
        category = entry.key;
        break;
      }
    }

    setState(() {
      _aiCategory = category;
      _selectedCategory = category;
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ AI suggests: $category'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _submitExpense() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final expenseProvider = context.read<ExpenseProvider>();

      await expenseProvider.addExpense(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        paymentMethod: _selectedPaymentMethod,
        merchantName: _merchantController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        receiptUrl: _receiptImage?.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Expense added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back with animation
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Expense'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Input
                _buildInputField(
                  controller: _titleController,
                  label: 'Expense Title *',
                  hint: 'e.g., Lunch at restaurant',
                  icon: Icons.description,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Amount Input
                _buildInputField(
                  controller: _amountController,
                  label: 'Amount (₹) *',
                  hint: '0.00',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Payment Method
                _buildPaymentMethodSelector(),
                const SizedBox(height: 16),

                // Merchant Name
                _buildInputField(
                  controller: _merchantController,
                  label: 'Merchant/Shop Name',
                  hint: 'Optional',
                  icon: Icons.store,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Category Selection with AI
                _buildCategorySelector(),
                const SizedBox(height: 16),

                // Date Picker
                _buildDatePicker(),
                const SizedBox(height: 16),

                // Description
                _buildInputField(
                  controller: _descriptionController,
                  label: 'Notes',
                  hint: 'Add any notes',
                  icon: Icons.note,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Recurring Toggle
                _buildRecurringToggle(),
                const SizedBox(height: 24),

                // Receipt Image Button
                _buildReceiptButton(),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['UPI', 'Card', 'Cash', 'Bank'].map((method) {
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPaymentMethod = method),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == method
                        ? AppTheme.primaryColor
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPaymentMethod == method
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      method,
                      style: TextStyle(
                        color: _selectedPaymentMethod == method
                            ? Colors.white
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Category *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            if (_titleController.text.isNotEmpty &&
                _amountController.text.isNotEmpty)
              GestureDetector(
                onTap: _aiCategorizeExpense,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      if (_isSubmitting)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else
                        const Icon(Icons.auto_awesome,
                            size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      const Text(
                        'AI Suggest',
                        style: TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            items: AppConstants.defaultCategories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      AppConstants.categoryIcons[category],
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Text(category),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _selectedCategory = newValue);
              }
            },
            hint: const Text('Select category'),
          ),
        ),
        if (_aiCategory != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.lightbulb, size: 14, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text(
                  'AI suggests: $_aiCategory',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isRecurring,
              onChanged: (value) =>
                  setState(() => _isRecurring = value ?? false),
              fillColor: const MaterialStatePropertyAll(AppTheme.primaryColor),
            ),
            const Text('Recurring Expense?'),
          ],
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: DropdownButton<String>(
              value: _recurringFrequency,
              isExpanded: true,
              underline: const SizedBox(),
              items: ['daily', 'weekly', 'monthly', 'yearly']
                  .map((frequency) => DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _recurringFrequency = value);
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReceiptButton() {
    return GestureDetector(
      onTap: _pickReceiptImage,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _receiptImage == null ? Colors.grey.shade300 : Colors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _receiptImage == null
              ? Colors.grey.shade50
              : Colors.green.shade50,
        ),
        child: Column(
          children: [
            Icon(
              Icons.camera_alt,
              size: 36,
              color:
                  _receiptImage == null ? Colors.grey.shade400 : Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              _receiptImage == null ? 'Capture Receipt' : '✓ Receipt captured',
              style: TextStyle(
                color:
                    _receiptImage == null ? Colors.grey.shade600 : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Cancel',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text(
                    'Add Expense',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    _animController.dispose();
    super.dispose();
  }
}
