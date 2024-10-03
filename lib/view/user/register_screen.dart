import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../view_model/user/register_view_model.dart';
import '../../widget/custom_ElevatedButton_1.dart';
import '../../widget/custom_header_2.dart';
import '../../widget/custom_snackbar_2.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegisterViewModel>(context, listen: false).resetFields();
    });
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
                  CustomHeader_2(title: tr('register')),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Center(
                                child: Image.asset(
                              'assets/images/logo.png',
                              height: 150,
                              width: 150,
                            )),
                            SizedBox(
                              height: 50,
                            ),
                            TextField(
                              controller: viewModel.emailController,
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(FontAwesomeIcons.solidEnvelope),
                                labelText: tr('email'),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                errorText: viewModel.emailError.isNotEmpty
                                    ? viewModel.emailError
                                    : null,
                                suffixText: '@gmail.com',
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: viewModel.passwordController,
                              obscureText: !viewModel.isPasswordVisible,
                              decoration: InputDecoration(
                                prefixIcon: Icon(FontAwesomeIcons.lock),
                                labelText: tr('password'),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                suffixIcon: IconButton(
                                  icon: Icon(viewModel.isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: viewModel.togglePasswordVisibility,
                                ),
                                errorText: viewModel.passwordError.isNotEmpty
                                    ? viewModel.passwordError
                                    : null,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: viewModel.confirmPasswordController,
                              obscureText: !viewModel.isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                prefixIcon: Icon(FontAwesomeIcons.lock),
                                labelText: tr('confirm_password'),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                suffixIcon: IconButton(
                                  icon: Icon(viewModel.isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed:
                                      viewModel.toggleConfirmPasswordVisibility,
                                ),
                                errorText:
                                    viewModel.confirmPasswordError.isNotEmpty
                                        ? viewModel.confirmPasswordError
                                        : null,
                              ),
                            ),
                            SizedBox(height: 20),
                            CustomElavatedButton_1(
                              onPressed: viewModel.enableButton
                                  ? () async {
                                      bool isRegistered =
                                          await viewModel.register(context);
                                      if (isRegistered) {
                                        await CustomSnackBar_2.show(context,
                                            tr('verification_email_sent'));
                                        Navigator.pushReplacementNamed(
                                            context, '/verify-email');
                                      }
                                    }
                                  : null,
                              text: tr('register'),
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: tr('have_account') + " ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          )),
                                      TextSpan(
                                        text: tr('login'),
                                        style: const TextStyle(
                                            color: Colors.green,
                                            decoration:
                                                TextDecoration.underline,
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
