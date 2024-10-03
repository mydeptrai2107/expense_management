import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/model/category_model.dart';
import 'package:expense_management/model/enum.dart';
import 'package:expense_management/model/wallet_model.dart';
import 'package:expense_management/model/transaction_model.dart';
import 'package:expense_management/services/transaction_service.dart';
import 'package:expense_management/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/category_service.dart';
import '../../services/wallet_service.dart';
import '../../utils/wallet_utils.dart';
import '../../widget/custom_snackbar_1.dart';

class EditTransactionViewModel extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();
  final TransactionHelper _transactionHelper = TransactionHelper();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController hourController = TextEditingController();

  String transactionTypeTitle = tr('income');
  bool isExpenseTabSelected = true;
  double amount = 0.0;
  Category? selectedCategory;
  bool showPlusButtonCategory = true;
  List<Category> frequentCategories = [];
  bool isFrequentCategoriesLoaded = false;
  Wallet? selectedWallet;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedHour = TimeOfDay.now();
  List<String> existingImageUrls = [];
  List<File> newImages = [];
  bool enableButton = false;

  EditTransactionViewModel() {
    amountController.addListener(() {
      formatAmount();
      updateButtonState();
    });
    noteController.addListener(updateButtonState);
    loadFrequentCategories();
  }

  Future<void> initialize(Transactions transaction) async {
    transactionTypeTitle =
        transaction.type == Type.expense ? tr('expense') : tr('income');
    isExpenseTabSelected = transaction.type == Type.expense;
    amountController.text = transaction.amount.toStringAsFixed(0);
    selectedCategory =
        await _categoryService.getCategoryById(transaction.categoryId);
    selectedWallet = await _walletService.getWalletById(transaction.walletId);
    selectedDate = transaction.date;
    selectedHour =
        TimeOfDay(hour: transaction.hour.hour, minute: transaction.hour.minute);
    noteController.text = transaction.note;
    existingImageUrls = transaction.images;
    updateDateController();
    updateHourController();
    updateButtonState();
    await loadFrequentCategories();
  }

  void updateButtonState() {
    enableButton = amountController.text.isNotEmpty &&
        selectedCategory != null &&
        selectedWallet != null;
    notifyListeners();
  }

  void formatAmount() {
    final text = amountController.text;
    if (text.isEmpty) return;

    final cleanedText = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedText.isNotEmpty) {
      final number = int.parse(cleanedText);
      final formatted = NumberFormat('#,###', 'vi_VN').format(number);

      amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
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
    dateController.text = formatDate(selectedDate);
    notifyListeners();
  }

  void setSelectedHour(TimeOfDay value) {
    selectedHour = value;
    hourController.text = formatHour(selectedHour);
    notifyListeners();
  }

  void updateDateController() {
    dateController.text = formatDate(selectedDate);
  }

  void updateHourController() {
    hourController.text = formatHour(selectedHour);
  }

  void setNote(String value) {
    noteController.text = value;
    notifyListeners();
  }

  Future<void> captureImage(BuildContext context) async {
    int currentImageCount = existingImageUrls.length + newImages.length;

    if (currentImageCount >= 3) {
      CustomSnackBar_1.show(context, tr('Only_three_photo'));
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      newImages.add(File(image.path));
      notifyListeners();
    }
  }

  Future<void> pickImageFromGallery(BuildContext context) async {
    int currentImageCount = existingImageUrls.length + newImages.length;

    if (currentImageCount >= 3) {
      CustomSnackBar_1.show(context, tr('Only_three_photo'));
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      newImages.add(File(image.path));
      notifyListeners();
    }
  }

  void removeImage(String imageUrl) {
    existingImageUrls.remove(imageUrl);
    notifyListeners();
  }

  void removeNewImage(File image) {
    newImages.remove(image);
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

  Future<bool> checkBalance(double amount, Type type,
      {Transactions? oldTransaction}) async {
    if (selectedWallet == null) {
      return false;
    }
    return await _transactionHelper.checkBalance(
        selectedWallet!.walletId, amount, type,
        oldTransaction: oldTransaction);
  }

  Future<Transactions?> updateTransaction(
      String transactionId, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cleanedAmount = amountController.text.replaceAll('.', '');
      final amount = double.parse(cleanedAmount);

      final transactionType = isExpenseTabSelected ? Type.expense : Type.income;

      // Lấy giao dịch cũ
      final oldTransaction =
          await _transactionService.getTransactionById(transactionId);
      if (oldTransaction == null) {
        CustomSnackBar_1.show(context, tr('Old_transaction_not_exist'));
        return null;
      }

      // Kiểm tra số dư trước khi cập nhật giao dịch
      final sufficientBalance = await checkBalance(amount, transactionType,
          oldTransaction: oldTransaction);
      if (!sufficientBalance) {
        CustomSnackBar_1.show(context, tr('wallet_balance_is_not_enough'));
        return null;
      }

      // Tải lên hình ảnh mới
      List<String> imageUrls = List.from(existingImageUrls);
      for (var imageFile in newImages) {
        String imageUrl = await _transactionService.uploadImage(imageFile);
        imageUrls.add(imageUrl);
      }

      final updatedTransaction = Transactions(
        transactionId: transactionId,
        userId: user.uid,
        amount: amount,
        type: transactionType,
        walletId: selectedWallet!.walletId,
        categoryId: selectedCategory!.categoryId,
        date: selectedDate,
        hour: selectedHour,
        note: noteController.text,
        images: imageUrls,
      );

      try {
        await _transactionService.updateTransaction(updatedTransaction);
        // Cập nhật số dư ví sau khi cập nhật giao dịch
        await _transactionHelper.updateWalletsForTransactionUpdate(
            updatedTransaction, oldTransaction);
        return updatedTransaction;
      } catch (e) {
        print('Error updating transactions: $e');
        return null;
      }
    }
    return null;
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
