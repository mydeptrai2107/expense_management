import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/model/wallet_model.dart';
import '../data/default_wallet.dart';
import '../model/enum.dart';
import 'budget_service.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addDefaultWallets(String userId) async {
    final userWallets = await _firestore
        .collection('wallets')
        .where('userId', isEqualTo: userId)
        .get();

    if (userWallets.docs.isEmpty) {
      for (var wallet in defaultWallets) {
        var newWallet = Wallet(
          walletId: _firestore.collection('wallets').doc().id,
          userId: userId,
          initialBalance: wallet.initialBalance,
          currentBalance: wallet.currentBalance,
          name: wallet.name,
          icon: wallet.icon,
          color: wallet.color,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('wallets')
            .doc(newWallet.walletId)
            .set(newWallet.toMap());
      }
    }
  }

  Future<void> addFixedWallet(String userId) async {
    try {
      // Check if there are any fixed categories already existing for the user
      final querySnapshot = await _firestore
          .collection('wallets')
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .limit(1) // Limit the query to check for at least one result
          .get();

      // If no fixed categories exist, add them
      if (querySnapshot.docs.isEmpty) {
        for (var wallet in fixedWallets) {
          var newWallet = Wallet(
            walletId: _firestore.collection('wallets').doc().id,
            userId: userId,
            initialBalance: wallet.initialBalance,
            currentBalance: wallet.currentBalance,
            name: wallet.name,
            icon: wallet.icon,
            color: wallet.color,
            createdAt: DateTime.now(),
            isDefault: true,
          );

          await _firestore
              .collection('wallets')
              .doc(newWallet.walletId)
              .set(newWallet.toMap());
        }
      }
    } catch (e) {
      print("Error adding fixed wallets: $e");
      rethrow;
    }
  }

  Future<bool> isFixedWallet(String walletId) async {
    try {
      final walletDoc =
          await _firestore.collection('wallets').doc(walletId).get();
      if (walletDoc.exists) {
        final walletData = walletDoc.data();
        return walletData?['isDefault'] ?? false;
      }
    } catch (e) {
      print('Error checking fixed wallet: $e');
    }
    return false;
  }

  Future<Wallet?> getWalletById(String walletId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('wallets').doc(walletId).get();
      if (docSnapshot.exists) {
        return Wallet.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error getting wallet by id: $e");
      rethrow;
    }
    return null;
  }

  Future<List<Wallet>> getWallets(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('wallets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Wallet.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting wallets: $e");
      rethrow;
    }
  }

  Future<void> createWallet(Wallet wallet) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('wallets').add(wallet.toMap());
      await docRef.update({'walletId': docRef.id});
    } catch (e) {
      print("Error creating wallet: $e");
      rethrow;
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    try {
      await _firestore
          .collection('wallets')
          .doc(wallet.walletId)
          .update(wallet.toMap());
    } catch (e) {
      print("Error updating wallet: $e");
      rethrow;
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      // Xóa tất cả các giao dịch liên quan trước khi xóa ví
      await deleteAllTransactionsRelatedToWallet(walletId);
      await _firestore.collection('wallets').doc(walletId).delete();
    } catch (e) {
      print("Error deleting wallet: $e");
      rethrow;
    }
  }

  Future<void> deleteAllTransactionsRelatedToWallet(String walletId) async {
    // Xóa tất cả các giao dịch chuyển khoản liên quan
    await _firestore
        .collection('transfers')
        .where('fromWallet', isEqualTo: walletId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });

    await _firestore
        .collection('transfers')
        .where('toWallet', isEqualTo: walletId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });

    // Xóa tất cả các giao dịch thu nhập liên quan
    await _firestore
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .where('type', isEqualTo: Type.income.index)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });

    // Xóa tất cả các giao dịch chi tiêu liên quan
    await _firestore
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .where('type', isEqualTo: Type.expense.index)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }
}
