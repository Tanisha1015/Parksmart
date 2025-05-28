// lib/services/payment_service.dart
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();
  final Function(PaymentSuccessResponse) onSuccess;
  final Function(PaymentFailureResponse) onFailure;
  final Function(ExternalWalletResponse) onExternalWallet;
  
  PaymentService({
    required this.onSuccess,
    required this.onFailure,
    required this.onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }
  
  void makePayment({
    required String name,
    required String description,
    required double amount,
    required String email,
    required String contact,
  }) {
    // Amount needs to be in paise (1 rupee = 100 paise)
    final int amountInPaise = (amount * 100).toInt();
    
    var options = {
      'key': 'YOUR_RAZORPAY_KEY',
      'amount': amountInPaise,
      'name': name,
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email,
      }
    };
    
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
  
  void dispose() {
    _razorpay.clear();
  }
}
