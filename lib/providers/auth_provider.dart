// lib/providers/auth_provider.dart
// State management for authentication with Provider package

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() async {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _isAuthenticated = true;
        await _loadUserData(user.uid);
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _currentUser = await _authService.getUserData(uid);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(email, password, displayName);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithEmail(email, password);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithGoogle();
      _isAuthenticated = _currentUser != null;
      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          // Handle code sent
        },
        onError: (error) {
          _error = error;
          notifyListeners();
        },
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(
    String verificationId,
    String otp,
    String? displayName,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.verifyOTP(
        verificationId,
        otp,
        displayName,
      );
      _isAuthenticated = _currentUser != null;
      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (_currentUser == null) return;
      await _authService.updateUserData(_currentUser!.uid, data);
      _loadUserData(_currentUser!.uid);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> incrementAiUsage() async {
    try {
      if (_currentUser == null) return false;
      return await _authService.incrementAiUsage(_currentUser!.uid);
    } catch (e) {
      _error = e.toString(); // Added error handling
      notifyListeners();
      return false;
    }
  }

  // Future<bool> incrementAiUsage() async {
  //   try {
  //     if (_currentUser == null) return false;
  //     return await _authService.incrementAiUsage(_currentUser!.uid);
  //   } catch (e) {
  //     return false;
  //   }
  // }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get hasAiCreditsAvailable {
    if (_currentUser == null) return false;
    return (_currentUser!.isPremium ||
        _currentUser!.aiUsageCount < _currentUser!.aiUsageLimit);
  }
}
