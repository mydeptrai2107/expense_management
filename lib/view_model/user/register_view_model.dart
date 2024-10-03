import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../services/auth_service.dart';
import '../../widget/custom_snackbar_1.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool hasEmailError = false;
  bool hasPasswordError = false;
  bool hasConfirmPasswordError = false;
  bool enableButton = false;
  bool isLoading = false;
  bool isVerifyingEmail = false;

  String emailError = '';
  String passwordError = '';
  String confirmPasswordError = '';

  RegisterViewModel() {
    emailController.addListener(() {
      validateEmail(emailController.text);
    });

    passwordController.addListener(() {
      validatePassword(passwordController.text);
    });

    confirmPasswordController.addListener(() {
      validateConfirmPassword(confirmPasswordController.text, passwordController.text);
    });
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
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

  void validatePassword(String password) {
    if (password.length < 6 && passwordController.text.isNotEmpty) {
      passwordError = tr('password_too_short');
      hasPasswordError = true;
    } else if (password.length > 30 && passwordController.text.isNotEmpty) {
      passwordError = tr('password_too_long');
      hasPasswordError = true;
    } else {
      passwordError = '';
      hasPasswordError = false;
    }
    validateForm();
  }

  void validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword != password) {
      confirmPasswordError = tr('confirm_password_error_match');
      hasConfirmPasswordError = true;
    } else {
      confirmPasswordError = '';
      hasConfirmPasswordError = false;
    }
    validateForm();
  }

  void validateForm() {
    enableButton = emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        !hasEmailError &&
        !hasPasswordError &&
        !hasConfirmPasswordError;
    notifyListeners();
  }

  Future<bool> register(BuildContext context) async {
    final email = emailController.text.trim() + '@gmail.com';
    final newPassword = passwordController.text.trim();

    final isEmailValid = !hasEmailError;
    final isPasswordValid = !hasPasswordError;
    final isConfirmPasswordValid = !hasConfirmPasswordError;
    if (!isEmailValid || !isPasswordValid || !isConfirmPasswordValid) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Tạo tài khoản mới với Firebase Authentication
      User? user = await _authService.createUserWithEmailAndPassword(email, newPassword);
      if (user != null) {
        // Gửi email xác thực
        await user.sendEmailVerification();
        isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emailError = tr('email_in_use');
      } else if (e.code == 'invalid-email') {
        emailError = tr('email_error_invalid');
      }
      // _showErrorSnackBar(context, emailError);
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _showErrorSnackBar(context, tr('error_occurred_later'));
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> saveUserToFirestore(String userId, String email, String password) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'userId': userId,
      'email': email,
      'password': password,
    });
  }

  Future<bool> monitorEmailVerification(User user, String password) async {
    isVerifyingEmail = true;
    notifyListeners();

    await user.reload();

    if (user.emailVerified) {
      String userId = user.uid;
      await saveUserToFirestore(userId, user.email!, password);

      isVerifyingEmail = false;
      notifyListeners();

      return true;
    } else {
      isVerifyingEmail = false;
      notifyListeners();

      return false;
    }
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    CustomSnackBar_1.show(context, error);
  }

  void resetFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    enableButton = false;
    isPasswordVisible = false;
    isConfirmPasswordVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
