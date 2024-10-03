import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/widget/custom_snackbar_1.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_management/model/transfer_model.dart';
import 'package:expense_management/model/wallet_model.dart';
import 'package:expense_management/services/transfer_service.dart';
import 'package:expense_management/services/wallet_service.dart';
import '../../utils/utils.dart';
import 'package:collection/collection.dart';
import '../../utils/wallet_utils.dart';


class EditTransferViewModel extends ChangeNotifier {
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

  EditTransferViewModel() {
    amountController.addListener(formatAmount);
  }

  void initialize(Transfer transfer) {
    loadWallets(transfer);
    amountController.text = transfer.amount.toStringAsFixed(0);
    formatAmount();
    selectedDate = transfer.date;
    selectedHour =
        TimeOfDay(hour: transfer.hour.hour, minute: transfer.hour.minute);
    noteController.text = transfer.note;
    updateDateController();
    updateHourController();
    updateButtonState();
  }

  Future<void> loadWallets(Transfer transfer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        wallets = await _walletService.getWallets(user.uid);
        selectedFromWallet = wallets.firstWhereOrNull(
            (wallet) => wallet.walletId == transfer.fromWallet);
        selectedToWallet = wallets
            .firstWhereOrNull((wallet) => wallet.walletId == transfer.toWallet);
        notifyListeners();
      } catch (e) {
        print("Error loading wallet: $e");
      }
    }
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

  void updateButtonState() {
    enableButton = selectedFromWallet != null &&
        selectedToWallet != null &&
        amountController.text.isNotEmpty;
    notifyListeners();
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
    updateButtonState();
    notifyListeners();
  }

  void setSelectedHour(TimeOfDay value) {
    selectedHour = value;
    updateHourController();
    updateButtonState();
    notifyListeners();
  }

  void updateDateController() {
    dateController.text = formatDate(selectedDate);
  }

  void updateHourController() {
    hourController.text = formatHour(selectedHour);
  }

  Future<Transfer?> updateTransfer(
      BuildContext context, String transferId) async {
    if (selectedFromWallet == selectedToWallet) {
      CustomSnackBar_1.show(context, tr('transfer_error_insufficient_balance'));
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final cleanedAmount = amountController.text.replaceAll('.', '');
        final amount = double.parse(cleanedAmount);

        final updateTransfer = Transfer(
          transferId: transferId,
          userId: user.uid,
          fromWallet: selectedFromWallet!.walletId,
          toWallet: selectedToWallet!.walletId,
          amount: amount,
          date: selectedDate,
          hour: TimeOfDay(hour: selectedHour.hour, minute: selectedHour.minute),
          note: noteController.text,
        );

        // Lấy giao dịch cũ
        final oldTransfer = await _transferService.getTransferById(transferId);
        if (oldTransfer == null) {
          print('Transfer not found');
          return null;
        }

        final transferHelper = TransferHelper();

        // Kiểm tra số dư ví nguồn cho giao dịch mới
        final isBalanceSufficient = await transferHelper.checkBalance(
            updateTransfer.fromWallet,
            updateTransfer.amount);
        if (!isBalanceSufficient) {
          CustomSnackBar_1.show(context, tr('transfer_error_not_enough_balance'));
          return null;
        }

        // Cập nhật số dư của các ví dựa trên giao dịch cũ và mới
        await transferHelper.updateWalletsForTransfer(updateTransfer,
            oldTransfer: oldTransfer);

        // Cập nhật giao dịch chuyển khoản
        await _transferService.updateTransfer(updateTransfer);

        return updateTransfer;
      } catch (e) {
        print('Error updating transfer: $e');
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
