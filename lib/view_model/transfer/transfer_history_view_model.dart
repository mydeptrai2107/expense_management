import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/model/transfer_model.dart';
import 'package:expense_management/model/wallet_model.dart';
import 'package:expense_management/services/transfer_service.dart';
import 'package:expense_management/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/wallet_utils.dart';

class TransferHistoryViewModel extends ChangeNotifier {
  final TransferService _transferService = TransferService();
  final WalletService _walletService = WalletService();

  List<Transfer> _transfers = [];
  Map<String, List<Transfer>> _groupedTransfers = {};
  Map<String, Wallet> _walletMap = {};
  DateTimeRange? _selectedDateRange;
  List<Wallet> _selectedWallets = [];
  bool isLoading = false;

  List<Transfer> get transfers => _transfers;
  Map<String, List<Transfer>> get groupedTransfers => _groupedTransfers;
  Map<String, Wallet> get walletMap => _walletMap;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  List<Wallet> get selectedWallets => _selectedWallets;

  TransferHistoryViewModel() {
    loadTransfers();
  }

  Future<void> loadTransfers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        isLoading = true;
        notifyListeners();
        _transfers = await _transferService.getTransfers(user.uid);
        await _loadWallets();
        _applyFilters();
        notifyListeners();
      } catch (e) {
        print("Error loading transfers: $e");
      }finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadWallets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        List<Wallet> wallets = await _walletService.getWallets(user.uid);
        _walletMap = {for (var wallet in wallets) wallet.walletId: wallet};
        if (_selectedWallets.isEmpty) {
          _selectedWallets = List.from(wallets); // Chỉ gán khi rỗng
        }
        notifyListeners();
      } catch (e) {
        print("Error loading wallets: $e");
      }
    }
  }

  void _applyFilters() {
    final filteredTransfers = _filteredTransfers();
    _groupTransfersByDate(filteredTransfers);
  }

  void _groupTransfersByDate(List<Transfer> transfers) {
    _groupedTransfers = {};
    for (var transfer in transfers) {
      final DateTime transferDate = transfer.date;
      final String formattedDate =
          DateFormat('dd/MM/yyyy').format(transferDate);

      if (_groupedTransfers.containsKey(formattedDate)) {
        _groupedTransfers[formattedDate]!.add(transfer);
      } else {
        _groupedTransfers[formattedDate] = [transfer];
      }
    }

    _groupedTransfers.forEach((key, value) {
      value.sort((a, b) {
        final DateTime aDateTime =
            DateTime(0, 1, 1, a.hour.hour, a.hour.minute);
        final DateTime bDateTime =
            DateTime(0, 1, 1, b.hour.hour, b.hour.minute);
        return bDateTime.compareTo(aDateTime);
      });
    });
  }

  List<Transfer> _filteredTransfers() {
    return _transfers.where((transfer) {
      if (_selectedDateRange != null) {
        if (transfer.date.isBefore(_selectedDateRange!.start) ||
            transfer.date.isAfter(_selectedDateRange!.end)) {
          return false;
        }
      }
      if (_selectedWallets.isNotEmpty) {
        bool isInSelectedWallets = _selectedWallets.any((wallet) =>
        transfer.fromWallet == wallet.walletId ||
            transfer.toWallet == wallet.walletId);
        if (!isInSelectedWallets) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void filterByDateRange(DateTimeRange dateRange) {
    _selectedDateRange = dateRange;
    _applyFilters();
    notifyListeners();
  }

  void filterByWallets(List<Wallet> wallets) {
    _selectedWallets = List.from(wallets);
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedDateRange = null;
    _selectedWallets = walletMap.values.toList();
    _applyFilters();
    notifyListeners();
  }

  String formatHour(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Wallet? getFromWalletByTransfer(Transfer transfer) {
    return _walletMap[transfer.fromWallet];
  }

  Wallet? getToWalletByTransfer(Transfer transfer) {
    return _walletMap[transfer.toWallet];
  }

  Future<void> deleteTransfer(BuildContext context, String transferId) async {
    try {
      final oldTransfer = await _transferService.getTransferById(transferId);
      if (oldTransfer == null) {
        print("Transfer not found");
        return;
      }

      _transfers.removeWhere((transfer) => transfer.transferId == transferId);

      // Hoàn lại số dư của ví nguồn và ví đích
      final transferHelper = TransferHelper();
      await transferHelper.updateWalletBalance(
          oldTransfer.fromWallet, oldTransfer.amount, true);
      await transferHelper.updateWalletBalance(
          oldTransfer.toWallet, oldTransfer.amount, false);

      await _transferService.deleteTransfer(transferId);

      _applyFilters();
      notifyListeners();
    } catch (e) {
      print("Error deleting transfer: $e");
    }
  }
}
