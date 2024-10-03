import 'dart:async';
import 'package:expense_management/widget/custom_snackbar_1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/auth_service.dart';
import '../../view_model/user/forgot_password_viewmodel.dart';
import '../../widget/custom_ElevatedButton_1.dart';
import '../../widget/custom_header_2.dart';
import '../../widget/custom_snackbar_2.dart';

class VerifyEmailPassScreen extends StatefulWidget {
  const VerifyEmailPassScreen({super.key});

  @override
  State<VerifyEmailPassScreen> createState() => _VerifyEmailPassScreenState();
}

class _VerifyEmailPassScreenState extends State<VerifyEmailPassScreen> {
  bool _isSendingVerification = false;
  bool _hasRecentlySentVerification = false;
  int _countdown = 60;
  Timer? _timer;

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _hasRecentlySentVerification = false;
          _timer?.cancel();
        }
      });
    });
  }

  void _sendPasswordResetEmail(ForgotPasswordViewModel viewModel) async {
    if (_hasRecentlySentVerification) {
      CustomSnackBar_2.show(context, tr('wait_for_resend'));
      return;
    }

    setState(() {
      _isSendingVerification = true;
    });

    try {
      final AuthService authService = AuthService();
      await authService.sendPasswordResetEmail('${viewModel.emailController.text.trim()}@gmail.com');
      setState(() {
        _hasRecentlySentVerification = true;
        _countdown = 60;
      });

      CustomSnackBar_2.show(context, tr('password_reset_email_resent'));
      _startCountdown();
    } catch (e) {
      print('Error sending password reset email: $e');
      if (e is FirebaseAuthException && e.code == 'too-many-requests') {
        CustomSnackBar_1.show(context, 'Quá nhiều yêu cầu gửi email đặt lại mật khẩu. Vui lòng thử lại sau ít phút.');
        setState(() {
          _hasRecentlySentVerification = true;
          _countdown = 60;
        });
        _startCountdown();
      } else {
        CustomSnackBar_1.show(context, 'Có lỗi xảy ra khi gửi email đặt lại mật khẩu. Vui lòng thử lại.');
      }
    }

    setState(() {
      _isSendingVerification = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<ForgotPasswordViewModel>(
      builder: (context, viewModel, child) {
        return Column(
            children: [
              CustomHeader_2(title: tr('verify_email_reset_password')),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Center(
                            child: Image.asset(
                              'assets/images/email.png',
                              height: 250,
                              width: 250,
                            )),
                        const SizedBox(
                          height: 30,
                        ),
                        RichText(
                          text: TextSpan(
                            text: tr('check_email_for_password_reset'),
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                '${viewModel.emailController.text}@gmail.com',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: tr('reset_password_instructions'),
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        CustomElavatedButton_1(
                          onPressed: (_isSendingVerification || _hasRecentlySentVerification)
                              ? null
                              : () => _sendPasswordResetEmail(viewModel),
                          text: tr('send_again'),
                        ),
                        if (_hasRecentlySentVerification)
                          Text(
                            tr('try_again_later_2') + '$_countdown',
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: tr('password_reset_successful'),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      )),
                                  TextSpan(
                                    text: tr('login'),
                                    style: const TextStyle(
                                        color: Colors.green,
                                        decoration: TextDecoration.underline,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacementNamed(
                                            context, '/login');
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
      },
    ));
  }
}
