import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/model/transaction_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          _storage.ref().child('transaction_images').child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }

  Future<Transactions?> getTransactionById(String transactionId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('transactions').doc(transactionId).get();
      if (doc.exists) {
        return Transactions.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting transaction by ID: $e');
      return null;
    }
  }

  Future<List<Transactions>> getTransaction(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map(
              (doc) => Transactions.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting transaction: $e");
      rethrow;
    }
  }

  Future<void> createTransaction(Transactions transaction) async {
    try {
      var transactionMap = transaction.toMap();
      DocumentReference docRef =
          await _firestore.collection('transactions').add(transactionMap);
      await docRef.update({'transactionId': docRef.id});
    } catch (e) {
      print("Error creating transaction: $e");
      rethrow;
    }
  }

  Future<void> updateTransaction(Transactions transaction) async {
    try {
      var transactionMap = transaction.toMap();

      await _firestore
          .collection('transactions')
          .doc(transaction.transactionId)
          .update(transactionMap);
    } catch (e) {
      print("Error updating transactions: $e");
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      print("Error deleting transaction: $e");
      rethrow;
    }
  }
}
