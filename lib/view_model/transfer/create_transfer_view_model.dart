import 'package:expense_management/widget/custom_snackbar_1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/model/transfer_model.dart';
import '../../model/wallet_model.dart';
import '../../services/transfer_service.dart';
import '../../services/wallet_service.dart';
import '../../utils/utils.dart';
import '../../utils/wallet_utils.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateTransferViewModel extends ChangeNotifier {
  final TransferService _transferService = TransferService();
  final WalletService _walletService = WalletService();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController hourController = TextEditingController();

  Wallet? selectedFromWallet;
  Wallet? selectedToWallet;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedHour = TimeOfDay.now();
  List<Wallet> wallets = [];
  bool enableButton = false;

  CreateTransferViewModel() {
    loadWallets();
    amountController.addListener(() {
      formatAmount_3(amountController);
      updateButtonState();
    });
    updateDateController();
    updateHourController();
  }

  Future<void> loadWallets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        wallets = await _walletService.getWallets(user.uid);
        notifyListeners();
      } catch (e) {
        print("Error loading wallets: $e");
      }
    }
  }

  void setSelectedFromWallet(Wallet? wallet) {
    selectedFromWallet = wallet;
    updateButtonState();
  }

  void setSelectedToWallet(Wallet? wallet) {
    selectedToWallet = wallet;
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

  void updateDateController() {
    dateController.text = formatDate(selectedDate);
  }

  void updateHourController() {
    hourController.text = formatHour(selectedHour);
  }

  void updateButtonState() {
    enableButton = selectedFromWallet != null &&
        selectedToWallet != null &&
        amountController.text.isNotEmpty;
    notifyListeners();
  }

  Future<Transfer?> createTransfer(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (selectedFromWallet == selectedToWallet) {
        CustomSnackBar_1.show(context, tr('transfer_error_insufficient_balance'));
        return null;
      }

      final cleanedAmount = amountController.text.replaceAll('.', '');
      final amount = double.parse(cleanedAmount);

      Transfer newTransfer = Transfer(
        transferId: '',
        userId: user.uid,
        fromWallet: selectedFromWallet!.walletId,
        toWallet: selectedToWallet!.walletId,
        amount: amount,
        date: selectedDate,
        hour: TimeOfDay(hour: selectedHour.hour, minute: selectedHour.minute),
        note: noteController.text,
      );

      try {
        final transferHelper = TransferHelper();
        final isBalanceSufficient = await transferHelper.checkBalance(
            newTransfer.fromWallet, newTransfer.amount);

        if (!isBalanceSufficient) {
          CustomSnackBar_1.show(context, tr('transfer_error_not_enough_balance'));
          return null;
        }

        await _transferService.createTransfer(newTransfer);
        // Cập nhật số dư của ví nguồn và ví đích
        await transferHelper.updateWalletsForTransfer(newTransfer);
        return newTransfer;
      } catch (e) {
        print('Error creating transfer: $e');
        return null;
      }
    }
    return null;
  }

  void resetFields() {
    selectedFromWallet = null;
    selectedToWallet = null;
    amountController.clear();
    noteController.clear();
    selectedDate = DateTime.now();
    selectedHour = TimeOfDay.now();
    enableButton = false;
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
