import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_model.dart';
import '../model/enum.dart';
import '../model/transfer_model.dart';

// check and update of transaction
class TransactionHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkBalance(String walletId, double transactionAmount, Type transactionType, {Transactions? oldTransaction}) async {
    try {
      DocumentSnapshot walletSnapshot = await _firestore.collection('wallets').doc(walletId).get();

      if (!walletSnapshot.exists) {
        throw Exception("Wallet not found");
      }

      Map<String, dynamic> walletData = walletSnapshot.data() as Map<String, dynamic>;
      double walletBalance = walletData['currentBalance'];

      double amountInWalletCurrency = transactionAmount;

      // Nếu có giao dịch cũ (đang cập nhật), thực hiện điều chỉnh số dư ví
      if (oldTransaction != null) {
        double oldAmountInWalletCurrency = oldTransaction.amount;

        if (oldTransaction.type == Type.income) {
          walletBalance -= oldAmountInWalletCurrency;
        } else if (oldTransaction.type == Type.expense) {
          walletBalance += oldAmountInWalletCurrency;
        }
      }

      // Kiểm tra số dư ví sau khi điều chỉnh giao dịch cũ
      if (transactionType == Type.expense) {
        return walletBalance >= amountInWalletCurrency;
      }

      return true; // Đối với thu nhập, không cần kiểm tra số dư
    } catch (e) {
      print("Error checking balance: $e");
      throw e;
    }
  }

  //isCreation: Cờ xác định xem giao dịch là mới tạo.
  // isDeletion: Cờ xác định xem giao dịch là bị xóa.
  // oldTransaction: Giao dịch cũ (dùng khi cập nhật giao dịch).
  Future<void> updateWalletBalance(Transactions transaction, {required bool isCreation, required bool isDeletion, Transactions? oldTransaction}) async {
    try {
      DocumentSnapshot walletSnapshot = await _firestore.collection('wallets').doc(transaction.walletId).get();

      if (!walletSnapshot.exists) {
        throw Exception("Wallet not found");
      }

      Map<String, dynamic> walletData = walletSnapshot.data() as Map<String, dynamic>;
      double currentBalance = walletData['currentBalance'];

      double amountInWalletCurrency = transaction.amount;
      double oldAmountInWalletCurrency = oldTransaction != null ? oldTransaction.amount : 0;

      if (isCreation) {
        if (transaction.type == Type.income) {
          currentBalance += amountInWalletCurrency;
        } else if (transaction.type == Type.expense) {
          currentBalance -= amountInWalletCurrency;
        }
      } else if (isDeletion) {
        if (transaction.type == Type.income) {
          currentBalance -= amountInWalletCurrency;
        } else if (transaction.type == Type.expense) {
          currentBalance += amountInWalletCurrency;
        }
      } else {
        if (oldTransaction != null) {
          // Hoàn tác số dư của giao dịch cũ
          if (oldTransaction.type == Type.income) {
            currentBalance -= oldAmountInWalletCurrency;
          } else if (oldTransaction.type == Type.expense) {
            currentBalance += oldAmountInWalletCurrency;
          }
        }
        // Áp dụng số dư của giao dịch mới
        if (transaction.type == Type.income) {
          currentBalance += amountInWalletCurrency;
        } else if (transaction.type == Type.expense) {
          currentBalance -= amountInWalletCurrency;
        }
      }

      await _firestore.collection('wallets').doc(transaction.walletId).update({'currentBalance': currentBalance});
    } catch (e) {
      print("Error updating wallet currentBalance: $e");
      throw e;
    }
  }

  Future<void> updateWalletsForTransactionUpdate(Transactions newTransaction, Transactions oldTransaction) async {
    try {
      if (newTransaction.walletId != oldTransaction.walletId) {
        // Hoàn tác ảnh hưởng của giao dịch cũ lên ví cũ
        await updateWalletBalance(oldTransaction, isCreation: false, isDeletion: true);
        // Áp dụng ảnh hưởng của giao dịch mới lên ví mới
        await updateWalletBalance(newTransaction, isCreation: true, isDeletion: false);
      } else {
        // Nếu ví không đổi, chỉ cần cập nhật số dư trong cùng một ví
        await updateWalletBalance(newTransaction, isCreation: false, isDeletion: false, oldTransaction: oldTransaction);
      }
    } catch (e) {
      print("Error updating wallets for transaction update: $e");
      throw e;
    }
  }
}

class TransferHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//Kiểm tra số dư ví
  Future<bool> checkBalance(String walletId, double amount) async {
    try {
      DocumentSnapshot walletSnapshot = await _firestore.collection('wallets').doc(walletId).get();

      if (!walletSnapshot.exists) {
        throw Exception("Wallet not found");
      }

      Map<String, dynamic> walletData = walletSnapshot.data() as Map<String, dynamic>;
      double walletBalance = walletData['currentBalance'];

      double amountInWalletCurrency = amount;

      return walletBalance >= amountInWalletCurrency;
    } catch (e) {
      print("Error checking balance: $e");
      throw e;
    }
  }

  Future<void> updateWalletBalance(String walletId, double amount, bool isIncome) async {
    try {
      DocumentSnapshot walletSnapshot = await _firestore.collection('wallets').doc(walletId).get();

      if (!walletSnapshot.exists) {
        throw Exception("Wallet not found");
      }

      Map<String, dynamic> walletData = walletSnapshot.data() as Map<String, dynamic>;
      double currentBalance = walletData['currentBalance'];

      double amountInWalletCurrency = amount;

      if (isIncome) {
        currentBalance += amountInWalletCurrency;
      } else {
        currentBalance -= amountInWalletCurrency;
      }

      await _firestore.collection('wallets').doc(walletId).update({'currentBalance': currentBalance});
    } catch (e) {
      print("Error updating wallet currentBalance: $e");
      throw e;
    }
  }

  Future<void> updateWalletsForTransfer(Transfer newTransfer, {Transfer? oldTransfer}) async {
    try {
      if (oldTransfer != null) {
        // Hoàn tác ảnh hưởng của giao dịch cũ lên ví cũ
        await updateWalletBalance(oldTransfer.fromWallet, oldTransfer.amount, true);
        await updateWalletBalance(oldTransfer.toWallet, oldTransfer.amount, false);
      }

      // Áp dụng ảnh hưởng của giao dịch mới lên ví mới
      await updateWalletBalance(newTransfer.fromWallet, newTransfer.amount, false);
      await updateWalletBalance(newTransfer.toWallet, newTransfer.amount, true);
    } catch (e) {
      print("Error updating wallets for transfer: $e");
      throw e;
    }
  }
}
