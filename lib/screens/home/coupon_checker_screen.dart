import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../services/ai_service.dart';

class CouponCheckerScreen extends StatefulWidget {
  const CouponCheckerScreen({super.key});

  @override
  State<CouponCheckerScreen> createState() => _CouponCheckerScreenState();
}

class _CouponCheckerScreenState extends State<CouponCheckerScreen> {
  final _couponController = TextEditingController();
  final _urlController = TextEditingController();
  final _aiService = AIService();
  bool _isChecking = false;

  Future<void> _checkCoupon() async {
    if (_couponController.text.trim().isEmpty || _urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both coupon code and URL')),
      );
      return;
    }

    setState(() => _isChecking = true);

    try {
      final coupon = await _aiService.checkCoupon(
        _couponController.text.trim(),
        _urlController.text.trim(),
        'guest_user',
      );

      setState(() => _isChecking = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(coupon.isValid ? 'Valid Coupon! ✅' : 'Invalid Coupon ❌'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${coupon.code}'),
                const SizedBox(height: 8),
                if (coupon.isValid) ...[
                  Text('Discount: ${coupon.discountText}'),
                  if (coupon.minPurchaseAmount != null)
                    Text('Min Purchase: ₹${coupon.minPurchaseAmount!.toStringAsFixed(0)}'),
                  if (coupon.maxDiscountAmount != null)
                    Text('Max Discount: ₹${coupon.maxDiscountAmount!.toStringAsFixed(0)}'),
                ],
                const SizedBox(height: 8),
                Text(coupon.description ?? ''),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isChecking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon Checker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.local_offer, size: 60, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'AI Coupon Validator',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check coupon validity and get maximum discount details',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _couponController,
              decoration: const InputDecoration(
                labelText: 'Coupon Code',
                hintText: 'e.g., SAVE20',
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Merchant URL',
                hintText: 'e.g., https://amazon.in',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isChecking ? null : _checkCoupon,
              icon: _isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(_isChecking ? 'Checking...' : 'Check Coupon'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'How it works:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.input, 'Enter coupon code and merchant URL'),
            _buildInfoCard(Icons.smart_toy, 'AI validates the coupon instantly'),
            _buildInfoCard(Icons.discount, 'Get discount details and terms'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}
