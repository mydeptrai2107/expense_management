import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_management/model/wallet_model.dart';
import 'package:expense_management/services/wallet_service.dart';
import '../../utils/utils.dart';
import '../../widget/custom_snackbar_1.dart';

class EditWalletViewModel extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  final TextEditingController walletNameController = TextEditingController();
  final TextEditingController currentBalanceController = TextEditingController();

  IconData? selectedIcon;
  Color? selectedColor;
  bool enableButton = false;
  bool showPlusButtonIcon = true;
  bool showPlusButtonColor = true;
  bool excludeFromTotal = false;

  bool get isEmptyWalletName => walletNameController.text.isEmpty;
  bool get isEmptyCurrentBalance => currentBalanceController.text.isEmpty;
  bool get isEmptyIcon => selectedIcon == null;
  bool get isEmptyColor => selectedColor == null;

  EditWalletViewModel() {
    currentBalanceController.addListener(formatCurrentBalance);
  }

  void initialize(Wallet wallet) {
    walletNameController.text = wallet.name;
    currentBalanceController.text = formatAmount(wallet.currentBalance);
    selectedIcon = parseIcon(wallet.icon);
    selectedColor = parseColor(wallet.color);
    print('Initialized selectedIcon: $selectedIcon');
    print('Initialized selectedColor: $selectedColor');
    excludeFromTotal = wallet.excludeFromTotal;
    updateButtonState();
  }

  void formatCurrentBalance() {
    final text = currentBalanceController.text;
    if (text.isEmpty) return;

    final isNegative = text.contains('-');
    final cleanedText = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedText.isEmpty) return;

    final number = int.parse(cleanedText);
    final formatted = NumberFormat('#,###', 'vi_VN').format(number);

    currentBalanceController.value = TextEditingValue(
      text: isNegative ? '- $formatted' : formatted,
      selection: TextSelection.collapsed(offset: isNegative ? formatted.length + 2 : formatted.length),
    );
  }

  void updateButtonState() {
    enableButton = !isEmptyWalletName && !isEmptyCurrentBalance && !isEmptyIcon && !isEmptyColor;
    notifyListeners();
  }

  void setSelectedIcon(IconData icon) {
    selectedIcon = icon;
    updateButtonState();
    notifyListeners();
  }

  void setSelectedColor(Color color) {
    selectedColor = color;
    updateButtonState();
    notifyListeners();
  }

  void toggleShowPlusButtonIcon() {
    showPlusButtonIcon = !showPlusButtonIcon;
    notifyListeners();
  }

  void toggleShowPlusButtonColor() {
    showPlusButtonColor = !showPlusButtonColor;
    notifyListeners();
  }

  void setExcludeFromTotal(bool value) {
    excludeFromTotal = value;
    notifyListeners();
  }

  Future<Wallet?> updateWallet(String walletId, DateTime createdAt, Wallet wallet) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Loại bỏ dấu '.' và khoảng trắng không cần thiết
      final cleanedBalance = currentBalanceController.text.replaceAll('.', '').replaceAll(' ', '');

      print('Cleaned Balance: $cleanedBalance');
      final currentBalance = double.parse(cleanedBalance);

      // Kiểm tra trạng thái isDefault của ví hiện tại
      bool isDefault = await _walletService.isFixedWallet(walletId);

      Wallet updatedWallet = Wallet(
        walletId: walletId,
        userId: user.uid,
        initialBalance: wallet.initialBalance,
        currentBalance: currentBalance,
        name: walletNameController.text,
        icon: selectedIcon.toString(),
        color: selectedColor.toString(),
        excludeFromTotal: excludeFromTotal,
        createdAt: createdAt,
        isDefault: isDefault,
      );

      try {
        await _walletService.updateWallet(updatedWallet);
        return updatedWallet;
      } catch (e, stackTrace) {
        print('Error updating wallet: $e');
        print('Stack trace: $stackTrace');
        return null;
      }
    }
    return null;
  }


  @override
  void dispose() {
    walletNameController.dispose();
    currentBalanceController.dispose();
    super.dispose();
  }
}
