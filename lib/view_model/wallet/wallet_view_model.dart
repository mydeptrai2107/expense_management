import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/model/wallet_model.dart';
import 'package:expense_management/services/wallet_service.dart';
import '../../utils/utils.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  TextEditingController searchController = TextEditingController();

  List<Wallet> _wallets = [];
  List<Wallet> _filteredWallets = [];
  double _totalBalance = 0;
  bool isSearching = false;
  String searchQuery = "";
  Wallet? _selectedWallet;
  int loadWalletsCallCount = 0;

  List<Wallet> get wallets => _filteredWallets;
  String get formattedTotalBalance => formatAmount(_totalBalance);
  Wallet? get selectedWallet => _selectedWallet;
  double get totalBalance => _totalBalance;

  WalletViewModel() {
    print("WalletViewModel constructor called");
    initializeWallets();
  }

  Future<void> initializeWallets() async {
    await addDefaultAndFixedWallets();
    await loadWallets();
  }

  void selectWallet(Wallet wallet) {
    _selectedWallet = wallet;
    notifyListeners();
  }

  Future<void> addDefaultAndFixedWallets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _walletService.addDefaultWallets(user.uid);
        await _walletService.addFixedWallet(user.uid);
      } catch (e) {
        print("Error adding default and fixed wallets: $e");
      }
    }
  }

  Future<void> loadWallets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        _wallets = await _walletService.getWallets(user.uid);
        _filteredWallets = _wallets;
        _calculateTotalBalance();
        notifyListeners();
      } catch (e) {
        print("Error loading wallets: $e");
      }
    }
  }

  void filterWallets(String query) {
    if (query.isEmpty) {
      _filteredWallets = _wallets;
    } else {
      _filteredWallets = _wallets.where((wallet) {
        return wallet.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      await _walletService.deleteWallet(walletId);
      await loadWallets();
    } catch (e) {
      print("Error deleting wallet: $e");
    }
  }

  void _calculateTotalBalance() {
    double total = 0;

    for (var wallet in _wallets) {
      double balance = wallet.currentBalance;
      if (!wallet.excludeFromTotal) {
        total += balance;
      }
    }
    _totalBalance = total;
    notifyListeners();
  }

  void clearSearch() {
    searchQuery = '';
    searchController.clear();
    filterWallets('');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
