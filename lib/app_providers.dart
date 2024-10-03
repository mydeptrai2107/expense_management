import 'package:expense_management/view_model/budget/create_budget_view_model.dart';
import 'package:expense_management/view_model/category/category_list_view_model.dart';
import 'package:expense_management/view_model/category/create_category_view_model.dart';
import 'package:expense_management/view_model/category/edit_category_view_model.dart';
import 'package:expense_management/view_model/transaction/create_transaction_view_model.dart';
import 'package:expense_management/view_model/transaction/edit_transaction_view_model.dart';
import 'package:expense_management/view_model/transaction/transaction_history_view_model.dart';
import 'package:expense_management/view_model/transfer/edit_transfer_view_model.dart';
import 'package:expense_management/view_model/transfer/transfer_history_view_model.dart';
import 'package:expense_management/view_model/user/change_password_view_model.dart';
import 'package:expense_management/view_model/user/edit_profile_view_model.dart';
import 'package:expense_management/view_model/user/forgot_password_viewmodel.dart';
import 'package:expense_management/view_model/user/login_view_model.dart';
import 'package:expense_management/view_model/user/register_view_model.dart';
import 'package:expense_management/view_model/wallet/create_wallet_view_model.dart';
import 'package:expense_management/view_model/wallet/edit_wallet_view_model.dart';
import 'package:expense_management/view_model/wallet/wallet_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => ChangePasswordViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => CreateCategoryViewModel()),
        ChangeNotifierProvider(create: (_) => EditCategoryViewModel()),
        ChangeNotifierProvider(create: (_) => CreateWalletViewModel()),
        ChangeNotifierProvider(create: (_) => EditWalletViewModel()),
        ChangeNotifierProvider(create: (_) => TransferHistoryViewModel()),
        ChangeNotifierProvider(create: (_) => EditTransferViewModel()),
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryListViewModel()),
        ChangeNotifierProvider(create: (_) => CreateTransactionViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionHistoryViewModel()),
        ChangeNotifierProvider(create: (_) => EditTransactionViewModel()),
        ChangeNotifierProvider(create: (_) => CreateBudgetViewModel()),
      ],
      child: child,
    );
  }
}
