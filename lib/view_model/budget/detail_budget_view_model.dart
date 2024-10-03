import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/model/transaction_model.dart';
import 'package:expense_management/services/transaction_service.dart';
import 'package:expense_management/services/category_service.dart';
import 'package:expense_management/services/wallet_service.dart';
import '../../model/budget_model.dart';
import '../../model/category_model.dart';
import '../../model/enum.dart';
import '../../model/wallet_model.dart';
import '../../utils/previous_period.dart';
import '../../utils/utils.dart';

class DetailBudgetViewModel with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();

  final Budget budget;
  bool _isExpired = false;
  bool get isExpired => _isExpired;
  bool showTransactions = false;
  // danh sách để lưu trữ các chu kỳ trước đó
  List<PreviousPeriod> previousPeriods = [];
  bool showPreviousPeriods = false;

  List<Transactions> transactions = [];
  Map<String, Wallet> walletMap = {};
  Map<String, Category> categoryMap = {};
  List<Transactions> filteredTransactions = [];
  Map<String, List<Transactions>> groupedTransactions = {};
  bool isLoading = false;

  int remainingDays = 0;

  double _totalExpenditure = 0.0;
  double get totalExpenditure => _totalExpenditure;

  double _actualSpending = 0.0;
  double get actualSpending => _actualSpending;

  double _recommendedSpending = 0.0;
  double get recommendedSpending => _recommendedSpending;

  double _projectedSpending = 0.0;
  double get projectedSpending => _projectedSpending;

  late DateTime _currentPeriodStart;
  late DateTime _currentPeriodEnd;
  DateTime get currentPeriodStart => _currentPeriodStart;
  DateTime get currentPeriodEnd => _currentPeriodEnd;

  DetailBudgetViewModel(this.budget) {
    _currentPeriodStart = budget.startDate;
    _currentPeriodEnd = _calculateEndOfCurrentPeriod(_currentPeriodStart, budget.repeat);
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        loadTransactions(),
        loadWallets(),
        loadCategories(),
      ]);
      if (DateTime.now().isAfter(budget.startDate)) {
        filterTransactionsByBudget();
        filterTransactionsBySelectedWallets();
        groupTransactions();
        checkAndUpdatePeriod();
        calculateExpenditures();
      }
    } catch (e) {
      print("Error loading data: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        transactions = await _transactionService.getTransaction(user.uid);
      } catch (e) {
        print("Error loading transactions: $e");
      }
    }
  }

  Future<void> loadWallets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        List<Wallet> wallets = await _walletService.getWallets(user.uid);
        walletMap = {for (var wallet in wallets) wallet.walletId: wallet};
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
        List<String> selectedCategoryIds = budget.categoryId;
        categoryMap = {
          for (var category in categories)
            if (selectedCategoryIds.contains(category.categoryId))
              category.categoryId: category
        };
      } catch (e) {
        print("Error loading categories: $e");
      }
    }
  }

  void toggleShowTransactions() {
    showTransactions = !showTransactions;
    notifyListeners();
  }

  void toggleShowPreviousPeriods() {
    showPreviousPeriods = !showPreviousPeriods;
    notifyListeners();
  }

//Lọc giao dịch theo ngân sách hiện tại
  void filterTransactionsByBudget() {
    try {
      filteredTransactions = transactions.where((transaction) {
        return budget.categoryId.contains(transaction.categoryId) &&
            (transaction.date.isAfter(_currentPeriodStart) ||
                isSameDate(transaction.date, _currentPeriodStart)) &&
            transaction.date.isBefore(_currentPeriodEnd);
      }).toList();
    } catch (e) {
      print("Error filtering transactions by budget: $e");
    }
  }

//Lọc giao dịch theo các ví được chọn trong ngân sách.
  void filterTransactionsBySelectedWallets() {
    try {
      filteredTransactions = filteredTransactions.where((transaction) {
        return budget.walletId.contains(transaction.walletId);
      }).toList();
    } catch (e) {
      print("Error filtering transactions by selected wallets: $e");
    }
  }

  void groupTransactions() {
    try {
      groupedTransactions = {};
      for (var transaction in filteredTransactions) {
        final date = DateFormat('dd/MM/yyyy').format(transaction.date);
        if (!groupedTransactions.containsKey(date)) {
          groupedTransactions[date] = [];
        }
        groupedTransactions[date]!.add(transaction);
      }
    } catch (e) {
      print("Error grouping transactions: $e");
    }
  }

