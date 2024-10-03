import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/model/enum.dart';
import 'package:expense_management/services/budget_service.dart';
import 'package:expense_management/widget/custom_snackbar_1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/budget_model.dart';
import '../../model/category_model.dart';
import '../../model/wallet_model.dart';
import '../../utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateBudgetViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BudgetService _budgetService = BudgetService();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  List<Category> categories = [];
  List<Category> selectedCategories = [];
  List<Wallet> wallets = [];
  List<Wallet> selectedWallets = [];
  Repeat selectedRepeat = Repeat.Monthly;
  DateTime startDate = DateTime.now();
  DateTime? endDate;
  bool enableButton = false;

  Map<String, Category> categoryMap = {};
  Map<String, Wallet> walletMap = {};

  List<Repeat> get repeatOptions => Repeat.values;

  CreateBudgetViewModel() {
    amountController.addListener(() {
      formatAmount_3(amountController);
    });
    loadWallets();
    loadCategories();
    updateDateControllers();
  }

  String getCategoriesText(
      List<Category> selectedCategories, List<Category> allCategories) {
    if (selectedCategories.isEmpty ||
        selectedCategories.length == allCategories.length) {
      return tr('all_expense_categories');
    }
    if (selectedCategories.length == 1) return selectedCategories[0].name;
    if (selectedCategories.length == 2) {
      return '${selectedCategories[0].name}, ${selectedCategories[1].name}';
    }
    return '${selectedCategories[0].name}, ${selectedCategories[1].name} + ${selectedCategories.length - 2} ' + tr('categories');
  }

  String getWalletsText(List<Wallet> selectedWallets, List<Wallet> allWallets) {
    if (selectedWallets.isEmpty ||
        selectedWallets.length == allWallets.length) return tr('all_wallet');
    if (selectedWallets.length == 1) return selectedWallets[0].name;
    if (selectedWallets.length == 2) {
      return '${selectedWallets[0].name}, ${selectedWallets[1].name}';
    }
    return '${selectedWallets[0].name}, ${selectedWallets[1].name} + ${selectedWallets.length - 2} ' + tr('wallet');
  }

  Future<void> loadWallets() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      QuerySnapshot walletSnapshot = await _firestore
          .collection('wallets')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      wallets = walletSnapshot.docs
          .map((doc) => Wallet.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      selectedWallets = List.from(wallets);

      walletMap = {for (var wallet in wallets) wallet.walletId: wallet};

      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      QuerySnapshot categorySnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: currentUser.uid)
          .where('type', isEqualTo: Type.expense.index)
          .get();
      categories = categorySnapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      selectedCategories = List.from(categories);

      categoryMap = {
        for (var category in categories) category.categoryId: category
      };

      notifyListeners();
    }
  }

  updateButtonState() {
    enableButton =
        amountController.text.isNotEmpty
            && nameController.text.isNotEmpty
            && endDate != null;
    notifyListeners();
  }

  void setWallets(List<Wallet> wallets) {
    selectedWallets = wallets;
    notifyListeners();
  }

  void setCategories(List<Category> categories) {
    selectedCategories = categories;
    notifyListeners();
  }

  void setSelectedRepeat(Repeat value) {
    selectedRepeat = value;
    notifyListeners();
  }

  void setStartDate(DateTime value) {
    startDate = value;
    updateDateControllers();
    notifyListeners();
  }

  void setEndDate(DateTime value) {
      endDate = value;
      updateDateControllers();
      updateButtonState();
    notifyListeners();
  }

  void updateDateControllers() {
    startDateController.text = formatDate(startDate);
    endDateController.text = endDate != null ? formatDate(endDate!) : '';
  }

  Future<Budget?> createBudget(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cleanedAmount = amountController.text.replaceAll('.', '');
      final amount = double.parse(cleanedAmount);

      List<String> categoryIdList = selectedCategories.map((category) => category.categoryId).toList();

      List<String> walletIdList = selectedWallets.map((wallet) => wallet.walletId).toList();

      // Kiểm tra tính hợp lệ của ngày kết thúc
      bool isValid = true;
      String message = '';

      if(selectedRepeat == Repeat.Daily){
        if (endDate!.isBefore(startDate)) {
          isValid = false;
          message = tr('end_date_must_be_greater') + '${formatDate(startDate)}';
        }
      }
      else if (selectedRepeat == Repeat.Weekly) {
        if (endDate!.isBefore(startDate.add(const Duration(days: 6)))) {
          isValid = false;
          message = tr('end_date_must_be_greater') + '${formatDate(startDate.add(const Duration(days: 6)))}';
        }
      } else if (selectedRepeat == Repeat.Monthly) {
        if (endDate!.isBefore(startDate.add(const Duration(days: 29)))) {
          isValid = false;
          message = tr('end_date_must_be_greater') + '${formatDate(startDate.add(const Duration(days: 29)))}';
        }
      } else if (selectedRepeat == Repeat.Quarterly) {
        if (endDate!.isBefore(startDate.add(const Duration(days: 89)))) {
          isValid = false;
          message = tr('end_date_must_be_greater') + '${formatDate(startDate.add(const Duration(days: 89)))}';
        }
      } else if (selectedRepeat == Repeat.Yearly) {
        if (endDate!.isBefore(startDate.add(const Duration(days: 364)))) {
          isValid = false;
          message = tr('end_date_must_be_greater') + '${formatDate(startDate.add(const Duration(days: 364)))}';
        }
      }

      if (!isValid) {
        CustomSnackBar_1.show(context, message);
        return null;
      }

      Budget newBudget = Budget(
        budgetId: '',
        userId: user.uid,
        amount: amount,
        name: nameController.text,
        categoryId: categoryIdList,
        walletId: walletIdList,
        startDate: startDate,
        endDate: endDate!,
        repeat: selectedRepeat,
        createdAt: DateTime.now(),
      );

      try {
        await _budgetService.createBudget(newBudget);
        return newBudget;
      } catch (e) {
        print('Error creating budget: $e');
        return null;
      }
    }
    return null;
  }

  @override
  void dispose() {
    amountController.dispose();
    nameController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }
}
