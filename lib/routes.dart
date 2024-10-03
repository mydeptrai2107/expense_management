import 'package:expense_management/view/bill/bill_list_screen.dart';
import 'package:expense_management/view/bill/create_bill_screen.dart';
import 'package:expense_management/view/budget/budget_list_screen.dart';
import 'package:expense_management/view/budget/create_budget_screen.dart';
import 'package:expense_management/view/category/category_list_screen.dart';
import 'package:expense_management/view/home_screen.dart';
import 'package:expense_management/view/intro/language_selection_screen.dart';
import 'package:expense_management/view/intro/onboarding_screen.dart';
import 'package:expense_management/view/category/create_categories_screen.dart';
import 'package:expense_management/view/transaction/component/expense_category_screen.dart';
import 'package:expense_management/view/transaction/component/income_category_screen.dart';
import 'package:expense_management/view/transaction/transaction_history_screen.dart';
import 'package:expense_management/view/user/change_password_screen.dart';
import 'package:expense_management/view/user/edit_profile_screen.dart';
import 'package:expense_management/view/user/forgot_password_screen.dart';
import 'package:expense_management/view/user/login_screen.dart';
import 'package:expense_management/view/user/profile_screen.dart';
import 'package:expense_management/view/user/register_screen.dart';
import 'package:expense_management/view/user/verify_email_pass_screen.dart';
import 'package:expense_management/view/user/verify_email_screen.dart';
import 'package:expense_management/view/transfer/create_transfer_screen.dart';
import 'package:expense_management/view/wallet/create_wallet_screen.dart';
import 'package:expense_management/view/transfer/transfer_history_screen.dart';
import 'package:expense_management/view/wallet/wallets_screen.dart';
import 'package:expense_management/widget/bottom_navigatorbar.dart';
import 'package:flutter/material.dart';


Map<String, WidgetBuilder> routes = {
  '/select-language': (context) => const LanguageSelectionScreen(),
  '/onboarding': (context) => const OnboardingScreen(),
  '/login': (context) =>  const LoginScreen(),
  '/register': (context) =>  RegisterScreen(),
  '/forgot-pass': (context) =>  const ForgotPasswordScreen(),
  '/change-password': (context) =>  const ChangePasswordScreen(),
  '/home': (context) =>  const HomeScreen(),
  '/create-categories': (context) =>  const CreateCategoriesScreen(),
  '/income-category': (context) =>  const IncomeCategoryScreen(),
  '/expense-category': (context) =>  const ExpenseCategoryScreen(),
  '/transaction-history': (context) =>  const TransactionHistoryScreen(),
  '/profile': (context) =>  const ProfileScreen(),
  '/bottom-navigator': (context) =>  const BottomNavigation(),
  '/wallets': (context) =>  const WalletScreen(),
  '/bill-list': (context) =>  const BillListScreen(),
  '/create-bill': (context) =>  const CreateBillScreen(),
  '/create-budget': (context) =>  const CreateBudgetScreen(),
  '/budget-list': (context) =>  const BudgetListScreen(),
  '/category-list': (context) =>  const CategoryListScreen(),
  '/verify-email-pass': (context) =>  const VerifyEmailPassScreen(),
  '/verify-email': (context) =>  VerifyEmailScreen(),
  '/edit-profile': (context) =>  const EditProfileScreen(),
  '/create-wallet': (context) =>  const CreateWalletScreen(),
  '/create-transfer': (context) =>  const CreateTransferScreen(),
  '/transfer-history': (context) =>  const TransferHistoryScreen(),
};