// Tính toán chi tiêu hiện tại
  void calculateExpenditures() {
    try {
      _totalExpenditure = filteredTransactions.fold(0, (sum, transaction) {
        double amount = transaction.amount;
        return sum + amount;
      });

      int spendingDays = filteredTransactions.isNotEmpty
          ? DateTime.now().difference(_currentPeriodStart).inDays + 1
          : 1;

      _actualSpending = _totalExpenditure / spendingDays;

      if (_isExpired) {
        remainingDays = 0;
      } else {
        remainingDays = _currentPeriodEnd.difference(DateTime.now()).inDays;
      }

      double remainingBudget = max(budget.amount - _totalExpenditure, 0);

      _recommendedSpending = (remainingDays > 0 && remainingBudget > 0)
          ? remainingBudget / remainingDays
          : 0;

      _projectedSpending = _actualSpending * remainingDays + _totalExpenditure;
    } catch (e) {
      print("Error calculating expenditures: $e");
    }
    notifyListeners();
  }

// Tính toán ngày kết thúc của chu kỳ hiện tại
  DateTime _calculateEndOfCurrentPeriod(DateTime startDate, Repeat repeat) {
    switch (repeat) {
      case Repeat.Daily:
        return DateTime(startDate.year, startDate.month, startDate.day)
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
      case Repeat.Weekly:
        return DateTime(startDate.year, startDate.month, startDate.day)
            .add(const Duration(days: 7))
            .subtract(const Duration(seconds: 1));
      case Repeat.Monthly:
        DateTime monthlyDate = DateTime(
            startDate.year, startDate.month + 1, startDate.day);
        return DateTime(monthlyDate.year, monthlyDate.month, monthlyDate.day)
            .subtract(const Duration(seconds: 1));
      case Repeat.Quarterly:
        DateTime quarterlyDate = DateTime(
            startDate.year, startDate.month + 3, startDate.day);
        return DateTime(quarterlyDate.year, quarterlyDate.month, quarterlyDate.day)
            .subtract(const Duration(seconds: 1));
      case Repeat.Yearly:
        return DateTime(startDate.year + 1, startDate.month, startDate.day)
            .subtract(const Duration(seconds: 1));
      default:
        return startDate;
    }
  }

// Kiểm tra và cập nhật chu kỳ ngân sách
  Future<void> checkAndUpdatePeriod() async {
    try {
      final now = DateTime.now();
      if (now.isAfter(_currentPeriodEnd)) {
        // Tính toán số tiền chi trong chu kỳ hiện tại
        double totalExpenditure =
            filteredTransactions.fold(0, (sum, transaction) {
          double amount = transaction.amount;
          return sum + amount;
        });

        // Lưu trữ chu kỳ hiện tại vào danh sách chu kỳ trước đó
        previousPeriods.add(
          PreviousPeriod(
            startDate: _currentPeriodStart,
            endDate: _currentPeriodEnd,
            totalExpenditure: totalExpenditure,
            remainingBudget: budget.amount - totalExpenditure,
            isOverBudget: totalExpenditure - budget.amount > 0 ? true : false,
            transactions: List.from(filteredTransactions),
          ),
        );

        // Cập nhật chu kỳ tiếp theo
        _currentPeriodStart = _currentPeriodEnd.add(const Duration(seconds: 1));
        DateTime nextPeriodEnd =
            _calculateEndOfCurrentPeriod(_currentPeriodStart, budget.repeat);

        // Kiểm tra nếu chu kỳ tiếp theo sẽ vượt quá ngày kết thúc hạn mức
        if (nextPeriodEnd.isAfter(budget.endDate)) {
          // Kiểm tra nếu thời gian còn lại đủ để tạo thành một chu kỳ mới
          Duration remainingDuration =
              budget.endDate.difference(_currentPeriodStart);
          Duration fullPeriodDuration =
              _calculateEndOfCurrentPeriod(_currentPeriodStart, budget.repeat)
                  .difference(_currentPeriodStart);

          if (remainingDuration >= fullPeriodDuration) {
            // Nếu chu kỳ tiếp theo vượt quá nhưng vẫn còn trong ngày kết thúc hạn mức, điều chỉnh ngày kết thúc
            _currentPeriodEnd = budget.endDate;
            _isExpired = true;
          } else {
            // Nếu thời gian còn lại không đủ để tạo thành một chu kỳ mới, dừng lại
            _isExpired = true;
            remainingDays = 0;
            resetValuesToDefault();
            return;
          }
        } else {
          // Nếu chu kỳ tiếp theo không vượt quá ngày kết thúc hạn mức, cập nhật bình thường
          _currentPeriodEnd = nextPeriodEnd;
          _isExpired = false;
        }

        // Tải lại dữ liệu mới sau khi cập nhật chu kỳ
        await loadData();
      }
    } catch (e) {
      print("Error checking and updating period: $e");
    }
  }

  void resetValuesToDefault() {
    filteredTransactions = [];
    groupedTransactions = {};
    _totalExpenditure = 0.0;
    _actualSpending = 0.0;
    _recommendedSpending = 0.0;
    _projectedSpending = 0.0;
    notifyListeners();
  }
}
