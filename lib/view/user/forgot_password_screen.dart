import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_model/user/forgot_password_viewmodel.dart';
import '../../widget/custom_ElevatedButton_1.dart';
import '../../widget/custom_header_1.dart';
import '../../widget/custom_snackbar_2.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ForgotPasswordViewModel>(context, listen: false)
      ..emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ForgotPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Column(
                children: [
                  CustomHeader_1(title: tr('forgot_password')),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tr('enter_email_to_reset_password'),
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: viewModel.emailController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email),
                                  labelText: tr('email'),
                                  border: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20))),
                                  suffixText: '@gmail.com',
                                  errorText: viewModel.emailError.isNotEmpty
                                      ? viewModel.emailError
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 30),
                              CustomElavatedButton_1(
                                text: tr('continue'),
                                onPressed: viewModel.enableButton
                                    ? () async {
                                        if (await viewModel.forgotPassword(context)) {
                                          await CustomSnackBar_2.show(context,
                                              tr('password_reset_email_sent'));
                                          Navigator.pushReplacementNamed(
                                              context, '/verify-email-pass');
                                        }
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ),
                ],
              ),
              if (viewModel.isLoading)
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
