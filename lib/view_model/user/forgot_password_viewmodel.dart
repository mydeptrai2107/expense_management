import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();

  bool enableButton = false;
  bool hasEmailError = false;
  bool isLoading = false;

  String emailError = '';

  ForgotPasswordViewModel() {
    emailController.addListener(() {
      validateEmail(emailController.text);
    });
  }

  void validateForm() {
    enableButton = emailController.text.isNotEmpty && !hasEmailError;
    notifyListeners();
  }

  void validateEmail(String email) {
    if (email.contains('@gmail.com')) {
      emailError = tr('email_error_invalid');
      hasEmailError = true;
    }else {
      emailError = '';
      hasEmailError = false;
    }
    validateForm();
  }

  Future<bool> forgotPassword(BuildContext context) async {
    final isEmailValid = !hasEmailError;

    if (!isEmailValid) {
      notifyListeners();
      return false;
    }

    final email = emailController.text.trim() + '@gmail.com';

    isLoading = true;
    notifyListeners();

    try {
      // Kiểm tra xem email đã tồn tại trong Firestore chưa
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Nếu tồn tại ít nhất một tài khoản có cùng email trong Firestore
      if (querySnapshot.docs.isNotEmpty) {
        await _authService.sendPasswordResetEmail(email);
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        emailError = tr('email_error_unregistered');
        isLoading = false;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      emailError = tr('error_occurred');
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Exception: $e');
      emailError = tr('error_occurred');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }
}


