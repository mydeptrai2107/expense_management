import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../view_model/user/login_view_model.dart';
import '../../widget/custom_ElevatedButton_1.dart';
import '../../widget/custom_header_2.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoginViewModel>(context, listen: false).resetFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginViewModel>(builder: (context, viewModel, child) {
        return Stack(
          children: [
            Column(
              children: [
                CustomHeader_2(title: tr('login')),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 150,
                              width: 150,
                            ),
                          ),
                          const SizedBox(height: 50),
                          TextField(
                            controller: viewModel.emailController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(FontAwesomeIcons.solidEnvelope),
                              labelText: tr('email'),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              suffixText: '@gmail.com',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: viewModel.passwordController,
                            obscureText: !viewModel.isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: tr('password'),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  viewModel.togglePasswordVisibility();
                                },
                                icon: Icon(
                                  viewModel.isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          CustomElavatedButton_1(
                            text: tr('login_button'),
                            onPressed: viewModel.enableButton
                                ? () async {
                              if (await viewModel.login(context)) {
                                Navigator.pushReplacementNamed(
                                    context, '/bottom-navigator');
                              }
                            }
                                : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 300,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                bool success =
                                await viewModel.signInWithGoogle(context);
                                if (success) {
                                  Navigator.pushReplacementNamed(
                                      context, '/bottom-navigator');
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    tr('log_in_with_google'),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/forgot-pass');
                              },
                              child: Text(
                                tr('forgot_password'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: tr('no_account'),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextSpan(
                                      text: tr('register'),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        decoration: TextDecoration.underline,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushReplacementNamed(
                                              context, '/register');
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
      }),
    );
  }
}