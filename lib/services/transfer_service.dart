import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/model/transfer_model.dart';

class TransferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTransfer(Transfer transfer) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('transfers').add(transfer.toMap());
      await docRef.update({'transferId': docRef.id});
    } catch (e) {
      print("Error creating transfer: $e");
      rethrow;
    }
  }

  Future<void> updateTransfer(Transfer transfer) async {
    try {
      await _firestore
          .collection('transfers')
          .doc(transfer.transferId)
          .update(transfer.toMap());
    } catch (e) {
      print("Error updating transfer: $e");
      rethrow;
    }
  }

  Future<void> deleteTransfer(String transferId) async {
    try {
      await _firestore.collection('transfers').doc(transferId).delete();
    } catch (e) {
      print("Error deleting transfer: $e");
      rethrow;
    }
  }

  Future<List<Transfer>> getTransfers(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('transfers')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transfer.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting transfers: $e");
      rethrow;
    }
  }

  Future<Transfer?> getTransferById(String transferId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('transfers').doc(transferId).get();

      if (docSnapshot.exists) {
        return Transfer.fromMap(docSnapshot.data() as Map<String, dynamic>);
      } else {
        print("Transfer with ID $transferId not found.");
        return null;
      }
    } catch (e) {
      print("Error getting transfer by ID: $e");
      rethrow;
    }
  }
}
