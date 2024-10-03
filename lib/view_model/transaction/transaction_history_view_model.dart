import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/model/enum.dart';
import 'package:expense_management/services/category_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../model/transaction_model.dart';
import '../../model/category_model.dart';
import '../../model/wallet_model.dart';
import '../../services/transaction_service.dart';
import '../../services/wallet_service.dart';
import '../../utils/utils.dart';
import '../../utils/wallet_utils.dart';
import '../wallet/wallet_view_model.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

class TransactionHistoryViewModel extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();
  final TransactionHelper _transactionHelper = TransactionHelper();

  List<Transactions> transactions = [];
  Map<String, Wallet> walletMap = {};
  Map<String, Category> categoryMap = {};
  List<Transactions> filteredTransactions = [];
  Map<String, List<Transactions>> groupedTransactions = {};
  DateTimeRange? selectedDateRange;
  List<String> selectedWalletIds = [];
  List<Wallet> selectedWallets = [];
  String searchQuery = "";
  bool isSearching = false;
  int _currentTabIndex = 0;
  bool isLoading = false;
  double totalIncome = 0;
  double totalExpense = 0;

  TransactionHistoryViewModel() {
    loadTransactions();
  }

  String formatAmount(double amount) {
    final formatted = NumberFormat('#,###', 'vi_VN').format(amount);
    return formatted;
  }

  void calculateTotals() {
    for (var transaction in filteredTransactions) {
      if (transaction.type == Type.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == Type.expense) {
        totalExpense += transaction.amount;
      }
    }
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        isLoading = true;
        notifyListeners();
        transactions = await _transactionService.getTransaction(user.uid);
        await loadWallets();
        await loadCategories();
        filteredTransactions = transactions;
        groupTransactions();
        calculateTotals();
        notifyListeners();
      } catch (e) {
        print("Error loading transaction: $e");
      }finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadWallets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        List<Wallet> wallets = await _walletService.getWallets(user.uid);
        walletMap = {for (var wallet in wallets) wallet.walletId: wallet};
        if (selectedWallets.isEmpty) {
          selectedWallets = List.from(wallets); // Chỉ gán khi rỗng
        }
        notifyListeners();
      } catch (e) {
        print("Error loading wallets: $e");
      }
    }
  }

  Future<void> loadCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        List<Category> categories =
            await _categoryService.getAllCategories(user.uid);
        categoryMap = {
          for (var category in categories) category.categoryId: category
        };
      } catch (e) {
        print("Error loading categories: $e");
      }
    }
  }

  void groupTransactions() {
    groupedTransactions = {};
    for (var transaction in filteredTransactions) {
      final date = formatDate_2(transaction.date);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }
    print("Grouped Transactions: ${groupedTransactions.length}");
  }

  void filterByDateRange(DateTimeRange range) {
    selectedDateRange = range;
    _applyFilters();
  }

  void filterByWallets(List<Wallet> wallets) {
    selectedWallets = List.from(wallets);
    _applyFilters();
  }


  void filterByTab(int index) {
    _currentTabIndex = index;
    _applyFilters();
  }

  void _applyFilters() {
    filteredTransactions = transactions;

    if (selectedDateRange != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction.date.isAfter(selectedDateRange!.start) &&
            transaction.date.isBefore(selectedDateRange!.end);
      }).toList();
    }

    // Lọc theo ví đã chọn
    if (selectedWallets.isNotEmpty) {
      filteredTransactions = filteredTransactions
          .where((transaction) => selectedWallets
          .any((wallet) => wallet.walletId == transaction.walletId))
          .toList();
    }

    // Lọc theo tab
    if (_currentTabIndex == 1) {
      // Thu nhập
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction.type == Type.income;
      }).toList();
    } else if (_currentTabIndex == 2) {
      // Chi tiêu
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction.type == Type.expense;
      }).toList();
    }
    print("Filtered Transactions Length: ${filteredTransactions.length}");
    groupTransactions();
    notifyListeners();
  }

  Wallet? getWalletByTransaction(Transactions transaction) {
    return walletMap[transaction.walletId];
  }

  Category? getCategoryByTransaction(Transactions transaction) {
    return categoryMap[transaction.categoryId];
  }

  void searchTransactions(String query) {
    searchQuery = query.toLowerCase();
    isSearching = true;

    // Hàm chuẩn hóa Unicode bằng unorm_dart
    String normalize(String input) {
      return unorm.nfd(input).toLowerCase(); // Chuẩn hóa thành NFD (Mẫu chuẩn hóa D) và chuyển đổi thành chữ thường
    }

    if (searchQuery.isNotEmpty) {
      filteredTransactions = transactions.where((transaction) {
        final category = getCategoryByTransaction(transaction);
        final categoryName = category?.name ?? '';
        final note = transaction.note;

        // Chuẩn hóa cả tên danh mục và truy vấn tìm kiếm
        final normalizedCategoryName = normalize(categoryName);
        final normalizedNote = normalize(note);
        final normalizedQuery = normalize(searchQuery);

        return normalizedCategoryName.contains(normalizedQuery) ||
            normalizedNote.contains(normalizedQuery);
      }).toList();
    } else {
      _applyFilters();
    }
    groupTransactions();
    notifyListeners();
  }

  void clearSearch() {
    searchQuery = "";
    isSearching = false;
    _applyFilters();
  }

  void clearFilters() {
    selectedDateRange = null;
    _currentTabIndex = 0;
    selectedWallets = walletMap.values.toList();
    filteredTransactions = transactions;
    groupTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(
      String transactionId, WalletViewModel walletViewModel) async {
    try {
      // Lấy thông tin của giao dịch trước khi xóa
      final transaction =
          await _transactionService.getTransactionById(transactionId);
      if (transaction == null) {
        print("Transaction not found");
        return;
      }

      // Cập nhật lại số dư ví
      await _transactionHelper.updateWalletBalance(transaction,
          isCreation: false, isDeletion: true);

      // Xóa giao dịch
      await _transactionService.deleteTransaction(transactionId);
      transactions.removeWhere(
          (transaction) => transaction.transactionId == transactionId);

      // Cập nhật lại tổng thu nhập và chi tiêu
      if (transaction.type == Type.income) {
        totalIncome -= transaction.amount;
      } else if (transaction.type == Type.expense) {
        totalExpense -= transaction.amount;
      }

      // Tải lại thông tin ví và cập nhật giao diện
      await walletViewModel.loadWallets();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print("Error deleting transaction: $e");
    }
  }
}
