// lib/screens/auth/otp_screen.dart
// OTP verification screen for phone authentication

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    required this.phoneNumber,
    super.key,
  });

  @override
  State createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  bool _showNameField = false;
  int _resendCountdown = 60;
  late Future<void> _countdownFuture;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  void _startResendCountdown() {
    _resendCountdown = 60;
    _countdownFuture = Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _resendCountdown--);
        if (_resendCountdown > 0) {
          _startResendCountdown();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Verify Phone Number'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Header
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_outlined,
                color: AppTheme.primaryColor,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Verification Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'We sent a code to ${widget.phoneNumber}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // OTP Input
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                hintText: '000000',
                prefixIcon: Icon(Icons.lock_outlined),
                counter: SizedBox.shrink(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Name field (only for new users)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              crossFadeState: _showNameField
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            
            const SizedBox(height: 32),
            
            // Verify button
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _handleOTPVerification(context, authProvider),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Verify'),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Resend button
            Center(
              child: _resendCountdown > 0
                  ? Text(
                      "Resend code in ${_resendCountdown}s",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        _startResendCountdown();
                        // Resend OTP logic
                      },
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // Help text
            Center(
              child: Column(
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Show contact support
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Need Help?'),
                          content: const Text(
                            'Please contact our support team at support@aifinance.app',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOTPVerification(
      BuildContext context, AuthProvider authProvider) async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    // This would typically come from the login screen's verification ID
    final success = await authProvider.verifyOTP(
      'verification_id_from_firebase', // This needs to be passed from login screen
      _otpController.text,
      _nameController.text.isNotEmpty ? _nameController.text : null,
    );

    if (success && context.mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Verification failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
