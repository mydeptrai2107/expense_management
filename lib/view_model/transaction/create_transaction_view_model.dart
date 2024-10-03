import 'dart:io';
import 'package:expense_management/widget/custom_snackbar_1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_management/model/transaction_model.dart';
import 'package:expense_management/model/enum.dart';
import '../../model/category_model.dart';
import '../../model/wallet_model.dart';
import '../../services/category_service.dart';
import '../../services/transaction_service.dart';
import '../../utils/utils.dart';
import '../../utils/wallet_utils.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateTransactionViewModel extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final TransactionHelper _transactionHelper = TransactionHelper();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController hourController = TextEditingController();

  String transactionTypeTitle = tr('expense');
  bool isExpenseTabSelected = true;
  double amount = 0.0;
  Category? selectedCategory;
  bool showPlusButtonCategory = true;
  List<Category> frequentCategories = [];
  bool isFrequentCategoriesLoaded = false;
  Wallet? selectedWallet;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedHour = TimeOfDay.now();
  String note = '';
  List<File> images = [];
  bool enableButton = false;

  CreateTransactionViewModel() {
    amountController.addListener(() {
      formatAmount_3(amountController);
      updateButtonState();
    });
    noteController.addListener(updateButtonState);
    loadFrequentCategories();
    updateDateController();
    updateHourController();
  }

  void updateButtonState() {
    enableButton = amountController.text.isNotEmpty &&
        selectedCategory != null &&
        selectedWallet != null;
    notifyListeners();
  }

  void setAmount(double value) {
    amount = value;
    updateButtonState();
  }

  void setSelectedCategory(Category? category) {
    selectedCategory = category;
    updateButtonState();
  }

  void toggleShowPlusButtonCategory() {
    showPlusButtonCategory = !showPlusButtonCategory;
    notifyListeners();
  }

  void setSelectedWallet(Wallet? wallet) {
    selectedWallet = wallet;
    updateButtonState();
  }

  void setSelectedDate(DateTime value) {
    selectedDate = value;
    updateDateController();
    notifyListeners();
  }

  void setSelectedHour(TimeOfDay value) {
    selectedHour = value;
    updateHourController();
    notifyListeners();
  }

  void setNote(String value) {
    note = value;
    notifyListeners();
  }

  void updateDateController() {
    dateController.text = formatDate(selectedDate);
  }

  void updateHourController() {
    hourController.text = formatHour(selectedHour);
  }

  Future<void> captureImage(BuildContext context) async {
    if (images.length >= 3) {
      CustomSnackBar_1.show(context, tr('Only_three_photo'));
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      images.add(File(image.path));
      notifyListeners();
    }
  }

  Future<void> pickImageFromGallery(BuildContext context) async {
    if (images.length >= 3) {
      CustomSnackBar_1.show(context, tr('Only_three_photo'));
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      images.add(File(image.path));
      notifyListeners();
    }
  }

  void removeImage(String imagePath) {
    images.removeWhere((element) => element.path == imagePath);
    notifyListeners();
  }

  void updateTransactionTypeTitle(String newTitle) {
    transactionTypeTitle = newTitle;
    isExpenseTabSelected = newTitle == tr('expense');
    selectedCategory = null;
    isFrequentCategoriesLoaded = false;
    loadFrequentCategories();
    notifyListeners();
  }

  Future<void> loadFrequentCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        List<Category> categories;
        if (isExpenseTabSelected) {
          categories =
              await _categoryService.getExpenseCategoryFrequent(user.uid);
        } else {
          categories =
              await _categoryService.getIncomeCategoryFrequent(user.uid);
        }
        frequentCategories = categories;
        isFrequentCategoriesLoaded = true;
        notifyListeners();
      } catch (e) {
        print("Error load FrequentCategories: $e");
      }
    }
  }

  Future<bool> checkBalance(double amount, Type type) async {
    if (selectedWallet == null) {
      return false;
    }
    return await _transactionHelper.checkBalance(
        selectedWallet!.walletId, amount, type);
  }

  Future<Transactions?> createTransaction(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cleanedAmount = amountController.text.replaceAll('.', '');
      final amount = double.parse(cleanedAmount);

      final transactionType = isExpenseTabSelected ? Type.expense : Type.income;
      final sufficientBalance = await checkBalance(amount, transactionType);
      if (!sufficientBalance) {
        CustomSnackBar_1.show(context, tr('wallet_balance_is_not_enough'));
        return null;
      }

      List<String> imageUrls = [];
      for (var imageFile in images) {
        String imageUrl = await _transactionService.uploadImage(imageFile);
        imageUrls.add(imageUrl);
      }

      final newTransaction = Transactions(
        transactionId: '',
        userId: user.uid,
        amount: amount,
        type: transactionType,
        walletId: selectedWallet!.walletId,
        categoryId: selectedCategory!.categoryId,
        date: selectedDate,
        hour: TimeOfDay(hour: selectedHour.hour, minute: selectedHour.minute),
        note: note,
        images: imageUrls,
      );
      try {
        await _transactionService.createTransaction(newTransaction);
        await _transactionHelper.updateWalletBalance(newTransaction,
            isCreation: true, isDeletion: false);
        return newTransaction;
      } catch (e) {
        print('Error creating transaction: $e');
        return null;
      }
    }
    return null;
  }

  void resetFields() {
    amountController.clear();
    noteController.clear();
    selectedDate = DateTime.now();
    selectedHour = TimeOfDay.now();
    selectedCategory = null;
    showPlusButtonCategory = true;
    enableButton = false;
    images = [];
    notifyListeners();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    dateController.dispose();
    hourController.dispose();
    super.dispose();
  }
}
