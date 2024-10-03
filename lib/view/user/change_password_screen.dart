import 'package:expense_management/widget/custom_ElevatedButton_1.dart';
import 'package:expense_management/widget/custom_header_1.dart';
import 'package:expense_management/widget/custom_snackbar_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/user/change_password_view_model.dart';
import 'package:easy_localization/easy_localization.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChangePasswordViewModel>(context, listen: false).resetFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ChangePasswordViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Column(
                children: [
                  CustomHeader_1(title: tr('change_password_title')),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Center(
                                child: Image.asset(
                              'assets/images/logo.png',
                              height: 150,
                              width: 150,
                            )),
                            const SizedBox(
                              height: 30,
                            ),
                            TextField(
                              controller: viewModel.currentPasswordController,
                              obscureText: !viewModel.isCurrentPasswordVisible,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                labelText: tr('current_password_label'),
                                suffixIcon: IconButton(
                                  icon: Icon(viewModel.isCurrentPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed:
                                      viewModel.toggleCurrentPasswordVisibility,
                                ),
                                errorText: viewModel.currentPasswordError.isNotEmpty
                                    ? viewModel.currentPasswordError
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: viewModel.newPasswordController,
                              obscureText: !viewModel.isNewPasswordVisible,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                labelText: tr('new_password_label'),
                                suffixIcon: IconButton(
                                  icon: Icon(viewModel.isNewPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: viewModel.toggleNewPasswordVisibility,
                                ),
                                errorText: viewModel.newPasswordError.isNotEmpty
                                    ? viewModel.newPasswordError
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: viewModel.confirmPasswordController,
                              obscureText: !viewModel.isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                labelText: tr('confirm_password_label'),
                                suffixIcon: IconButton(
                                  icon: Icon(viewModel.isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed:
                                      viewModel.toggleConfirmPasswordVisibility,
                                ),
                                errorText: viewModel.confirmPasswordError.isNotEmpty
                                    ? viewModel.confirmPasswordError
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 30),
                            CustomElavatedButton_1(
                              onPressed: viewModel.enableButton
                                  ? () async {
                                      if (await viewModel.changePassword(context)) {
                                        await CustomSnackBar_2.show(
                                            context, tr('save_success'));
                                        Navigator.pop(context);
                                      }
                                    }
                                  : null,
                              text: tr('save_button'),
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
