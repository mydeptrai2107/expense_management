import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widget/custom_snackbar_1.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool hasCurrentPassword = false;
  bool hasNewPassword = false;
  bool hasConfirmPassword = false;
  bool enableButton = false;
  bool isLoading = false;

  String error = '';
  String currentPasswordError = '';
  String newPasswordError = '';
  String confirmPasswordError = '';

  ChangePasswordViewModel() {
    currentPasswordController.addListener(() {
      validateCurrenPassword(currentPasswordController.text);
    });
    newPasswordController.addListener(() {
      validateNewPassword(
          newPasswordController.text, currentPasswordController.text);
    });
    confirmPasswordController.addListener(() {
      validateConfirmPassword(
          confirmPasswordController.text, newPasswordController.text);
    });
  }

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible = !isCurrentPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible = !isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  void validateCurrenPassword(String currentPassword) {
    if (currentPassword.length < 6 &&
        currentPasswordController.text.isNotEmpty) {
      currentPasswordError = tr('current_password_error_short');
      hasCurrentPassword = true;
    } else if (currentPassword.length > 30 &&
        currentPasswordController.text.isNotEmpty) {
      currentPasswordError = tr('current_password_error_long');
      hasCurrentPassword = true;
    } else {
      currentPasswordError = '';
      hasCurrentPassword = false;
    }
    validateForm();
  }

  void validateNewPassword(String newPassword, String currentPassword) {
    if (newPassword.isEmpty) {
      newPasswordError = ''; // Không có lỗi nếu mật khẩu mới trống
      hasNewPassword = false;
    } else if (newPassword.length < 6) {
      newPasswordError = tr('new_password_error_short');
      hasNewPassword = true;
    } else if (newPassword.length > 30) {
      newPasswordError = tr('new_password_error_long');
      hasNewPassword = true;
    } else if (newPassword == currentPassword && currentPassword.isNotEmpty) {
      newPasswordError = tr('new_password_error_same');
      hasNewPassword = true;
    } else {
      newPasswordError = "";
      hasNewPassword = false;
    }
    validateForm();
  }


  void validateConfirmPassword(String confirmPassword, String newPassword) {
    if (confirmPassword != newPassword) {
      confirmPasswordError = tr('confirm_password_error_match');
      hasConfirmPassword = true;
    } else {
      confirmPasswordError = '';
      hasConfirmPassword = false;
    }
    validateForm();
  }

  void validateForm() {
    enableButton = currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        !hasCurrentPassword &&
        !hasNewPassword &&
        !hasConfirmPassword;
    notifyListeners();
  }

    Future<bool> changePassword(BuildContext context) async {
      final currentPassword = currentPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();

      final isCurrentPasswordValid = !hasCurrentPassword;
      final isNewPasswordValid = !hasNewPassword;
      final isConfirmPasswordValid = !hasConfirmPassword;

      if (!isCurrentPasswordValid ||
          !isNewPasswordValid ||
          !isConfirmPasswordValid) {
        notifyListeners();
        return false;
      }

      isLoading = true;
      notifyListeners();

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Xác thực mật khẩu hiện tại
          await _authService.reauthenticateUser(user, currentPassword);
          // Cập nhật mật khẩu mới
          await _authService.updateUserPassword(user, newPassword);
          // Cập nhật mật khẩu mới vào Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'password': newPassword,
          });

          isLoading = false;
          notifyListeners();
          return true;
        }
      } on FirebaseAuthException catch (e) {
        print('Error code: ${e.code}');
        if (e.code == 'invalid-credential') {
          error = tr('invalid-credential-pass');
          _showErrorSnackBar(context, error);
        } else if (e.code == 'too-many-requests') {
          error = tr('password_change_too_many_requests');
          _showErrorSnackBar(context, error);
        } else {
          error = tr('error_occurred');
          _showErrorSnackBar(context, error);
          print('Error change password: $e');
        }
        isLoading = false;
        notifyListeners();
      } catch (e) {
        error = tr('error_occurred_later');
        _showErrorSnackBar(context, error);
        print('Error change password: $e');
        isLoading = false;
        notifyListeners();
      }
      return false;
    }

    void _showErrorSnackBar(BuildContext context, String error) {
      CustomSnackBar_1.show(context, error);
    }

  void resetFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    enableButton = false;
    isCurrentPasswordVisible = false;
    isNewPasswordVisible = false;
    isConfirmPasswordVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
