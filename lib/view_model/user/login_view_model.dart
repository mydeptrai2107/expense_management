import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widget/custom_snackbar_1.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool enableButton = false;
  bool isPasswordVisible = false;
  bool isLoading = false;

  String loginError = '';

  LoginViewModel() {
    emailController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void validateForm() {
    enableButton = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    notifyListeners();
  }

  Future<void> updatePasswordInFirestore(String userId, String newPassword) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'password': newPassword,
      });
    } catch (e) {
      print('Error updating password in Firestore: $e');
    }
  }

  Future<bool> login(BuildContext context) async {
    final email = emailController.text.trim() + '@gmail.com';
    final password = passwordController.text.trim();

    isLoading = true;
    notifyListeners();

    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        await user.reload(); // Reload user để cập nhật trạng thái email đã xác thực hay chưa
        if (user.emailVerified) {
          // Email đã được xác thực, cập nhật mật khẩu mới vào Firestore
          await updatePasswordInFirestore(user.uid, password);
          isLoading = false;
          notifyListeners();
          return true;
        } else {
          // Email chưa được xác thực, hiển thị thông báo lỗi
          loginError = tr('unverified_email');
          _showErrorSnackBar(context, loginError);
          isLoading = false;
          notifyListeners();
          return false;
        }
      }
      isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      print('Error code: ${e.code}'); // In ra mã lỗi
      switch (e.code) {
        case 'invalid-email':
          loginError = tr('email_invalid');
          break;
        case 'invalid-credential':
          loginError = tr('invalid_credential');
          break;
        case 'network-request-failed':
          loginError = tr('network_error');
          break;
        default:
          loginError = tr('login_failed');
          break;
      }
      _showErrorSnackBar(context, loginError);
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      loginError = tr('error_occurred');
      _showErrorSnackBar(context, loginError);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService.signInWithGoogle();
      User? user = userCredential.user;

      if (user != null) {
        await user.reload();
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        _showErrorSnackBar(context, tr('google_login_failed'));
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      loginError = tr('error_occurred');
      _showErrorSnackBar(context, loginError);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetFields() {
    emailController.clear();
    passwordController.clear();
    enableButton = false;
    isPasswordVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    CustomSnackBar_1.show(context, error);
  }
}
