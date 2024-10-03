import 'dart:async';
import 'package:expense_management/widget/custom_header_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../view_model/user/register_view_model.dart';
import '../../widget/custom_ElevatedButton_1.dart';
import '../../widget/custom_snackbar_1.dart';
import '../../widget/custom_snackbar_2.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isSendingVerification = false;
  bool _hasRecentlySentVerification = false;
  int _countdown = 60;
  Timer? _timer;

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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

  void _sendEmailVerification(RegisterViewModel viewModel) async {
    if (_hasRecentlySentVerification) {
      CustomSnackBar_2.show(context, tr('try_again_later'));
      return;
    }

    setState(() {
      _isSendingVerification = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        setState(() {
          _hasRecentlySentVerification = true;
          _countdown = 60;
        });

        CustomSnackBar_2.show(context, tr('verification_email_sent_again'));
        _startCountdown();
      }
    } catch (e) {
      print('Error sending email verification: $e');
      if (e is FirebaseAuthException && e.code == 'too-many-requests') {
        CustomSnackBar_1.show(context, tr('too_many_requests'));
        setState(() {
          _hasRecentlySentVerification = true;
          _countdown = 60;
        });
        _startCountdown();
      } else {
        CustomSnackBar_1.show(context, tr('error_sending_verification_email'));
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
    return Scaffold(
      body: Consumer<RegisterViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
                Column(
                  children: [
                    CustomHeader_2(title: tr('verify_email')),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Center(
                                  child: Image.asset(
                                    'assets/images/email.png',
                                    height: 250,
                                    width: 250,
                                  )),
                              SizedBox(
                                height: 30,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: tr('check_email'),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    TextSpan(
                                      text: '${viewModel.emailController.text}@gmail.com',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    TextSpan(
                                      text: tr('and_click_verification_link'),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              CustomElavatedButton_1(
                                onPressed: () async {
                                  User? user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    await user.reload();
                                    if (user.emailVerified) {
                                      await viewModel.monitorEmailVerification(
                                          user, viewModel.passwordController.text);
                                      await CustomSnackBar_2.show(context, tr('registration_successful'));
                                      Navigator.pushReplacementNamed(context, '/login');
                                    } else {
                                      CustomSnackBar_1.show(context, tr('email_not_verified'));
                                    }
                                  }
                                },
                                text: tr('i_have_verified'),
                              ),
                              SizedBox(height: 20),
                              CustomElavatedButton_1(
                                onPressed: (_isSendingVerification || _hasRecentlySentVerification)
                                    ? null
                                    : () => _sendEmailVerification(viewModel),
                                text: tr('resend_verification_email'),
                              ),
                              if (_hasRecentlySentVerification)
                                Text(
                                  tr('try_again_later_2') + '$_countdown',
                                  style: TextStyle(color: Colors.red),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (viewModel.isVerifyingEmail)
                Container(
                  color: Colors.black.withOpacity(0.5), // nền mờ
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        strokeWidth: 6.0, // độ dày
                      ),
                    ),
                  ),
                ),
              ],
          );
        },
      ),
    );
  }
}